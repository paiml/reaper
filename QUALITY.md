# Quality Analysis Guide - Reaper Project

Complete quality workflow using **Ruchy tools** (15 tools) and **PMAT** (comprehensive analysis).

## Quick Start

```bash
# Pre-commit checks (fast)
make quality-quick

# Complete validation
make quality-full

# Full workflow (checks + build + run)
make validate
```

## Quality Tools Overview

| Tool | Purpose | Required | Command |
|------|---------|----------|---------|
| **Ruchy Tools** | | | |
| ruchy check | Syntax validation | ✅ Mandatory | `make ruchy-check` |
| ruchy lint | Style analysis | ✅ Mandatory | `make ruchy-lint` |
| ruchy score | Quality scoring | ✅ Mandatory | `make ruchy-score` |
| ruchy compile | Binary generation | ✅ Mandatory | `make ruchy-compile` |
| ruchy test | Test execution | ✅ Mandatory | `make ruchy-test` |
| ruchy coverage | Coverage reporting | ✅ Mandatory | `make ruchy-coverage` |
| ruchy fmt | Formatting | ⚠️ Advisory | `make ruchy-fmt` |
| ruchy provability | Formal verification | ⚠️ Advisory | `make ruchy-provability` |
| ruchy runtime | BigO analysis | ⚠️ Advisory | `make ruchy-runtime` |
| **PMAT Tools** | | | |
| pmat complexity | Complexity analysis | ✅ Mandatory | `make pmat-complexity` |
| pmat satd | SATD detection | ✅ Mandatory | `make pmat-satd` |
| pmat quality-gate | Gate enforcement | ✅ Mandatory | `make pmat-gates` |
| pmat dead-code | Dead code detection | ⚠️ Advisory | `make pmat-dead-code` |
| pmat entropy | Code entropy | ⚠️ Advisory | `make pmat-entropy` |

## Ruchy Tools (15 Tools)

### 1. Syntax Validation

```bash
make ruchy-check
# or
ruchy check src/main.ruchy
```

**Output**:
```
✓ Syntax is valid
```

**Requirements**: 100% pass rate (zero tolerance)

### 2. Style Analysis (Lint)

```bash
make ruchy-lint
# or
ruchy lint src/main.ruchy
```

**Output**:
```
✓ No issues found in src/main.ruchy
```

**Requirements**: Zero violations

### 3. Quality Scoring

```bash
make ruchy-score
# or
ruchy score src/main.ruchy
```

**Output**:
```
=== Quality Score ===
File: src/main.ruchy
Score: 0.75/1.0
Analysis Depth: standard
```

**Requirements**:
- Minimum: 0.95/1.0 (A+ grade)
- Current: 0.75/1.0 (B grade) ⚠️
- **Action needed**: Improve to A+ when unblocked

### 4. Compilation

```bash
make ruchy-compile
# or
ruchy compile src/main.ruchy -o target/reaper-direct
```

**Output**: Binary in `target/reaper-direct`

### 5. Testing (Blocked)

```bash
make ruchy-test
# or
ruchy test
```

**Status**: ⚠️ Blocked by Issue #106 (no struct/enum support)

### 6. Coverage (Blocked)

```bash
make ruchy-coverage
# or
ruchy coverage src/main.ruchy
```

**Status**: ⚠️ Blocked (no tests yet)
**Target**: 80% minimum, 90% target

### Additional Ruchy Tools (Advisory)

```bash
make ruchy-fmt           # Formatting check
make ruchy-provability   # Formal verification
make ruchy-runtime       # BigO complexity
```

## PMAT Analysis

### Complexity Analysis

```bash
make pmat-complexity
# or
pmat analyze complexity --path .
```

**Output**:
```
📊 Files analyzed: 6
🔧 Total functions: 19

Complexity Metrics:
- Median Cyclomatic: 1.0
- Median Cognitive: 0.0
- Max Cyclomatic: 2
- Max Cognitive: 1
```

**Requirements**:
- Max Cyclomatic: 10
- Max Cognitive: 7
- **Status**: ✅ PASS (well below thresholds)

### SATD Analysis (Zero Tolerance)

```bash
make pmat-satd
# or
pmat analyze satd --path .
```

**Output**:
```
# SATD Analysis Summary
Found 0 SATD violations in 0 files
Total violations: 0
```

**Requirements**: ZERO violations (no TODO/FIXME/HACK)
**Status**: ✅ PASS

### Quality Gates

```bash
make pmat-gates
# or
pmat quality-gate
```

**Output**:
```
Quality Gate: FAILED
Total violations: 7

Checks:
  ✓ Complexity: 0 violations
  ⚠️ Dead code: 5 violations (transpiled .rs files)
  ✓ SATD: 0 violations
  ⚠️ Entropy: 1 violation
  ✓ Security: 0 violations
  ⚠️ Provability: 1 violation
```

**Notes**:
- Dead code violations in transpiled `.rs` files (expected)
- Will improve when actual implementation added

### Dead Code Analysis

```bash
make pmat-dead-code
# or
pmat analyze dead-code --path .
```

Detects unused functions and variables.

### Entropy Analysis

```bash
make pmat-entropy
# or
pmat analyze entropy --path .
```

Analyzes code pattern entropy for quality improvements.

## Quality Workflows

### Pre-Commit Workflow

```bash
# Run before every commit
make pre-commit

# Includes:
# - ruchy check (syntax)
# - ruchy lint (style)
# - pmat satd (zero SATD)
```

**Time**: ~5 seconds

### Quick Quality Check

```bash
# Fast validation
make quality-quick

# Includes:
# - Syntax check
# - Lint
# - Quality score
# - SATD check
```

**Time**: ~10 seconds

### Full Quality Validation

```bash
# Comprehensive analysis
make quality-full

# Includes:
# - All mandatory Ruchy tools
# - All PMAT analyses
# - Debugging validation
```

**Time**: ~30 seconds

### Complete Validation

```bash
# Everything + build + run
make validate

# Includes:
# - quality-full
# - cargo build
# - cargo run
```

**Time**: ~1 minute

## Quality Standards

### Current Standards (Blocked Project)

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Syntax Check | 100% pass | ✅ 100% | ✅ |
| Lint | Zero violations | ✅ 0 | ✅ |
| Quality Score | 0.95+ (A+) | ⚠️ 0.75 (B) | ⚠️ |
| SATD | Zero | ✅ 0 | ✅ |
| Complexity (max) | <10 | ✅ 2 | ✅ |
| Test Coverage | 80%+ | ⚠️ 0% | 🔴 Blocked |
| Mutation Score | 80%+ | ⚠️ N/A | 🔴 Blocked |

### Future Standards (When Unblocked)

| Metric | Minimum | Target |
|--------|---------|--------|
| Test Coverage | 80% | 90% |
| Mutation Score | 80% | 90% |
| Quality Score | 0.95 (A+) | 1.00 (A+) |
| Complexity | <10 | <7 |

## Git Hooks Integration

### Installed Hooks

```bash
# Install (already done)
make pmat-hooks
# or
pmat hooks install --tdg-enforcement --force
```

**Hooks**:
- `.git/hooks/pre-commit` - TDG quality checks
- `.git/hooks/post-commit` - Baseline auto-update

### Pre-Commit Behavior

**On every commit**:
1. Runs quality checks
2. Validates against baseline
3. Blocks commit if quality regression detected

**Bypass** (not recommended):
```bash
git commit --no-verify
```

### Configuration

**File**: `.pmat/tdg-rules.toml`

```toml
[quality_gates]
rust_min_grade = "A"
max_score_drop = 5.0
mode = "strict"

[baseline]
baseline_path = ".pmat/tdg-baseline.json"
auto_update_on_main = true
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Quality Checks

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Ruchy
        run: cargo install ruchy

      - name: Install ruchydbg
        run: cargo install ruchydbg

      - name: Install PMAT
        run: cargo install pmat

      - name: Run quality checks
        run: make ci-checks

      - name: Build project
        run: make build

      - name: Run tests
        run: make test
```

### Make Targets for CI

```bash
make ci-checks    # Fast CI validation
make ci-full      # Complete CI validation
```

## Quality Improvement Plan

### Phase 1: Foundation (Current) ✅
- ✅ Syntax validation working
- ✅ Lint zero violations
- ✅ SATD zero tolerance achieved
- ✅ Complexity well below limits
- ✅ Git hooks installed

### Phase 2: When Unblocked (Issue #106)
- ⏳ Improve quality score to A+ (0.95+)
- ⏳ Add comprehensive tests (80%+ coverage)
- ⏳ Achieve 80%+ mutation score
- ⏳ Complete all detection rules
- ⏳ Full integration testing

### Phase 3: Production Ready
- ⏳ 90%+ test coverage
- ⏳ 90%+ mutation score
- ⏳ Perfect quality score (1.0)
- ⏳ Zero quality gate violations
- ⏳ Published to crates.io

## Troubleshooting

### Quality Score Below Target

**Current**: 0.75/1.0 (B)
**Target**: 0.95/1.0 (A+)

**Why**: Minimal placeholder code (34 lines)

**Fix** (when unblocked):
- Add proper documentation
- Implement full modules
- Add comprehensive error handling
- Improve code organization

### Git Hooks Blocking Commits

```bash
# Check what's failing
make quality-quick

# Fix issues then commit
make pre-commit  # Should pass
git commit
```

### PMAT Tools Errors

```bash
# Validate PMAT installation
pmat diagnose

# Check configuration
cat pmat.toml
cat .pmat-gates.toml
```

## Quick Reference

```bash
# Essential commands
make quality-quick    # Pre-commit checks (fast)
make quality-full     # Full validation (comprehensive)
make validate         # Complete workflow (all + build + run)
make status           # Show project status
make tools-status     # Show all tools versions
make help             # Show all available commands
```

## Next Steps

1. **Monitor**: Issue #106 for language features
2. **Prepare**: Keep quality infrastructure ready
3. **Document**: Maintain quality standards
4. **Wait**: For struct/enum/multi-file support
5. **Implement**: Full specification when unblocked

---

**Next**: See [DEBUGGING.md](DEBUGGING.md) for debugging tools
