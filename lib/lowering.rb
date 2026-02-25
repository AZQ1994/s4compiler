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
    end

    # Lower an entire IR module
    def lower(ir_module)
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
        end
      end

      self
    end

    private

    def register_function(func)
      param_labels = func.params.map do |_type, name|
        @mem.func_param(func.name, name)
      end
      retval = @mem.func_var(func.name, "__retval")
      # Per-operand label for the D operand of the return jump instruction
      ret_d_label = "#{func.name}_ret_d"
      @functions[func.name] = { params: param_labels, retval: retval, ret_d_label: ret_d_label }
    end

    def lower_function(func)
      @current_func = func.name

      emit PLabel.new("func_#{func.name}", comment: "function #{func.name}")

      # Process each basic block
      func.blocks.each do |block|
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
      when 'ret'  then lower_ret(inst)
      when 'br'   then lower_br(inst)
      when 'icmp' then lower_icmp(inst)
      when 'alloca'        then lower_alloca(inst)
      when 'load'          then lower_load(inst)
      when 'store'         then lower_store(inst)
      when 'getelementptr' then lower_gep(inst)
      when 'call'          then lower_call(inst)
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

    # %r = mul i32 %a, %b → call built-in __mul subroutine
    def lower_mul(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)
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
        label = bb_label(inst.operands[0].value)
        emit PGoto.new(label, comment: "goto #{inst.operands[0].value}")
      elsif inst.operands.length == 3
        cond = resolve_operand(inst.operands[0])
        true_label  = bb_label(inst.operands[1].value)
        false_label = bb_label(inst.operands[2].value)
        emit PNeg.new(cond, true_label, comment: "if #{op_str(inst.operands[0])} < 0 goto #{inst.operands[1].value}")
        emit PGoto.new(false_label, comment: "goto #{inst.operands[2].value}")
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

    # %r = sdiv i32 %a, %b → call built-in __sdiv subroutine
    def lower_sdiv(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)
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

    # %r = srem i32 %a, %b → call built-in __srem subroutine
    def lower_srem(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = fvar(inst.result)
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
      # operands: [raw:[3 x i32], var:base, const:0, const:index]
      # For constant indices, resolve to the specific array element label
      base_op = inst.operands.find { |o| o.var? }
      index_ops = inst.operands.select { |o| o.const? }

      if base_op && index_ops.length >= 1
        # Last constant index is the element index
        element_idx = index_ops.last.value
        base_name = base_op.value

        # Look up the array element label
        element_label = @mem.func_array_element(@current_func, base_name, element_idx)
        if element_label
          # GEP result is an alias to the element
          key = "#{@current_func}::#{inst.result}"
          @mem.set_alias(key, element_label)
        else
          # Fallback: treat as pointer arithmetic
          fvar(inst.result)
          emit PLabel.new("", comment: "GEP fallback: #{inst.raw}")
        end
      else
        fvar(inst.result)
        emit PLabel.new("", comment: "UNSUPPORTED GEP: #{inst.raw}")
      end
    end

    # %r = load i32, ptr %p
    def lower_load(inst)
      ptr = resolve_operand(inst.operands[0])
      r = fvar(inst.result)
      emit PCp.new(r, ptr, comment: "load #{inst.result} from #{op_str(inst.operands[0])}")
    end

    # store i32 %v, ptr %p
    def lower_store(inst)
      val = resolve_operand(inst.operands[0])
      ptr = resolve_operand(inst.operands[1])
      emit PCp.new(ptr, val, comment: "store #{op_str(inst.operands[0])} to #{op_str(inst.operands[1])}")
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
        val = resolve_operand(arg)
        emit PCp.new(callee[:params][i], val, comment: "arg #{i}: #{op_str(arg)}")
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

    def lower_phi(inst)
      fvar(inst.result)
      emit PLabel.new("", comment: "TODO: phi #{inst.raw}")
    end

    def lower_cast(inst)
      src = resolve_operand(inst.operands[0])
      r = fvar(inst.result)
      emit PCp.new(r, src, comment: "cast #{inst.result} = #{op_str(inst.operands[0])}")
    end

    # Resolve an IR operand to a SUBNEG4 variable name (scoped to current function)
    def resolve_operand(op)
      case op.kind
      when :var   then fvar(op.value)
      when :const then @mem.const(op.value)
      when :label then bb_label(op.value)
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

    def emit(op)
      @pseudo_ops << op
    end
  end
end
