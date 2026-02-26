# frozen_string_literal: true

require_relative 'pseudo_ops'
require 'set'

module S4C
  # Optimizes pseudo-op sequences between Lowering and Expander.
  # Runs iterative passes: GotoNext, GotoChain, RedundantBranch, Unreachable,
  # DeadLabel, ConstFold, StrengthRed, Peephole, LVN, LICM, CopyProp, DeadStore, PushPop.
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
      @has_indirect = @ops.any? { |op| op.is_a?(PIndirectLoad) || op.is_a?(PIndirectStore) || op.is_a?(PIndirectLoadSubNeg) }

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
        changed |= add_to_sub_conversion
        changed |= peephole_double_negation
        changed |= cmp_branch_fusion
        changed |= indirect_load_subneg_fusion
        changed |= local_value_numbering
        changed |= gep_address_reuse
        changed |= loop_invariant_code_motion
        changed |= loop_rotation
        changed |= loop_add_to_sub
        changed |= tail_call_elimination
        changed |= write_destination_forwarding
        changed |= copy_propagation
        changed |= phi_coalescing
        changed |= arg_local_aliasing
        changed |= dead_store_elimination
        changed |= local_dead_store_elimination
        changed |= liveness_push_pop_elimination
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
      when PSub     then [op.a, op.b]
      when PSubNeg  then [op.a, op.b]
      when PAdd     then [op.a, op.b]
      when PCp      then [op.src]
      when PNeg     then [op.val]
      when PPush    then [op.val]
      when PPop     then []
      when PIndirectLoad  then [op.addr_var]
      when PIndirectLoadSubNeg then [op.addr_var, op.cmp_val]
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
      when PSubNeg, PNeg, PGoto, PLabel, PData, PHalt, PPush,
           PIndirectStore, PIndirectLoadSubNeg, PCallSetReturn, PReturnJump
        []
      else
        []
      end
    end

    # Variables that must never be eliminated by DSE
    def protected_var?(v)
      return true if v.include?('___retval')
      return true if v.include?('_arg_')
      return true if v.end_with?('_ret_d')
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
        op.is_a?(PIndirectLoad) || op.is_a?(PIndirectLoadSubNeg) || op.is_a?(PIndirectStore) ||
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
        when PGoto   then @jump_targets << op.label
        when PNeg    then @jump_targets << op.label
        when PSubNeg then @jump_targets << op.label
        when PIndirectLoadSubNeg then @jump_targets << op.label
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
        nxt = @ops[i + 1]
        if op.is_a?(PGoto)
          if nxt.is_a?(PLabel) && nxt.name == op.label
            changed = true
            next # skip this PGoto — jumping to next instruction
          end
        elsif op.is_a?(PSubNeg)
          if nxt.is_a?(PLabel) && nxt.name == op.label
            # PSubNeg(a, b, NEXT) → branch target is next instruction → no-op
            changed = true
            next
          end
        elsif op.is_a?(PNeg)
          if nxt.is_a?(PLabel) && nxt.name == op.label
            # PNeg(v, NEXT) → branch target is next instruction → no-op
            changed = true
            next
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
        when PSubNeg
          target = redirect[op.label]
          if target
            changed = true
            PSubNeg.new(op.a, op.b, target, comment: op.comment)
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
        elsif op.is_a?(PSubNeg)
          nxt = @ops[i + 1]
          if nxt.is_a?(PGoto) && nxt.label == op.label
            changed = true
            next # skip PSubNeg, keep PGoto
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
        when PGoto   then referenced << op.label
        when PNeg    then referenced << op.label
        when PSubNeg then referenced << op.label
        when PIndirectLoadSubNeg then referenced << op.label
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

        when PSubNeg
          va = const_map[op.a]
          vb = const_map[op.b]
          if va && vb
            diff = vb - va  # result = b - a
            if diff < 0
              changed = true
              PGoto.new(op.label, comment: "#{op.comment} [folded: #{vb}-#{va}=#{diff}<0 always]")
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
        when PSubNeg
          if zero_labels.include?(op.a)
            # PSubNeg(ZERO, b, L) → test if b < 0 → PNeg(b, L)
            changed = true
            PNeg.new(op.b, op.label, comment: op.comment)
          elsif op.a == op.b
            # PSubNeg(x, x, L) → x - x = 0, never negative → delete
            changed = true
            nil
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

    # ── Pass: AddToSubConversion ──────────────────────────────────────
    # PAdd(const, b, c) → PSub(neg_const, b, c): 2 SUBNEG4 → 1 SUBNEG4.
    # When 'a' is a known constant, we can negate it at compile time and use PSub.

    def add_to_sub_conversion
      changed = false
      const_map = build_constant_map

      result = @ops.map do |op|
        if op.is_a?(PAdd)
          va = const_map[op.a]
          vb = const_map[op.b]
          if va
            # PAdd(const, b, c) → c = b + const → PSub(-const, b, c) = b - (-const)
            neg_label = @mem.const(-va)
            changed = true
            PSub.new(neg_label, op.b, op.c, comment: "#{op.comment} [add→sub: +#{va}]")
          elsif vb
            # PAdd(a, const, c) → c = const + a → PSub(-const, a, c) = a - (-const)
            neg_label = @mem.const(-vb)
            changed = true
            PSub.new(neg_label, op.a, op.c, comment: "#{op.comment} [add→sub: +#{vb}]")
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

    # ── Pass 9: LocalValueNumbering ──────────────────────────────────
    # Within-block CSE: detect identical computations and replace with PCp.

    def local_value_numbering
      changed = false
      value_map = {}   # signature → result variable
      result = []

      @ops.each do |op|
        # Reset at block boundaries
        if op.is_a?(PLabel) || barrier?(op) || unconditional_transfer?(op) || op.is_a?(PNeg) || op.is_a?(PSubNeg)
          result << op
          value_map = {} if op.is_a?(PLabel) || barrier?(op) || unconditional_transfer?(op)
          next
        end

        # Invalidate entries whose result or operands reference a variable
        # being written by this op (must happen BEFORE signature check so
        # stale entries are cleared, but AFTER which new entries can be added)
        writes(op).each do |w|
          value_map.delete_if { |sig, res| res == w || sig.split(':').include?(w) }
        end

        sig = value_signature(op)
        if sig && value_map[sig]
          # Redundant computation → replace with copy
          dst = writes(op).first
          if dst
            changed = true
            result << PCp.new(dst, value_map[sig], comment: "#{op.comment} [LVN]")
          else
            result << op
          end
        else
          result << op
          # Register this computation
          if sig
            dst = writes(op).first
            value_map[sig] = dst if dst
          end
        end
      end

      @ops = result
      changed
    end

    # Compute a canonical value signature for CSE
    def value_signature(op)
      case op
      when PAdd
        # Commutative: sort operands
        "ADD:#{[op.a, op.b].sort.join(':')}"
      when PSub
        # Non-commutative: preserve order (c = b - a)
        "SUB:#{op.a}:#{op.b}"
      when PCp
        # Copy from same source → reuse
        "CP:#{op.src}"
      else
        nil
      end
    end

    # ── Pass: GepAddressReuse ───────────────────────────────────────
    # Within a basic block, if PAdd(x, y, addr1) is followed by PAdd(x, y, addr2)
    # with the same operands (and no intervening writes to x, y, or addr1),
    # replace the second PAdd with PCp(addr2, addr1).
    # Saves 1 SUBNEG4 per reuse (PAdd=2 → PCp=1).

    def gep_address_reuse
      changed = false
      addr_cache = {} # [sorted(canonical_a, canonical_b)] → result_label

      # Build canonical name map: labels with same addr-of target are equivalent
      canon = {}
      @mem.addr_of_refs.each do |label, target|
        canon[label] = target
      end

      normalize = ->(v) { canon[v] || v }

      result = @ops.map do |op|
        # Reset cache at unconditional control flow and merge points.
        # Conditional branches (PSubNeg, PNeg) don't clear: fall-through
        # path retains valid cache; taken path lands on PLabel which clears.
        if op.is_a?(PLabel) || op.is_a?(PGoto) ||
           op.is_a?(PReturnJump) || op.is_a?(PHalt)
          addr_cache.clear
          op
        elsif op.is_a?(PAdd)
          key = [:add, *[normalize[op.a], normalize[op.b]].sort]
          if addr_cache.key?(key) && addr_cache[key] != op.c
            changed = true
            PCp.new(op.c, addr_cache[key], comment: "#{op.comment} [addr reuse]")
          else
            addr_cache[key] = op.c
            op
          end
        elsif op.is_a?(PSub) && op.b != "ZERO"
          # PSub(a, b, c) computes c = b - a; not commutative, so key is ordered
          key = [:sub, normalize[op.a], normalize[op.b]]
          if addr_cache.key?(key) && addr_cache[key] != op.c
            changed = true
            PCp.new(op.c, addr_cache[key], comment: "#{op.comment} [addr reuse]")
          else
            addr_cache[key] = op.c
            op
          end
        else
          # Invalidate cache entries whose result or operands are overwritten
          written = writes(op)
          unless written.empty?
            addr_cache.reject! do |k, v|
              written.any? { |w| k.include?(normalize[w]) || k.include?(w) || v == w }
            end
          end
          op
        end
      end

      @ops = result
      changed
    end

    # ── Pass 10: LoopInvariantCodeMotion ─────────────────────────────
    # Hoist loop-invariant operations to just before the loop header.

    def loop_invariant_code_motion
      # Find back-edges: PGoto(L) where PLabel(L) appears earlier
      label_positions = {}
      @ops.each_with_index do |op, i|
        label_positions[op.name] = i if op.is_a?(PLabel)
      end

      back_edges = []
      @ops.each_with_index do |op, i|
        if op.is_a?(PGoto) && label_positions[op.label] && label_positions[op.label] < i
          # Skip function calls: PGoto preceded by PCallSetReturn is a call, not a loop
          prev = i > 0 ? @ops[i - 1] : nil
          next if prev.is_a?(PCallSetReturn)
          # Skip jumps to function entries (tail calls, not loops)
          next if op.label.start_with?("func_")
          back_edges << { header: label_positions[op.label], tail: i, label: op.label }
        end
      end

      # Also detect conditional back-edges (PSubNeg/PNeg branching to an earlier label).
      # These arise from rotated loops where the back-edge is a conditional branch.
      cond_back_edges = []
      @ops.each_with_index do |op, i|
        next unless op.is_a?(PSubNeg) || op.is_a?(PNeg)
        target = label_positions[op.label]
        next unless target && target < i
        cond_back_edges << { header: target, tail: i }
      end

      return false if back_edges.empty?

      # Sort by header position descending (process inner loops first)
      back_edges.sort_by! { |e| -e[:header] }

      changed = false
      back_edges.each do |edge|
        header_idx = edge[:header]
        tail_idx = edge[:tail]

        # Collect variables defined inside the loop
        loop_defs = Set.new
        has_call = false
        (header_idx..tail_idx).each do |i|
          writes(@ops[i]).each { |v| loop_defs << v }
          has_call = true if @ops[i].is_a?(PCallSetReturn)
        end

        # If loop contains subroutine calls, their shared result variables
        # (e.g. __mul_result, __srem_remainder) are modified outside the loop
        # body's index range. Treat all __-prefixed vars as loop-variant.
        if has_call
          @ops.each do |op|
            (reads(op) + writes(op)).each do |v|
              loop_defs << v if v.start_with?('__')
            end
          end
        end

        # Count how many times each variable is written in the loop
        write_counts = Hash.new(0)
        (header_idx..tail_idx).each do |i|
          writes(@ops[i]).each { |v| write_counts[v] += 1 }
        end

        # Find loop-invariant ops
        const_map = build_constant_map
        hoistable = []

        ((header_idx + 1)..tail_idx).each do |i|
          op = @ops[i]
          next unless op.is_a?(PAdd) || op.is_a?(PSub) || op.is_a?(PCp)

          # Check: all reads are loop-invariant (not defined in loop OR constant)
          all_reads_invariant = reads(op).all? { |v| !loop_defs.include?(v) || const_map[v] }

          # Check: destination written only once in the loop
          # Also: subroutine-shared vars (__*) can be modified by calls
          dst = writes(op).first
          next unless dst
          single_write = write_counts[dst] == 1
          next if has_call && dst.start_with?('__')

          if all_reads_invariant && single_write
            hoistable << i
          end
        end

        next if hoistable.empty?

        # Safety: don't hoist if the insert position (just before header) falls
        # inside another loop's body. This can happen with rotated loops where
        # the code before the header is an inner loop body.
        inside_other = cond_back_edges.any? do |cb|
          cb[:header] < header_idx && header_idx <= cb[:tail]
        end
        inside_other ||= back_edges.any? do |other|
          next false if other[:header] == header_idx && other[:tail] == tail_idx
          other[:header] < header_idx && header_idx <= other[:tail]
        end
        next if inside_other

        # Hoist: move ops to just before the header
        hoisted_ops = hoistable.map { |i| @ops[i] }
        hoistable.sort.reverse.each { |i| @ops.delete_at(i) }

        # Recalculate header position (indices shifted by deletions before header)
        deletions_before_header = hoistable.count { |i| i < header_idx }
        insert_pos = header_idx - deletions_before_header

        hoisted_ops.reverse.each { |op| @ops.insert(insert_pos, op) }
        changed = true
        break # Indices are stale after modification; re-detect loops on next iteration
      end

      changed
    end

    # ── Pass: LoopAddToSub ─────────────────────────────────────────
    # For PAdd(variant, invariant, result) inside loops where one operand
    # is never written (e.g., address-of constants like &data), precompute
    # the negation of the invariant operand at function entry and replace
    # PAdd with PSub.  Saves 1 SUBNEG4 per PAdd execution (PAdd=2 → PSub=1).

    def loop_add_to_sub
      # Collect all variables written by any instruction
      written_vars = Set.new
      @ops.each { |op| writes(op).each { |v| written_vars << v } }

      # Detect tight inner loops: conditional back-edges only
      # (PSubNeg/PNeg/PIndirectLoadSubNeg branching backward)
      # These are the hot scan loops; PGoto back-edges are outer loops
      # where gep_address_reuse handles address sharing better.
      label_positions = {}
      @ops.each_with_index { |op, i| label_positions[op.name] = i if op.is_a?(PLabel) }

      in_inner_loop = Array.new(@ops.length, false)
      inner_loop_headers = []  # earliest header positions for insertion
      @ops.each_with_index do |op, i|
        next unless op.is_a?(PSubNeg) || op.is_a?(PNeg) || op.is_a?(PIndirectLoadSubNeg)
        target = label_positions[op.label]
        next unless target.is_a?(Integer) && target < i
        (target..i).each { |j| in_inner_loop[j] = true }
        inner_loop_headers << target
      end

      return false if inner_loop_headers.empty?

      const_map = build_constant_map

      # Deduplicate invariant variables by addr_of_refs target
      addr_of = @mem.addr_of_refs
      canonical = {}  # invariant_var → canonical representative
      addr_of.each do |label, target|
        next if written_vars.include?(label)
        next if const_map[label]
        key = target
        canonical[label] = key
      end

      neg_cache = {}  # canonical_key → neg_var
      changed = false

      @ops = @ops.map.with_index do |op, i|
        next op unless in_inner_loop[i] && op.is_a?(PAdd)

        a_const = !written_vars.include?(op.a) && !const_map[op.a]
        b_const = !written_vars.include?(op.b) && !const_map[op.b]

        invariant, variant = if a_const && !b_const
                               [op.a, op.b]
                             elsif b_const && !a_const
                               [op.b, op.a]
                             end
        next op unless invariant

        # Use canonical key for deduplication
        key = canonical[invariant] || invariant
        neg_cache[key] ||= { neg_var: @mem.temp, first_invariant: invariant }
        neg_var = neg_cache[key][:neg_var]
        changed = true
        PSub.new(neg_var, variant, op.c, comment: "#{op.comment} [add→sub]")
      end

      return false unless changed

      # Insert precomputations just before the earliest inner loop header.
      # This is after any base-case early-return checks but before the
      # outer loop entry, so base-case calls skip the precomputation.
      earliest_header = inner_loop_headers.min
      # Find the PGoto entry that jumps to the inner loop area (just before the header)
      insert_pos = earliest_header
      # Walk backward to find the PGoto entry for this loop region
      (earliest_header - 1).downto(0) do |j|
        if @ops[j].is_a?(PGoto) && label_positions[@ops[j].label] &&
           label_positions[@ops[j].label] >= earliest_header
          insert_pos = j
          break
        end
      end

      neg_cache.each_value do |info|
        @ops.insert(insert_pos, PSub.new(info[:first_invariant], "ZERO", info[:neg_var],
              comment: "precompute -#{info[:first_invariant]}"))
        insert_pos += 1
      end

      # Phase 2: Also convert PAdds outside inner loops that can reuse
      # the precomputed negation (e.g., swap block address computations).
      # After Phase 1, all inner-loop PAdds are already PSubs, so any
      # remaining PAdds after the precomputation point are outer-loop only.
      # Deduplicates within basic blocks: if two PAdds compute the same
      # address (same invariant key + same variant), the second becomes PCp.
      phase2_addr_cache = {}  # [canonical_key, variant] → result_var
      @ops = @ops.map.with_index do |op, i|
        # Clear cache at control flow boundaries
        if op.is_a?(PLabel) || op.is_a?(PGoto) || op.is_a?(PReturnJump) || op.is_a?(PHalt)
          phase2_addr_cache.clear
          next op
        end
        # Invalidate on writes to variant variables
        w = writes(op)
        w.each { |v| phase2_addr_cache.reject! { |k, _| k[1] == v } } unless w.empty?

        next op if i < insert_pos  # before precomputation
        next op unless op.is_a?(PAdd)

        a_const = !written_vars.include?(op.a) && !const_map[op.a]
        b_const = !written_vars.include?(op.b) && !const_map[op.b]

        invariant, variant = if a_const && !b_const
                               [op.a, op.b]
                             elsif b_const && !a_const
                               [op.b, op.a]
                             end
        next op unless invariant

        key = canonical[invariant] || invariant
        next op unless neg_cache[key]  # only if precomputation exists

        cache_key = [key, variant]
        if phase2_addr_cache[cache_key] && phase2_addr_cache[cache_key] != op.c
          # Duplicate address: reuse earlier result instead of recomputing
          PCp.new(op.c, phase2_addr_cache[cache_key], comment: "#{op.comment} [addr reuse]")
        else
          neg_var = neg_cache[key][:neg_var]
          phase2_addr_cache[cache_key] = op.c
          PSub.new(neg_var, variant, op.c, comment: "#{op.comment} [add→sub]")
        end
      end

      true
    end

    # ── Pass: LoopRotation ─────────────────────────────────────────
    # Convert header-tested loops to tail-tested, eliminating the
    # back-edge PGoto.  Pattern:
    #   L_header: [test ops] PSubNeg/PNeg → L_body; PGoto L_exit
    #   L_body:   [body ops] PGoto L_header
    # Becomes:
    #   PGoto L_header;  L_body: [body ops]  L_header: [test ops] PSubNeg/PNeg → L_body
    # Saves 1 PGoto (1 SUBNEG4) per iteration.

    def loop_rotation
      label_pos = {}
      @ops.each_with_index { |op, i| label_pos[op.name] = i if op.is_a?(PLabel) }

      # Find back-edges and verify the rotation pattern
      rotations = []
      @ops.each_with_index do |op, i|
        next unless op.is_a?(PGoto)
        header_idx = label_pos[op.label]
        next unless header_idx && header_idx < i  # back-edge

        info = detect_rotatable_loop(header_idx, i)
        rotations << info if info
      end

      return false if rotations.empty?

      # Remove overlapping rotations (keep first)
      rotations.sort_by! { |r| r[:header_idx] }
      filtered = [rotations[0]]
      rotations[1..].each do |r|
        filtered << r if r[:header_idx] > filtered.last[:backedge_idx]
      end

      # Build new ops array
      result = []
      skip_ranges = {}
      filtered.each { |r| (r[:header_idx]..r[:backedge_idx]).each { |j| skip_ranges[j] = r } }

      i = 0
      while i < @ops.length
        rot = skip_ranges[i]
        if rot && i == rot[:header_idx]
          # Emit rotated loop
          result << PGoto.new(rot[:header_label], comment: "loop rotation entry")
          result << PLabel.new(rot[:body_label], comment: @ops[rot[:body_label_idx]].comment)
          rot[:body_range].each { |j| result << @ops[j] }
          result << PLabel.new(rot[:header_label], comment: @ops[rot[:header_idx]].comment)
          rot[:test_range].each { |j| result << @ops[j] }
          result << @ops[rot[:cond_idx]]
          i = rot[:backedge_idx] + 1
        elsif skip_ranges[i]
          i += 1  # inside a rotated range, skip
        else
          result << @ops[i]
          i += 1
        end
      end

      @ops = result
      true
    end

    def detect_rotatable_loop(header_idx, backedge_idx)
      header_label = @ops[header_idx].name

      # Scan test ops: header+1 until we find PSubNeg or PNeg
      cond_idx = nil
      ((header_idx + 1)..backedge_idx).each do |j|
        op = @ops[j]
        if op.is_a?(PSubNeg) || op.is_a?(PNeg)
          cond_idx = j
          break
        end
        # Test ops must be simple (no labels, gotos, branches)
        return nil if op.is_a?(PLabel) || op.is_a?(PGoto) || op.is_a?(PHalt)
      end
      return nil unless cond_idx

      # Next must be PGoto L_exit
      exit_idx = cond_idx + 1
      return nil unless exit_idx < @ops.length && @ops[exit_idx].is_a?(PGoto)
      exit_label = @ops[exit_idx].label

      # Next must be PLabel L_body (conditional branch target)
      body_label_idx = exit_idx + 1
      return nil unless body_label_idx < @ops.length && @ops[body_label_idx].is_a?(PLabel)
      body_label = @ops[body_label_idx].name

      # Conditional branch must target L_body
      cond_target = @ops[cond_idx].label
      return nil unless cond_target == body_label

      # Body ops: body_label_idx+1 to backedge_idx-1 (must be simple)
      ((body_label_idx + 1)...backedge_idx).each do |j|
        op = @ops[j]
        return nil if op.is_a?(PLabel) || op.is_a?(PGoto) || op.is_a?(PNeg) ||
                       op.is_a?(PSubNeg) || op.is_a?(PHalt)
      end

      # Back-edge must jump to header
      return nil unless @ops[backedge_idx].label == header_label

      # After back-edge must be L_exit (for fall-through to work)
      after_idx = backedge_idx + 1
      return nil unless after_idx < @ops.length && @ops[after_idx].is_a?(PLabel)
      return nil unless @ops[after_idx].name == exit_label

      {
        header_idx: header_idx,
        header_label: header_label,
        cond_idx: cond_idx,
        body_label_idx: body_label_idx,
        body_label: body_label,
        backedge_idx: backedge_idx,
        test_range: ((header_idx + 1)...cond_idx).to_a,
        body_range: ((body_label_idx + 1)...backedge_idx).to_a,
      }
    end

    # ── Pass: TailCallElimination ──────────────────────────────────
    # Replace tail-position function calls (call followed by return) with
    # a direct jump, eliminating push/pop save/restore overhead.
    # Pattern: [PPush...] [arg PCp...] PCallSetReturn PGoto(func_F)
    #          PLabel(ret) [PCp result?] [PPop...] [PCp/PLabel...] PReturnJump
    # → [arg PCp...] PGoto(func_F)  (subsequent passes clean up dead code)

    def tail_call_elimination
      changed = false

      # Find PCallSetReturn positions (process last-to-first for tail call priority)
      indices = []
      @ops.each_with_index { |op, i| indices << i if op.is_a?(PCallSetReturn) }

      indices.reverse_each do |call_set_idx|
        csr = @ops[call_set_idx]

        # PGoto must follow (the actual call jump)
        goto_idx = call_set_idx + 1
        next unless goto_idx < @ops.length && @ops[goto_idx].is_a?(PGoto)
        call_target = @ops[goto_idx].label
        next unless call_target.start_with?('func_')

        # PLabel(return_label) must follow PGoto
        ret_label_idx = goto_idx + 1
        next unless ret_label_idx < @ops.length &&
                    @ops[ret_label_idx].is_a?(PLabel) &&
                    @ops[ret_label_idx].name == csr.return_label

        # Skip optional result copies (PCp between return label and pops)
        j = ret_label_idx + 1
        j += 1 while j < @ops.length && @ops[j].is_a?(PCp)

        # Collect PPop sequence
        pop_start = j
        pop_end = j
        pop_end += 1 while pop_end < @ops.length && @ops[pop_end].is_a?(PPop)
        next if pop_start == pop_end

        # Find PReturnJump scanning through only PCp and PLabel
        ret_jump_idx = nil
        j = pop_end
        while j < @ops.length
          if @ops[j].is_a?(PReturnJump)
            ret_jump_idx = j
            break
          elsif @ops[j].is_a?(PCp) || @ops[j].is_a?(PLabel)
            j += 1
          else
            break
          end
        end
        next unless ret_jump_idx

        our_ret_d = @ops[ret_jump_idx].d_label
        callee_ret_d = csr.ret_d_label

        # Walk backward from PCallSetReturn: arg setups (PCp) then pushes (PPush)
        j = call_set_idx - 1
        j -= 1 while j >= 0 && @ops[j].is_a?(PCp)
        arg_start = j + 1

        j -= 1 while j >= 0 && @ops[j].is_a?(PPush)
        push_start = j + 1

        push_count = arg_start - push_start
        pop_count = pop_end - pop_start
        next if push_count == 0
        next unless push_count == pop_count

        # Build replacement: arg setups + optional ret_d forward + tail jump
        replacement = (arg_start...call_set_idx).map { |k| @ops[k] }

        unless our_ret_d == callee_ret_d
          # Cross-function tail call: forward our return address to callee
          replacement << PCp.new(callee_ret_d, our_ret_d, comment: "tail call: forward return addr")
        end

        replacement << PGoto.new(call_target, comment: "#{@ops[goto_idx].comment} [tail call]")

        # Replace [push_start..goto_idx] with replacement
        @ops = @ops[0...push_start] + replacement + @ops[(goto_idx + 1)..]
        changed = true
        break # indices stale; let iterative optimizer handle remaining
      end

      changed
    end

    # ── Pass: WriteDestinationForwarding ─────────────────────────────
    # If an instruction writes to X and the next op is PCp(Y, X) where X
    # has exactly one read (the PCp itself), change the instruction to
    # write directly to Y and remove the PCp.  Saves 1 SUBNEG4 per site.

    def write_destination_forwarding
      read_count = Hash.new(0)
      @ops.each do |op|
        reads(op).each { |v| read_count[v] += 1 }
      end

      changed = false
      result = []
      i = 0
      while i < @ops.length
        op = @ops[i]
        nxt = @ops[i + 1] if i + 1 < @ops.length

        if nxt.is_a?(PCp)
          w = writes(op)
          if w.length == 1 && w[0] == nxt.src &&
             read_count[nxt.src] == 1 &&
             !protected_var?(nxt.src) && !protected_var?(nxt.dst)
            forwarded = forward_write_dst(op, nxt.dst)
            if forwarded
              result << forwarded
              changed = true
              i += 2
              next
            end
          end
        end

        result << op
        i += 1
      end

      @ops = result
      changed
    end

    def forward_write_dst(op, new_dst)
      case op
      when PAdd then PAdd.new(op.a, op.b, new_dst, comment: op.comment)
      when PSub then PSub.new(op.a, op.b, new_dst, comment: op.comment)
      when PIndirectLoad then PIndirectLoad.new(new_dst, op.addr_var, op.id, comment: op.comment)
      when PCp then PCp.new(new_dst, op.src, comment: op.comment)
      else nil
      end
    end

    # ── Pass 11: CopyPropagation ───────────────────────────────────────
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

        # PIndirectLoad: only invalidate dst (doesn't modify other variables)
        if op.is_a?(PIndirectLoad)
          modified = substitute_reads(op, subst)
          changed = true if modified != op
          result << modified
          dst = modified.dst
          subst.delete_if { |_t, src| src == dst }
          subst.delete(dst)
          next
        end

        # PPush: keep subst alive across PPush (it only reads val, no tracked
        # variable writes). Do NOT substitute PPush's val — changing it breaks
        # push/pop variable-name matching used by liveness_push_pop_elimination.
        if op.is_a?(PPush)
          result << op
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
        if unconditional_transfer?(op) || op.is_a?(PNeg) || op.is_a?(PSubNeg)
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

      when PSubNeg
        a2 = subst[op.a] || op.a
        b2 = subst[op.b] || op.b
        (a2 != op.a || b2 != op.b) ? PSubNeg.new(a2, b2, op.label, comment: op.comment) : op

      when PNeg
        v2 = subst[op.val] || op.val
        v2 != op.val ? PNeg.new(v2, op.label, comment: op.comment) : op

      when PPush
        v2 = subst[op.val] || op.val
        v2 != op.val ? PPush.new(v2, op.push_id, comment: op.comment) : op

      when PIndirectLoadSubNeg
        a2 = subst[op.addr_var] || op.addr_var
        c2 = subst[op.cmp_val] || op.cmp_val
        (a2 != op.addr_var || c2 != op.cmp_val) ?
          PIndirectLoadSubNeg.new(a2, c2, op.label, op.id, op.indirect_pos, comment: op.comment) : op

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
        when PGoto   then used << op.label
        when PNeg    then used << op.label
        when PSubNeg then used << op.label
        when PIndirectLoadSubNeg then used << op.label
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

    # ── Pass: LocalDeadStoreElimination ─────────────────────────────
    # Within basic blocks, if a variable is written and then overwritten
    # before being read, the first write is dead.
    def local_dead_store_elimination
      changed = false
      result = []
      # Track last write index for each variable within current block
      last_write = {}  # var → index in result array
      live_writes = Set.new  # indices that have been read (thus live)

      @ops.each do |op|
        # Block boundary: reset tracking
        if op.is_a?(PLabel) || unconditional_transfer?(op) || op.is_a?(PSubNeg) ||
           op.is_a?(PNeg) || op.is_a?(PIndirectLoadSubNeg)
          last_write.clear
          live_writes.clear
          result << op
          next
        end

        # Mark reads as live
        reads(op).each do |v|
          if last_write[v]
            live_writes << last_write[v]
          end
        end

        # Check writes: if previous write to same var exists and wasn't read, kill it
        writes(op).each do |v|
          if last_write[v] && !live_writes.include?(last_write[v]) && !protected_var?(v)
            prev_idx = last_write[v]
            # Only eliminate if previous write has no side effects
            prev_op = result[prev_idx]
            if prev_op.is_a?(PCp) || prev_op.is_a?(PSub) || prev_op.is_a?(PAdd)
              result[prev_idx] = nil
              changed = true
            end
          end
          last_write[v] = result.length
        end

        result << op
      end

      @ops = result.compact if changed
      changed
    end

    # ── Pass: CmpBranchFusion ────────────────────────────────────────
    # PSub(a, b, t) followed by PNeg(t, L) where t is only used by those two
    # → PSubNeg(a, b, L)

    def cmp_branch_fusion
      changed = false

      # Count uses of each variable (read occurrences)
      use_count = Hash.new(0)
      @ops.each do |op|
        reads(op).each { |v| use_count[v] += 1 }
      end

      result = []
      i = 0
      while i < @ops.length
        op = @ops[i]
        nxt = @ops[i + 1]
        if op.is_a?(PSub) && nxt.is_a?(PNeg) &&
           op.c == nxt.val && use_count[op.c] == 1
          result << PSubNeg.new(op.a, op.b, nxt.label, comment: "#{op.comment} [fused cmp+br]")
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

    # ── Pass: IndirectLoadSubNegFusion ─────────────────────────────────
    # Fuse PIndirectLoad + PSubNeg into PIndirectLoadSubNeg when the loaded
    # value is only used by the PSubNeg. Saves 1 SUBNEG4 per occurrence.

    def indirect_load_subneg_fusion
      changed = false

      # Count uses of each variable (read occurrences)
      use_count = Hash.new(0)
      @ops.each { |op| reads(op).each { |v| use_count[v] += 1 } }

      result = []
      i = 0
      while i < @ops.length
        op = @ops[i]
        nxt = @ops[i + 1]
        if op.is_a?(PIndirectLoad) && nxt.is_a?(PSubNeg) && use_count[op.dst] == 1
          if nxt.b == op.dst # loaded value in B position
            result << PIndirectLoadSubNeg.new(op.addr_var, nxt.a, nxt.label, op.id, :b,
                        comment: "#{op.comment} [fused load+cmp+br]")
            changed = true
            i += 2
          elsif nxt.a == op.dst # loaded value in A position
            result << PIndirectLoadSubNeg.new(op.addr_var, nxt.b, nxt.label, op.id, :a,
                        comment: "#{op.comment} [fused load+cmp+br]")
            changed = true
            i += 2
          else
            result << op
            i += 1
          end
        else
          result << op
          i += 1
        end
      end

      @ops = result
      changed
    end

    # ── Pass: PhiCoalescing ──────────────────────────────────────────
    # Merge phi copy destinations with their sources when they don't interfere.

    def phi_coalescing
      changed = false

      # Collect phi copies: PCp with "phi" in comment
      phi_copies = []
      @ops.each_with_index do |op, i|
        if op.is_a?(PCp) && op.comment.include?("phi")
          phi_copies << { idx: i, dst: op.dst, src: op.src }
        end
      end

      return false if phi_copies.empty?

      phi_copies.each do |phi|
        dst = phi[:dst]
        src = phi[:src]
        next if dst == src

        # Skip if dst is written elsewhere (replacing would create writes to src)
        dst_write_count = 0
        @ops.each_with_index do |op, i|
          dst_write_count += 1 if writes(op).include?(dst)
        end
        # dst should only be written by this one phi copy
        next if dst_write_count > 1

        # Skip if src is a constant or protected variable (would be corrupted)
        next if protected_var?(src)
        const_map = build_constant_map
        next if const_map.key?(src)

        # Collect indices where dst and src are read/written
        src_last_read = -1

        @ops.each_with_index do |op, i|
          reads(op).each { |v| src_last_read = i if v == src }
        end

        dst_first_def = phi[:idx]

        # Non-interference: src's last use <= dst's first definition
        next unless src_last_read <= dst_first_def

        # Coalesce: replace dst with src in all ops
        @ops = @ops.map { |op| replace_var_in_op(op, dst, src) }
        # Remove self-copies
        @ops.reject! { |op| op.is_a?(PCp) && op.dst == op.src }
        changed = true
      end

      changed
    end

    # ── Pass: ArgLocalAliasing ────────────────────────────────────────
    # Detect prologue copies PCp(local_X, arg_Y) right after func_ labels
    # where local_X is written only once. Replace local_X with arg_Y
    # everywhere and remove resulting self-copies.
    def arg_local_aliasing
      changed = false
      i = 0
      while i < @ops.length
        if @ops[i].is_a?(PLabel) && @ops[i].name.start_with?("func_")
          # Scan prologue copies immediately after function entry
          j = i + 1
          restart = false
          while j < @ops.length && @ops[j].is_a?(PCp)
            cp = @ops[j]
            # PCp(local_X, arg_Y) where arg_Y contains "_arg_"
            if cp.src.include?("_arg_") && !cp.dst.include?("_arg_")
              local_var = cp.dst
              arg_var = cp.src
              # Check: local_var written only once (this prologue copy)
              write_count = @ops.count { |op| writes(op).include?(local_var) }
              if write_count == 1
                @ops = @ops.map { |op| replace_var_in_op(op, local_var, arg_var) }
                @ops.reject! { |op| op.is_a?(PCp) && op.dst == op.src }
                changed = true
                restart = true
                break  # restart scan (ops changed)
              end
            end
            j += 1
          end
          next if restart  # re-scan from current i (ops changed, indices shifted)
        end
        i += 1
      end
      changed
    end

    # Replace occurrences of old_var with new_var in an op's read/write positions
    def replace_var_in_op(op, old_var, new_var)
      case op
      when PSub
        a2 = op.a == old_var ? new_var : op.a
        b2 = op.b == old_var ? new_var : op.b
        c2 = op.c == old_var ? new_var : op.c
        (a2 != op.a || b2 != op.b || c2 != op.c) ? PSub.new(a2, b2, c2, comment: op.comment) : op
      when PSubNeg
        a2 = op.a == old_var ? new_var : op.a
        b2 = op.b == old_var ? new_var : op.b
        (a2 != op.a || b2 != op.b) ? PSubNeg.new(a2, b2, op.label, comment: op.comment) : op
      when PAdd
        a2 = op.a == old_var ? new_var : op.a
        b2 = op.b == old_var ? new_var : op.b
        c2 = op.c == old_var ? new_var : op.c
        (a2 != op.a || b2 != op.b || c2 != op.c) ? PAdd.new(a2, b2, c2, comment: op.comment) : op
      when PCp
        d2 = op.dst == old_var ? new_var : op.dst
        s2 = op.src == old_var ? new_var : op.src
        (d2 != op.dst || s2 != op.src) ? PCp.new(d2, s2, comment: op.comment) : op
      when PNeg
        v2 = op.val == old_var ? new_var : op.val
        v2 != op.val ? PNeg.new(v2, op.label, comment: op.comment) : op
      when PPush
        v2 = op.val == old_var ? new_var : op.val
        v2 != op.val ? PPush.new(v2, op.push_id, comment: op.comment) : op
      when PPop
        d2 = op.dst == old_var ? new_var : op.dst
        d2 != op.dst ? PPop.new(d2, op.pop_id, comment: op.comment) : op
      when PIndirectLoadSubNeg
        a2 = op.addr_var == old_var ? new_var : op.addr_var
        c2 = op.cmp_val == old_var ? new_var : op.cmp_val
        (a2 != op.addr_var || c2 != op.cmp_val) ?
          PIndirectLoadSubNeg.new(a2, c2, op.label, op.id, op.indirect_pos, comment: op.comment) : op
      when PIndirectLoad
        d2 = op.dst == old_var ? new_var : op.dst
        a2 = op.addr_var == old_var ? new_var : op.addr_var
        (d2 != op.dst || a2 != op.addr_var) ? PIndirectLoad.new(d2, a2, op.id, comment: op.comment) : op
      when PIndirectStore
        a2 = op.addr_var == old_var ? new_var : op.addr_var
        v2 = op.val == old_var ? new_var : op.val
        (a2 != op.addr_var || v2 != op.val) ? PIndirectStore.new(a2, v2, op.id, comment: op.comment) : op
      else
        op
      end
    end

    # Helper: check if var is written before being read in straight-line
    # code after pop_idx. Used to allow eliminating push/pop of protected
    # vars when the restored value is immediately overwritten.
    def written_before_read_after_pop?(pop_idx, var)
      j = pop_idx + 1
      while j < @ops.length
        op_j = @ops[j]
        # Stop at control flow boundaries (conservative)
        return false if op_j.is_a?(PLabel) || op_j.is_a?(PGoto) ||
                        op_j.is_a?(PSubNeg) || op_j.is_a?(PNeg) ||
                        op_j.is_a?(PReturnJump) || op_j.is_a?(PHalt)
        # Write before read → pop value unused
        return true if writes(op_j).include?(var) && !reads(op_j).include?(var)
        # Read before write → pop value needed
        return false if reads(op_j).include?(var)
        j += 1
      end
      false
    end

    # Helper: check if var is not read between pop and the next tail call,
    # return jump, or halt. If we hit one of those without reading var,
    # the pop is unnecessary because execution leaves the function.
    # Distinguishes tail calls (PGoto func_* without preceding PCallSetReturn)
    # from regular calls (PGoto func_* with preceding PCallSetReturn).
    def not_read_before_tail_call?(pop_idx, var)
      pending_call = false
      j = pop_idx + 1
      while j < @ops.length
        op_j = @ops[j]
        return true if op_j.is_a?(PHalt)
        if op_j.is_a?(PReturnJump)
          # PReturnJump uses its d_label as jump destination;
          # if var matches, the variable is needed.
          return op_j.d_label != var
        end
        if op_j.is_a?(PCallSetReturn)
          pending_call = true
          j += 1
          next
        end
        if op_j.is_a?(PGoto)
          if op_j.label.start_with?("func_")
            if pending_call
              pending_call = false  # regular call, continue scanning
            else
              return true  # tail call → function exits
            end
          else
            # Local goto (loop back, branch) — can't follow control flow,
            # conservatively assume variable may be needed.
            return false
          end
          j += 1
          next
        end
        return false if reads(op_j).include?(var)
        j += 1
      end
      false
    end

    # ── Pass: LivenessPushPopElimination ──────────────────────────────
    # More precise push/pop elimination using local liveness analysis.

    def liveness_push_pop_elimination
      changed = false

      # Group PPush/PPop by call_id
      call_sites = Hash.new { |h, k| h[k] = { pushes: [], pops: [] } }
      @ops.each_with_index do |op, i|
        case op
        when PPush
          call_id = op.push_id.sub(/_s\d+$/, '')
          call_sites[call_id][:pushes] << { idx: i, var: op.val }
        when PPop
          call_id = op.pop_id.sub(/_r\d+$/, '')
          call_sites[call_id][:pops] << { idx: i, var: op.dst }
        end
      end

      to_remove = Set.new

      call_sites.each do |_call_id, site|
        site[:pops].each do |pop_info|
          pop_idx = pop_info[:idx]
          var = pop_info[:var]

          # Protected vars: ret_d is always kept (needed for return mechanism).
          # Other protected vars can be eliminated if:
          #   (a) written before read after pop, OR
          #   (b) not read in straight-line code before a tail call (the tail call
          #       re-enters the function, making the saved value irrelevant).
          if protected_var?(var)
            if written_before_read_after_pop?(pop_idx, var)
              # Proceed to normal checks below
            elsif !var.end_with?('_ret_d') && not_read_before_tail_call?(pop_idx, var)
              # Tail call path: var is not read, directly eliminate.
              # (used_after scan would find reads past the tail call in other
              # functions, but those are from a different execution context.)
              matching_push = site[:pushes].find { |p| p[:var] == var }
              if matching_push
                to_remove << matching_push[:idx]
                to_remove << pop_idx
                changed = true
              end
              next
            else
              next  # Protected, keep push/pop
            end
          end

          # Find matching push
          matching_push = site[:pushes].find { |p| p[:var] == var }
          next unless matching_push
          push_idx = matching_push[:idx]

          # Check 1: Is var read by any non-PPush instruction after the pop?
          # Scan forward from pop, stopping at function exit boundaries:
          # - PHalt (program ends)
          # - PReturnJump (function returns; check if d_label == var)
          # - PGoto func_* without preceding PCallSetReturn (tail call)
          # Regular calls (PCallSetReturn + PGoto func_*) don't break.
          # Local PGoto and PLabel are traversed (conservative within function).
          used_after = false
          pending_call_ua = false
          ((pop_idx + 1)...@ops.length).each do |j|
            op_j = @ops[j]
            break if op_j.is_a?(PHalt)
            if op_j.is_a?(PReturnJump)
              used_after = true if op_j.d_label == var
              break
            end
            if op_j.is_a?(PCallSetReturn)
              pending_call_ua = true
              next
            end
            if op_j.is_a?(PGoto) && op_j.label.start_with?("func_")
              if pending_call_ua
                pending_call_ua = false  # regular call, don't break
              else
                break  # tail call → function exits
              end
              next
            end
            next if op_j.is_a?(PPush)  # exclude PPush reads (break circular dep)
            if reads(op_j).include?(var)
              used_after = true
              break
            end
          end

          unless used_after
            to_remove << push_idx
            to_remove << pop_idx
            changed = true
            next
          end

          # Check 2: defined-before — scan backward from push to function entry
          # Scan all instructions (ignoring intermediate PLabel/PGoto) until
          # we reach the func_ entry label.
          defined_before = true  # conservative default
          found_func_entry = false
          (push_idx - 1).downto(0) do |j|
            op_j = @ops[j]
            if writes(op_j).include?(var)
              defined_before = true
              break
            end
            if op_j.is_a?(PLabel) && op_j.name.start_with?('func_')
              found_func_entry = true
              defined_before = false
              break
            end
          end

          if found_func_entry && !defined_before
            to_remove << push_idx
            to_remove << pop_idx
            changed = true
          end
        end
      end

      if changed
        @ops = @ops.each_with_index.reject { |_, i| to_remove.include?(i) }.map(&:first)
      end

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
        when PGoto   then used_without_push << op.label
        when PNeg    then used_without_push << op.label
        when PSubNeg then used_without_push << op.label
        when PIndirectLoadSubNeg then used_without_push << op.label
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
