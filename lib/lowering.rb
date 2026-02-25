# frozen_string_literal: true

require_relative 'pseudo_ops'
require_relative 'memory'

module S4C
  # Lowers IR instructions into pseudo-operations.
  # Phase 1: add, sub, ret (basic arithmetic)
  # Phase 2: br, icmp (control flow)
  class Lowering
    attr_reader :mem, :pseudo_ops

    def initialize
      @mem = Memory.new
      @pseudo_ops = []
    end

    # Lower an entire IR module
    def lower(ir_module)
      ir_module.functions.each do |func|
        lower_function(func)
      end
      self
    end

    private

    def lower_function(func)
      # Register parameters
      func.params.each do |_type, name|
        @mem.param(name)
      end

      # Process each basic block
      func.blocks.each do |block|
        emit PLabel.new("bb_#{block.name}", comment: "Basic block: #{block.name}")

        block.instructions.each do |inst|
          lower_instruction(inst)
        end
      end
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
      when 'phi'    then lower_phi(inst)
      when 'sext', 'zext', 'trunc', 'bitcast'
        lower_cast(inst)
      else
        # Unsupported — emit comment
        emit PLabel.new("", comment: "UNSUPPORTED: #{inst.raw}")
      end
    end

    # %r = add i32 %a, %b  →  P_ADD(var_a, var_b, var_r)
    def lower_add(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = @mem.var(inst.result)
      emit PAdd.new(a, b, r, comment: "#{inst.result} = #{op_str(inst.operands[0])} + #{op_str(inst.operands[1])}")
    end

    # %r = sub i32 %a, %b  →  P_SUB(var_b, var_a, var_r)
    # SUBNEG4: c = b - a, so for IR sub (a - b): P_SUB(b_var, a_var, r)
    def lower_sub(inst)
      a = resolve_operand(inst.operands[0])
      b = resolve_operand(inst.operands[1])
      r = @mem.var(inst.result)
      # IR: result = operands[0] - operands[1]
      # SUBNEG4 P_SUB(subtrahend, minuend, dest): dest = minuend - subtrahend
      # So: P_SUB(operands[1], operands[0], result)
      emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[0])} - #{op_str(inst.operands[1])}")
    end

    # %r = mul i32 %a, %b → multiplication subroutine (Phase 1: skip)
    def lower_mul(inst)
      emit PLabel.new("", comment: "TODO: mul #{inst.raw}")
      @mem.var(inst.result) # allocate result slot
    end

    # ret i32 %val  →  P_CP(retval, var_val) + HALT (for Phase 1, single function)
    def lower_ret(inst)
      if inst.operands.empty?
        # ret void
        emit PHalt.new
      else
        val = resolve_operand(inst.operands[0])
        retval = @mem.var("__retval")
        emit PCp.new(retval, val, comment: "return #{op_str(inst.operands[0])}")
        emit PHalt.new
      end
    end

    # br label %L → P_GOTO
    # br i1 %c, label %T, label %F → P_NEG + P_GOTO
    def lower_br(inst)
      if inst.operands.length == 1
        # Unconditional
        label = "bb_#{inst.operands[0].value}"
        emit PGoto.new(label, comment: "goto #{inst.operands[0].value}")
      elsif inst.operands.length == 3
        # Conditional: operands = [cond, true_label, false_label]
        cond = resolve_operand(inst.operands[0])
        true_label  = "bb_#{inst.operands[1].value}"
        false_label = "bb_#{inst.operands[2].value}"
        # icmp produces negative value for true → P_NEG branches on negative
        emit PNeg.new(cond, true_label, comment: "if #{op_str(inst.operands[0])} < 0 goto #{inst.operands[1].value}")
        emit PGoto.new(false_label, comment: "goto #{inst.operands[2].value}")
      end
    end

    # %r = icmp slt i32 %a, %b → compute a - b (negative if a < b)
    def lower_icmp(inst)
      pred = inst.operands[0].value  # slt, sgt, eq, ne, sle, sge
      a = resolve_operand(inst.operands[1])
      b = resolve_operand(inst.operands[2])
      r = @mem.var(inst.result)

      case pred
      when 'slt'
        # a < b  ↔  a - b < 0
        # P_SUB(b, a, r): r = a - b
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} < #{op_str(inst.operands[2])}")
      when 'sgt'
        # a > b  ↔  b - a < 0
        emit PSub.new(a, b, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} > #{op_str(inst.operands[2])}")
      when 'eq'
        # a == b  ↔  a - b == 0 → need special handling
        # For Phase 2, use: r = a - b, then check if r == 0
        # Approximate: store a - b (caller must handle zero check)
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} == #{op_str(inst.operands[2])} (diff)")
      when 'ne'
        emit PSub.new(b, a, r, comment: "#{inst.result} = #{op_str(inst.operands[1])} != #{op_str(inst.operands[2])} (diff)")
      when 'sle'
        # a <= b  ↔  a - b - 1 < 0
        # P_SUB: r = a - b, then r = r - 1
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
        @mem.var(inst.result)
      end
    end

    # %r = alloca i32 → allocate a local variable
    def lower_alloca(inst)
      @mem.alloca_var(inst.result)
    end

    # %r = load i32, ptr %p → P_CP(var_r, var_p)
    # Phase 1: treat as direct copy (no indirection yet)
    def lower_load(inst)
      ptr = resolve_operand(inst.operands[0])
      r = @mem.var(inst.result)
      emit PCp.new(r, ptr, comment: "load #{inst.result} from #{op_str(inst.operands[0])}")
    end

    # store i32 %v, ptr %p → P_CP(var_p, var_v)
    def lower_store(inst)
      val = resolve_operand(inst.operands[0])
      ptr = resolve_operand(inst.operands[1])
      emit PCp.new(ptr, val, comment: "store #{op_str(inst.operands[0])} to #{op_str(inst.operands[1])}")
    end

    # phi: handled by inserting copies at predecessor block ends (simplified)
    def lower_phi(inst)
      # Phase 2: For now, just allocate the result variable
      # Proper phi elimination requires inserting copies at pred block ends
      @mem.var(inst.result)
      emit PLabel.new("", comment: "TODO: phi #{inst.raw}")
    end

    # Cast instructions: for i32-only programs, just copy the value
    def lower_cast(inst)
      src = resolve_operand(inst.operands[0])
      r = @mem.var(inst.result)
      emit PCp.new(r, src, comment: "cast #{inst.result} = #{op_str(inst.operands[0])}")
    end

    # Resolve an IR operand to a SUBNEG4 variable name
    def resolve_operand(op)
      case op.kind
      when :var   then @mem.var(op.value)
      when :const then @mem.const(op.value)
      when :label then "bb_#{op.value}"
      else
        raise "Cannot resolve operand: #{op}"
      end
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
