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
      when 'ret'  then lower_ret(inst)
      when 'br'   then lower_br(inst)
      when 'icmp' then lower_icmp(inst)
      when 'alloca' then lower_alloca(inst)
      when 'load'   then lower_load(inst)
      when 'store'  then lower_store(inst)
      when 'call'   then lower_call(inst)
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

    def lower_mul(inst)
      emit PLabel.new("", comment: "TODO: mul #{inst.raw}")
      fvar(inst.result)
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
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} == #{op_str(inst.operands[2])} (diff)")
      when 'ne'
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} != #{op_str(inst.operands[2])} (diff)")
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

    def lower_alloca(inst)
      @mem.func_alloca(@current_func, inst.result)
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

      # Generate unique return label for this call site
      @call_id += 1
      ret_label = "#{@current_func}_ret#{@call_id}"
      @mem.alloc_label(ret_label)

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

      # Copy callee's return value to our result variable
      if inst.result
        r = fvar(inst.result)
        emit PCp.new(r, callee[:retval], comment: "#{inst.result} = #{func_name}() result")
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
