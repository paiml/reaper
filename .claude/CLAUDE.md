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
