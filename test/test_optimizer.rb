# frozen_string_literal: true

require 'minitest/autorun'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'pseudo_ops'
require 'memory'
require 'optimizer'

class TestOptimizer < Minitest::Test
  def setup
    @mem = S4C::Memory.new
  end

  # Helper: create a retval variable (protected, so it's never eliminated)
  def retval
    @mem.func_var("test", "__retval")
  end

  # ── GotoNextElimination ──────────────────────────────────────────

  def test_goto_next_removes_redundant_goto
    ops = [
      S4C::PGoto.new("label_x"),
      S4C::PLabel.new("label_x"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "label_x" }
    assert result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "label_x" }
  end

  def test_goto_next_keeps_non_matching_goto
    ops = [
      S4C::PGoto.new("label_x"),
      S4C::PLabel.new("label_y"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "label_x" }
  end

  # ── UnreachableCodeElimination ───────────────────────────────────

  def test_unreachable_after_goto
    a = @mem.func_var("f", "a")
    b = @mem.func_var("f", "b")
    c = @mem.func_var("f", "c")
    ops = [
      S4C::PGoto.new("target"),
      S4C::PSub.new(a, b, c),        # unreachable
      S4C::PLabel.new("other"),       # use different label so goto isn't eliminated
      S4C::PCp.new(retval, a),
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, b),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PSub) }
    assert result.any? { |op| op.is_a?(S4C::PGoto) }
  end

  def test_unreachable_after_halt
    a = @mem.func_var("f", "a")
    b = @mem.func_var("f", "b")
    c = @mem.func_var("f", "c")
    ops = [
      S4C::PCp.new(retval, a),
      S4C::PHalt.new,
      S4C::PAdd.new(a, b, c),        # unreachable
      S4C::PLabel.new("next_block"),
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  def test_conditional_branch_not_unreachable
    a = @mem.func_var("f", "a")
    b = @mem.func_var("f", "b")
    ops = [
      S4C::PNeg.new(a, "target"),
      S4C::PAdd.new(a, b, retval),   # reachable (fallthrough from PNeg)
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, a),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  # ── ConstantFolding ──────────────────────────────────────────────

  def test_fold_add_constants
    c3 = @mem.const(3)
    c5 = @mem.const(5)
    ops = [
      S4C::PAdd.new(c3, c5, retval),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # PAdd should be folded to PCp(retval, C_8)
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    c8 = @mem.const(8)
    assert_equal c8, copies[0].src
  end

  def test_fold_sub_constants
    c3 = @mem.const(3)
    c5 = @mem.const(5)
    ops = [
      S4C::PSub.new(c3, c5, retval),  # retval = 5 - 3 = 2
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    c2 = @mem.const(2)
    assert_equal c2, copies[0].src
  end

  def test_fold_neg_always_taken
    cn1 = @mem.const(-1)
    ops = [
      S4C::PNeg.new(cn1, "target"),
      S4C::PGoto.new("fallback"),
      S4C::PLabel.new("fallback"),
      S4C::PCp.new(retval, cn1),
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # PNeg(-1, target) should fold → PGoto("target") → unreachable eliminates fallback code
    refute result.any? { |op| op.is_a?(S4C::PNeg) }
    # "fallback" goto should be eliminated as unreachable
    refute result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "fallback" }
  end

  def test_fold_neg_never_taken
    c5 = @mem.const(5)
    a = @mem.func_var("f", "a")
    ops = [
      S4C::PNeg.new(c5, "target"),   # 5 >= 0 → never taken
      S4C::PAdd.new(a, c5, retval),  # should still be here
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, a),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PNeg) }
    assert result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  def test_no_fold_non_constant
    c3 = @mem.const(3)
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PAdd.new(c3, x, retval),  # x is not a constant
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  # ── CopyPropagation ─────────────────────────────────────────────

  def test_copy_chain_propagation
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    ops = [
      S4C::PCp.new(t, x),
      S4C::PCp.new(retval, t),   # should become PCp(retval, x)
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal retval, copies[0].dst
    assert_equal x, copies[0].src
  end

  def test_copy_prop_into_arithmetic
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    y = @mem.func_var("f", "y")
    ops = [
      S4C::PCp.new(t, x),
      S4C::PAdd.new(t, y, retval),  # t should be substituted with x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    assert_equal 1, adds.length
    assert_equal x, adds[0].a
  end

  def test_copy_prop_stops_at_jump_target_label
    # Label "block2" is a jump target from PNeg → multi-predecessor → subst resets
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    y = @mem.func_var("f", "y")
    ops = [
      S4C::PCp.new(t, x),
      S4C::PNeg.new(y, "block2"),        # makes "block2" a jump target
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("block2"),
      S4C::PCp.new(retval, t),           # should NOT substitute t→x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) && op.dst == retval }
    # The copy after "block2" label should use t (not x)
    block2_copy = nil
    seen_block2 = false
    result.each do |op|
      seen_block2 = true if op.is_a?(S4C::PLabel) && op.name == "block2"
      if seen_block2 && op.is_a?(S4C::PCp) && op.dst == retval
        block2_copy = op
        break
      end
    end
    assert block2_copy, "Should have a PCp to retval after block2"
    assert_equal t, block2_copy.src  # NOT x
  end

  def test_self_copy_removed
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PCp.new(x, x),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PCp) && op.dst == op.src }
  end

  def test_copy_prop_handles_redefinition
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    d = @mem.func_var("f", "d")
    r1 = @mem.func_var("f", "r1")
    ops = [
      S4C::PCp.new(t, x),         # subst: t → x
      S4C::PAdd.new(t, t, r1),    # should use x: PAdd(x, x, r1)
      S4C::PCp.new(t, d),         # redefine t → d
      S4C::PAdd.new(t, r1, retval), # should use d and r1
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    assert_equal 2, adds.length
    assert_equal x, adds[0].a  # first PAdd uses x (propagated from t)
    assert_equal d, adds[1].a  # second PAdd uses d (propagated from redefined t)
  end

  # ── DeadStoreElimination ─────────────────────────────────────────

  def test_dead_store_removed
    x = @mem.func_var("f", "x")
    y = @mem.func_var("f", "y")
    z = @mem.const(0)
    ops = [
      S4C::PCp.new(x, z),       # x is never read → dead
      S4C::PAdd.new(z, z, y),   # y is never read → dead
      S4C::PCp.new(retval, z),  # retval is protected → kept
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PAdd) }
    # Only PCp to retval + PHalt should remain
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal retval, copies[0].dst
  end

  def test_dead_store_keeps_used_var
    x = @mem.func_var("f", "x")
    y = @mem.func_var("f", "y")
    ops = [
      S4C::PCp.new(x, y),            # x IS read below (and y isn't a constant)
      S4C::PAdd.new(x, x, retval),   # reads x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # After copy prop: PAdd(y, y, retval). PCp(x,y) is dead → removed.
    # PAdd should remain.
    assert result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  def test_dead_store_preserves_retval
    z = @mem.const(0)
    ops = [
      S4C::PCp.new(retval, z),  # retval is protected
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PCp) && op.dst == retval }
  end

  def test_dead_store_preserves_indirect_targets
    arr0 = @mem.func_alloca_array("f", "a", 3)
    ptr = @mem.func_var("f", "ptr")
    val = @mem.const(42)
    ops = [
      S4C::PCp.new(arr0, val),                   # write to array element
      S4C::PIndirectLoad.new(retval, ptr, 0),     # indirect read (retval is protected)
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # arr0 should NOT be eliminated because PIndirectLoad exists and arr elements protected
    assert result.any? { |op| op.is_a?(S4C::PCp) && op.dst == arr0 }
  end

  # ── StrengthReduction ───────────────────────────────────────────

  def test_strength_add_zero_left
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PAdd.new(z, x, retval),  # retval = x + 0 = x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PAdd) }
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal x, copies[0].src
  end

  def test_strength_add_zero_right
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PAdd.new(x, z, retval),  # retval = 0 + x = x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PAdd) }
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal x, copies[0].src
  end

  def test_strength_sub_zero_identity
    # PSub(ZERO, x, c) → c = x - 0 = x → PCp(c, x)
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PSub.new(z, x, retval),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PSub) }
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal x, copies[0].src
  end

  def test_strength_sub_self
    # PSub(x, x, c) → c = x - x = 0
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PSub.new(x, x, retval),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PSub) }
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal z, copies[0].src
  end

  def test_strength_negation_preserved
    # PSub(x, ZERO, c) = c = 0 - x = -x → NOT identity, keep as PSub
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PSub.new(x, z, retval),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PSub) }
  end

  def test_strength_no_change_for_nonzero
    x = @mem.func_var("f", "x")
    y = @mem.func_var("f", "y")
    ops = [
      S4C::PAdd.new(x, y, retval),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PAdd) }
  end

  # ── DeadLabelElimination ───────────────────────────────────────

  def test_dead_label_removed
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("orphan"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "orphan" }
  end

  def test_dead_label_keeps_referenced
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PNeg.new(x, "target"),      # conditional branch keeps "target" referenced
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "target" }
  end

  def test_dead_label_keeps_first
    ops = [
      S4C::PLabel.new("func_main"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "func_main" }
  end

  def test_dead_label_keeps_neg_target
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PNeg.new(x, "negative_path"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("negative_path"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "negative_path" }
  end

  # ── GotoChainSimplification ────────────────────────────────────

  def test_goto_chain_collapsed
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PGoto.new("L1"),
      S4C::PLabel.new("L1"),
      S4C::PGoto.new("L2"),
      S4C::PLabel.new("L2"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # After chain simplification, no goto should target L1
    refute result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "L1" }
  end

  def test_goto_chain_transitive
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PGoto.new("L1"),
      S4C::PLabel.new("L1"),
      S4C::PGoto.new("L2"),
      S4C::PLabel.new("L2"),
      S4C::PGoto.new("L3"),
      S4C::PLabel.new("L3"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "L1" }
    refute result.any? { |op| op.is_a?(S4C::PGoto) && op.label == "L2" }
  end

  def test_goto_chain_neg_target
    # PNeg target "L1" → PGoto("final") should redirect PNeg to "final"
    # Use separate labels to prevent GotoNextElimination from interfering
    x = @mem.func_var("f", "x")
    y = @mem.func_var("f", "y")
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PNeg.new(x, "L1"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("L1"),
      S4C::PGoto.new("final"),
      S4C::PLabel.new("mid"),            # different label between goto and final
      S4C::PCp.new(y, @mem.zero),        # some code
      S4C::PHalt.new,
      S4C::PLabel.new("final"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    negs = result.select { |op| op.is_a?(S4C::PNeg) }
    if negs.any?
      assert_equal "final", negs[0].label
    end
  end

  def test_goto_chain_cycle_safe
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PNeg.new(x, "done"),
      S4C::PGoto.new("L1"),
      S4C::PLabel.new("L1"),
      S4C::PGoto.new("L2"),
      S4C::PLabel.new("L2"),
      S4C::PGoto.new("L1"),
      S4C::PLabel.new("done"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PHalt) }
  end

  # ── PeepholeDoubleNegation ───────────────────────────────────

  def test_double_negation_folded
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    z = @mem.zero
    ops = [
      S4C::PSub.new(x, z, t),        # t = -x
      S4C::PSub.new(t, z, retval),   # retval = -t = x → PCp(retval, x)
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) && op.dst == retval }
    assert_equal 1, copies.length
    assert_equal x, copies[0].src
  end

  def test_single_negation_preserved
    x = @mem.func_var("f", "x")
    z = @mem.zero
    ops = [
      S4C::PSub.new(x, z, retval),   # retval = -x (single negation, keep)
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PSub) }
  end

  # ── RedundantBranchElimination ─────────────────────────────────

  def test_redundant_neg_goto_same_label
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PNeg.new(x, "target"),
      S4C::PGoto.new("target"),
      S4C::PLabel.new("other"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
      S4C::PLabel.new("target"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    # PNeg should be removed, PGoto kept
    refute result.any? { |op| op.is_a?(S4C::PNeg) }
    assert result.any? { |op| op.is_a?(S4C::PGoto) }
  end

  def test_neg_goto_different_labels_kept
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PNeg.new(x, "target_a"),
      S4C::PGoto.new("target_b"),
      S4C::PLabel.new("target_a"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
      S4C::PLabel.new("target_b"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PNeg) }
  end

  # ── CopyProp single-predecessor extension ──────────────────────

  def test_copy_prop_across_single_pred_label
    # Label "block2" is NOT a jump target and previous falls through → propagate
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    ops = [
      S4C::PCp.new(t, x),
      S4C::PLabel.new("block2"),         # single fallthrough predecessor
      S4C::PCp.new(retval, t),           # should substitute t→x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) && op.dst == retval }
    assert_equal 1, copies.length
    assert_equal x, copies[0].src  # propagated across label
  end

  # ── PushPopElimination ─────────────────────────────────────────

  def test_push_pop_dead_pair_removed
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PPush.new(x, "1_s0"),
      S4C::PPop.new(x, "1_r0"),
      S4C::PCp.new(retval, @mem.zero),  # x is never read
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PPush) }
    refute result.any? { |op| op.is_a?(S4C::PPop) }
  end

  def test_push_pop_live_pair_kept
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PPush.new(x, "1_s0"),
      S4C::PPop.new(x, "1_r0"),
      S4C::PCp.new(retval, x),          # x IS read
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PPush) }
    assert result.any? { |op| op.is_a?(S4C::PPop) }
  end

  def test_push_pop_protected_var_kept
    rv = @mem.func_var("f", "__retval")
    ops = [
      S4C::PPush.new(rv, "1_s0"),
      S4C::PPop.new(rv, "1_r0"),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    assert result.any? { |op| op.is_a?(S4C::PPush) }
    assert result.any? { |op| op.is_a?(S4C::PPop) }
  end

  # ── Combined: new passes interact with existing ────────────────

  def test_strength_enables_copy_prop
    x = @mem.func_var("f", "x")
    t = @mem.func_var("f", "t")
    z = @mem.zero
    ops = [
      S4C::PSub.new(z, x, t),     # t = x - 0 = x → PCp(t, x)
      S4C::PCp.new(retval, t),    # retval = t → retval = x
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    copies = result.select { |op| op.is_a?(S4C::PCp) }
    assert_equal 1, copies.length
    assert_equal retval, copies[0].dst
    assert_equal x, copies[0].src
  end

  def test_dead_label_after_unreachable
    x = @mem.func_var("f", "x")
    ops = [
      S4C::PLabel.new("entry"),
      S4C::PCp.new(retval, x),
      S4C::PHalt.new,
      S4C::PGoto.new("orphan_target"),   # unreachable
      S4C::PLabel.new("orphan_target"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize
    refute result.any? { |op| op.is_a?(S4C::PLabel) && op.name == "orphan_target" }
  end

  # ── LocalValueNumbering ─────────────────────────────────────────

  def test_lvn_redundant_add_eliminated
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PAdd.new(a, b, c1),
      S4C::PAdd.new(a, b, c2),  # redundant
      S4C::PAdd.new(c1, c2, rv),  # use both so DSE keeps them
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    # LVN should eliminate the second PAdd, then copy prop may simplify further
    # The key: there should be fewer than 3 PAdds (at least one was eliminated)
    assert adds.length < 3, "LVN should eliminate redundant PAdd"
  end

  def test_lvn_add_commutativity
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PAdd.new(a, b, c1),
      S4C::PAdd.new(b, a, c2),  # same computation (commutative)
      S4C::PAdd.new(c1, c2, rv),  # use both
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    assert adds.length < 3, "Commutative PAdd should be eliminated by LVN"
  end

  def test_lvn_sub_not_commutative
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PSub.new(a, b, c1),  # c1 = b - a
      S4C::PSub.new(b, a, c2),  # c2 = a - b (different!)
      S4C::PAdd.new(c1, c2, rv),  # use both
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    subs = result.select { |op| op.is_a?(S4C::PSub) }
    assert_equal 2, subs.length, "Non-commutative PSub should NOT be merged"
  end

  def test_lvn_resets_at_label
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PAdd.new(a, b, c1),
      S4C::PNeg.new(a, "lbl"),  # branch to lbl (makes it a jump target)
      S4C::PLabel.new("lbl"),
      S4C::PAdd.new(a, b, c2),  # same computation but after label
      S4C::PAdd.new(c1, c2, rv),  # use both
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # Both PAdds must survive (LVN resets at label boundary)
    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    assert adds.length >= 2, "PAdd after label should not be eliminated by LVN"
  end

  def test_lvn_invalidation_on_operand_redefine
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PAdd.new(a, b, c1),
      S4C::PCp.new(a, @mem.const(99)),  # redefine a
      S4C::PAdd.new(a, b, c2),          # same signature but a changed!
      S4C::PAdd.new(c1, c2, rv),        # use both
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # Both PAdds reading a and b should survive
    # (constant folding may convert the second to PCp since a=99 is constant)
    arith = result.select { |op| op.is_a?(S4C::PAdd) || op.is_a?(S4C::PSub) }
    assert arith.length >= 2, "PAdd after operand redefine should not be merged by LVN"
  end

  def test_lvn_different_ops_not_merged
    a = @mem.func_var("main", "a")
    b = @mem.func_var("main", "b")
    c1 = @mem.func_var("main", "c1")
    c2 = @mem.func_var("main", "c2")
    rv = @mem.func_var("main", "___retval")

    ops = [
      S4C::PAdd.new(a, b, c1),
      S4C::PSub.new(a, b, c2),  # different op
      S4C::PAdd.new(c1, c2, rv),  # use both
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    subs = result.select { |op| op.is_a?(S4C::PSub) }
    assert subs.length >= 1, "PSub should survive"
    assert adds.length >= 1, "PAdd should survive"
  end

  # ── LoopInvariantCodeMotion ────────────────────────────────────

  def test_licm_invariant_hoisted
    # Use actual lowered loop pattern: PLabel→body→PNeg(exit)→PGoto(header)
    x = @mem.func_var("main", "x")
    y = @mem.func_var("main", "y")
    cnt = @mem.func_var("main", "cnt")
    tmp = @mem.func_var("main", "tmp")
    rv = @mem.func_var("main", "___retval")
    c1 = @mem.const(1)
    c10 = @mem.const(10)

    ops = [
      S4C::PCp.new(cnt, @mem.zero),
      S4C::PLabel.new("loop"),
      S4C::PAdd.new(x, c1, y),       # invariant: x and C_1 not modified in loop
      S4C::PAdd.new(cnt, c1, cnt),    # variant: cnt is loop-defined
      S4C::PAdd.new(cnt, y, rv),      # use y inside loop
      S4C::PSub.new(cnt, c10, tmp),
      S4C::PNeg.new(tmp, "done"),     # if tmp < 0, exit loop
      S4C::PGoto.new("loop"),         # back-edge (PGoto to earlier label)
      S4C::PLabel.new("done"),
      S4C::PCp.new(rv, y),
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # y should be computed before the loop (hoisted)
    loop_idx = result.index { |op| op.is_a?(S4C::PLabel) && op.name == "loop" }
    pre_loop = result[0...loop_idx]
    pre_writes = pre_loop.flat_map { |op|
      case op
      when S4C::PAdd then [op.c]
      when S4C::PSub then [op.c]
      when S4C::PCp then [op.dst]
      else []
      end
    }
    assert pre_writes.include?(y), "Invariant computation of y should be hoisted before loop"
  end

  def test_licm_variant_not_hoisted
    cnt = @mem.func_var("main", "cnt")
    tmp = @mem.func_var("main", "tmp")
    rv = @mem.func_var("main", "___retval")
    c1 = @mem.const(1)
    c10 = @mem.const(10)

    ops = [
      S4C::PCp.new(cnt, @mem.zero),
      S4C::PLabel.new("loop"),
      S4C::PAdd.new(cnt, c1, cnt),    # variant: reads and writes cnt
      S4C::PSub.new(cnt, c10, tmp),
      S4C::PNeg.new(tmp, "done"),
      S4C::PGoto.new("loop"),         # back-edge
      S4C::PLabel.new("done"),
      S4C::PCp.new(rv, cnt),
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # PAdd(cnt, c1, cnt) should be inside the loop
    loop_idx = result.index { |op| op.is_a?(S4C::PLabel) && op.name == "loop" }
    add_idx = result.index { |op| op.is_a?(S4C::PAdd) && op.c == cnt }
    assert add_idx && add_idx > loop_idx, "Variant op should NOT be hoisted"
  end

  def test_licm_call_blocks_shared_var_hoist
    # Subroutine shared variables (__*) should not be hoisted when loop has calls
    shared = @mem.func_var("main", "__mul_arg2")
    cnt = @mem.func_var("main", "cnt")
    tmp = @mem.func_var("main", "tmp")
    rv = @mem.func_var("main", "___retval")
    c1 = @mem.const(1)
    c2 = @mem.const(2)
    c10 = @mem.const(10)

    ops = [
      S4C::PCp.new(cnt, @mem.zero),
      S4C::PLabel.new("loop"),
      S4C::PCp.new(shared, c2),                              # writes to __mul_arg2
      S4C::PCallSetReturn.new("ret_lbl", "ret_d"),
      S4C::PGoto.new("func___mul"),                           # subroutine call (not a back-edge)
      S4C::PLabel.new("ret_lbl"),
      S4C::PAdd.new(cnt, c1, cnt),
      S4C::PSub.new(cnt, c10, tmp),
      S4C::PNeg.new(tmp, "done"),
      S4C::PGoto.new("loop"),                                 # back-edge
      S4C::PLabel.new("done"),
      S4C::PCp.new(rv, cnt),
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # PCp(__mul_arg2, c2) should remain inside the loop
    loop_idx = result.index { |op| op.is_a?(S4C::PLabel) && op.name == "loop" }
    cp_idx = result.index { |op| op.is_a?(S4C::PCp) && op.dst == shared }
    if cp_idx
      assert cp_idx > loop_idx, "Shared var write should NOT be hoisted when loop has calls"
    end
  end

  # ── Combined optimization ───────────────────────────────────────

  def test_alloca_load_store_chain
    # Typical -O0 pattern: store to alloca, load back, compute, store, load, return
    arg0 = @mem.func_param("main", "a")
    arg1 = @mem.func_param("main", "b")
    local_a = @mem.func_alloca("main", "la")
    local_b = @mem.func_alloca("main", "lb")
    local_r = @mem.func_alloca("main", "lr")
    v5 = @mem.func_var("main", "v5")
    v6 = @mem.func_var("main", "v6")
    v7 = @mem.func_var("main", "v7")
    v8 = @mem.func_var("main", "v8")
    rv = @mem.func_var("main", "__retval")

    ops = [
      S4C::PCp.new(local_a, arg0),    # store arg to alloca
      S4C::PCp.new(local_b, arg1),    # store arg to alloca
      S4C::PCp.new(v5, local_a),      # load from alloca
      S4C::PCp.new(v6, local_b),      # load from alloca
      S4C::PAdd.new(v5, v6, v7),      # compute
      S4C::PCp.new(local_r, v7),      # store result to alloca
      S4C::PCp.new(v8, local_r),      # load from alloca
      S4C::PCp.new(rv, v8),           # return
      S4C::PHalt.new,
    ]

    opt = S4C::Optimizer.new(ops, @mem)
    result = opt.optimize

    # PAdd should directly use args and write to retval (via copy prop chain)
    adds = result.select { |op| op.is_a?(S4C::PAdd) }
    assert_equal 1, adds.length
    assert_equal arg0, adds[0].a
    assert_equal arg1, adds[0].b

    # Should be very short
    non_halt = result.reject { |op| op.is_a?(S4C::PHalt) }
    assert non_halt.length <= 2, "Expected at most 2 non-halt ops, got #{non_halt.length}"
  end

  # ── Stats ────────────────────────────────────────────────────────

  def test_stats_tracking
    ops = [
      S4C::PGoto.new("L"),
      S4C::PLabel.new("L"),
      S4C::PCp.new(retval, @mem.zero),
      S4C::PHalt.new,
    ]
    opt = S4C::Optimizer.new(ops, @mem)
    opt.optimize
    assert opt.stats[:iterations] >= 1
    assert opt.stats[:removed] >= 1
  end
end
