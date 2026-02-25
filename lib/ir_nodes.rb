# frozen_string_literal: true

module S4C
  # A single LLVM IR instruction (SSA form)
  class IRInstruction
    attr_reader :opcode, :result, :operands, :type, :raw

    def initialize(opcode:, result: nil, operands: [], type: nil, raw: "")
      @opcode   = opcode
      @result   = result      # %name or nil for void ops
      @operands = operands    # array of Operand
      @type     = type        # e.g. "i32", "ptr"
      @raw      = raw
    end

    def to_s
      if @result
        "%#{@result} = #{@opcode} #{@operands.map(&:to_s).join(', ')}"
      else
        "#{@opcode} #{@operands.map(&:to_s).join(', ')}"
      end
    end
  end

  # An operand in an IR instruction — either a variable (%name) or a constant
  class Operand
    attr_reader :kind, :value, :type

    def initialize(kind, value, type: nil)
      @kind  = kind   # :var, :const, :label, :type
      @value = value   # variable name (without %), integer, or label name
      @type  = type    # e.g. "i32"
    end

    def var?    = @kind == :var
    def const?  = @kind == :const
    def label?  = @kind == :label
    def raw?    = @kind == :raw
    def global? = @kind == :global

    def to_s
      case @kind
      when :var   then "%#{@value}"
      when :const then @value.to_s
      when :label then "%#{@value}"
      else @value.to_s
      end
    end
  end

  # A basic block within a function
  class BasicBlock
    attr_reader :name, :instructions

    def initialize(name)
      @name = name
      @instructions = []
    end

    def <<(inst)
      @instructions << inst
    end

    def to_s
      "#{@name}:\n" + @instructions.map { |i| "  #{i}" }.join("\n")
    end
  end

  # A function definition
  class IRFunction
    attr_reader :name, :return_type, :params, :blocks

    def initialize(name:, return_type:, params: [])
      @name        = name
      @return_type = return_type
      @params      = params     # array of [type, name]
      @blocks      = []
    end

    def <<(block)
      @blocks << block
    end

    def to_s
      "define #{@return_type} @#{@name}(#{@params.map { |t, n| "#{t} %#{n}" }.join(', ')})\n" +
        @blocks.map(&:to_s).join("\n")
    end
  end

  # Top-level module containing functions and globals
  class IRModule
    attr_reader :functions, :globals

    def initialize
      @functions = []
      @globals   = []
    end

    def <<(func)
      @functions << func
    end
  end
end
