# GitHub Issues Filed for Ruchy v3.155.0 Tooling Limitations

## Date: 2025-10-31
## Repository: paiml/ruchy
## Discovered During: Reaper project Sprint 7 (Quality & Testing)

## Summary

Filed 4 detailed bug reports for tooling issues encountered when using Ruchy v3.155.0's new struct/enum features.

---

## Issue #107: ruchy lint - False Positives on Enum/Struct Types

**URL**: https://github.com/paiml/ruchy/issues/107

**Problem**: Linter reports 137 false positives, claiming enum and struct types are "undefined variables"

**Example**:
```bash
$ ruchy lint src/main.ruchy
Error - undefined variable: ProcessStatus  # FALSE POSITIVE
Error - undefined variable: Priority       # FALSE POSITIVE
Error - undefined variable: ActionResult   # FALSE POSITIVE
```

**Impact**: 
- Makes real linting issues impossible to find
- Quality scoring artificially low (0.35/1.0)
- Quality gate fails due to false positives

**Verification**: Code is valid (`ruchy check` passes, all tests pass)

---

## Issue #108: ruchy mutations - Finds 0 Mutants in v3.155.0 Code

**URL**: https://github.com/paiml/ruchy/issues/108

**Problem**: Mutation testing tool finds 0 mutants in code using structs/enums

**Example**:
```bash
$ ruchy mutations src/main.ruchy --verbose
WARN No mutants found under the active filters
Found 0 mutants to test
```

**Expected**: Should find dozens of mutants in:
- Boolean operators (<, >, <=, >=, ==, !=)
- Arithmetic operators
- Return values (true/false swaps)
- Boundary conditions

**Impact**:
- Cannot measure mutation score (goal: 80%+)
- Cannot validate test suite quality via mutation testing

**Workaround**: Comprehensive edge case testing (100 tests, 100% coverage)

---

## Issue #109: ruchy quality-gate - False SATD and Complexity Violations

**URL**: https://github.com/paiml/ruchy/issues/109

**Problem**: Quality gate reports false violations for single-file architecture

**Issues**:

1. **Complexity**: Reports file-level (172) instead of per-function (<10)
   - Single-file required by v3.155.0 (no multi-file modules yet)
   - All functions individually <10 complexity

2. **SATD**: Claims "Contains SATD comments" but none exist
   - PMAT v2.183.0 reports 0 SATD violations
   - Manual grep finds no TODO/FIXME/HACK comments

**Impact**:
- Quality score artificially low (0.35/1.0 vs actual A+ quality)
- Cannot meet quality gate requirements despite high quality

**Verification**: PMAT (independent tool) reports 0 violations

---

## Issue #110: ruchy doc - Minimal Documentation Extraction

**URL**: https://github.com/paiml/ruchy/issues/110

**Problem**: Doc generator extracts minimal documentation (36 bytes) from file with extensive docs

**Stats**:
- Input: 4,606 lines, ~2,300 lines of doc comments (50%)
- Output: 36 bytes (1 line: "# Documentation for src/main.ruchy")

**Expected**: Should generate ~60KB markdown with:
- Enum documentation (3 enums)
- Struct documentation (4 structs)
- Function documentation (27 functions)
- Usage examples
- Parameter/return descriptions

**Impact**:
- Cannot generate API documentation
- Manual documentation required
- Documentation drift risk

---

## Filed By

Tool: `gh` CLI  
Command: `gh issue create --repo paiml/ruchy`  
From: paiml/reaper repository  
Commit: 9802281

---

## Next Steps

1. ✅ Issues filed with detailed reproduction steps
2. ⏳ Wait for Ruchy maintainer response
3. ⏳ Retest when fixes are available
4. ⏳ Update SPRINT7_STATUS.md when resolved

## Workarounds Used

While waiting for fixes:
- **Lint**: Ignore false positives, verify with PMAT
- **Mutations**: Comprehensive edge case testing (100 tests)
- **Quality**: Use PMAT for independent verification
- **Docs**: Maintain inline documentation, manual extraction for publication
