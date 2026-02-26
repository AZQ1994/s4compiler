# Benchmark: measure data entries, code instructions, and cycle counts
$LOAD_PATH.unshift(File.join(__dir__, 'lib'))
require 'parser'
require 'lowering'
require 'expander'
require 'emitter'
require 'optimizer'

# Minimal SUBNEG4 simulator
class Sim
  def initialize(source)
    @labels = {}; @memory = []; @pending = []
    parse(source); resolve
  end

  def run(max = 10_000_000)
    pc = 0; cy = 0
    while cy < max
      cy += 1
      return { cycles: cy, error: "OOB #{pc}" } if pc < 0 || pc >= @memory.length
      a, b, c, d = @memory[pc], @memory[pc+1], @memory[pc+2], @memory[pc+3]
      va = (a >= 0 && a < @memory.length) ? (@memory[a] || 0) : 0
      vb = (b >= 0 && b < @memory.length) ? (@memory[b] || 0) : 0
      r = vb - va
      @memory[c] = r if c >= 0 && c < @memory.length
      if r < 0
        return { cycles: cy } if d == -1
        pc = d
      else
        pc += 4
      end
    end
    { cycles: max, error: "max cycles" }
  end

  def read(name); addr = @labels[name]; addr ? @memory[addr] : nil; end

  private

  def parse(source)
    instrs = []; data = []; allocs = []
    source.each_line do |raw|
      line = raw.strip.sub(/\s*\/\/.*$/, '').strip
      next if line.empty? || line.start_with?('>>>')
      if line.start_with?("\#{") && line.end_with?('}#')
        parts = line[2..-3].split(',').map(&:strip)
        allocs << [parts[0].to_i, parts[1], parts[2]] if parts.length == 3
        next
      end
      line.include?(',') ? instrs << line.split(',').map(&:strip) : data << line
    end
    addr = 0
    instrs.each do |parts|
      base = addr
      parts.each do |op|
        segs = op.split(':'); val = segs.pop
        segs.each { |l| @labels[l] = addr }
        @memory[addr] = case val
          when 'NEXT' then base + 4
          when 'HALT' then -1
          when /^-?\d+$/ then val.to_i
          else @pending << [addr, val]; 0
        end
        addr += 1
      end
    end
    data.each do |entry|
      segs = entry.split(':'); val = segs.pop
      segs.each { |l| @labels[l] = addr }
      if val =~ /^&(.+)$/
        @pending << [addr, $1]; @memory[addr] = 0
      elsif val =~ /^-?\d+$/
        @memory[addr] = val.to_i
      else
        @pending << [addr, val]; @memory[addr] = 0
      end
      addr += 1
    end
    allocs.each do |size, sl, el|
      size.times do |i|
        @labels[sl] = addr if i == 0
        @labels[el] = addr if i == size - 1
        @memory[addr] = 0; addr += 1
      end
    end
  end

  def resolve
    @pending.each { |addr, label| @memory[addr] = @labels[label] || raise("Unresolved: #{label}") }
  end
end

def compile(path)
  source = File.read(path)
  ir = S4C::Parser.new.parse(source)
  low = S4C::Lowering.new; low.lower(ir)
  opt = S4C::Optimizer.new(low.pseudo_ops, low.mem); optimized = opt.optimize
  exp = S4C::Expander.new(low.mem); exp.expand(optimized)
  em = S4C::Emitter.new(low.mem, exp.instructions, show_result: true)
  em.emit
end

puts "%-22s %6s %6s %10s %6s" % ["test", "data", "code", "cycles", "result"]
puts "-" * 56
Dir.glob(File.join(__dir__, 'test/fixtures/*.ll')).sort.each do |path|
  name = File.basename(path, '.ll')
  asm = compile(path)
  data = asm.lines.count { |l| l =~ /^\w[^,]*$/ && l.include?(':') }
  code = asm.lines.count { |l| l.include?(',') && l =~ /\w/ && l !~ /^\/\// }
  sim = Sim.new(asm)
  res = sim.run(100_000_000)
  val = sim.read("main___retval")
  cy = res[:error] ? "ERR" : res[:cycles].to_s
  puts "%-22s %6d %6d %10s %6s" % [name, data, code, cy, val]
end
