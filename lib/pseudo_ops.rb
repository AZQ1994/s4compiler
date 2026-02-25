# frozen_string_literal: true

module S4C
  # Base class for pseudo-instructions (intermediate between IR and SUBNEG4)
  class PseudoOp
    attr_reader :comment

    def initialize(comment: "")
      @comment = comment
    end
  end

  # P_SUB(a, b, c): c = b - a → one SUBNEG4 instruction
  class PSub < PseudoOp
    attr_reader :a, :b, :c

    def initialize(a, b, c, comment: "")
      super(comment: comment)
      @a = a  # subtrahend
      @b = b  # minuend
      @c = c  # destination: c = b - a
    end

    def to_s = "P_SUB #{@a}, #{@b}, #{@c}"
  end

  # P_ADD(a, b, c): c = b + a → two SUBNEG4 instructions
  class PAdd < PseudoOp
    attr_reader :a, :b, :c

    def initialize(a, b, c, comment: "")
      super(comment: comment)
      @a = a
      @b = b
      @c = c  # destination: c = b + a
    end

    def to_s = "P_ADD #{@a}, #{@b}, #{@c}"
  end

  # P_CP(dst, src): dst = src → one SUBNEG4 instruction
  class PCp < PseudoOp
    attr_reader :dst, :src

    def initialize(dst, src, comment: "")
      super(comment: comment)
      @dst = dst
      @src = src
    end

    def to_s = "P_CP #{@dst}, #{@src}"
  end

  # P_GOTO(label): unconditional jump → one SUBNEG4 instruction
  class PGoto < PseudoOp
    attr_reader :label

    def initialize(label, comment: "")
      super(comment: comment)
      @label = label
    end

    def to_s = "P_GOTO #{@label}"
  end

  # P_NEG(val, label): branch to label if val < 0 → one SUBNEG4 instruction
  class PNeg < PseudoOp
    attr_reader :val, :label

    def initialize(val, label, comment: "")
      super(comment: comment)
      @val = val
      @label = label
    end

    def to_s = "P_NEG #{@val}, #{@label}"
  end

  # P_LABEL(name): a label marker (no code generated, just a position)
  class PLabel < PseudoOp
    attr_reader :name

    def initialize(name, comment: "")
      super(comment: comment)
      @name = name
    end

    def to_s = "P_LABEL #{@name}"
  end

  # P_DATA(name, value): a data word in the data section
  class PData < PseudoOp
    attr_reader :name, :value

    def initialize(name, value, comment: "")
      super(comment: comment)
      @name = name
      @value = value
    end

    def to_s = "P_DATA #{@name}: #{@value}"
  end

  # P_HALT: halt execution
  class PHalt < PseudoOp
    def to_s = "P_HALT"
  end
end
