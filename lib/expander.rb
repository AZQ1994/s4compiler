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
      when PPush          then expand_push(op)
      when PPop           then expand_pop(op)
      when PIndirectLoad  then expand_indirect_load(op)
      when PIndirectStore then expand_indirect_store(op)
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
      z = @mem.zero
      c_n1 = @mem.const(-1)
      t = @mem.temp
      @instructions << Subneg4.new(z, c_n1, t, 'HALT', "halt")
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

    # PPush(val, push_id):
    # Self-modifying push: write val to mem[SP], then SP -= 1
    # 1. Copy SP into C operand of write instruction
    # 2. Write val to mem[SP]  (C operand was patched)
    # 3. Decrement SP
    def expand_push(op)
      z = @mem.zero
      sp = @mem.func_var("__stack", "SP")
      one = @mem.const(1)
      c_label = "push_c_#{op.push_id}"
      # Step 1: Copy SP to the C operand of the write instruction
      @instructions << Subneg4.new(z, sp, c_label, 'NEXT', "#{op.comment} (set write addr)")
      # Step 2: Write val to mem[SP]. C operand has per-operand label, patched by step 1
      @instructions << [:push_write, z, op.val, c_label, op.comment]
      # Step 3: SP -= 1
      @instructions << Subneg4.new(one, sp, sp, 'NEXT', "#{op.comment} (SP--)")
    end

    # PPop(dst, pop_id):
    # Self-modifying pop: SP += 1, then read mem[SP] into dst
    # 1. Increment SP
    # 2. Copy SP into B operand of read instruction
    # 3. Read mem[SP] into dst (B operand was patched)
    def expand_pop(op)
      z = @mem.zero
      sp = @mem.func_var("__stack", "SP")
      c_n1 = @mem.const(-1)
      b_label = "pop_b_#{op.pop_id}"
      # Step 1: SP += 1 (SP = SP - (-1))
      @instructions << Subneg4.new(c_n1, sp, sp, 'NEXT', "#{op.comment} (SP++)")
      # Step 2: Copy SP to B operand of read instruction
      @instructions << Subneg4.new(z, sp, b_label, 'NEXT', "#{op.comment} (set read addr)")
      # Step 3: Read mem[SP] to dst
      @instructions << [:pop_read, z, b_label, op.dst, op.comment]
    end

    # PIndirectLoad(dst, addr_var, id): dst = mem[addr_var]
    # Same pattern as pop_read: patch B operand with addr_var's value, then read
    # 1. Copy addr_var into B operand of read instruction
    # 2. Read: dst = mem[addr_var] via patched B operand
    def expand_indirect_load(op)
      z = @mem.zero
      b_label = "iload_b_#{op.id}"
      # Step 1: Copy addr_var to B operand of read instruction
      @instructions << Subneg4.new(z, op.addr_var, b_label, 'NEXT', "#{op.comment} (set read addr)")
      # Step 2: Read mem[addr_var] into dst (B operand patched)
      @instructions << [:pop_read, z, b_label, op.dst, op.comment]
    end

    # PIndirectStore(addr_var, val, id): mem[addr_var] = val
    # Same pattern as push_write: patch C operand with addr_var's value, then write
    # 1. Copy addr_var into C operand of write instruction
    # 2. Write: mem[addr_var] = val via patched C operand
    def expand_indirect_store(op)
      z = @mem.zero
      c_label = "istore_c_#{op.id}"
      # Step 1: Copy addr_var to C operand of write instruction
      @instructions << Subneg4.new(z, op.addr_var, c_label, 'NEXT', "#{op.comment} (set write addr)")
      # Step 2: Write val to mem[addr_var] (C operand patched)
      @instructions << [:push_write, z, op.val, c_label, op.comment]
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
