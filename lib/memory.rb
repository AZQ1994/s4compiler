# frozen_string_literal: true

module S4C
  # Manages variable allocation and name generation for the SUBNEG4 output.
  # All variables are symbolic names — the SUBNEG4 assembler resolves addresses.
  class Memory
    attr_reader :data_entries, :constants, :addr_of_refs

    def initialize
      @variables = {}       # "func::ir_name" → SUBNEG4 label name
      @constants = {}       # integer value → label name
      @temps     = 0        # temp counter
      @data_entries = []    # ordered list of [label, initial_value]
      @used_names = {}
      @arrays = {}          # "func::ir_name" → [element_label_0, element_label_1, ...]
      @addr_of_refs = {}    # label → target_label (for &target address-of references)

      # Pre-allocate ZERO constant (always needed)
      alloc_const(0)
    end

    # Get or create a function-scoped variable
    def func_var(func_name, ir_name)
      key = "#{func_name}::#{ir_name}"
      @variables[key] ||= alloc_var("#{func_name}_#{sanitize(ir_name)}")
    end

    # Register a function parameter
    def func_param(func_name, ir_name)
      key = "#{func_name}::#{ir_name}"
      label = "#{func_name}_arg_#{sanitize(ir_name)}"
      label = unique_name(label)
      @variables[key] = label
      @data_entries << [label, 0]
      @used_names[label] = true
      label
    end

    # Allocate a local variable for alloca (function-scoped)
    def func_alloca(func_name, ir_name)
      key = "#{func_name}::#{ir_name}"
      label = "#{func_name}_local_#{sanitize(ir_name)}"
      label = unique_name(label)
      @variables[key] = label
      @data_entries << [label, 0]
      @used_names[label] = true
      label
    end

    # Allocate a global variable with an initial value
    def alloc_global(label, value)
      label = unique_name(label) if @used_names[label]
      @used_names[label] = true
      @data_entries << [label, value]
      label
    end

    # Allocate a global array with initial values
    # Returns the base label (first element)
    def alloc_global_array(base_label, values)
      base_label = unique_name(base_label) if @used_names[base_label]
      values.each_with_index do |v, idx|
        elem_label = idx == 0 ? base_label : "#{base_label}_#{idx}"
        @used_names[elem_label] = true
        @data_entries << [elem_label, v]
      end
      base_label
    end

    # Backward compat: unscoped var (for single-function programs)
    def var(ir_name)
      func_var("_", ir_name)
    end

    # Backward compat: unscoped param
    def param(ir_name)
      func_param("_", ir_name)
    end

    # Backward compat: unscoped alloca
    def alloca_var(ir_name)
      func_alloca("_", ir_name)
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

    # Get the label for constant zero
    def zero
      const(0)
    end

    # Allocate an array of N consecutive data cells
    def func_alloca_array(func_name, ir_name, size)
      key = "#{func_name}::#{ir_name}"
      base = "#{func_name}_arr_#{sanitize(ir_name)}"
      elements = size.times.map do |i|
        label = "#{base}_#{i}"
        label = unique_name(label)
        @used_names[label] = true
        @data_entries << [label, 0]
        label
      end
      @arrays[key] = elements
      # The variable itself points to the first element
      @variables[key] = elements[0]
      elements[0]
    end

    # Get the label for array element at constant index
    def func_array_element(func_name, ir_name, index)
      key = "#{func_name}::#{ir_name}"
      arr = @arrays[key]
      return nil unless arr
      return nil if index < 0 || index >= arr.length
      arr[index]
    end

    # Set a variable key to alias an existing label
    def set_alias(key, label)
      @variables[key] = label
    end

    # Mark a label as holding the address of another label
    def mark_addr_of(label, target_label)
      @addr_of_refs[label] = target_label
    end

    # Allocate a label that can be used as a goto target
    def alloc_label(name)
      name = unique_name(name) if @used_names[name]
      @used_names[name] = true
      name
    end

    # Get all variable labels for a given function (in allocation order)
    def func_all_labels(func_name)
      prefix = "#{func_name}::"
      @variables.select { |k, _| k.start_with?(prefix) }.values
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
