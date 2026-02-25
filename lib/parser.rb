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
              inst = parse_instruction($1.strip)
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
      # Strip trailing comments
      line = line.sub(/\s*;.*$/, '').strip
      return nil if line.empty?

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
      when 'sext', 'zext', 'trunc', 'bitcast', 'ptrtoint', 'inttoptr'
        parse_cast_operands(rest)
      else
        # Unknown opcode — store raw
        [Operand.new(:raw, rest)]
      end
    end

    # "i32 %a, %b" or "i32 %a, 5" or "nsw i32 %a, %b"
    def parse_arith_operands(rest)
      # Strip optional flags like nsw, nuw
      rest = rest.sub(/^(nsw|nuw|nsw nuw|nuw nsw)\s+/, '')
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

    # "i32, ptr %p, align 4"
    def parse_load_operands(rest)
      if rest =~ /^(\w+),\s*ptr\s+(.+?)(?:,\s*align\s+\d+)?$/
        [parse_value($2.strip, 'ptr')]
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

    # "i32, align 4"
    def parse_alloca_operands(rest)
      if rest =~ /^(\w+)/
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

    # "i32 @func(i32 %a, i32 %b)"
    def parse_call_operands(rest)
      if rest =~ /^(\w+)\s+@([\w.]+)\(([^)]*)\)/
        ret_type = $1
        func_name = $2
        args = $3.split(',').map(&:strip).reject(&:empty?).map do |a|
          if a =~ /^(\w+)\s+(.+)/
            parse_value($2.strip, $1)
          else
            Operand.new(:raw, a)
          end
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

    # Cast: "i32 %val to i64"
    def parse_cast_operands(rest)
      if rest =~ /^(\w+)\s+(.+)\s+to\s+(\w+)/
        [parse_value($2.strip, $1), Operand.new(:type, $3)]
      else
        [Operand.new(:raw, rest)]
      end
    end

    # Parse a single value: "%name" → var, "42" → const
    def parse_value(str, type = nil)
      if str.start_with?('%')
        Operand.new(:var, str[1..], type: type)
      elsif str =~ /^-?\d+$/
        Operand.new(:const, str.to_i, type: type)
      else
        Operand.new(:raw, str, type: type)
      end
    end
  end
end
