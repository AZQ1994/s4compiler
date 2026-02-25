# S4C — LLVM IR to SUBNEG4 Compiler

S4C compiles LLVM IR (`.ll`) to SUBNEG4 assembly (`.s4`).

[SUBNEG4](https://en.wikipedia.org/wiki/One-instruction_set_computer#Subtract_and_branch_if_less_than_or_equal_to_zero) is a one-instruction set computer (OISC): each instruction has 4 operands `A B C D` and executes `mem[C] = mem[B] - mem[A]; if result < 0 then goto D`.

## Quick Start

```bash
# Compile C to LLVM IR
clang -S -emit-llvm -O0 -o program.ll program.c

# Compile LLVM IR to SUBNEG4 assembly
ruby s4c.rb program.ll -o program.s4

# Or skip the optimizer
ruby s4c.rb program.ll -o program.s4 --no-opt
```

## Pipeline

```
.c  →  clang -S -emit-llvm  →  .ll  →  S4C  →  .s4
                                         │
                              ┌──────────┴──────────┐
                              │  Parser (.ll regex)  │
                              │  Lowering (IR→pseudo) │
                              │  Optimizer (13 passes)│
                              │  Expander (→SUBNEG4)  │
                              │  Emitter (.s4 text)   │
                              └─────────────────────┘
```

## Supported LLVM IR Features

- **Arithmetic**: `add`, `sub`, `mul`, `sdiv`, `srem`
- **Bitwise**: `and`, `or`, `xor`, `shl`, `ashr`, `lshr`
- **Comparisons**: `icmp` (`slt`, `sgt`, `sle`, `sge`, `eq`, `ne`)
- **Control flow**: `br` (conditional/unconditional), `select`, `phi`
- **Memory**: `alloca` (scalar/array), `load`, `store`, `getelementptr`
- **Functions**: `call` with save/restore (recursion-safe), `ret`, multi-function
- **Pointers**: `ptr` parameters, indirect load/store, passing arrays
- **Global variables**
- **Casts**: `sext`, `zext`, `trunc`, `bitcast`

## Optimizer

13 iterative passes (up to 10 rounds until convergence):

| # | Pass | Description |
|---|------|-------------|
| 1 | GotoNextElimination | Remove `goto L` followed by `L:` |
| 2 | GotoChainSimplification | Redirect `goto L1` when `L1: goto L2` |
| 3 | RedundantBranchElimination | `branch(x, L) + goto L` → `goto L` |
| 4 | UnreachableCodeElimination | Remove code after unconditional jumps |
| 5 | DeadLabelElimination | Remove unreferenced labels |
| 6 | ConstantFolding | Evaluate constant expressions at compile time |
| 7 | StrengthReduction | `x + 0` → `x`, `x - x` → `0` |
| 8 | PeepholeDoubleNegation | `-(-x)` → `x` |
| 9 | LocalValueNumbering | Within-block CSE (common subexpression elimination) |
| 10 | LoopInvariantCodeMotion | Hoist invariant ops before loop header |
| 11 | CopyPropagation | Forward substitution of copies |
| 12 | DeadStoreElimination | Remove writes to unused variables |
| 13 | PushPopElimination | Remove unused save/restore pairs |

Additionally, the lowering phase performs **constant specialization**:
- `mul(x, 0..8)` → inline addition chains (no subroutine call)
- `sdiv(x, 1)`, `srem(x, 1)` → identity/zero

## Tests

```bash
ruby -Ilib test/test_e2e.rb        # 26 end-to-end tests
ruby -Ilib test/test_optimizer.rb   # 54 optimizer unit tests
```

Test fixtures include: fibonacci, factorial, collatz, sieve of Eratosthenes, GCD, bubble sort, matrix multiplication, Tower of Hanoi, and more.

## Project Structure

```
s4c.rb              CLI entry point
lib/
  parser.rb         Regex-based .ll parser
  ir_nodes.rb       IR data structures
  lowering.rb       IR → pseudo-op conversion
  pseudo_ops.rb     Pseudo-instruction definitions
  optimizer.rb      13-pass optimizer
  expander.rb       Pseudo-ops → SUBNEG4 expansion
  emitter.rb        SUBNEG4 assembly text output
  memory.rb         Variable/constant allocation
test/
  test_e2e.rb       E2E tests with built-in SUBNEG4 simulator
  test_optimizer.rb Optimizer unit tests
  fixtures/         .c and .ll test programs
```

## Limitations

- No unsigned comparisons (`ult`, `ugt`, `ule`, `uge`)
- No floating point
- No i8/string handling (everything is word-sized)
- No struct support
- Arithmetic operations are loop-based (mul is O(n), div/mod is O(n/d))
