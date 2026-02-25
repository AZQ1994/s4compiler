# frozen_string_literal: true

require 'minitest/autorun'
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
require 'parser'
require 'lowering'
require 'expander'
require 'emitter'

# Minimal SUBNEG4 simulator for testing s4c output
class Subneg4Sim
  attr_reader :memory, :labels

  def initialize(source)
    @labels = {}
    @memory = []
    @pending_refs = []
    parse_and_build(source)
    resolve_refs
  end

  def run(max_cycles: 1_000_000)
    pc = 0
    cycle = 0

    while cycle < max_cycles
      cycle += 1

      return { halted: true, cycles: cycle, error: "PC out of bounds: #{pc}" } if pc < 0 || pc >= @memory.length

      addr_a = @memory[pc] || 0
      addr_b = @memory[pc + 1] || 0
      addr_c = @memory[pc + 2] || 0
      addr_d = @memory[pc + 3] || 0

      val_a = read(addr_a)
      val_b = read(addr_b)

      result = val_b - val_a

      write(addr_c, result) if addr_c >= 0 && addr_c < @memory.length

      if result < 0
        if addr_d == -1
          return { halted: true, cycles: cycle }
        end
        pc = addr_d
      else
        pc += 4
      end
    end

    { halted: false, cycles: cycle, error: "Max cycles exceeded" }
  end

  def read_label(name)
    addr = @labels[name]
    return nil unless addr
    @memory[addr]
  end

  private

  def read(addr)
    return 0 if addr < 0 || addr >= @memory.length
    @memory[addr] || 0
  end

  def write(addr, value)
    @memory[addr] = value if addr >= 0 && addr < @memory.length
  end

  def parse_and_build(source)
    instructions = []
    data_entries = []
    allocations = []

    source.each_line do |raw_line|
      line = raw_line.strip
      line = line.sub(/\s*\/\/.*$/, '').strip
      next if line.empty?
      next if line.start_with?('>>>')

      if line.start_with?("\#{") && line.end_with?('}#')
        inner = line[2..-3]
        alloc_parts = inner.split(',').map(&:strip)
        if alloc_parts.length == 3
          allocations << [alloc_parts[0].to_i, alloc_parts[1], alloc_parts[2]]
          next
        end
      end

      if line.include?(',')
        parts = line.split(',').map(&:strip)
        next unless parts.length == 4
        instructions << parts
      else
        data_entries << line
      end
    end

    addr = 0

    # Instructions (4 words each)
    instructions.each do |parts|
      base = addr
      parts.each do |operand|
        segments = operand.split(':')
        value_str = segments.pop
        segments.each { |l| @labels[l] = addr }

        if value_str == 'NEXT'
          @memory[addr] = base + 4
        elsif value_str == 'HALT'
          @memory[addr] = -1
        elsif value_str =~ /^-?\d+$/
          @memory[addr] = value_str.to_i
        else
          @memory[addr] = 0
          @pending_refs << [addr, value_str]
        end

        addr += 1
      end
    end

    # Data entries (1 word each)
    data_entries.each do |entry|
      segments = entry.split(':')
      value_str = segments.pop
      segments.each { |l| @labels[l] = addr }

      if value_str =~ /^&(.+)$/
        @memory[addr] = 0
        @pending_refs << [addr, $1]
      elsif value_str =~ /^-?\d+$/
        @memory[addr] = value_str.to_i
      else
        @memory[addr] = 0
        @pending_refs << [addr, value_str]
      end

      addr += 1
    end

    # Allocations
    allocations.each do |size, start_label, end_label|
      size.times do |i|
        @labels[start_label] = addr if i == 0
        @labels[end_label] = addr if i == size - 1
        @memory[addr] = 0
        addr += 1
      end
    end
  end

  def resolve_refs
    @pending_refs.each do |addr, label|
      resolved = @labels[label]
      raise "Unresolved label: '#{label}' (referenced at addr #{addr})" unless resolved
      @memory[addr] = resolved
    end
  end
end

class TestE2E < Minitest::Test
  def compile_and_run(ll_path, max_cycles: 1_000_000)
    source = File.read(ll_path)
    parser = S4C::Parser.new
    ir_module = parser.parse(source)
    lowering = S4C::Lowering.new
    lowering.lower(ir_module)
    expander = S4C::Expander.new(lowering.mem)
    expander.expand(lowering.pseudo_ops)
    emitter = S4C::Emitter.new(lowering.mem, expander.instructions, show_result: true)
    asm = emitter.emit

    sim = Subneg4Sim.new(asm)
    result = sim.run(max_cycles: max_cycles)
    [sim, result, asm]
  end

  def fixture(name)
    File.join(__dir__, 'fixtures', name)
  end

  def test_simple_add
    # int main() { int a=3; int b=5; int c=a+b; return c; } → should return 8
    sim, result, _ = compile_and_run(fixture('simple_add.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected"
    assert_equal 8, sim.read_label('main___retval')
  end

  def test_mul
    # int main() { int a = 7; int b = 8; int c = a * b; return c; } → should return 56
    sim, result, _ = compile_and_run(fixture('mul.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 56, sim.read_label('main___retval')
  end

  def test_fib
    # int fib(int n) { if (n<=1) return n; return fib(n-1)+fib(n-2); }
    # int main() { return fib(10); } → should return 55
    sim, result, _ = compile_and_run(fixture('fib.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 55, sim.read_label('main___retval')
  end

  def test_max
    # int main() { int a=7,b=3; if(a>b) return a; else return b; } → should return 7
    sim, result, _ = compile_and_run(fixture('max.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 7, sim.read_label('main___retval')
  end

  def test_loop_sum
    # int main() { int sum=0; for(int i=1;i<=10;i++) sum+=i; return sum; } → should return 55
    sim, result, _ = compile_and_run(fixture('loop_sum.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 55, sim.read_label('main___retval')
  end

  def test_call
    # int add(int a, int b) { return a+b; }
    # int main() { return add(3,5); } → should return 8
    sim, result, _ = compile_and_run(fixture('call.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 8, sim.read_label('main___retval')
  end

  def test_array
    # int main() { int a[3]={10,20,30}; return a[0]+a[1]+a[2]; } → should return 60
    sim, result, _ = compile_and_run(fixture('array.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 60, sim.read_label('main___retval')
  end

  def test_eq
    # int main() { int a=5, b=5; if (a==b) return 42; return 0; } → should return 42
    sim, result, _ = compile_and_run(fixture('eq_test.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 42, sim.read_label('main___retval')
  end

  def test_factorial
    # factorial(6) = 720
    sim, result, _ = compile_and_run(fixture('factorial.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 720, sim.read_label('main___retval')
  end

  def test_shift
    # 5 << 3 = 40; 100 >> 2 = 25 (constant-folded); 40 + 25 = 65
    sim, result, _ = compile_and_run(fixture('shift.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 65, sim.read_label('main___retval')
  end

  def test_bitwise
    # 0xAB & 0x0F = 11; 0xAB | 0x0F = 175; 0xAB ^ 0x0F = 164; sum = 350
    sim, result, _ = compile_and_run(fixture('bitwise.ll'), max_cycles: 100_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 350, sim.read_label('main___retval')
  end

  def test_gcd
    # gcd(48, 18) = 6
    sim, result, _ = compile_and_run(fixture('gcd.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 6, sim.read_label('main___retval')
  end

  def test_collatz
    # collatz_steps(27) = 111
    sim, result, _ = compile_and_run(fixture('collatz.ll'), max_cycles: 100_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 111, sim.read_label('main___retval')
  end

  def test_array_sum
    # Sum array with variable index: a[0..4] = {10,20,30,40,50} → sum = 150
    sim, result, _ = compile_and_run(fixture('array_sum.ll'))
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 150, sim.read_label('main___retval')
  end

  def test_bubble_sort
    # Bubble sort [50,20,40,10,30] → [10,20,30,40,50]; return a[0]+a[4] = 60
    sim, result, _ = compile_and_run(fixture('bubble_sort.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 60, sim.read_label('main___retval')
  end

  def test_global
    # Global variables: counter=10, multiplier=3; compute() = 10*3 = 30
    sim, result, _ = compile_and_run(fixture('global.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 30, sim.read_label('main___retval')
  end

  def test_array_func
    # Pass array to function, sum elements: {100,200,300,400} → 1000
    sim, result, _ = compile_and_run(fixture('array_func.ll'), max_cycles: 10_000_000)
    assert result[:halted], "Program should halt"
    refute result[:error], "No error expected: #{result[:error]}"
    assert_equal 1000, sim.read_label('main___retval')
  end
end
