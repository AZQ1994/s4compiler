# frozen_string_literal: true

require_relative 'pseudo_ops'

module S4C
  # A single SUBNEG4 instruction: A B C D
  # Semantics: mem[C] = mem[B] - mem[A]; if result < 0 then goto D
  Subneg4 = Struct.new(:a, :b, :c, :d, :comment) do
    def to_s
      "#{a}, #{b}, #{c}, #{d}"
    end
  end

  # Expands pseudo-operations into SUBNEG4 instructions.
  class Expander
    attr_reader :instructions

    def initialize(memory)
      @mem = memory
      @instructions = []
    end

    def expand(pseudo_ops)
      pseudo_ops.each { |op| expand_one(op) }
      self
    end

    private

    def expand_one(op)
      case op
      when PSub  then expand_sub(op)
      when PAdd  then expand_add(op)
      when PCp   then expand_cp(op)
      when PGoto then expand_goto(op)
      when PNeg  then expand_neg(op)
      when PHalt then expand_halt(op)
      when PCallSetReturn then expand_call_set_return(op)
      when PReturnJump    then expand_return_jump(op)
      when PLabel
        @instructions << [:label, op.name, op.comment]
      when PData
        @instructions << [:data, op.name, op.value, op.comment]
      else
        raise "Unknown pseudo-op: #{op.class}"
      end
    end

    def expand_sub(op)
      @instructions << Subneg4.new(op.a, op.b, op.c, 'NEXT', op.comment)
    end

    def expand_add(op)
      t = @mem.temp
      z = @mem.zero
      @instructions << Subneg4.new(op.a, z, t, 'NEXT', "#{op.comment} (negate)")
      @instructions << Subneg4.new(t, op.b, op.c, 'NEXT', "#{op.comment} (add)")
    end

    def expand_cp(op)
      z = @mem.zero
      @instructions << Subneg4.new(z, op.src, op.dst, 'NEXT', op.comment)
    end

    def expand_goto(op)
      z = @mem.zero
      c_n1 = @mem.const(-1)
      t = @mem.temp
      @instructions << Subneg4.new(z, c_n1, t, op.label, op.comment)
    end

    def expand_neg(op)
      z = @mem.zero
      t = @mem.temp
      @instructions << Subneg4.new(z, op.val, t, op.label, op.comment)
    end

    def expand_halt(_op)
      @instructions << Subneg4.new(@mem.zero, @mem.zero, @mem.zero, 'HALT', "halt")
    end

    # PReturnJump(d_label):
    # Emit a goto with a per-operand label on the D operand.
    # The D value starts as 0 (will be overwritten by caller).
    # Output: cd:D_LABEL: ZERO, C_n1, temp, 0
    def expand_return_jump(op)
      z = @mem.zero
      c_n1 = @mem.const(-1)
      t = @mem.temp
      # Special instruction with per-operand label on D
      @instructions << [:return_jump, z, c_n1, t, op.d_label, op.comment]
    end

    # PCallSetReturn(ret_d_label, return_label):
    # Create a data word holding &return_label, then copy it into the D operand cell.
    # Output:
    #   addr_DATA: &return_label   (data: address of return label)
    #   ZERO, addr_DATA, ret_d_label, NEXT  (copy address into D cell)
    def expand_call_set_return(op)
      # Emit a data word with &return_label as value
      addr_name = @mem.temp
      @instructions << [:addr_data, addr_name, op.return_label, op.comment]
      # Copy the address value into the callee's D operand cell
      z = @mem.zero
      @instructions << Subneg4.new(z, addr_name, op.ret_d_label, 'NEXT', op.comment)
    end
  end
end
