# frozen_string_literal: true

require_relative 'ir_nodes'

module S4C
  # Regex-based parser for LLVM IR text (.ll) files
  class Parser
    def parse(source)
      mod = IRModule.new
      lines = source.lines.map(&:chomp)
      i = 0

      while i < lines.length
        line = lines[i]

        # Global array declaration: @name = global [N x i32] [i32 v0, i32 v1, ...], align N
        if line =~ /^@([\w.]+)\s*=\s*(?:(?:common|dso_local|external|internal|private|weak)\s+)*(?:global|constant)\s+\[(\d+)\s+x\s+(\w+)\]\s+\[([^\]]+)\]/
          name = $1
          size = $2.to_i
          elem_type = $3
          # Extract values after type prefixes (e.g., "i32 50, i32 20" → [50, 20])
          values = $4.scan(/\w+\s+(-?\d+)/).flatten.map(&:to_i)
          mod.globals << { name: name, type: elem_type, array: true, size: size, values: values }
          i += 1
          next
        end

        # Global array zeroinitializer: @name = global [N x i32] zeroinitializer
        if line =~ /^@([\w.]+)\s*=\s*(?:(?:common|dso_local|external|internal|private|weak)\s+)*(?:global|constant)\s+\[(\d+)\s+x\s+(\w+)\]\s+zeroinitializer/
          name = $1
          size = $2.to_i
          elem_type = $3
          mod.globals << { name: name, type: elem_type, array: true, size: size, values: Array.new(size, 0) }
          i += 1
          next
        end

        # Global scalar declaration: @name = [common] [dso_local] global i32 VALUE, align N
        if line =~ /^@([\w.]+)\s*=\s*(?:(?:common|dso_local|external|internal|private|weak)\s+)*(?:global|constant)\s+(\w+)\s+(-?\d+)/
          name = $1
          type = $2
          value = $3.to_i
          mod.globals << { name: name, type: type, value: value }
          i += 1
          next
        end

        # Function definition
        if line =~ /^define\s+(\w+)\s+@([\w.]+)\(([^)]*)\)/
          ret_type = $1
          fname    = $2
          params   = parse_params($3)
          func = IRFunction.new(name: fname, return_type: ret_type, params: params)
          i += 1

          # Parse function body until closing }
          current_block = nil
          while i < lines.length
            line = lines[i]
            break if line.strip == '}'

            # Basic block label
            if line =~ /^([\w.]+):\s*(;.*)?$/
              current_block = BasicBlock.new($1)
              func << current_block
              i += 1
              next
            end

            # Entry block (first instruction without explicit label)
            if current_block.nil? && line =~ /^\s+\S/
              current_block = BasicBlock.new('entry')
              func << current_block
            end

            # Instruction
            if line =~ /^\s+(.+)$/
              inst_text = $1.strip
              # Handle multi-line instructions (e.g., switch with [ ... ])
              if inst_text.include?('[') && !inst_text.include?(']')
                i += 1
                while i < lines.length
                  cont = lines[i].strip
                  inst_text += " #{cont}"
                  break if cont.include?(']')
                  i += 1
                end
              end
              inst = parse_instruction(inst_text)
              current_block << inst if inst && current_block
            end

            i += 1
          end

          mod << func
        end

        i += 1
      end

      mod
    end

    private

    # Parse function parameter list: "i32 noundef %0, i32 noundef %1" → [["i32","0"], ["i32","1"]]
    # Strips parameter attributes like noundef, signext, zeroext, etc.
    PARAM_ATTRS = %w[noundef signext zeroext inreg byval sret nonnull dereferenceable nocapture readonly].freeze

    def parse_params(param_str)
      return [] if param_str.strip.empty?
      param_str.split(',').map do |p|
        parts = p.strip.split(/\s+/)
        type = parts.shift
        # Skip parameter attributes
        parts.shift while parts.any? && PARAM_ATTRS.include?(parts[0])
        name = parts[0]&.delete_prefix('%') || ""
        [type, name]
      end
    end

    # Parse a single instruction line
    def parse_instruction(line)
      # Strip trailing comments and metadata (e.g. !llvm.loop !6)
      line = line.sub(/\s*;.*$/, '').sub(/,?\s*![\w.]+\s+!\d+.*$/, '').strip
      return nil if line.empty?

      # Strip call prefixes: tail, musttail, notail
      line = line.sub(/\btail\s+call\b/, 'call')
                 .sub(/\bmusttail\s+call\b/, 'call')
                 .sub(/\bnotail\s+call\b/, 'call')

      # Assignment form: %result = opcode ...
      if line =~ /^%([\w.]+)\s*=\s*(\w+)\s+(.*)/
        result = $1
        opcode = $2
        rest   = $3
        operands = parse_operands(opcode, rest)
        return IRInstruction.new(opcode: opcode, result: result, operands: operands, raw: line)
      end

      # Void form: opcode ...
      if line =~ /^(\w+)\s+(.*)/
        opcode = $1
        rest   = $2
        operands = parse_operands(opcode, rest)
        return IRInstruction.new(opcode: opcode, operands: operands, raw: line)
      end

      nil
    end

    # Parse operands based on opcode
    def parse_operands(opcode, rest)
      case opcode
      when 'add', 'sub', 'mul', 'sdiv', 'srem',
           'and', 'or', 'xor', 'shl', 'ashr', 'lshr'
        parse_arith_operands(rest)
      when 'icmp'
        parse_icmp_operands(rest)
      when 'br'
        parse_br_operands(rest)
      when 'ret'
        parse_ret_operands(rest)
      when 'load'
        parse_load_operands(rest)
      when 'store'
        parse_store_operands(rest)
      when 'alloca'
        parse_alloca_operands(rest)
      when 'getelementptr'
        parse_gep_operands(rest)
      when 'call'
        parse_call_operands(rest)
      when 'phi'
        parse_phi_operands(rest)
      when 'switch'
        parse_switch_operands(rest)
      when 'select'
        parse_select_operands(rest)
      when 'sext', 'zext', 'trunc', 'bitcast', 'ptrtoint', 'inttoptr'
        parse_cast_operands(rest)
      else
        # Unknown opcode — store raw
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 %a, %b" or "i32 %a, 5" or "nsw i32 %a, %b"
    def parse_arith_operands(rest)
      # Strip optional flags like nsw, nuw, exact
      rest = rest.sub(/^(?:(?:nsw|nuw|exact)\s+)+/, '')
      if rest =~ /^(\w+)\s+(.+),\s*(.+)/
        type = $1
        [parse_value($2.strip, type), parse_value($3.strip, type)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "slt i32 %a, %b"
    def parse_icmp_operands(rest)
      if rest =~ /^(\w+)\s+(\w+)\s+(.+),\s*(.+)/
        pred = $1
        type = $2
        [Operand.new(:raw, pred), parse_value($3.strip, type), parse_value($4.strip, type)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i1 %cond, label %T, label %F" or "label %L"
    def parse_br_operands(rest)
      if rest =~ /^i1\s+(.+),\s*label\s+%(.+),\s*label\s+%(.*)/
        cond = parse_value($1.strip, 'i1')
        [cond, Operand.new(:label, $2.strip), Operand.new(:label, $3.strip)]
      elsif rest =~ /^label\s+%(.*)/
        [Operand.new(:label, $1.strip)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 %val" or "void"
    def parse_ret_operands(rest)
      if rest =~ /^void/
        []
      elsif rest =~ /^(\w+)\s+(.+)/
        [parse_value($2.strip, $1)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32, ptr %p, align 4" or "ptr, ptr %p, align 8"
    def parse_load_operands(rest)
      if rest =~ /^(\w+),\s*ptr\s+(.+?)(?:,\s*align\s+\d+)?$/
        load_type = $1
        [parse_value($2.strip, 'ptr'), Operand.new(:type, load_type)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 %v, ptr %p, align 4"
    def parse_store_operands(rest)
      if rest =~ /^(\w+)\s+(.+?),\s*ptr\s+(.+?)(?:,\s*align\s+\d+)?$/
        type = $1
        [parse_value($2.strip, type), parse_value($3.strip, 'ptr')]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32, align 4" or "[3 x i32], align 4"
    def parse_alloca_operands(rest)
      if rest =~ /^\[(\d+)\s*x\s*(\w+)\]/
        # Array alloca: [N x type]
        [Operand.new(:const, $1.to_i), Operand.new(:type, $2)]
      elsif rest =~ /^(\w+)/
        [Operand.new(:type, $1)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "inbounds i32, ptr %base, i32 %idx"
    def parse_gep_operands(rest)
      # Strip optional "inbounds" flag
      rest = rest.sub(/^inbounds\s+/, '')
      parts = rest.split(',').map(&:strip)
      parts.map do |p|
        if p =~ /^(\w+)\s+(.+)/
          parse_value($2.strip, $1)
        else
          Operand.new(:raw, p)
        end
      end
    end

    # "i32 @func(i32 noundef %a, i32 noundef %b)"
    def parse_call_operands(rest)
      if rest =~ /^(\w+)\s+@([\w.]+)\(([^)]*)\)/
        _ret_type = $1
        func_name = $2
        args = $3.split(',').map(&:strip).reject(&:empty?).map do |a|
          parts = a.split(/\s+/)
          type = parts.shift
          # Skip parameter attributes (noundef, signext, etc.)
          parts.shift while parts.any? && PARAM_ATTRS.include?(parts[0])
          parse_value(parts.join(' ').strip, type)
        end
        [Operand.new(:label, func_name)] + args
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 [ %val1, %bb1 ], [ %val2, %bb2 ]"
    def parse_phi_operands(rest)
      if rest =~ /^(\w+)\s+(.*)/
        type = $1
        pairs = $2.scan(/\[\s*(.+?),\s*%(.+?)\s*\]/)
        pairs.flat_map do |val, bb|
          [parse_value(val.strip, type), Operand.new(:label, bb)]
        end
      else
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 %val, label %default [ i32 1, label %L1 i32 2, label %L2 ... ]"
    def parse_switch_operands(rest)
      # Parse: i32 %val, label %default [ i32 N, label %LN ... ]
      if rest =~ /^(\w+)\s+(.+?),\s*label\s+%(\S+)\s*\[(.+)\]/m
        type = $1
        val = parse_value($2.strip, type)
        default_label = Operand.new(:label, $3.strip)
        cases_str = $4
        # Parse case pairs: i32 N, label %LN
        cases = cases_str.scan(/(\w+)\s+(-?\d+),\s*label\s+%([\w.]+)/).map do |_t, v, l|
          [Operand.new(:const, v.to_i), Operand.new(:label, l)]
        end
        [val, default_label] + cases.flatten
      else
        [Operand.new(:raw, rest)]
      end
    end

    # Select: "i1 %cond, i32 %a, i32 %b"
    def parse_select_operands(rest)
      if rest =~ /^i1\s+(.+?),\s*(\w+)\s+(.+?),\s*(\w+)\s+(.+)/
        cond = parse_value($1.strip, 'i1')
        true_val = parse_value($3.strip, $2)
        false_val = parse_value($5.strip, $4)
        [cond, true_val, false_val]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # Cast: "i32 %val to i64"
    def parse_cast_operands(rest)
      if rest =~ /^(\w+)\s+(.+)\s+to\s+(\w+)/
        [parse_value($2.strip, $1), Operand.new(:type, $3)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # Parse a single value: "%name" → var, "@name" → global, "42" → const
    def parse_value(str, type = nil)
      if str.start_with?('%')
        Operand.new(:var, str[1..], type: type)
      elsif str.start_with?('@')
        Operand.new(:global, str[1..], type: type)
      elsif str =~ /^-?\d+$/
        Operand.new(:const, str.to_i, type: type)
      else
        Operand.new(:raw, str, type: type)
      end
    end
  end
end
