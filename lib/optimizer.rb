# frozen_string_literal: true

require_relative 'pseudo_ops'
require 'set'

module S4C
  # Optimizes pseudo-op sequences between Lowering and Expander.
  # Runs iterative passes: GotoNext, GotoChain, RedundantBranch, Unreachable,
  # DeadLabel, ConstFold, StrengthRed, Peephole, CopyProp, DeadStore, PushPop.
  class Optimizer
    attr_reader :stats

    def initialize(pseudo_ops, memory)
      @ops = pseudo_ops.dup
      @mem = memory
      @stats = { iterations: 0, removed: 0 }
    end

    def optimize
      original_count = @ops.length

      # Pre-compute: does the program use indirect memory access?
      # If so, array elements must be protected from DSE across all iterations.
      @has_indirect = @ops.any? { |op| op.is_a?(PIndirectLoad) || op.is_a?(PIndirectStore) }

      # Pre-compute jump targets for copy propagation single-predecessor extension
      compute_jump_targets

      10.times do |i|
        @stats[:iterations] = i + 1
        changed = false
        changed |= goto_next_elimination
        changed |= goto_chain_simplification
        changed |= redundant_branch_elimination
        changed |= unreachable_code_elimination
        changed |= dead_label_elimination
        changed |= constant_folding
        changed |= strength_reduction
        changed |= peephole_double_negation
        changed |= copy_propagation
        changed |= dead_store_elimination
        changed |= push_pop_elimination
        compute_jump_targets if changed  # recompute for next iteration
        break unless changed
      end
      @stats[:removed] = original_count - @ops.length
      @ops
    end

    private

    # ── Analysis helpers ──────────────────────────────────────────────

    # Return variable names read by an op
    def reads(op)
      case op
      when PSub  then [op.a, op.b]
      when PAdd  then [op.a, op.b]
      when PCp   then [op.src]
      when PNeg  then [op.val]
      when PPush then [op.val]
      when PPop  then []
      when PIndirectLoad  then [op.addr_var]
      when PIndirectStore then [op.addr_var, op.val]
      when PGoto, PLabel, PData, PHalt, PCallSetReturn, PReturnJump
        []
      else
        []
      end
    end

    # Return variable names written by an op
    def writes(op)
      case op
      when PSub  then [op.c]
      when PAdd  then [op.c]
      when PCp   then [op.dst]
      when PPop  then [op.dst]
      when PIndirectLoad then [op.dst]
      when PNeg, PGoto, PLabel, PData, PHalt, PPush,
           PIndirectStore, PCallSetReturn, PReturnJump
        []
      else
        []
      end
    end

    # Variables that must never be eliminated by DSE
    def protected_var?(v)
      return true if v.include?('___retval')
      return true if v.include?('_arg_')
      return true if v == '__stack_SP'
      return true if v.start_with?('__mul_', '__sdiv_', '__srem_',
                                    '__shl_', '__shr_',
                                    '__and_', '__or_', '__xor_')
      return true if @mem.addr_of_refs.key?(v)
      false
    end

    # Is this op a barrier for copy propagation? (side effects on unknown memory)
    def barrier?(op)
      op.is_a?(PPush) || op.is_a?(PPop) ||
        op.is_a?(PIndirectLoad) || op.is_a?(PIndirectStore) ||
        op.is_a?(PCallSetReturn) || op.is_a?(PReturnJump)
    end

    # Is this op an unconditional control transfer?
    def unconditional_transfer?(op)
      op.is_a?(PGoto) || op.is_a?(PHalt) || op.is_a?(PReturnJump)
    end

    # Compute set of labels that are jump targets (for copy prop single-pred extension)
    def compute_jump_targets
      @jump_targets = Set.new
      @ops.each do |op|
        case op
        when PGoto then @jump_targets << op.label
        when PNeg  then @jump_targets << op.label
        when PCallSetReturn then @jump_targets << op.return_label
        end
      end
    end

    # Build inverse constant map: label_name → integer value (only true constants)
    def build_constant_map
      map = {}
      @mem.constants.each { |val, label| map[label] = val }
      map
    end

    # ── Pass 1: GotoNextElimination ───────────────────────────────────

    def goto_next_elimination
      changed = false
      result = []
      @ops.each_with_index do |op, i|
        if op.is_a?(PGoto)
          nxt = @ops[i + 1]
          if nxt.is_a?(PLabel) && nxt.name == op.label
            changed = true
            next # skip this PGoto
          end
        end
        result << op
      end
      @ops = result
      changed
    end

    # ── Pass 2: GotoChainSimplification ────────────────────────────────
    # If label L is immediately followed by PGoto(L2) (skipping consecutive labels),
    # redirect all PGoto(L) and PNeg(_, L) to L2. Resolves chains transitively.

    def goto_chain_simplification
      # Build redirect map: label → goto target (only if label's first real op is PGoto)
      redirect = {}
      i = 0
      while i < @ops.length
        if @ops[i].is_a?(PLabel)
          label_name = @ops[i].name
          j = i + 1
          j += 1 while j < @ops.length && @ops[j].is_a?(PLabel)
          if j < @ops.length && @ops[j].is_a?(PGoto)
            redirect[label_name] = @ops[j].label
          end
        end
        i += 1
      end

      return false if redirect.empty?

      # Resolve transitive chains with cycle detection
      redirect.each_key do |label|
        visited = Set.new
        current = label
        while redirect[current] && !visited.include?(current)
          visited << current
          current = redirect[current]
        end
        redirect[label] = visited.include?(current) ? label : current
      end

      # Remove self-redirects
      redirect.delete_if { |k, v| k == v }
      return false if redirect.empty?

      changed = false
      @ops = @ops.map do |op|
        case op
        when PGoto
          target = redirect[op.label]
          if target
            changed = true
            PGoto.new(target, comment: op.comment)
          else
            op
          end
        when PNeg
          target = redirect[op.label]
          if target
            changed = true
            PNeg.new(op.val, target, comment: op.comment)
          else
            op
          end
        else
          op
        end
      end
      changed
    end

    # ── Pass 3: RedundantBranchElimination ──────────────────────────────
    # PNeg(x, L) followed by PGoto(L) → both paths go to L → PGoto(L)

    def redundant_branch_elimination
      changed = false
      result = []
      @ops.each_with_index do |op, i|
        if op.is_a?(PNeg)
          nxt = @ops[i + 1]
          if nxt.is_a?(PGoto) && nxt.label == op.label
            changed = true
            next # skip PNeg, keep PGoto
          end
        end
        result << op
      end
      @ops = result
      changed
    end

    # ── Pass 4: UnreachableCodeElimination ────────────────────────────

    def unreachable_code_elimination
      changed = false
      result = []
      unreachable = false

      @ops.each do |op|
        if unreachable
          if op.is_a?(PLabel)
            unreachable = false
            result << op
          else
            changed = true # dropping unreachable op
          end
        else
          result << op
          unreachable = true if unconditional_transfer?(op)
        end
      end

      @ops = result
      changed
    end

    # ── Pass 4: DeadLabelElimination ────────────────────────────────────
    # Remove PLabel ops not referenced by any PGoto, PNeg, or PCallSetReturn.

    def dead_label_elimination
      referenced = Set.new
      @ops.each do |op|
        case op
        when PGoto then referenced << op.label
        when PNeg  then referenced << op.label
        when PCallSetReturn then referenced << op.return_label
        end
      end

      first_label = @ops.find { |op| op.is_a?(PLabel) }

      changed = false
      result = @ops.select do |op|
        if op.is_a?(PLabel) && op != first_label && !referenced.include?(op.name)
          changed = true
          false
        else
          true
        end
      end

      @ops = result
      changed
    end

    # ── Pass 5: ConstantFolding ───────────────────────────────────────
    # Only folds operations where BOTH operands are true constants
    # (from memory.constants). Does NOT propagate constants through copies
    # to avoid unsoundness across control flow boundaries.

    def constant_folding
      changed = false
      const_map = build_constant_map

      result = @ops.map do |op|
        case op
        when PAdd
          va = const_map[op.a]
          vb = const_map[op.b]
          if va && vb
            sum = va + vb
            label = @mem.const(sum)
            const_map[label] = sum
            changed = true
            PCp.new(op.c, label, comment: "#{op.comment} [folded #{va}+#{vb}=#{sum}]")
          else
            op
          end

        when PSub
          va = const_map[op.a]
          vb = const_map[op.b]
          if va && vb
            diff = vb - va  # PSub: c = b - a
            label = @mem.const(diff)
            const_map[label] = diff
            changed = true
            PCp.new(op.c, label, comment: "#{op.comment} [folded #{vb}-#{va}=#{diff}]")
          else
            op
          end

        when PNeg
          vv = const_map[op.val]
          if vv
            if vv < 0
              changed = true
              PGoto.new(op.label, comment: "#{op.comment} [folded: #{vv}<0 always]")
            else
              # Never taken → delete
              changed = true
              nil
            end
          else
            op
          end

        else
          op
        end
      end

      @ops = result.compact
      changed
    end

    # ── Pass 6: StrengthReduction ──────────────────────────────────────
    # Replace arithmetic with zero operands with cheaper PCp ops.

    def strength_reduction
      changed = false
      const_map = build_constant_map
      zero_labels = Set.new
      const_map.each { |label, val| zero_labels << label if val == 0 }

      result = @ops.map do |op|
        case op
        when PAdd
          if zero_labels.include?(op.a)
            # PAdd(ZERO, x, c) → c = x + 0 = x
            changed = true
            PCp.new(op.c, op.b, comment: op.comment)
          elsif zero_labels.include?(op.b)
            # PAdd(x, ZERO, c) → c = 0 + x = x
            changed = true
            PCp.new(op.c, op.a, comment: op.comment)
          else
            op
          end
        when PSub
          if zero_labels.include?(op.a)
            # PSub(ZERO, x, c) → c = x - 0 = x
            changed = true
            PCp.new(op.c, op.b, comment: op.comment)
          elsif op.a == op.b
            # PSub(x, x, c) → c = x - x = 0
            changed = true
            PCp.new(op.c, @mem.zero, comment: op.comment)
          else
            op
          end
        else
          op
        end
      end

      @ops = result
      changed
    end

    # ── Pass 8: PeepholeDoubleNegation ──────────────────────────────────
    # PSub(x, ZERO, t); PSub(t, ZERO, r) → t=-x; r=-(-x)=x → PCp(r, x)

    def peephole_double_negation
      changed = false
      const_map = build_constant_map
      zero_labels = Set.new
      const_map.each { |label, val| zero_labels << label if val == 0 }

      result = []
      i = 0
      while i < @ops.length
        op = @ops[i]
        nxt = @ops[i + 1]
        if op.is_a?(PSub) && nxt.is_a?(PSub) &&
           zero_labels.include?(op.b) && zero_labels.include?(nxt.b) &&
           op.c == nxt.a
          # op:  PSub(x, ZERO, t) → t = -x
          # nxt: PSub(t, ZERO, r) → r = -t = x
          result << op  # keep first negation (DSE removes if t unused)
          result << PCp.new(nxt.c, op.a, comment: nxt.comment)
          changed = true
          i += 2
        else
          result << op
          i += 1
        end
      end

      @ops = result
      changed
    end

    # ── Pass 9: CopyPropagation ───────────────────────────────────────
    # Single-pass forward substitution within straight-line blocks.
    # Resets substitution map at PLabel and barrier boundaries.
    # Extension: keeps subst alive across PLabel with single fallthrough predecessor.

    def copy_propagation
      changed = false
      subst = {}
      result = []
      prev_falls_through = true  # track if previous op falls through

      @ops.each do |op|
        # At block boundaries: reset unless single fallthrough predecessor
        if op.is_a?(PLabel)
          if @jump_targets.include?(op.name) || !prev_falls_through
            subst = {}
          end
          result << op
          prev_falls_through = true
          next
        end

        if barrier?(op)
          # Apply substitutions to this barrier op's reads, then reset
          modified = substitute_reads(op, subst)
          changed = true if modified != op
          result << modified
          subst = {}
          next
        end

        # Apply current substitutions to reads
        modified = substitute_reads(op, subst)
        changed = true if modified != op
        result << modified

        # Update substitution map based on writes
        writes(modified).each do |w|
          # Invalidate substitutions whose source is being overwritten
          subst.delete_if { |_t, src| src == w }
          # Remove the old substitution for this destination
          subst.delete(w)
        end

        # If this is a PCp, register new substitution
        if modified.is_a?(PCp)
          subst[modified.dst] = modified.src
        end

        # Reset substitutions after unconditional transfers and conditional branches
        if unconditional_transfer?(op) || op.is_a?(PNeg)
          prev_falls_through = unconditional_transfer?(op) ? false : true
          subst = {}
        else
          prev_falls_through = true
        end
      end

      # Remove self-copies PCp(x, x)
      before = result.length
      result.reject! { |op| op.is_a?(PCp) && op.dst == op.src }
      changed = true if result.length != before

      @ops = result
      changed
    end

    # Replace reads in an op using the substitution map
    def substitute_reads(op, subst)
      return op if subst.empty?

      case op
      when PSub
        a2 = subst[op.a] || op.a
        b2 = subst[op.b] || op.b
        (a2 != op.a || b2 != op.b) ? PSub.new(a2, b2, op.c, comment: op.comment) : op

      when PAdd
        a2 = subst[op.a] || op.a
        b2 = subst[op.b] || op.b
        (a2 != op.a || b2 != op.b) ? PAdd.new(a2, b2, op.c, comment: op.comment) : op

      when PCp
        s2 = subst[op.src] || op.src
        s2 != op.src ? PCp.new(op.dst, s2, comment: op.comment) : op

      when PNeg
        v2 = subst[op.val] || op.val
        v2 != op.val ? PNeg.new(v2, op.label, comment: op.comment) : op

      when PPush
        v2 = subst[op.val] || op.val
        v2 != op.val ? PPush.new(v2, op.push_id, comment: op.comment) : op

      when PIndirectLoad
        a2 = subst[op.addr_var] || op.addr_var
        a2 != op.addr_var ? PIndirectLoad.new(op.dst, a2, op.id, comment: op.comment) : op

      when PIndirectStore
        a2 = subst[op.addr_var] || op.addr_var
        v2 = subst[op.val] || op.val
        (a2 != op.addr_var || v2 != op.val) ? PIndirectStore.new(a2, v2, op.id, comment: op.comment) : op

      else
        op
      end
    end

    # ── Pass 8: DeadStoreElimination ──────────────────────────────────

    def dead_store_elimination
      # Build global set of all variables that are ever read
      used = Set.new
      @ops.each do |op|
        reads(op).each { |v| used << v }
      end

      # Also mark special references as used
      @ops.each do |op|
        case op
        when PGoto then used << op.label
        when PNeg  then used << op.label
        when PCallSetReturn
          used << op.ret_d_label
          used << op.return_label
        when PReturnJump then used << op.d_label
        end
      end

      # If program uses indirect memory access, protect all variables that
      # could be targets of computed pointers (array elements, addr_of targets)
      if @has_indirect
        # Protect all targets of address-of references
        @mem.addr_of_refs.each_value { |target| used << target }
        # Protect all array element variables (pattern: *_arr_*_N)
        @mem.data_entries.each do |label, _|
          used << label if label.include?('_arr_')
        end
      end

      changed = false
      result = @ops.select do |op|
        w = writes(op)
        if w.empty?
          true # no writes → keep
        elsif w.all? { |v| !used.include?(v) && !protected_var?(v) }
          changed = true
          false
        else
          true
        end
      end

      @ops = result
      changed
    end

    # ── Pass 11: PushPopElimination ──────────────────────────────────
    # Remove PPush/PPop pairs where the restored value is never used.
    # Standard DSE can't catch this because PPush reads the variable,
    # creating a circular dependency. We break it by excluding PPush reads.

    def push_pop_elimination
      # Build used set excluding PPush reads to break circular dependency
      used_without_push = Set.new
      @ops.each do |op|
        next if op.is_a?(PPush)
        reads(op).each { |v| used_without_push << v }
      end

      # Also include special references
      @ops.each do |op|
        case op
        when PGoto then used_without_push << op.label
        when PNeg  then used_without_push << op.label
        when PCallSetReturn
          used_without_push << op.ret_d_label
          used_without_push << op.return_label
        when PReturnJump then used_without_push << op.d_label
        end
      end

      # Find removable PPop indices
      removable_pop_indices = Set.new
      @ops.each_with_index do |op, i|
        if op.is_a?(PPop) && !used_without_push.include?(op.dst) && !protected_var?(op.dst)
          removable_pop_indices << i
        end
      end

      return false if removable_pop_indices.empty?

      # For each removable PPop, find the matching PPush
      removable_push_indices = Set.new
      removable_pop_indices.each do |pop_idx|
        pop_op = @ops[pop_idx]
        # Extract call_id from pop_id (format: "C_rN")
        call_id = pop_op.pop_id.sub(/_r\d+$/, '')
        var = pop_op.dst

        # Search backwards for matching PPush (same call_id, same variable)
        (0...pop_idx).reverse_each do |j|
          push_op = @ops[j]
          if push_op.is_a?(PPush) && push_op.val == var
            push_call_id = push_op.push_id.sub(/_s\d+$/, '')
            if push_call_id == call_id
              removable_push_indices << j
              break
            end
          end
        end
      end

      # Remove marked ops
      to_remove = removable_pop_indices | removable_push_indices
      @ops = @ops.each_with_index.reject { |_, i| to_remove.include?(i) }.map(&:first)
      true
    end
  end
end
