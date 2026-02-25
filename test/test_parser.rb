# frozen_string_literal: true

require 'minitest/autorun'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'parser'

class TestParser < Minitest::Test
  def setup
    @parser = S4C::Parser.new
  end

  def test_parse_simple_function
    ir = <<~LL
      define i32 @add(i32 %a, i32 %b) {
      entry:
        %r = add i32 %a, %b
        ret i32 %r
      }
    LL

    mod = @parser.parse(ir)
    assert_equal 1, mod.functions.length

    func = mod.functions[0]
    assert_equal 'add', func.name
    assert_equal 'i32', func.return_type
    assert_equal [['i32', 'a'], ['i32', 'b']], func.params
    assert_equal 1, func.blocks.length

    block = func.blocks[0]
    assert_equal 'entry', block.name
    assert_equal 2, block.instructions.length

    add_inst = block.instructions[0]
    assert_equal 'add', add_inst.opcode
    assert_equal 'r', add_inst.result
    assert_equal 2, add_inst.operands.length
    assert add_inst.operands[0].var?
    assert_equal 'a', add_inst.operands[0].value
    assert add_inst.operands[1].var?
    assert_equal 'b', add_inst.operands[1].value

    ret_inst = block.instructions[1]
    assert_equal 'ret', ret_inst.opcode
    assert_nil ret_inst.result
  end

  def test_parse_constants
    ir = <<~LL
      define i32 @const_add() {
      entry:
        %r = add i32 3, 5
        ret i32 %r
      }
    LL

    mod = @parser.parse(ir)
    func = mod.functions[0]
    add_inst = func.blocks[0].instructions[0]
    assert add_inst.operands[0].const?
    assert_equal 3, add_inst.operands[0].value
    assert add_inst.operands[1].const?
    assert_equal 5, add_inst.operands[1].value
  end

  def test_parse_branch
    ir = <<~LL
      define void @test() {
      entry:
        br label %loop
      loop:
        br label %loop
      }
    LL

    mod = @parser.parse(ir)
    func = mod.functions[0]
    assert_equal 2, func.blocks.length

    br_inst = func.blocks[0].instructions[0]
    assert_equal 'br', br_inst.opcode
    assert_equal 1, br_inst.operands.length
    assert br_inst.operands[0].label?
    assert_equal 'loop', br_inst.operands[0].value
  end

  def test_parse_conditional_branch
    ir = <<~LL
      define void @test(i32 %a, i32 %b) {
      entry:
        %cmp = icmp slt i32 %a, %b
        br i1 %cmp, label %then, label %else
      then:
        ret void
      else:
        ret void
      }
    LL

    mod = @parser.parse(ir)
    func = mod.functions[0]
    block = func.blocks[0]

    icmp = block.instructions[0]
    assert_equal 'icmp', icmp.opcode
    assert_equal 'cmp', icmp.result

    br = block.instructions[1]
    assert_equal 'br', br.opcode
    assert_equal 3, br.operands.length
    assert br.operands[0].var?
    assert_equal 'cmp', br.operands[0].value
    assert br.operands[1].label?
    assert_equal 'then', br.operands[1].value
    assert br.operands[2].label?
    assert_equal 'else', br.operands[2].value
  end

  def test_parse_noundef_params
    ir = <<~LL
      define i32 @add(i32 noundef %0, i32 noundef %1) #0 {
        %3 = add nsw i32 %0, %1
        ret i32 %3
      }
    LL

    mod = @parser.parse(ir)
    func = mod.functions[0]
    assert_equal [['i32', '0'], ['i32', '1']], func.params
  end

  def test_parse_alloca_store_load
    ir = <<~LL
      define i32 @test() {
      entry:
        %1 = alloca i32, align 4
        store i32 42, ptr %1, align 4
        %2 = load i32, ptr %1, align 4
        ret i32 %2
      }
    LL

    mod = @parser.parse(ir)
    block = mod.functions[0].blocks[0]

    alloca = block.instructions[0]
    assert_equal 'alloca', alloca.opcode

    store = block.instructions[1]
    assert_equal 'store', store.opcode
    assert_equal 2, store.operands.length

    load_inst = block.instructions[2]
    assert_equal 'load', load_inst.opcode
  end
end
