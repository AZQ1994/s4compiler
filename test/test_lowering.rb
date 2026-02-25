# frozen_string_literal: true

require 'minitest/autorun'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'parser'
require 'lowering'
require 'expander'
require 'emitter'

class TestLowering < Minitest::Test
  def compile(ir_source)
    parser = S4C::Parser.new
    mod = parser.parse(ir_source)
    lowering = S4C::Lowering.new
    lowering.lower(mod)
    expander = S4C::Expander.new(lowering.mem)
    expander.expand(lowering.pseudo_ops)
    S4C::Emitter.new(lowering.mem, expander.instructions, show_result: true).emit
  end

  def test_simple_add
    ir = <<~LL
      define i32 @main() {
      entry:
        %1 = add i32 3, 5
        ret i32 %1
      }
    LL

    output = compile(ir)
    assert_includes output, "C_3:3"
    assert_includes output, "C_5:5"
    assert_includes output, "main___retval"
    assert_includes output, "HALT"
    assert_includes output, ">>> Result:"
  end

  def test_sub
    ir = <<~LL
      define i32 @main() {
      entry:
        %1 = sub i32 10, 3
        ret i32 %1
      }
    LL

    output = compile(ir)
    assert_includes output, "C_10:10"
    assert_includes output, "C_3:3"
    assert_includes output, "HALT"
  end

  def test_branch
    ir = <<~LL
      define i32 @main() {
      entry:
        br label %done
      done:
        ret i32 0
      }
    LL

    output = compile(ir)
    assert_includes output, "main_bb_done"
    assert_includes output, "HALT"
  end

  def test_conditional_branch
    ir = <<~LL
      define i32 @main() {
      entry:
        %cmp = icmp slt i32 3, 5
        br i1 %cmp, label %then, label %else
      then:
        ret i32 1
      else:
        ret i32 0
      }
    LL

    output = compile(ir)
    assert_includes output, "main_bb_then"
    assert_includes output, "main_bb_else"
  end

  def test_alloca_store_load
    ir = <<~LL
      define i32 @main() {
      entry:
        %1 = alloca i32, align 4
        store i32 42, ptr %1, align 4
        %2 = load i32, ptr %1, align 4
        ret i32 %2
      }
    LL

    output = compile(ir)
    assert_includes output, "main_local_1:0"
    assert_includes output, "C_42:42"
  end

  def test_function_call
    ir = <<~LL
      define i32 @add(i32 %a, i32 %b) {
      entry:
        %r = add i32 %a, %b
        ret i32 %r
      }
      define i32 @main() {
      entry:
        %1 = call i32 @add(i32 3, i32 5)
        ret i32 %1
      }
    LL

    output = compile(ir)
    # Both functions exist
    assert_includes output, "func_add"
    assert_includes output, "func_main"
    # Argument passing
    assert_includes output, "add_arg_a"
    assert_includes output, "add_arg_b"
    # Return value
    assert_includes output, "add___retval"
    # Self-modifying return
    assert_includes output, "cd:add_ret_d:"
    # Return label
    assert_includes output, "main_ret1"
    assert_includes output, "&main_ret1"
    # Entry jumps to main
    assert_match(/func_main/, output)
  end
end
