#!/usr/bin/env ruby
# frozen_string_literal: true

# S4C: LLVM IR (.ll) → SUBNEG4 assembly compiler
#
# Usage:
#   ruby s4c.rb input.ll [-o output.s4]
#   echo "source.c" | clang -S -emit-llvm -O0 -o - - | ruby s4c.rb -
#
# Pipeline:
#   source.c → clang -S -emit-llvm -O0 → source.ll → s4c → output.s4

$LOAD_PATH.unshift(File.join(__dir__, 'lib'))

require 'parser'
require 'ir_nodes'
require 'lowering'
require 'expander'
require 'emitter'
require 'optimizer'

def main
  input_file = nil
  output_file = nil
  show_result = false
  no_opt = false

  args = ARGV.dup
  while args.any?
    arg = args.shift
    case arg
    when '-o'
      output_file = args.shift
    when '-r', '--show-result'
      show_result = true
    when '--no-opt'
      no_opt = true
    when '-h', '--help'
      usage
      exit 0
    when '-'
      input_file = :stdin
    else
      input_file = arg
    end
  end

  unless input_file
    usage
    exit 1
  end

  # Read input
  source = if input_file == :stdin
             $stdin.read
           else
             File.read(input_file)
           end

  # Parse .ll
  parser = S4C::Parser.new
  ir_module = parser.parse(source)

  if ir_module.functions.empty?
    $stderr.puts "s4c: no functions found in input"
    exit 1
  end

  $stderr.puts "s4c: parsed #{ir_module.functions.length} function(s): #{ir_module.functions.map(&:name).join(', ')}"

  # Lower IR → pseudo-ops
  lowering = S4C::Lowering.new
  lowering.lower(ir_module)

  $stderr.puts "s4c: generated #{lowering.pseudo_ops.length} pseudo-operations"

  # Optimize pseudo-ops
  ops = lowering.pseudo_ops
  unless no_opt
    optimizer = S4C::Optimizer.new(ops, lowering.mem)
    ops = optimizer.optimize
    $stderr.puts "s4c: optimized to #{ops.length} pseudo-operations (removed #{optimizer.stats[:removed]} in #{optimizer.stats[:iterations]} iterations)"
  end

  # Expand pseudo-ops → SUBNEG4
  expander = S4C::Expander.new(lowering.mem)
  expander.expand(ops)

  $stderr.puts "s4c: expanded to #{expander.instructions.count { |i| i.is_a?(S4C::Subneg4) }} SUBNEG4 instructions"

  # Emit assembly
  emitter = S4C::Emitter.new(lowering.mem, expander.instructions, show_result: show_result)
  output = emitter.emit

  # Write output
  if output_file
    File.write(output_file, output)
    $stderr.puts "s4c: wrote #{output_file}"
  else
    puts output
  end
end

def usage
  $stderr.puts <<~HELP
    Usage: ruby s4c.rb INPUT.ll [-o OUTPUT.s4]

    S4C compiles LLVM IR text (.ll) to SUBNEG4 assembly.

    Options:
      -o FILE    Write output to FILE (default: stdout)
      -r         Add output directive showing return value
      --no-opt   Disable optimization passes
      -          Read from stdin
      -h         Show this help

    Example:
      clang -S -emit-llvm -O0 -o add.ll add.c
      ruby s4c.rb add.ll -o add.s4
  HELP
end

main
