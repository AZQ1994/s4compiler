# frozen_string_literal: true

module S4C
  # Manages variable allocation and name generation for the SUBNEG4 output.
  # All variables are symbolic names — the SUBNEG4 assembler resolves addresses.
  class Memory
    attr_reader :data_entries, :constants

    def initialize
      @variables = {}       # IR variable name → SUBNEG4 label name
      @constants = {}       # integer value → label name
      @temps     = 0        # temp counter
      @data_entries = []    # ordered list of [label, initial_value]
      @used_names = {}

      # Pre-allocate ZERO constant (always needed)
      alloc_const(0)
    end

    # Get or create a SUBNEG4 label for an IR variable (%name)
    def var(ir_name)
      @variables[ir_name] ||= alloc_var("v_#{sanitize(ir_name)}")
    end

    # Get or create a label for a constant value
    def const(value)
      @constants[value] ||= alloc_const(value)
    end

    # Allocate a fresh temporary variable
    def temp
      name = "t#{@temps}"
      @temps += 1
      alloc_var(name, 0)
    end

    # Get the label for constant zero (always "ZERO")
    def zero
      const(0)
    end

    # Register a function parameter as a variable with initial value 0
    def param(ir_name)
      label = "arg_#{sanitize(ir_name)}"
      label = unique_name(label)
      @variables[ir_name] = label
      @data_entries << [label, 0]
      label
    end

    # Allocate a named data slot (e.g. for alloca)
    def alloca_var(ir_name)
      label = "local_#{sanitize(ir_name)}"
      label = unique_name(label)
      @variables[ir_name] = label
      @data_entries << [label, 0]
      label
    end

    private

    def sanitize(name)
      name.to_s.gsub(/[^a-zA-Z0-9_]/, '_')
    end

    def unique_name(base)
      return base unless @used_names[base]
      i = 2
      i += 1 while @used_names["#{base}_#{i}"]
      "#{base}_#{i}"
    end

    def alloc_var(name, init_value = 0)
      name = unique_name(name)
      @used_names[name] = true
      @data_entries << [name, init_value]
      name
    end

    def alloc_const(value)
      label = value == 0 ? "ZERO" : "C_#{value < 0 ? 'n' : ''}#{value.abs}"
      label = unique_name(label)
      @used_names[label] = true
      @constants[value] = label
      @data_entries << [label, value]
      label
    end
  end
end
