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
      @instructions = []  # mixed: Subneg4, :label, :data, :comment
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
      when PLabel
        @instructions << [:label, op.name, op.comment]
      when PData
        @instructions << [:data, op.name, op.value, op.comment]
      else
        raise "Unknown pseudo-op: #{op.class}"
      end
    end

    # P_SUB(a, b, c): c = b - a → SUBNEG4: a b c NEXT
    def expand_sub(op)
      @instructions << Subneg4.new(op.a, op.b, op.c, 'NEXT', op.comment)
    end

    # P_ADD(a, b, c): c = b + a
    # → temp = 0 - a = -a      (SUBNEG4: a ZERO temp NEXT)
    # → c = b - (-a) = b + a   (SUBNEG4: temp b c NEXT)
    def expand_add(op)
      t = @mem.temp
      z = @mem.zero
      @instructions << Subneg4.new(op.a, z, t, 'NEXT', "#{op.comment} (negate)")
      @instructions << Subneg4.new(t, op.b, op.c, 'NEXT', "#{op.comment} (add)")
    end

    # P_CP(dst, src): dst = src → SUBNEG4: ZERO src dst NEXT (dst = src - 0)
    def expand_cp(op)
      z = @mem.zero
      @instructions << Subneg4.new(z, op.src, op.dst, 'NEXT', op.comment)
    end

    # P_GOTO(label): unconditional jump
    # → SUBNEG4: ZERO C_n1 temp label  (temp = -1 - 0 = -1, always < 0 → branch)
    def expand_goto(op)
      z = @mem.zero
      c_n1 = @mem.const(-1)
      t = @mem.temp
      @instructions << Subneg4.new(z, c_n1, t, op.label, op.comment)
    end

    # P_NEG(val, label): branch if val < 0
    # → SUBNEG4: ZERO val temp label  (temp = val - 0 = val, branch if < 0)
    def expand_neg(op)
      z = @mem.zero
      t = @mem.temp
      @instructions << Subneg4.new(z, op.val, t, op.label, op.comment)
    end

    # HALT: jump to HALT
    def expand_halt(_op)
      @instructions << Subneg4.new(@mem.zero, @mem.zero, @mem.zero, 'HALT', "halt")
    end
  end
end
