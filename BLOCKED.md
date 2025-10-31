# Blocked Issues

## Active Blockers

### Issue #106: Missing Language Features for Real Projects
- **GitHub**: https://github.com/paiml/ruchy/issues/106
- **Filed**: 2025-10-31
- **Status**: BLOCKED - Cannot proceed with implementation
- **Severity**: CRITICAL - Blocks entire project

**Missing Features**:
1. ❌ **Multi-file Module Support**
   - Syntax `mod scanner;` not supported
   - Can only use inline modules: `mod scanner { }`
   - Impact: All code must be in single file

2. ❌ **Custom Struct Support**
   - `pub struct Process { }` not supported
   - Cannot define custom data types
   - Impact: Cannot model domain properly

3. ❌ **Enum Support**
   - `pub enum Priority { }` not supported
   - Cannot use type-safe variants
   - Impact: No type safety for states/modes

**Overall Impact**: **PROJECT BLOCKED**

The Reaper specification requires:
- Process struct with metadata fields
- Rule priority enums
- Multiple modules (scanner, detector, terminator, config, logger, cli)

**None of these are possible in current Ruchy (v3.154.0)**

**Current State**:
- Minimal `src/main.ruchy` with basic println statements
- Reference modules in `reference/` directory (documentation only)
- Project demonstrates what Ruchy CANNOT do yet

**What Works**:
- ✅ Basic functions
- ✅ String and numeric types
- ✅ Inline modules (all code in one file)
- ✅ println! output
- ✅ Cargo integration

**What Doesn't Work**:
- ❌ Separate module files
- ❌ Custom structs
- ❌ Enums
- ❌ Real project structure
- ❌ Domain modeling

**Quality Validation**:
```bash
ruchy check src/main.ruchy   # ✅ PASS
ruchy lint src/main.ruchy    # ✅ PASS (no issues)
ruchy score src/main.ruchy   # ⚠️  0.75/1.0 (B grade, need A+ 0.95)
cargo build                  # ✅ PASS
cargo run                    # ✅ PASS (shows blocked status)
```

**Resolution Plan**:
1. **Monitor**: Watch paiml/ruchy#106 for updates
2. **Reevaluate**: When features added, revisit project viability
3. **Alternative**: Consider simpler showcase project that fits current Ruchy capabilities
4. **Documentation**: Keep reference modules as future roadmap

**Recommendation**:
This project should be **PAUSED** until Ruchy adds necessary language features. Consider:
- Building simpler calculator/utility tool within current capabilities
- Contributing to Ruchy language development
- Using this as motivation for Ruchy feature priorities
