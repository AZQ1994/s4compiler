# frozen_string_literal: true

require_relative 'pseudo_ops'
require_relative 'memory'

module S4C
  # Lowers IR instructions into pseudo-operations.
  # Supports: add, sub, ret, br, icmp, alloca, load, store, call
  class Lowering
    attr_reader :mem, :pseudo_ops

    def initialize
      @mem = Memory.new
      @pseudo_ops = []
      @current_func = nil
      @functions = {}       # func_name → { params: [...], retval: label }
      @call_id = 0          # unique ID for each call site
      @builtins = {}        # :mul → { arg1:, arg2:, result:, ret_d: }
      @deferred_subroutines = []
      @cmp_id = 0           # unique ID for inline comparison labels
      @pointers = {}        # "func::ir_name" → true (tracks variables that hold computed addresses)
      @indirect_id = 0      # unique ID for indirect load/store operations
    end

    # Lower an entire IR module
    def lower(ir_module)
      # Allocate global variables in the data section
      @globals_map ||= {}
      ir_module.globals.each do |g|
        label = "global_#{g[:name]}"
        if g[:array]
          @mem.alloc_global_array(label, g[:values])
          @globals_map[g[:name]] = label
          @global_arrays ||= {}
          @global_arrays[g[:name]] = { base: label, size: g[:size] }
        else
          @mem.alloc_global(label, g[:value])
          @globals_map[g[:name]] = label
        end
      end

      # First pass: register all functions and their params
      ir_module.functions.each do |func|
        register_function(func)
      end

      # Find the entry function (main, or last if no main)
      entry = ir_module.functions.find { |f| f.name == 'main' } || ir_module.functions.last

      # Emit entry: jump to main
      if ir_module.functions.length > 1 || entry.name != ir_module.functions.first.name
        emit PGoto.new("func_#{entry.name}", comment: "entry → #{entry.name}")
      end

      # Lower each function
      ir_module.functions.each do |func|
        lower_function(func)
      end

      # Emit deferred built-in subroutines
      @deferred_subroutines.each do |name|
        case name
        when :mul  then emit_mul_subroutine
        when :sdiv then emit_sdiv_subroutine
        when :srem then emit_srem_subroutine
        when :shl  then emit_shl_subroutine
        when :shr  then emit_shr_subroutine
        when :and  then emit_and_subroutine
        when :or   then emit_or_subroutine
        when :xor  then emit_xor_subroutine
        end
      end

      self
    end

    private

    def register_function(func)
      param_labels = func.params.map do |_type, name|
        @mem.func_param(func.name, name)
      end
      param_types = func.params.map { |type, _name| type }
      retval = @mem.func_var(func.name, "__retval")
      # Per-operand label for the D operand of the return jump instruction
      ret_d_label = "#{func.name}_ret_d"
      @functions[func.name] = { params: param_labels, param_types: param_types, retval: retval, ret_d_label: ret_d_label }

      # Mark pointer parameters as pointers
      func.params.each do |type, name|
        mark_pointer_for(func.name, name) if type == 'ptr'
      end
    end

    def lower_function(func)
      @current_func = func.name

      # The entry block's implicit LLVM number is the parameter count
      entry_block_num = func.params.length.to_s

      # Pre-scan: collect phi nodes and build mapping
      # @phi_copies["target_block"]["source_block"] = [[phi_result, value], ...]
      @phi_copies = {}
      func.blocks.each do |block|
        block.instructions.each do |inst|
          next unless inst.opcode == 'phi'
          # Pre-allocate the phi result variable
          fvar(inst.result)
          # Operands: [value0, label0, value1, label1, ...]
          inst.operands.each_slice(2) do |val_op, bb_op|
            next unless bb_op&.label?
            src_block = bb_op.value
            # Map entry block number to our "entry" name
            src_block = 'entry' if src_block == entry_block_num && func.blocks.first&.name == 'entry'
            @phi_copies[block.name] ||= {}
            @phi_copies[block.name][src_block] ||= []
            @phi_copies[block.name][src_block] << [inst.result, val_op]
          end
        end
      end

      emit PLabel.new("func_#{func.name}", comment: "function #{func.name}")

      # Process each basic block
      func.blocks.each do |block|
        @current_block = block.name
        emit PLabel.new(bb_label(block.name), comment: "#{func.name}::#{block.name}")

        block.instructions.each do |inst|
          lower_instruction(inst)
        end
      end
    end

    def bb_label(block_name)
      "#{@current_func}_bb_#{block_name}"
    end

    def lower_instruction(inst)
      case inst.opcode
      when 'add'  then lower_add(inst)
      when 'sub'  then lower_sub(inst)
      when 'mul'  then lower_mul(inst)
      when 'sdiv' then lower_sdiv(inst)
      when 'srem' then lower_srem(inst)
      when 'shl'  then lower_shl(inst)
      when 'ashr', 'lshr' then lower_shr(inst)
      when 'and'  then lower_bitwise(inst, :and)
      when 'or'   then lower_bitwise(inst, :or)
      when 'xor'  then lower_bitwise(inst, :xor)
      when 'ret'  then lower_ret(inst)
      when 'br'   then lower_br(inst)
      when 'icmp' then lower_icmp(inst)
      when 'alloca'        then lower_alloca(inst)
      when 'load'          then lower_load(inst)
      when 'store'         then lower_store(inst)
      when 'getelementptr' then lower_gep(inst)
      when 'call'          then lower_call(inst)
      when 'switch' then lower_switch(inst)
      when 'select' then lower_select(inst)
      when 'phi'    then lower_phi(inst)
      when 'sext', 'zext', 'trunc', 'bitcast'
        lower_cast(inst)
      else
        emit PLabel.new("", comment: "UNSUPPORTED: #{inst.raw}")
      end
    end

    # %r = add i32 %a, %b
    def lower_add(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)
      emit PAdd.new(a, b, r, comment: "#{inst.result} = #{op_str(inst.operands[0])} + #{op_str(inst.operands[1])}")
    end

    # %r = sub i32 %a, %b → dest = op[0] - op[1]
    def lower_sub(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)
      emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[0])} - #{op_str(inst.operands[1])}")
    end

    # %r = mul i32 %a, %b → inline for small constants, else call __mul subroutine
    def lower_mul(inst)
      r = fvar(inst.result)

      # Detect constant operand (mul is commutative)
      const_op, var_op = nil, nil
      if inst.operands[0].const?
        const_op, var_op = inst.operands[0], inst.operands[1]
      elsif inst.operands[1].const?
        const_op, var_op = inst.operands[1], inst.operands[0]
      end

      if const_op
        n = const_op.value
        var_label = resolve_operand(var_op)

        case n
        when 0
          emit PCp.new(r, @mem.zero, comment: "#{inst.result} = 0 (mul by 0)")
          return
        when 1
          emit PCp.new(r, var_label, comment: "#{inst.result} = #{op_str(var_op)} (mul by 1)")
          return
        when -1
          emit PSub.new(var_label, @mem.zero, r, comment: "#{inst.result} = -#{op_str(var_op)} (mul by -1)")
          return
        when 2..8
          emit_mul_addition_chain(var_label, n, r)
          return
        when -8..-2
          t = @mem.temp
          emit_mul_addition_chain(var_label, n.abs, t)
          emit PSub.new(t, @mem.zero, r, comment: "#{inst.result} = negate (mul by #{n})")
          return
        end
      end

      # Fallback: subroutine call
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      ensure_mul_subroutine
      mul = @builtins[:mul]

      @call_id += 1
      ret_label = "#{@current_func}_mulret#{@call_id}"
      @mem.alloc_label(ret_label)

      emit PCp.new(mul[:arg1], a, comment: "mul arg1 = #{op_str(inst.operands[0])}")
      emit PCp.new(mul[:arg2], b, comment: "mul arg2 = #{op_str(inst.operands[1])}")
      emit PCallSetReturn.new(mul[:ret_d], ret_label, comment: "mul return addr")
      emit PGoto.new("__mul", comment: "call __mul")
      emit PLabel.new(ret_label, comment: "return from __mul")
      emit PCp.new(r, mul[:result], comment: "#{inst.result} = mul result")
    end

    # Emit inline addition chain for multiplication by small constant N (2..8)
    def emit_mul_addition_chain(var_label, n, dest)
      if n & (n - 1) == 0
        # Power of 2: doubling chain (log2(N) PAdd ops)
        shifts = Math.log2(n).to_i
        current = var_label
        shifts.times do |i|
          dst = (i == shifts - 1) ? dest : @mem.temp
          emit PAdd.new(current, current, dst, comment: "mul by #{n} (double #{i + 1}/#{shifts})")
          current = dst
        end
      else
        # General: repeated addition (N-1 PAdd ops)
        current = var_label
        (n - 1).times do |i|
          dst = (i == n - 2) ? dest : @mem.temp
          emit PAdd.new(var_label, current, dst, comment: "mul by #{n} (accum #{i + 2}x)")
          current = dst
        end
      end
    end

    # Emit the __mul subroutine once (repeated addition: result = arg1 * arg2)
    # Algorithm: result=0; if arg2<0 then negate both; while arg2>0: result+=arg1, arg2-=1
    def ensure_mul_subroutine
      return if @builtins[:mul]

      arg1   = @mem.func_var("__mul", "arg1")
      arg2   = @mem.func_var("__mul", "arg2")
      result = @mem.func_var("__mul", "result")
      ret_d  = "__mul_ret_d"

      @builtins[:mul] = { arg1: arg1, arg2: arg2, result: result, ret_d: ret_d }

      # The actual subroutine code will be emitted at the end
      @deferred_subroutines << :mul
    end

    def emit_mul_subroutine
      mul = @builtins[:mul]
      a1  = mul[:arg1]
      a2  = mul[:arg2]
      res = mul[:result]

      emit PLabel.new("__mul", comment: "built-in: multiply")
      # result = 0
      emit PCp.new(res, @mem.zero, comment: "result = 0")
      # if arg2 == 0, return immediately
      # Check sign of arg2: if negative, negate both
      t = @mem.temp
      emit PLabel.new("__mul_signchk")
      emit PNeg.new(a2, "__mul_neg", comment: "if arg2 < 0 → negate both")
      emit PGoto.new("__mul_loop", comment: "arg2 >= 0, start loop")
      # Negate both
      emit PLabel.new("__mul_neg")
      emit PSub.new(a1, @mem.zero, a1, comment: "arg1 = -arg1")
      emit PSub.new(a2, @mem.zero, a2, comment: "arg2 = -arg2")
      # Loop: while arg2 > 0, result += arg1, arg2 -= 1
      emit PLabel.new("__mul_loop")
      one = @mem.const(1)
      # Check arg2 > 0: arg2 - 1 >= 0 means arg2 > 0
      # Use: 0 - arg2 → if negative (arg2 > 0), continue
      emit PSub.new(a2, @mem.zero, t, comment: "t = -arg2")
      emit PNeg.new(t, "__mul_body", comment: "if -arg2 < 0 (arg2 > 0) → loop body")
      emit PGoto.new("__mul_done", comment: "arg2 <= 0 → done")
      emit PLabel.new("__mul_body")
      emit PAdd.new(a1, res, res, comment: "result += arg1")
      emit PSub.new(one, a2, a2, comment: "arg2 -= 1")
      emit PGoto.new("__mul_loop", comment: "repeat")
      emit PLabel.new("__mul_done")
      emit PReturnJump.new(mul[:ret_d], comment: "return from __mul")
    end

    def ensure_sdiv_subroutine
      return if @builtins[:sdiv]

      dividend = @mem.func_var("__sdiv", "dividend")
      divisor  = @mem.func_var("__sdiv", "divisor")
      quotient = @mem.func_var("__sdiv", "quotient")
      ret_d    = "__sdiv_ret_d"

      @builtins[:sdiv] = { dividend: dividend, divisor: divisor, quotient: quotient, ret_d: ret_d }
      @deferred_subroutines << :sdiv
    end

    # Signed division: quotient = dividend / divisor
    # Algorithm: negate operands if needed, repeated subtraction, fix sign
    def emit_sdiv_subroutine
      sdiv = @builtins[:sdiv]
      dvd  = sdiv[:dividend]
      dvs  = sdiv[:divisor]
      q    = sdiv[:quotient]
      sign = @mem.func_var("__sdiv", "sign")
      t    = @mem.temp
      z    = @mem.zero
      one  = @mem.const(1)

      emit PLabel.new("__sdiv", comment: "built-in: signed division")
      emit PCp.new(q, z, comment: "quotient = 0")
      emit PCp.new(sign, z, comment: "sign = 0")
      # If dividend < 0, negate it and flip sign
      emit PNeg.new(dvd, "__sdiv_neg_dvd", comment: "if dividend < 0")
      emit PGoto.new("__sdiv_chk_dvs", comment: "dividend >= 0")
      emit PLabel.new("__sdiv_neg_dvd")
      emit PSub.new(dvd, z, dvd, comment: "dividend = -dividend")
      emit PSub.new(sign, one, sign, comment: "sign = 1 - sign")
      emit PLabel.new("__sdiv_chk_dvs")
      # If divisor < 0, negate it and flip sign
      emit PNeg.new(dvs, "__sdiv_neg_dvs", comment: "if divisor < 0")
      emit PGoto.new("__sdiv_loop", comment: "divisor >= 0")
      emit PLabel.new("__sdiv_neg_dvs")
      emit PSub.new(dvs, z, dvs, comment: "divisor = -divisor")
      emit PSub.new(sign, one, sign, comment: "sign = 1 - sign")
      # Loop: while dividend >= divisor
      emit PLabel.new("__sdiv_loop")
      emit PSub.new(dvs, dvd, t, comment: "t = dividend - divisor")
      emit PNeg.new(t, "__sdiv_fixsign", comment: "if t < 0 → done")
      emit PCp.new(dvd, t, comment: "dividend = t")
      emit PAdd.new(one, q, q, comment: "quotient += 1")
      emit PGoto.new("__sdiv_loop", comment: "repeat")
      # Fix sign
      emit PLabel.new("__sdiv_fixsign")
      emit PNeg.new(sign, "__sdiv_negate_q", comment: "if sign < 0 → negate quotient")
      emit PGoto.new("__sdiv_ret", comment: "sign >= 0, done")
      emit PLabel.new("__sdiv_negate_q")
      emit PSub.new(q, z, q, comment: "quotient = -quotient")
      emit PLabel.new("__sdiv_ret")
      emit PReturnJump.new(sdiv[:ret_d], comment: "return from __sdiv")
    end

    def ensure_srem_subroutine
      return if @builtins[:srem]

      dividend  = @mem.func_var("__srem", "dividend")
      divisor   = @mem.func_var("__srem", "divisor")
      remainder = @mem.func_var("__srem", "remainder")
      ret_d     = "__srem_ret_d"

      @builtins[:srem] = { dividend: dividend, divisor: divisor, remainder: remainder, ret_d: ret_d }
      @deferred_subroutines << :srem
    end

    # Signed remainder: remainder = dividend % divisor
    # Remainder has same sign as dividend
    def emit_srem_subroutine
      srem = @builtins[:srem]
      dvd  = srem[:dividend]
      dvs  = srem[:divisor]
      rem  = srem[:remainder]
      sign = @mem.func_var("__srem", "sign")
      t    = @mem.temp
      z    = @mem.zero

      emit PLabel.new("__srem", comment: "built-in: signed remainder")
      emit PCp.new(sign, z, comment: "sign = 0 (positive)")
      # If dividend < 0, negate it and record sign
      emit PNeg.new(dvd, "__srem_neg_dvd", comment: "if dividend < 0")
      emit PGoto.new("__srem_chk_dvs", comment: "dividend >= 0")
      emit PLabel.new("__srem_neg_dvd")
      emit PSub.new(dvd, z, dvd, comment: "dividend = -dividend")
      c_n1 = @mem.const(-1)
      emit PCp.new(sign, c_n1, comment: "sign = -1 (negative)")
      emit PLabel.new("__srem_chk_dvs")
      # If divisor < 0, negate it (sign of remainder follows dividend, not divisor)
      emit PNeg.new(dvs, "__srem_neg_dvs", comment: "if divisor < 0")
      emit PGoto.new("__srem_loop", comment: "divisor >= 0")
      emit PLabel.new("__srem_neg_dvs")
      emit PSub.new(dvs, z, dvs, comment: "divisor = -divisor")
      # Loop: while dividend >= divisor, subtract
      emit PLabel.new("__srem_loop")
      emit PSub.new(dvs, dvd, t, comment: "t = dividend - divisor")
      emit PNeg.new(t, "__srem_done", comment: "if t < 0 → done")
      emit PCp.new(dvd, t, comment: "dividend = t")
      emit PGoto.new("__srem_loop", comment: "repeat")
      # Done: remainder = dividend; apply sign
      emit PLabel.new("__srem_done")
      emit PCp.new(rem, dvd, comment: "remainder = dividend")
      emit PNeg.new(sign, "__srem_negate", comment: "if sign < 0 → negate remainder")
      emit PGoto.new("__srem_ret", comment: "sign >= 0, done")
      emit PLabel.new("__srem_negate")
      emit PSub.new(rem, z, rem, comment: "remainder = -remainder")
      emit PLabel.new("__srem_ret")
      emit PReturnJump.new(srem[:ret_d], comment: "return from __srem")
    end

    # %r = shl i32 %val, N
    def lower_shl(inst)
      val = resolve_operand(inst.operands[0])
      shift_op = inst.operands[1]
      r = fvar(inst.result)

      if shift_op.const? && shift_op.value <= 8
        # Inline chain of doublings for small constant shifts
        n = shift_op.value
        if n == 0
          emit PCp.new(r, val, comment: "shl by 0")
        else
          current = val
          n.times do |i|
            dst = (i == n - 1) ? r : @mem.temp
            emit PAdd.new(current, current, dst, comment: "shl (double #{i + 1}/#{n})")
            current = dst
          end
        end
      else
        # Variable or large constant: call __shl subroutine
        ensure_shl_subroutine
        shl = @builtins[:shl]
        @call_id += 1
        ret_label = "#{@current_func}_shlret#{@call_id}"
        @mem.alloc_label(ret_label)

        emit PCp.new(shl[:val], val, comment: "shl val")
        amt = shift_op.const? ? @mem.const(shift_op.value) : resolve_operand(shift_op)
        emit PCp.new(shl[:amount], amt, comment: "shl amount")
        emit PCallSetReturn.new(shl[:ret_d], ret_label, comment: "shl return addr")
        emit PGoto.new("__shl", comment: "call __shl")
        emit PLabel.new(ret_label, comment: "return from __shl")
        emit PCp.new(r, shl[:result], comment: "#{inst.result} = shl result")
      end
    end

    # %r = ashr/lshr i32 %val, N → use __shr subroutine (N halvings, faster than sdiv for large values)
    def lower_shr(inst)
      val = resolve_operand(inst.operands[0])
      shift_op = inst.operands[1]
      r = fvar(inst.result)

      if shift_op.const?
        n = shift_op.value
        if n == 0
          emit PCp.new(r, val, comment: "shr by 0")
          return
        end
      end

      # Use __shr subroutine for both constant and variable shifts
      ensure_shr_subroutine
      shr = @builtins[:shr]
      @call_id += 1
      ret_label = "#{@current_func}_shrret#{@call_id}"
      @mem.alloc_label(ret_label)

      emit PCp.new(shr[:val], val, comment: "shr val")
      emit PCp.new(shr[:amount], resolve_operand(shift_op), comment: "shr amount#{shift_op.const? ? " = #{shift_op.value}" : ''}")
      emit PCallSetReturn.new(shr[:ret_d], ret_label, comment: "shr return addr")
      emit PGoto.new("__shr", comment: "call __shr")
      emit PLabel.new(ret_label, comment: "return from __shr")
      emit PCp.new(r, shr[:result], comment: "#{inst.result} = shr result")
    end

    # %r = and/or/xor i32 %a, %b → call built-in subroutine
    def lower_bitwise(inst, op)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)

      ensure_bitwise_subroutine(op)
      info = @builtins[op]
      @call_id += 1
      ret_label = "#{@current_func}_#{op}ret#{@call_id}"
      @mem.alloc_label(ret_label)

      emit PCp.new(info[:arg1], a, comment: "#{op} arg1 = #{op_str(inst.operands[0])}")
      emit PCp.new(info[:arg2], b, comment: "#{op} arg2 = #{op_str(inst.operands[1])}")
      emit PCallSetReturn.new(info[:ret_d], ret_label, comment: "#{op} return addr")
      emit PGoto.new("__#{op}", comment: "call __#{op}")
      emit PLabel.new(ret_label, comment: "return from __#{op}")
      emit PCp.new(r, info[:result], comment: "#{inst.result} = #{op} result")
    end

    def ensure_shl_subroutine
      return if @builtins[:shl]
      val    = @mem.func_var("__shl", "val")
      amount = @mem.func_var("__shl", "amount")
      result = @mem.func_var("__shl", "result")
      ret_d  = "__shl_ret_d"
      @builtins[:shl] = { val: val, amount: amount, result: result, ret_d: ret_d }
      @deferred_subroutines << :shl
    end

    def emit_shl_subroutine
      shl = @builtins[:shl]
      v   = shl[:val]
      amt = shl[:amount]
      res = shl[:result]
      z   = @mem.zero
      one = @mem.const(1)
      t   = @mem.temp

      emit PLabel.new("__shl", comment: "built-in: left shift")
      emit PCp.new(res, v, comment: "result = val")
      emit PLabel.new("__shl_loop")
      # Check amount > 0: if -amount < 0 (amount > 0), continue
      emit PSub.new(amt, z, t, comment: "t = -amount")
      emit PNeg.new(t, "__shl_body", comment: "if amount > 0 → loop body")
      emit PGoto.new("__shl_done", comment: "amount <= 0 → done")
      emit PLabel.new("__shl_body")
      emit PAdd.new(res, res, res, comment: "result = result * 2")
      emit PSub.new(one, amt, amt, comment: "amount -= 1")
      emit PGoto.new("__shl_loop", comment: "repeat")
      emit PLabel.new("__shl_done")
      emit PReturnJump.new(shl[:ret_d], comment: "return from __shl")
    end

    def ensure_shr_subroutine
      return if @builtins[:shr]
      val    = @mem.func_var("__shr", "val")
      amount = @mem.func_var("__shr", "amount")
      result = @mem.func_var("__shr", "result")
      ret_d  = "__shr_ret_d"
      @builtins[:shr] = { val: val, amount: amount, result: result, ret_d: ret_d }
      @deferred_subroutines << :shr
    end

    # Right shift via repeated halving (sdiv by 2 loop)
    def emit_shr_subroutine
      shr = @builtins[:shr]
      v   = shr[:val]
      amt = shr[:amount]
      res = shr[:result]
      z   = @mem.zero
      one = @mem.const(1)
      two = @mem.const(2)
      t   = @mem.temp

      emit PLabel.new("__shr", comment: "built-in: right shift")
      emit PCp.new(res, v, comment: "result = val")
      emit PLabel.new("__shr_loop")
      emit PSub.new(amt, z, t, comment: "t = -amount")
      emit PNeg.new(t, "__shr_body", comment: "if amount > 0 → loop body")
      emit PGoto.new("__shr_done", comment: "amount <= 0 → done")
      emit PLabel.new("__shr_body")
      # Halve: quotient = res / 2 via repeated subtraction
      # Inline a simple div-by-2: q=0; while res>=2: res-=2, q++
      q = @mem.func_var("__shr", "q")
      emit PCp.new(q, z, comment: "q = 0")
      emit PLabel.new("__shr_half")
      emit PSub.new(two, res, t, comment: "t = res - 2")
      emit PNeg.new(t, "__shr_half_done", comment: "if res < 2 → done halving")
      emit PCp.new(res, t, comment: "res = t")
      emit PAdd.new(one, q, q, comment: "q++")
      emit PGoto.new("__shr_half", comment: "repeat halving")
      emit PLabel.new("__shr_half_done")
      emit PCp.new(res, q, comment: "res = quotient")
      emit PSub.new(one, amt, amt, comment: "amount -= 1")
      emit PGoto.new("__shr_loop", comment: "repeat shift")
      emit PLabel.new("__shr_done")
      emit PReturnJump.new(shr[:ret_d], comment: "return from __shr")
    end

    def ensure_bitwise_subroutine(op)
      return if @builtins[op]
      arg1   = @mem.func_var("__#{op}", "arg1")
      arg2   = @mem.func_var("__#{op}", "arg2")
      result = @mem.func_var("__#{op}", "result")
      ret_d  = "__#{op}_ret_d"
      @builtins[op] = { arg1: arg1, arg2: arg2, result: result, ret_d: ret_d }
      @deferred_subroutines << op
    end

    # Bitwise AND: extract bits, AND them, reconstruct (32-bit)
    def emit_and_subroutine
      info = @builtins[:and]
      a1 = info[:arg1]; a2 = info[:arg2]; res = info[:result]
      z = @mem.zero; one = @mem.const(1); two = @mem.const(2)
      bit_val = @mem.func_var("__and", "bit_val")
      cnt     = @mem.func_var("__and", "cnt")
      t       = @mem.temp
      b1      = @mem.func_var("__and", "b1")
      b2      = @mem.func_var("__and", "b2")
      c32     = @mem.const(32)

      emit PLabel.new("__and", comment: "built-in: bitwise AND")
      emit PCp.new(res, z, comment: "result = 0")
      emit PCp.new(bit_val, one, comment: "bit_val = 1")
      emit PCp.new(cnt, c32, comment: "cnt = 32")
      emit_bitwise_loop("__and", a1, a2, res, bit_val, cnt, b1, b2, t, z, one, two) { |b1v, b2v, t_var|
        # AND: result += bit_val only if BOTH bits are 1
        # b1 * b2: since both are 0 or 1, use: if b1 != 0 AND b2 != 0
        # Check b1 > 0: -b1 < 0
        emit PSub.new(b1v, z, t_var, comment: "t = -b1")
        emit PNeg.new(t_var, "__and_chk2", comment: "if b1 > 0")
        emit PGoto.new("__and_skip", comment: "b1 == 0, skip")
        emit PLabel.new("__and_chk2")
        emit PSub.new(b2v, z, t_var, comment: "t = -b2")
        emit PNeg.new(t_var, "__and_set", comment: "if b2 > 0")
        emit PGoto.new("__and_skip", comment: "b2 == 0, skip")
        emit PLabel.new("__and_set")
        emit PAdd.new(bit_val, res, res, comment: "result += bit_val")
        emit PLabel.new("__and_skip")
      }
      emit PReturnJump.new(info[:ret_d], comment: "return from __and")
    end

    # Bitwise OR
    def emit_or_subroutine
      info = @builtins[:or]
      a1 = info[:arg1]; a2 = info[:arg2]; res = info[:result]
      z = @mem.zero; one = @mem.const(1); two = @mem.const(2)
      bit_val = @mem.func_var("__or", "bit_val")
      cnt     = @mem.func_var("__or", "cnt")
      t       = @mem.temp
      b1      = @mem.func_var("__or", "b1")
      b2      = @mem.func_var("__or", "b2")
      c32     = @mem.const(32)

      emit PLabel.new("__or", comment: "built-in: bitwise OR")
      emit PCp.new(res, z, comment: "result = 0")
      emit PCp.new(bit_val, one, comment: "bit_val = 1")
      emit PCp.new(cnt, c32, comment: "cnt = 32")
      emit_bitwise_loop("__or", a1, a2, res, bit_val, cnt, b1, b2, t, z, one, two) { |b1v, b2v, t_var|
        # OR: result += bit_val if EITHER bit is 1
        emit PSub.new(b1v, z, t_var, comment: "t = -b1")
        emit PNeg.new(t_var, "__or_set", comment: "if b1 > 0 → set")
        emit PSub.new(b2v, z, t_var, comment: "t = -b2")
        emit PNeg.new(t_var, "__or_set", comment: "if b2 > 0 → set")
        emit PGoto.new("__or_skip", comment: "both 0, skip")
        emit PLabel.new("__or_set")
        emit PAdd.new(bit_val, res, res, comment: "result += bit_val")
        emit PLabel.new("__or_skip")
      }
      emit PReturnJump.new(info[:ret_d], comment: "return from __or")
    end

    # Bitwise XOR
    def emit_xor_subroutine
      info = @builtins[:xor]
      a1 = info[:arg1]; a2 = info[:arg2]; res = info[:result]
      z = @mem.zero; one = @mem.const(1); two = @mem.const(2)
      bit_val = @mem.func_var("__xor", "bit_val")
      cnt     = @mem.func_var("__xor", "cnt")
      t       = @mem.temp
      b1      = @mem.func_var("__xor", "b1")
      b2      = @mem.func_var("__xor", "b2")
      c32     = @mem.const(32)

      emit PLabel.new("__xor", comment: "built-in: bitwise XOR")
      emit PCp.new(res, z, comment: "result = 0")
      emit PCp.new(bit_val, one, comment: "bit_val = 1")
      emit PCp.new(cnt, c32, comment: "cnt = 32")
      emit_bitwise_loop("__xor", a1, a2, res, bit_val, cnt, b1, b2, t, z, one, two) { |b1v, b2v, t_var|
        # XOR: result += bit_val if bits differ
        # diff = b1 - b2; if diff != 0 → bits differ
        emit PSub.new(b2v, b1v, t_var, comment: "t = b1 - b2")
        emit PNeg.new(t_var, "__xor_set", comment: "if t < 0 → differ")
        emit PSub.new(t_var, z, t_var, comment: "t = -t")
        emit PNeg.new(t_var, "__xor_set", comment: "if -t < 0 → differ")
        emit PGoto.new("__xor_skip", comment: "same, skip")
        emit PLabel.new("__xor_set")
        emit PAdd.new(bit_val, res, res, comment: "result += bit_val")
        emit PLabel.new("__xor_skip")
      }
      emit PReturnJump.new(info[:ret_d], comment: "return from __xor")
    end

    # Common bit-extraction loop for bitwise ops
    # Extracts one bit from each operand per iteration, calls block for the combine logic
    def emit_bitwise_loop(prefix, a1, a2, _res, bit_val, cnt, b1, b2, t, z, one, two)
      q1 = @mem.func_var(prefix, "q1")
      q2 = @mem.func_var(prefix, "q2")

      emit PLabel.new("#{prefix}_loop")
      # Check cnt > 0
      emit PSub.new(cnt, z, t, comment: "t = -cnt")
      emit PNeg.new(t, "#{prefix}_body", comment: "if cnt > 0 → loop body")
      emit PGoto.new("#{prefix}_done", comment: "cnt <= 0 → done")
      emit PLabel.new("#{prefix}_body")

      # Extract bit from a1: b1 = a1 % 2 (via a1 - 2*(a1/2))
      # Simple: halve a1, double it, subtract from original
      # q1 = a1/2 (repeated subtraction of 2)
      emit PCp.new(q1, z, comment: "q1 = 0")
      emit PLabel.new("#{prefix}_div1")
      emit PSub.new(two, a1, t, comment: "t = a1 - 2")
      emit PNeg.new(t, "#{prefix}_div1_done", comment: "if a1 < 2 → done")
      emit PCp.new(a1, t, comment: "a1 -= 2")
      emit PAdd.new(one, q1, q1, comment: "q1++")
      emit PGoto.new("#{prefix}_div1", comment: "repeat")
      emit PLabel.new("#{prefix}_div1_done")
      # b1 = a1 (remainder: 0 or 1)
      emit PCp.new(b1, a1, comment: "b1 = a1 % 2")
      emit PCp.new(a1, q1, comment: "a1 = a1 / 2")

      # Same for a2
      emit PCp.new(q2, z, comment: "q2 = 0")
      emit PLabel.new("#{prefix}_div2")
      emit PSub.new(two, a2, t, comment: "t = a2 - 2")
      emit PNeg.new(t, "#{prefix}_div2_done", comment: "if a2 < 2 → done")
      emit PCp.new(a2, t, comment: "a2 -= 2")
      emit PAdd.new(one, q2, q2, comment: "q2++")
      emit PGoto.new("#{prefix}_div2", comment: "repeat")
      emit PLabel.new("#{prefix}_div2_done")
      emit PCp.new(b2, a2, comment: "b2 = a2 % 2")
      emit PCp.new(a2, q2, comment: "a2 = a2 / 2")

      # Call combine logic (block)
      yield b1, b2, t

      # Advance
      emit PAdd.new(bit_val, bit_val, bit_val, comment: "bit_val *= 2")
      emit PSub.new(one, cnt, cnt, comment: "cnt -= 1")
      emit PGoto.new("#{prefix}_loop", comment: "next bit")
      emit PLabel.new("#{prefix}_done")
    end

    # ret i32 %val
    def lower_ret(inst)
      info = @functions[@current_func]
      if inst.operands.empty?
        if @current_func == 'main'
          emit PHalt.new
        else
          emit PReturnJump.new(info[:ret_d_label], comment: "return void to caller")
        end
      else
        val = resolve_operand(inst.operands[0])
        emit PCp.new(info[:retval], val, comment: "return #{op_str(inst.operands[0])}")
        if @current_func == 'main'
          emit PHalt.new
        else
          emit PReturnJump.new(info[:ret_d_label], comment: "return to caller")
        end
      end
    end

    # br label %L / br i1 %c, label %T, label %F
    def lower_br(inst)
      if inst.operands.length == 1
        target = inst.operands[0].value
        emit_phi_copies(target)
        label = bb_label(target)
        emit PGoto.new(label, comment: "goto #{target}")
      elsif inst.operands.length == 3
        cond = resolve_operand(inst.operands[0])
        true_target  = inst.operands[1].value
        false_target = inst.operands[2].value

        # Phi copies for conditional branches need special handling:
        # We can't insert copies before the branch because we don't know which path
        # will be taken. Instead, emit copies after the condition check.
        # For true branch: if cond < 0, do phi copies for true_target, then jump
        # For false branch: do phi copies for false_target, then jump
        true_has_phis = has_phi_copies?(true_target)
        false_has_phis = has_phi_copies?(false_target)

        if !true_has_phis && !false_has_phis
          # No phi nodes in either target
          emit PNeg.new(cond, bb_label(true_target), comment: "if #{op_str(inst.operands[0])} < 0 goto #{true_target}")
          emit PGoto.new(bb_label(false_target), comment: "goto #{false_target}")
        else
          # Need intermediate blocks for phi copies
          @cmp_id += 1
          true_phi_label = @mem.alloc_label("#{@current_func}_phi_t#{@cmp_id}")
          false_phi_label = @mem.alloc_label("#{@current_func}_phi_f#{@cmp_id}")

          emit PNeg.new(cond, true_phi_label, comment: "if #{op_str(inst.operands[0])} < 0")
          # Fall through to false path
          emit PLabel.new(false_phi_label)
          emit_phi_copies(false_target)
          emit PGoto.new(bb_label(false_target), comment: "goto #{false_target}")
          # True path
          emit PLabel.new(true_phi_label)
          emit_phi_copies(true_target)
          emit PGoto.new(bb_label(true_target), comment: "goto #{true_target}")
        end
      end
    end

    # %r = icmp pred i32 %a, %b
    def lower_icmp(inst)
      pred = inst.operands[0].value
      a = resolve_operand(inst.operands[1])
      b = resolve_operand(inst.operands[2])
      r = fvar(inst.result)

      case pred
      when 'slt'
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} < #{op_str(inst.operands[2])}")
      when 'sgt'
        emit PSub.new(a, b, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} > #{op_str(inst.operands[2])}")
      when 'eq'
        lower_icmp_eq(inst, a, b, r)
      when 'ne'
        lower_icmp_ne(inst, a, b, r)
      when 'sle'
        t = @mem.temp
        one = @mem.const(1)
        emit PSub.new(b, a, t, comment: "#{inst.result} = #{op_str(inst.operands[1])} - #{op_str(inst.operands[2])}")
        emit PSub.new(one, t, r, comment: "#{inst.result} = diff - 1 (sle)")
      when 'sge'
        t = @mem.temp
        one = @mem.const(1)
        emit PSub.new(a, b, t, comment: "#{inst.result} = #{op_str(inst.operands[2])} - #{op_str(inst.operands[1])}")
        emit PSub.new(one, t, r, comment: "#{inst.result} = diff - 1 (sge)")
      when 'ult'
        lower_icmp_unsigned(inst, a, b, r, :lt)
      when 'ugt'
        lower_icmp_unsigned(inst, b, a, r, :lt)
      when 'ule'
        lower_icmp_unsigned(inst, a, b, r, :le)
      when 'uge'
        lower_icmp_unsigned(inst, b, a, r, :le)
      else
        emit PLabel.new("", comment: "UNSUPPORTED icmp pred: #{pred}")
        fvar(inst.result)
      end
    end

    # icmp eq: r = -1 if a == b, r = 0 if a != b
    def lower_icmp_eq(inst, a, b, r)
      @cmp_id += 1
      ne_label = "#{@current_func}_cmp_ne_#{@cmp_id}"
      done_label = "#{@current_func}_cmp_done_#{@cmp_id}"
      @mem.alloc_label(ne_label)
      @mem.alloc_label(done_label)
      diff = @mem.temp
      neg_diff = @mem.temp
      c_n1 = @mem.const(-1)
      z = @mem.zero

      emit PSub.new(b, a, diff, comment: "#{inst.result} = diff(#{op_str(inst.operands[1])}, #{op_str(inst.operands[2])})")
      emit PCp.new(r, c_n1, comment: "assume eq (r = -1)")
      emit PNeg.new(diff, ne_label, comment: "if diff < 0 → not eq")
      emit PSub.new(diff, z, neg_diff, comment: "neg_diff = -diff")
      emit PNeg.new(neg_diff, ne_label, comment: "if diff > 0 → not eq")
      emit PGoto.new(done_label, comment: "diff == 0 → eq")
      emit PLabel.new(ne_label)
      emit PCp.new(r, z, comment: "not eq (r = 0)")
      emit PLabel.new(done_label)
    end

    # icmp ne: r = -1 if a != b, r = 0 if a == b
    def lower_icmp_ne(inst, a, b, r)
      @cmp_id += 1
      ne_label = "#{@current_func}_cmp_ne_#{@cmp_id}"
      done_label = "#{@current_func}_cmp_done_#{@cmp_id}"
      @mem.alloc_label(ne_label)
      @mem.alloc_label(done_label)
      diff = @mem.temp
      neg_diff = @mem.temp
      z = @mem.zero

      emit PSub.new(b, a, diff, comment: "#{inst.result} = diff(#{op_str(inst.operands[1])}, #{op_str(inst.operands[2])})")
      emit PCp.new(r, z, comment: "assume eq (r = 0)")
      emit PNeg.new(diff, ne_label, comment: "if diff < 0 → ne")
      emit PSub.new(diff, z, neg_diff, comment: "neg_diff = -diff")
      emit PNeg.new(neg_diff, ne_label, comment: "if diff > 0 → ne")
      emit PGoto.new(done_label, comment: "diff == 0 → eq")
      emit PLabel.new(ne_label)
      c_n1 = @mem.const(-1)
      emit PCp.new(r, c_n1, comment: "ne (r = -1)")
      emit PLabel.new(done_label)
    end

    # icmp unsigned: ult/ugt/ule/uge via sign-bit branching
    # For same-sign operands, unsigned order == signed order.
    # For different signs, negative value is larger unsigned (high bit set).
    def lower_icmp_unsigned(inst, a, b, r, mode)
      @cmp_id += 1
      id = @cmp_id
      z = @mem.zero
      c_n1 = @mem.const(-1)
      neg_a = @mem.temp
      neg_b = @mem.temp

      a_neg_label = @mem.alloc_label("#{@current_func}_ucmp_aneg#{id}")
      same_sign_label = @mem.alloc_label("#{@current_func}_ucmp_same#{id}")
      true_label = @mem.alloc_label("#{@current_func}_ucmp_true#{id}")
      false_label = @mem.alloc_label("#{@current_func}_ucmp_false#{id}")
      done_label = @mem.alloc_label("#{@current_func}_ucmp_done#{id}")

      # Check sign of a: neg_a = 0 - a; if neg_a < 0 (a > 0), fall through; if a < 0, goto a_neg
      emit PSub.new(a, z, neg_a, comment: "ucmp: neg_a = -a")
      emit PNeg.new(neg_a, a_neg_label, comment: "ucmp: if a < 0 goto a_neg")

      # a >= 0: check sign of b
      emit PSub.new(b, z, neg_b, comment: "ucmp: neg_b = -b")
      emit PNeg.new(neg_b, true_label, comment: "ucmp: a>=0, b<0 → a < b unsigned")
      # a >= 0, b >= 0 → same sign
      emit PGoto.new(same_sign_label, comment: "ucmp: both non-negative")

      # a < 0:
      emit PLabel.new(a_neg_label)
      emit PSub.new(b, z, neg_b, comment: "ucmp: neg_b = -b")
      emit PNeg.new(neg_b, same_sign_label, comment: "ucmp: both negative → same sign")
      # a < 0, b >= 0 → a > b unsigned → not (a < b)
      emit PGoto.new(false_label, comment: "ucmp: a<0, b>=0 → a > b unsigned")

      # Both same sign → use signed comparison
      emit PLabel.new(same_sign_label)
      if mode == :lt
        emit PSub.new(b, a, r, comment: "ucmp: signed lt (same sign)")
      else # :le
        t = @mem.temp
        one = @mem.const(1)
        emit PSub.new(b, a, t, comment: "ucmp: signed le (same sign)")
        emit PSub.new(one, t, r, comment: "ucmp: diff - 1 (le)")
      end
      emit PGoto.new(done_label, comment: "ucmp: done")

      emit PLabel.new(true_label)
      emit PCp.new(r, c_n1, comment: "ucmp: result = true (-1)")
      emit PGoto.new(done_label, comment: "ucmp: done")

      emit PLabel.new(false_label)
      emit PCp.new(r, z, comment: "ucmp: result = false (0)")

      emit PLabel.new(done_label)
    end

    # %r = sdiv i32 %a, %b → inline trivial cases, else call __sdiv subroutine
    def lower_sdiv(inst)
      r = fvar(inst.result)

      # Trivial constant divisors
      if inst.operands[1].const?
        d = inst.operands[1].value
        if d == 1
          emit PCp.new(r, resolve_operand(inst.operands[0]), comment: "#{inst.result} = #{op_str(inst.operands[0])} (sdiv by 1)")
          return
        elsif d == -1
          emit PSub.new(resolve_operand(inst.operands[0]), @mem.zero, r, comment: "#{inst.result} = -#{op_str(inst.operands[0])} (sdiv by -1)")
          return
        end
      end

      # 0 / x = 0
      if inst.operands[0].const? && inst.operands[0].value == 0
        emit PCp.new(r, @mem.zero, comment: "#{inst.result} = 0 (0 / x)")
        return
      end

      # Fallback: subroutine call
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      ensure_sdiv_subroutine

      sdiv = @builtins[:sdiv]
      @call_id += 1
      ret_label = "#{@current_func}_sdivret#{@call_id}"
      @mem.alloc_label(ret_label)

      emit PCp.new(sdiv[:dividend], a, comment: "sdiv dividend = #{op_str(inst.operands[0])}")
      emit PCp.new(sdiv[:divisor], b, comment: "sdiv divisor = #{op_str(inst.operands[1])}")
      emit PCallSetReturn.new(sdiv[:ret_d], ret_label, comment: "sdiv return addr")
      emit PGoto.new("__sdiv", comment: "call __sdiv")
      emit PLabel.new(ret_label, comment: "return from __sdiv")
      emit PCp.new(r, sdiv[:quotient], comment: "#{inst.result} = sdiv result")
    end

    # %r = srem i32 %a, %b → inline trivial cases, else call __srem subroutine
    def lower_srem(inst)
      r = fvar(inst.result)

      # Trivial constant divisors
      if inst.operands[1].const?
        d = inst.operands[1].value
        if d == 1 || d == -1
          emit PCp.new(r, @mem.zero, comment: "#{inst.result} = 0 (srem by #{d})")
          return
        end
      end

      # 0 % x = 0
      if inst.operands[0].const? && inst.operands[0].value == 0
        emit PCp.new(r, @mem.zero, comment: "#{inst.result} = 0 (0 % x)")
        return
      end

      # Fallback: subroutine call
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      ensure_srem_subroutine

      srem = @builtins[:srem]
      @call_id += 1
      ret_label = "#{@current_func}_sremret#{@call_id}"
      @mem.alloc_label(ret_label)

      emit PCp.new(srem[:dividend], a, comment: "srem dividend = #{op_str(inst.operands[0])}")
      emit PCp.new(srem[:divisor], b, comment: "srem divisor = #{op_str(inst.operands[1])}")
      emit PCallSetReturn.new(srem[:ret_d], ret_label, comment: "srem return addr")
      emit PGoto.new("__srem", comment: "call __srem")
      emit PLabel.new(ret_label, comment: "return from __srem")
      emit PCp.new(r, srem[:remainder], comment: "#{inst.result} = srem result")
    end

    def lower_alloca(inst)
      if inst.operands.length >= 2 && inst.operands[0].const?
        # Array alloca: [N x type]
        size = inst.operands[0].value
        @mem.func_alloca_array(@current_func, inst.result, size)
      else
        @mem.func_alloca(@current_func, inst.result)
      end
    end

    # %r = getelementptr inbounds [3 x i32], ptr %base, i64 0, i64 INDEX
    def lower_gep(inst)
      # operands: [raw:[3 x i32], var:base, const:0, const:index] or with var index
      # base can be a local var or a global (@data)
      base_op = inst.operands.find { |o| o.var? || o.global? }
      non_base_ops = inst.operands.reject { |o| o.raw? || o == base_op }

      is_global_base = base_op&.global?

      # Check if all indices are constants
      all_const = non_base_ops.all? { |o| o.const? }

      if base_op && all_const && non_base_ops.length >= 1
        element_idx = non_base_ops.last.value

        if is_global_base
          # Constant-index GEP on global array: alias to the element
          @global_arrays ||= {}
          ga = @global_arrays[base_op.value]
          if ga && element_idx >= 0 && element_idx < ga[:size]
            elem_label = element_idx == 0 ? ga[:base] : "#{ga[:base]}_#{element_idx}"
            key = "#{@current_func}::#{inst.result}"
            @mem.set_alias(key, elem_label)
          else
            fvar(inst.result)
            emit PLabel.new("", comment: "GEP global fallback: #{inst.raw}")
          end
        else
          # Constant-index GEP on local array: alias to the specific array element
          base_name = base_op.value
          element_label = @mem.func_array_element(@current_func, base_name, element_idx)
          if element_label
            key = "#{@current_func}::#{inst.result}"
            @mem.set_alias(key, element_label)
          else
            fvar(inst.result)
            emit PLabel.new("", comment: "GEP fallback: #{inst.raw}")
          end
        end
      elsif base_op
        # Variable-index GEP: compute address + index at runtime
        if is_global_base
          # Global array base: use address-of the base label
          @global_arrays ||= {}
          ga = @global_arrays[base_op.value]
          base_label = ga ? ga[:base] : resolve_global(base_op.value)
          addr_source = @mem.temp
          @mem.mark_addr_of(addr_source, base_label)
        else
          base_name = base_op.value
          base_label = fvar(base_name)
          if is_pointer?(base_name)
            addr_source = base_label
          else
            addr_source = @mem.temp
            @mem.mark_addr_of(addr_source, base_label)
          end
        end

        # Find the variable index operand (last non-base var operand)
        var_indices = non_base_ops.select { |o| o.var? }
        if var_indices.any?
          index_var = resolve_operand(var_indices.last)
          r = fvar(inst.result)
          emit PAdd.new(index_var, addr_source, r, comment: "GEP #{inst.result} = #{base_op.value} + #{op_str(var_indices.last)}")
          mark_pointer(inst.result)
        else
          fvar(inst.result)
          emit PLabel.new("", comment: "UNSUPPORTED GEP: #{inst.raw}")
        end
      else
        fvar(inst.result)
        emit PLabel.new("", comment: "UNSUPPORTED GEP: #{inst.raw}")
      end
    end

    # %r = load i32, ptr %p  or  %r = load ptr, ptr %p
    def lower_load(inst)
      ptr_name = inst.operands[0].var? ? inst.operands[0].value : nil
      ptr = resolve_operand(inst.operands[0])
      r = fvar(inst.result)

      # Check if the load type is ptr (second operand if present)
      load_type = inst.operands[1]&.value if inst.operands.length > 1 && inst.operands[1].kind == :type
      mark_pointer(inst.result) if load_type == 'ptr'

      if ptr_name && is_pointer?(ptr_name)
        # Indirect load: ptr holds a computed address
        id = @indirect_id += 1
        emit PIndirectLoad.new(r, ptr, "il#{id}", comment: "load #{inst.result} from [#{op_str(inst.operands[0])}]")
      else
        emit PCp.new(r, ptr, comment: "load #{inst.result} from #{op_str(inst.operands[0])}")
      end
    end

    # store i32 %v, ptr %p
    def lower_store(inst)
      val = resolve_operand(inst.operands[0])
      ptr_name = inst.operands[1].var? ? inst.operands[1].value : nil
      ptr = resolve_operand(inst.operands[1])

      if ptr_name && is_pointer?(ptr_name)
        # Indirect store: ptr holds a computed address
        id = @indirect_id += 1
        emit PIndirectStore.new(ptr, val, "is#{id}", comment: "store #{op_str(inst.operands[0])} to [#{op_str(inst.operands[1])}]")
      else
        emit PCp.new(ptr, val, comment: "store #{op_str(inst.operands[0])} to #{op_str(inst.operands[1])}")
      end
    end

    # %r = call i32 @func(i32 %a, i32 %b)
    # operands: [label:func_name, arg0, arg1, ...]
    def lower_call(inst)
      func_name = inst.operands[0].value
      args = inst.operands[1..]
      callee = @functions[func_name]

      unless callee
        emit PLabel.new("", comment: "UNSUPPORTED: call to unknown function #{func_name}")
        fvar(inst.result) if inst.result
        return
      end

      # Generate unique return label and IDs for this call site
      @call_id += 1
      call_id = @call_id
      ret_label = "#{@current_func}_ret#{call_id}"
      @mem.alloc_label(ret_label)

      # Save current function's state onto the stack (for recursion safety)
      caller_info = @functions[@current_func]
      save_labels = @mem.func_all_labels(@current_func)
      # Also save the return address cell (lives in code section, but addressable)
      save_labels = save_labels + [caller_info[:ret_d_label]] if caller_info && @current_func != 'main'

      save_labels.each_with_index do |label, i|
        emit PPush.new(label, "#{call_id}_s#{i}", comment: "save #{label}")
      end

      # Copy arguments to callee's parameter slots
      args.each_with_index do |arg, i|
        next unless i < callee[:params].length
        param_type = callee[:param_types][i]

        if param_type == 'ptr' && arg.var? && !is_pointer?(arg.value)
          # Passing address of a non-pointer variable (e.g., array element alias)
          val = resolve_operand(arg)
          addr_temp = @mem.temp
          @mem.mark_addr_of(addr_temp, val)
          emit PCp.new(callee[:params][i], addr_temp, comment: "arg #{i}: &#{op_str(arg)}")
        else
          val = resolve_operand(arg)
          emit PCp.new(callee[:params][i], val, comment: "arg #{i}: #{op_str(arg)}")
        end
      end

      # Write &ret_label into the callee's return jump D operand (self-modifying)
      emit PCallSetReturn.new(callee[:ret_d_label], ret_label, comment: "set return addr for #{func_name}")

      # Jump to callee
      emit PGoto.new("func_#{func_name}", comment: "call #{func_name}")

      # Return label — execution continues here after callee returns
      emit PLabel.new(ret_label, comment: "return from #{func_name}")

      # Copy result BEFORE restoring state (callee's retval will be overwritten by pop)
      result_temp = nil
      if inst.result
        result_temp = @mem.temp
        emit PCp.new(result_temp, callee[:retval], comment: "save #{func_name}() result")
      end

      # Restore current function's state from the stack (reverse order)
      save_labels.reverse.each_with_index do |label, i|
        emit PPop.new(label, "#{call_id}_r#{i}", comment: "restore #{label}")
      end

      # Copy saved result to final destination variable
      if inst.result
        r = fvar(inst.result)
        emit PCp.new(r, result_temp, comment: "#{inst.result} = #{func_name}() result")
      end
    end

    # %r = select i1 %cond, i32 %a, i32 %b
    # if cond < 0, r = a; else r = b
    def lower_select(inst)
      cond = resolve_operand(inst.operands[0])
      true_val = resolve_operand(inst.operands[1])
      false_val = resolve_operand(inst.operands[2])
      r = fvar(inst.result)

      @cmp_id += 1
      true_label = "#{@current_func}_sel_t_#{@cmp_id}"
      done_label = "#{@current_func}_sel_done_#{@cmp_id}"
      @mem.alloc_label(true_label)
      @mem.alloc_label(done_label)

      emit PNeg.new(cond, true_label, comment: "select: if cond < 0")
      emit PCp.new(r, false_val, comment: "select false value")
      emit PGoto.new(done_label, comment: "select done")
      emit PLabel.new(true_label)
      emit PCp.new(r, true_val, comment: "select true value")
      emit PLabel.new(done_label)
    end

    # switch i32 %val, label %default [ i32 N, label %LN ... ]
    # operands: [val, default_label, case_val1, case_label1, ...]
    def lower_switch(inst)
      val = resolve_operand(inst.operands[0])
      default_target = inst.operands[1].value
      cases = inst.operands[2..].each_slice(2).to_a

      # For each case: if val == case_val, goto case_label
      cases.each do |case_val_op, case_label_op|
        case_val = resolve_operand(case_val_op)
        target = case_label_op.value

        # Inline eq check: diff = val - case_val; if diff == 0 goto target
        @cmp_id += 1
        id = @cmp_id
        diff = @mem.temp
        neg_diff = @mem.temp
        not_eq_label = @mem.alloc_label("#{@current_func}_sw_ne#{id}")

        emit PSub.new(val, case_val, diff, comment: "switch: #{op_str(inst.operands[0])} == #{case_val_op.value}?")
        # if diff < 0, not equal
        emit PNeg.new(diff, not_eq_label, comment: "switch: diff < 0 → skip")
        # if -diff < 0 (diff > 0), not equal
        emit PSub.new(diff, @mem.zero, neg_diff, comment: "switch: negate diff")
        emit PNeg.new(neg_diff, not_eq_label, comment: "switch: -diff < 0 → skip")
        # diff == 0 → match!
        emit_phi_copies(target)
        emit PGoto.new(bb_label(target), comment: "switch: goto #{target}")
        emit PLabel.new(not_eq_label)
      end

      # Default case
      emit_phi_copies(default_target)
      emit PGoto.new(bb_label(default_target), comment: "switch: default → #{default_target}")
    end

    def lower_phi(_inst)
      # Phi copies are handled at branch points (see emit_phi_copies)
      # The phi result variable was pre-allocated in lower_function
    end

    def lower_cast(inst)
      src = resolve_operand(inst.operands[0])
      r = fvar(inst.result)
      emit PCp.new(r, src, comment: "cast #{inst.result} = #{op_str(inst.operands[0])}")
    end

    # Resolve an IR operand to a SUBNEG4 variable name (scoped to current function)
    def resolve_operand(op)
      case op.kind
      when :var    then fvar(op.value)
      when :const  then @mem.const(op.value)
      when :label  then bb_label(op.value)
      when :global then resolve_global(op.value)
      when :global_element then resolve_global_element(op.value[:name], op.value[:index])
      else
        raise "Cannot resolve operand: #{op}"
      end
    end

    # Get a function-scoped variable
    def fvar(name)
      @mem.func_var(@current_func, name)
    end

    def op_str(op)
      case op.kind
      when :var   then "%#{op.value}"
      when :const then op.value.to_s
      when :label then "%#{op.value}"
      else op.value.to_s
      end
    end

    def emit_phi_copies(target_block)
      return unless @phi_copies[target_block]
      copies = @phi_copies[target_block][@current_block]
      return unless copies
      copies.each do |phi_result, val_op|
        r = fvar(phi_result)
        val = resolve_operand(val_op)
        emit PCp.new(r, val, comment: "phi #{phi_result} = #{op_str(val_op)}")
      end
    end

    def has_phi_copies?(target_block)
      return false unless @phi_copies[target_block]
      @phi_copies[target_block][@current_block]&.any?
    end

    def resolve_global(name)
      @globals_map ||= {}
      @globals_map[name] || raise("Unknown global: @#{name}")
    end

    def resolve_global_element(name, index)
      @global_arrays ||= {}
      ga = @global_arrays[name]
      if ga
        index == 0 ? ga[:base] : "#{ga[:base]}_#{index}"
      else
        raise "Unknown global array: @#{name}"
      end
    end

    def mark_pointer(ir_name)
      @pointers["#{@current_func}::#{ir_name}"] = true
    end

    def mark_pointer_for(func_name, ir_name)
      @pointers["#{func_name}::#{ir_name}"] = true
    end

    def is_pointer?(ir_name)
      @pointers["#{@current_func}::#{ir_name}"]
    end

    def emit(op)
      @pseudo_ops << op
    end
  end
end
