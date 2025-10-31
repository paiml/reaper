# Contributing to Reaper

Thank you for your interest in contributing! This is a **showcase project** for the Ruchy programming language demonstrating extreme quality standards.

## Development Philosophy

We follow **Extreme TDD** with **Toyota Way** principles:

1. **Jidoka (Stop the Line)**: If you discover a bug in Ruchy, STOP immediately and file an issue
2. **Genchi Genbutsu (Go and See)**: Test everything, assume nothing
3. **Kaizen (Continuous Improvement)**: Every commit must improve quality
4. **Zero Defects**: All quality gates must pass

## Workflow

### 1. RED-GREEN-REFACTOR

Every feature follows this cycle:

```bash
# RED: Write failing test first
echo 'test_new_feature() { assert!(false) }' > tests/unit/new_feature.ruchy
ruchy test  # Should FAIL

# GREEN: Make it pass (minimum code)
# Write implementation

# REFACTOR: Clean up and optimize
ruchy lint
ruchy score  # Must be A+
```

### 2. Quality Gates

Before every commit:

```bash
# All gates must pass
ruchy check src/
ruchy lint src/
ruchy score src/  # Must be A+ (≥0.95)
pmat analyze tdg  # Must be grade A
pmat analyze satd # Must be 0 violations
ruchy test        # 100% pass rate
```

### 3. Bug Discovery Policy: STOP THE LINE

If you discover a **Ruchy compiler bug**:

1. **STOP immediately** - Don't continue development
2. **Create minimal reproduction** - Simplest possible example
3. **File GitHub issue**:
   ```bash
   gh issue create --repo paiml/ruchy \
     --title "Bug: [brief description]" \
     --body "$(cat bug-reproduction.ruchy)"
   ```
4. **Document in BLOCKED.md**:
   ```yaml
   - issue: "Brief description"
     github: "paiml/ruchy#123"
     workaround: "Description if any"
     status: "blocked"
   ```
5. **Implement workaround** if possible, or pause ticket

### 4. Ticket Workflow

All work is tracked via tickets in `roadmap.yaml`:

```yaml
- id: REAPER-XXX
  title: "Feature description"
  status: pending → in_progress → done
  tdd_cycle: RED-GREEN-REFACTOR
```

Update status after each phase:
```bash
# Starting ticket
sed -i 's/status: pending/status: in_progress/' roadmap.yaml
git commit -am "REAPER-XXX: Starting [feature]"

# Completing ticket
sed -i 's/status: in_progress/status: done/' roadmap.yaml
git commit -am "REAPER-XXX: Complete [feature]"
```

## Testing Requirements

### Coverage
- **Minimum**: 80%
- **Target**: 90%
- **Measure**: `ruchy coverage src/`

### Mutation Testing
- **Minimum**: 80% mutation score
- **Target**: 90% mutation score
- **Run**: `pmat mutate --target src/`

### Test Types

1. **Unit Tests** (`tests/unit/`)
   - Every function tested in isolation
   - Edge cases covered
   - Error paths tested

2. **Property Tests** (`tests/property/`)
   - State machines
   - Algorithms
   - Invariants

3. **Integration Tests** (`tests/integration/`)
   - Real process spawning
   - Full workflow testing
   - System integration

4. **Fuzz Tests**
   - All `/proc` parsers
   - TOML config parsing
   - Command-line argument parsing

## Ruchy Tools Validation

Before committing, validate with all 15 Ruchy tools:

### Mandatory (Must Pass)
```bash
ruchy check src/       # Syntax validation
ruchy compile src/     # Binary generation
ruchy test            # Test execution
ruchy lint src/       # Style analysis (zero violations)
ruchy score src/      # A+ grade required (≥0.95)
ruchy quality-gate    # All gates pass
ruchy coverage        # ≥80% coverage
```

### Advisory (Warnings OK)
```bash
ruchy fmt src/         # Formatting (can auto-fix)
ruchy provability src/ # Formal verification (best effort)
ruchy runtime src/     # BigO analysis (informational)
ruchy optimize src/    # Hardware optimization (advisory)
ruchy prove src/       # Theorem proving (advanced features)
ruchy bench src/       # Performance benchmarking
```

## Commit Standards

### Commit Messages
```
REAPER-XXX: Brief description (50 chars max)

Detailed explanation of what and why (not how).
Reference ticket number and test status.

Tests:
- test_feature_basic: PASS
- test_feature_edge_case: PASS
- prop_feature_invariant: PASS

Quality Gates:
- ruchy score: 0.98 (A+)
- pmat tdg: 95.2 (A)
- coverage: 87%
- mutation: 85%
```

### Atomic Commits
One ticket = One commit (after complete RED-GREEN-REFACTOR cycle)

```bash
# Bad: Partial commits
git commit -m "WIP: half done"

# Good: Complete ticket
git commit -m "REAPER-005: Process metadata struct with 100% tests"
```

## Code Style

### Ruchy Conventions
```ruchy
// Use `fun` keyword (not `fn`)
fun process_scan() -> Result<Vec<Process>, Error> {
    // Explicit error handling
    let processes = scan_proc_dir()?;

    // Type annotations for clarity
    let filtered: Vec<Process> = processes
        .filter(|p| is_user_process(p))
        .collect();

    Ok(filtered)
}
```

### Documentation
```ruchy
/// Scan /proc for user processes
///
/// Returns filtered list of processes owned by current user,
/// excluding system processes (PID < 1000).
///
/// # Errors
/// Returns `Error::ProcRead` if /proc directory unreadable.
///
/// # Examples
/// ```
/// let procs = scan_user_processes()?;
/// assert!(procs.len() > 0);
/// ```
fun scan_user_processes() -> Result<Vec<Process>, Error>
```

## Quality Standards Summary

| Metric | Minimum | Target | Tool |
|--------|---------|--------|------|
| Test Coverage | 80% | 90% | `ruchy coverage` |
| Mutation Score | 80% | 90% | `pmat mutate` |
| Ruchy Score | 0.95 (A+) | 1.00 (A+) | `ruchy score` |
| TDG Grade | A | A+ | `pmat analyze tdg` |
| Complexity | <10 | <7 | `pmat analyze complexity` |
| SATD Count | 0 | 0 | `pmat analyze satd` |

## Questions?

- Ruchy Language: https://github.com/paiml/ruchy
- PMAT Toolkit: https://github.com/paiml/paiml-mcp-agent-toolkit
- Roadmap: See `roadmap.yaml`

Thank you for contributing to this showcase project! 🦀✨
