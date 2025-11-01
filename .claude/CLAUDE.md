# Reaper Project - Claude Code Instructions

## Project Overview

**Reaper v1.0.0** - Rogue process watcher and terminator written in Ruchy language.

- **Language**: Ruchy (Ruby-like syntax, compiles to Rust)
- **Status**: CODE COMPLETE, publication blocked by transpiler regression
- **Quality**: 100% test coverage, 0 SATD violations, 110 comprehensive tests
- **Architecture**: Single-file (src/main.ruchy) due to Ruchy v3.155.0 limitations

---

## Development Workflow

### Quality Standards (Extreme TDD)
- ✅ 100% line and function coverage (validated with `ruchy coverage`)
- ✅ Zero technical debt (SATD = 0, validated with PMAT)
- ✅ All tests passing (110 tests: 100 example + 10 property-based)
- ✅ RED-GREEN-REFACTOR for every function
- ✅ Atomic commits per roadmap ticket

### Build & Test Commands

```bash
# Syntax validation
ruchy check src/main.ruchy

# Run all tests (100 example + 10 property)
ruchy test src/main.ruchy

# Coverage analysis
ruchy coverage src/main.ruchy

# Execute program
ruchy run src/main.ruchy

# Transpile to Rust (currently blocked by v3.167.0 regression)
cargo build --release
cargo test
```

---

## Ruchy Stack Profiler (DEBUGGER-041)

### Overview

The Ruchy stack profiler analyzes function call depth and identifies performance hotspots. Essential for:
- Debugging deep recursion patterns
- Performance analysis and optimization
- Preventing stack overflow bugs
- Understanding execution flow

### Usage

**Profile any Ruchy file**:
```bash
ruchydbg profile --stack src/main.ruchy
```

**Output provides**:
- Maximum call depth reached during execution
- Total function calls executed
- Per-function call counts (which functions are hot)
- Call stack at maximum depth (for debugging deep recursion)

**Performance**: <5% overhead (typically <1%)

### Example Output

```
=== Stack Depth Profile ===

File: src/main.ruchy
Max depth: 5
Total calls: 127

Call counts:
  test_process_creation: 1 call
  test_priority_high_vs_medium: 1 call
  is_higher_priority: 2 calls
  new_process: 45 calls
  format_process: 12 calls
  ...

Deepest call stack:
  1. test_nested_function_calls
  2. outer_function
  3. middle_function
  4. inner_function
  5. deepest_function
```

### When to Use

1. **Debugging recursion** - Identify infinite recursion before stack overflow
2. **Performance analysis** - Find hotspots (most-called functions)
3. **Architecture validation** - Verify call depth expectations
4. **Regression testing** - Track performance changes across versions

### Integration with Reaper

**Current Status**: Ready to use, but transpiler regression blocks execution

**Expected Profile** (when transpiler is fixed):
- Max depth: ~3 (tests → functions → helpers)
- Total calls: ~500-700 (110 tests × ~5-6 calls each)
- Hot functions: `new_process`, `new_detection_rule`, `rule_matches_process`

---

## Ruchy Pathological Input Detector (DEBUGGER-042)

### Overview

The pathological detector finds **performance cliffs** - specific inputs that cause extreme slowdown (10x-1000x) compared to typical inputs. Complements other testing tools:

- **Fuzzing** finds crashes (binary: crash or no crash)
- **Benchmarking** measures average performance across typical inputs
- **Pathological detector** finds specific inputs causing performance degradation

Essential for:
- Detecting quadratic/exponential algorithmic complexity
- Finding parser stress cases (deeply nested expressions)
- Preventing production performance issues
- Performance regression testing

### Usage

**Detect pathological inputs**:
```bash
# Default 10x threshold
ruchydbg detect test.ruchy

# Custom threshold (15x)
ruchydbg detect test.ruchy --threshold 15
```

**Exit codes**:
- `0`: Performance within acceptable bounds ✅
- `1`: Pathological input detected ⚠️

**Performance**: Runs code once, measures time vs baseline

### Categories of Pathological Inputs

1. **ParserStress**: Deeply nested expressions, long identifier chains
   - Example: `((((1 + 2) + 3) + 4) + ...)` (50+ levels)
   - Causes: Parser recursion depth, stack pressure

2. **EvaluatorStress**: Quadratic variable lookup, deep call stacks
   - Example: `let a=1; let b=a; let c=b; ... lookup(z)`
   - Causes: Linear scan through N variables → O(N²)

3. **MemoryStress**: Allocation bombs, exponential structure growth
   - Example: Exponential tree expansion
   - Causes: Unbounded memory allocation

### Example Output

**Simple arithmetic** (NOT pathological):
```
=== Pathological Input Detection ===

File: test_simple.ruchy
Category: ParserStress
Threshold: 10.0x

Performance:
  Baseline: 5.60 µs
  Actual: 31.99 µs
  Slowdown: 5.71x

✅ Performance within acceptable bounds
```

**Nested expression** (pathological):
```
=== Pathological Input Detection ===

File: test_nested_100.ruchy
Category: ParserStress
Threshold: 10.0x

Performance:
  Baseline: 5.60 µs
  Actual: 245.80 µs
  Slowdown: 43.89x

⚠️  PATHOLOGICAL INPUT DETECTED!
    This input causes 43.89x performance degradation
```

### Performance Baselines

From INTERP-030 benchmarking (averaged over 1000+ iterations):

| Operation | Baseline Time | Notes |
|-----------|---------------|-------|
| Simple arithmetic | 5.6 µs | `1 + 2 + 3` |
| Variable ops | 12.0 µs | Variable lookup + assignment |
| Function call | 20.0 µs | Function invocation overhead |

**Important**: Single-run measurements have 6-8x variance vs averaged baselines (cold start, JIT warmup). Default 10x threshold accounts for this.

### When to Use

1. **Pre-production testing** - Validate inputs won't cause performance issues
2. **Regression testing** - Detect when code changes introduce performance cliffs
3. **Security testing** - Find DoS-vulnerable inputs (algorithmic complexity attacks)
4. **Development** - Test edge cases that stress parser/evaluator

### Integration with Reaper

**Current Status**: Ready to use, but enum syntax blocks parser

**Expected Use Cases** (when fixed):
1. **Validate test complexity**: Ensure tests don't have pathological patterns
2. **Detect accidental O(N²)**: Large rule sets with many processes
3. **Parser stress testing**: Verify deeply nested detection rules don't cause issues

**Example Test**:
```bash
# Test if 100 rules × 100 processes causes quadratic blowup
ruchydbg detect test_large_ruleset.ruchy --threshold 20
```

**Red Flags for Reaper**:
- ⚠️ Slowdown > 10x: May indicate quadratic behavior in `apply_rules()`
- ⚠️ Parser stress: Deep nesting in rule conditions
- ⚠️ Memory stress: Creating thousands of Process objects

### Input Generators

Built-in generators for common pathological patterns:

```rust
// Deeply nested expressions
PathologicalDetector::generate_nested_expression(20);
// Output: ((((1 + 2) + 3) + 4) + ... + 20)

// Quadratic variable lookup
PathologicalDetector::generate_quadratic_lookup(10);
// Output: let a=1; let b=a; let c=b; ... lookup(j)
```

### Comparison: Testing Tools

| Tool | Finds | Overhead | When to Use |
|------|-------|----------|-------------|
| **Pathological Detector** | Performance cliffs | Single run | Pre-production, security |
| Stack Profiler | Call depth, hotspots | <1% | Recursion debugging |
| Fuzzer | Crashes, hangs | 10-100x | Finding bugs |
| Benchmarks | Average performance | Variable | Comparing implementations |
| Coverage | Untested code | ~5% | Test completeness |

---

## Roadmap & Status Tracking

**Sprint 8 Status**: 26.5/29 tickets complete (91%)

**Completed**:
- ✅ REAPER-701: Quality gate validation (9/10 PASS)
- ✅ REAPER-702: Publication preparation (LICENSE, version bump, README)
- ✅ REAPER-603: Property-based tests (10 tests added)

**Blocked**:
- 🛑 REAPER-703: Publish to crates.io (blocked by transpiler regression)
- ⏳ REAPER-704: Release announcement (deferred until publication)

**Transpiler Status**: Ruchy v3.167.0 has CRITICAL REGRESSION
- v3.166.0: 10 errors (91% progress)
- v3.167.0: 63 errors (REGRESSION - all v3.161.0-v3.164.0 fixes lost)
- GitHub Issue #111: Regression reported, awaiting fix

---

## GitHub Issues Filed

**Transpiler Issues**:
- [#111](https://github.com/paiml/ruchy/issues/111): Critical transpiler bugs (with v3.167.0 regression report)

**Tool Validation Issues**:
- [#112](https://github.com/paiml/ruchy/issues/112): Comprehensive tool suite validation (consolidates #107-#110)
- [#107](https://github.com/paiml/ruchy/issues/107): ruchy lint false positives
- [#108](https://github.com/paiml/ruchy/issues/108): ruchy mutations finds 0 mutants
- [#109](https://github.com/paiml/ruchy/issues/109): ruchy quality-gate false violations
- [#110](https://github.com/paiml/ruchy/issues/110): ruchy doc minimal extraction

---

## Important Files

| File | Purpose | Lines |
|------|---------|-------|
| `src/main.ruchy` | Complete implementation | 4,606 |
| `PROJECT_STATUS.md` | Comprehensive project status | 420 |
| `README.md` | Project documentation | 140 |
| `ARCHITECTURE.md` | Design rationale | 470 |
| `roadmap-v3.155.yaml` | Sprint planning | 298 |
| `LICENSE` | MIT License | 21 |

---

## Stack Profiler Best Practices

### For Reaper Development

1. **Before major refactoring**: Profile to establish baseline
   ```bash
   ruchydbg profile --stack src/main.ruchy > profile_baseline.txt
   ```

2. **After changes**: Compare profiles to detect regressions
   ```bash
   ruchydbg profile --stack src/main.ruchy > profile_after.txt
   diff profile_baseline.txt profile_after.txt
   ```

3. **Performance optimization**: Identify hot functions
   - Functions with highest call counts are optimization targets
   - Deep recursion (max_depth > 10) may need optimization

4. **Testing recursion**: Validate stack depth stays safe
   - Reaper should have shallow call stacks (depth < 5)
   - Deep stacks indicate potential architectural issues

### Red Flags

- ⚠️ Max depth > 30: Risk of stack overflow
- ⚠️ Single function dominates call counts: Potential bottleneck
- ⚠️ Unexpected recursion: May indicate logic bug

---

## Next Steps (When Transpiler Fixed)

1. **Profile baseline**: `ruchydbg profile --stack src/main.ruchy`
2. **Cargo build**: `cargo build --release`
3. **Cargo test**: `cargo test` (validate all 110 tests in Rust)
4. **Publish**: `cargo publish` (REAPER-703)
5. **Release**: GitHub release + announcement (REAPER-704)

---

**Status**: Awaiting Ruchy team to fix v3.167.0 regression
**Repository**: https://github.com/paiml/reaper
**Last Updated**: 2025-11-01
