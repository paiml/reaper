# Debugging Guide - Reaper Project

Complete debugging workflow using **ruchydbg** and Ruchy's built-in debugging tools.

## Quick Start

```bash
# Basic debugging
make debug

# With type-aware tracing
make debug-trace

# Performance benchmarking
make benchmark
```

## ruchydbg - RuchyRuchy Debugging Tools

**Version**: v1.9.1
**Documentation**: https://github.com/paiml/ruchyruchy

### Features

1. **Timeout Detection** - Catches infinite loops and hangs
2. **Type-Aware Tracing** - Shows argument and return types
3. **Source Mapping** - Maps transpiled code back to .ruchy source
4. **Record-Replay** - Time-travel debugging
5. **Performance Benchmarking** - Measure execution time

### Basic Usage

#### Run with Timeout Detection

```bash
ruchydbg run src/main.ruchy --timeout 5000
```

**Output**:
```
🔍 Running: src/main.ruchy
⏱️  Timeout: 5000ms
✅ Execution completed successfully
```

#### Type-Aware Tracing

```bash
ruchydbg run src/main.ruchy --timeout 5000 --trace
```

**Output**:
```
TRACE: → main()
TRACE: → println("Reaper v0.1.0": string)
Reaper v0.1.0
TRACE: ← println = nil: nil
TRACE: ← main = nil: nil
```

**Benefits**:
- See every function call
- View argument types (string, i32, f64, etc.)
- Track return values and types
- Identify where code spends time

#### Validation

```bash
ruchydbg validate
```

Runs complete debugging tools validation suite.

### Advanced Usage

#### Custom Timeout

```bash
# 10 second timeout for slow operations
ruchydbg run src/main.ruchy --timeout 10000
```

#### Performance Benchmarking

```bash
# Run with tracing and extract timing information
ruchydbg run src/main.ruchy --timeout 10000 --trace | grep -E "(TRACE|ms)"
```

### Integration with Makefile

```bash
make debug               # Basic debugging
make debug-trace         # With type-aware tracing
make debug-validate      # Validate debugging tools
make benchmark           # Performance benchmarking
```

## Ruchy Built-in Debugging

### --trace Flag

```bash
ruchy run src/main.ruchy --trace
```

Enables execution tracing directly in Ruchy interpreter.

### VM Modes

```bash
# AST interpreter (default, stable)
ruchy run src/main.ruchy --vm-mode ast

# Bytecode VM (experimental, 40-60% faster)
ruchy run src/main.ruchy --vm-mode bytecode
```

## Debugging Workflow

### 1. Quick Syntax Check

```bash
make check
# or
ruchy check src/main.ruchy
```

### 2. Run Normally

```bash
make run
# or
cargo run
```

### 3. Debug with Tracing

```bash
make debug-trace
```

**Analyze output for**:
- Function call sequence
- Type information
- Return values
- Execution flow

### 4. Identify Issues

**Common patterns**:

```
TRACE: → infinite_loop()
TRACE: → infinite_loop()  # ⚠️  Recursive without termination
TRACE: → infinite_loop()
```

**Timeout detected**:
```
⚠️  Execution timeout after 5000ms
💡 Possible infinite loop detected
```

### 5. Fix and Verify

```bash
# Edit code
vim src/main.ruchy

# Verify fix
make debug-trace
```

## Debugging Common Issues

### Infinite Loops

**Detection**:
```bash
ruchydbg run problem.ruchy --timeout 1000
```

**Output**:
```
⚠️  Timeout: Execution exceeded 1000ms
💡 Check for infinite loops or unbounded recursion
```

**Trace analysis**:
```bash
ruchydbg run problem.ruchy --timeout 5000 --trace | tail -50
```

Look for repeating function calls.

### Type Mismatches

**Trace shows types**:
```
TRACE: → calculate(42: i32, "hello": string)
                           ^^^^^^^^ ⚠️  Should be i32
```

### Performance Issues

**Benchmark**:
```bash
make benchmark
```

**Analyze**:
```
TRACE: → slow_function()
       ... (1000 lines of output)
TRACE: ← slow_function = result
       ⚠️  This function has too many operations
```

## Debugging When Unblocked (Issue #106)

When Ruchy adds struct/enum/multi-file support:

### 1. Module-Level Debugging

```bash
# Debug specific module
ruchydbg run src/scanner.ruchy --trace

# Debug detector rules
ruchydbg run src/detector.ruchy --trace
```

### 2. Integration Debugging

```bash
# Run full application with tracing
ruchydbg run src/main.ruchy --timeout 30000 --trace > debug.log

# Analyze trace
grep "TRACE: → scan" debug.log
grep "TRACE: → detect_" debug.log
```

### 3. Record-Replay Debugging

```bash
# Record execution
ruchydbg run src/main.ruchy --record session.replay

# Replay and analyze
ruchydbg replay session.replay --trace
```

## Best Practices

### 1. Always Use Timeouts

```bash
# ❌ Bad: No timeout (can hang forever)
ruchydbg run src/main.ruchy

# ✅ Good: With timeout
ruchydbg run src/main.ruchy --timeout 5000
```

### 2. Start Without Tracing

```bash
# 1. Run normally first
make run

# 2. If issues, add tracing
make debug-trace
```

Tracing generates lots of output - only use when needed.

### 3. Filter Trace Output

```bash
# See only specific functions
make debug-trace | grep "detect_"

# Count function calls
make debug-trace | grep "TRACE: →" | wc -l
```

### 4. Use Makefile Targets

```bash
# ✅ Preferred: Consistent, documented
make debug-trace

# ⚠️  Direct: Works but less discoverable
ruchydbg run src/main.ruchy --timeout 5000 --trace
```

## Integration with Quality Tools

### Combined Workflow

```bash
# 1. Quick checks
make quality-quick

# 2. If failing, debug
make debug-trace

# 3. Fix and validate
make validate
```

### CI/CD Integration

```bash
# In .github/workflows/ci.yml
- name: Debug validation
  run: make debug-validate

- name: Quality checks
  run: make ci-checks
```

## Troubleshooting

### ruchydbg not found

```bash
# Install ruchydbg
cargo install ruchydbg

# Verify
which ruchydbg
ruchydbg --version
```

### Timeout too short

```bash
# Increase timeout in Makefile
# Edit: Makefile
# Change: --timeout 5000
# To:     --timeout 30000
```

### Too much trace output

```bash
# Filter to essentials
make debug-trace | grep -E "(→|←) (main|scan|detect)"
```

### Performance issues

```bash
# Use bytecode VM
ruchy run src/main.ruchy --vm-mode bytecode

# Benchmark specific section
ruchydbg run src/main.ruchy --timeout 10000 --trace | \
  sed -n '/→ slow_section/,/← slow_section/p'
```

## References

- **ruchydbg GitHub**: https://github.com/paiml/ruchyruchy
- **Ruchy Debugging**: See `ruchy --help` for --trace flag
- **Makefile**: See `make help` for all debugging targets
- **Examples**: See `make example-debug`

## Quick Reference

| Command | Purpose |
|---------|---------|
| `make debug` | Run with timeout detection |
| `make debug-trace` | Run with type-aware tracing |
| `make debug-validate` | Validate debugging tools |
| `make benchmark` | Performance benchmarking |
| `ruchydbg run FILE --timeout MS` | Direct debugging |
| `ruchy run FILE --trace` | Ruchy built-in tracing |

---

**Next**: See [QUALITY.md](QUALITY.md) for quality analysis tools
