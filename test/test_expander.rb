# frozen_string_literal: true

require 'minitest/autorun'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'pseudo_ops'
require 'memory'
require 'expander'

class TestExpander < Minitest::Test
  def setup
    @mem = S4C::Memory.new
  end

  def test_expand_sub
    a = @mem.var("a")
    b = @mem.var("b")
    c = @mem.var("c")
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PSub.new(a, b, c)])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 1, sng.length
    # SUBNEG4: a b c NEXT  →  c = b - a
    assert_equal a, sng[0].a
    assert_equal b, sng[0].b
    assert_equal c, sng[0].c
    assert_equal 'NEXT', sng[0].d
  end

  def test_expand_add
    a = @mem.var("a")
    b = @mem.var("b")
    c = @mem.var("c")
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PAdd.new(a, b, c)])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 2, sng.length
    # First: a ZERO temp NEXT  →  temp = 0 - a = -a
    assert_equal a, sng[0].a
    assert_equal @mem.zero, sng[0].b
    # Second: temp b c NEXT  →  c = b - temp = b - (-a) = b + a
    assert_equal b, sng[1].b
    assert_equal c, sng[1].c
  end

  def test_expand_cp
    dst = @mem.var("dst")
    src = @mem.var("src")
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PCp.new(dst, src)])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 1, sng.length
    # ZERO src dst NEXT  →  dst = src - 0 = src
    assert_equal @mem.zero, sng[0].a
    assert_equal src, sng[0].b
    assert_equal dst, sng[0].c
  end

  def test_expand_goto
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PGoto.new("target")])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 1, sng.length
    # ZERO C_n1 temp target  →  temp = -1 - 0 = -1 < 0 → branch
    assert_equal @mem.zero, sng[0].a
    assert_equal @mem.const(-1), sng[0].b
    assert_equal 'target', sng[0].d
  end

  def test_expand_neg
    val = @mem.var("val")
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PNeg.new(val, "label")])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 1, sng.length
    # ZERO val temp label  →  temp = val - 0; if temp < 0 → branch
    assert_equal @mem.zero, sng[0].a
    assert_equal val, sng[0].b
    assert_equal 'label', sng[0].d
  end

  def test_expand_halt
    exp = S4C::Expander.new(@mem)
    exp.expand([S4C::PHalt.new])

    sng = exp.instructions.select { |i| i.is_a?(S4C::Subneg4) }
    assert_equal 1, sng.length
    assert_equal 'HALT', sng[0].d
  end
end
