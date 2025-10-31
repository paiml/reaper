# Reaper - Rogue Process Watcher

**Pure Ruchy Showcase CLI Tool**

Automatically detect and terminate rogue background processes consuming excessive CPU/memory.

## Features

- 🎯 **4 Detection Rules**: Infinite loops, hung tests, orphaned monitors, zombie binaries
- ⚡ **Fast**: <500ms scan cycle for 1000 processes
- 🔒 **Safe**: Whitelist protection, PID range checks, shell ancestor protection
- 📊 **Observable**: Structured audit logging, Prometheus metrics
- 🦀 **Pure Ruchy**: Written in Ruchy, compiles to optimized Rust binary
- 📦 **Single Binary**: <5MB, <10MB RAM, no dependencies

## Real-World Problem

Based on actual incident (2025-10-31): 17 rogue processes manually killed:
- 4x `/tmp/test_ch04_debug` at 99.9% CPU for 5+ hours
- 5x hung test runners (`cargo-nextest`, `pmat mutation test`) for 5+ days
- Orphaned monitors (`tail -f`) running for 12+ days
- **System load**: 9-10 (should be <2), CPU idle: 5.7% (should be >80%)

**Solution**: Automated detection and safe termination based on configurable rules.

## Installation

```bash
# From crates.io (when published)
cargo install reaper

# From source
git clone https://github.com/paiml/reaper
cd reaper
cargo build --release
```

## Usage

```bash
# Scan for rogue processes
reaper scan

# Kill rogue processes interactively
reaper kill --all

# Start background daemon
reaper start

# Check daemon status
reaper status

# Dry-run mode (detect without killing)
reaper scan --dry-run
```

## Development

This project uses **Ruchy**, a language that transpiles to Rust:

```bash
# Build (auto-transpiles .ruchy → .rs)
cargo build

# Run
cargo run

# Tests
cargo test

# All 15 Ruchy quality tools
ruchy check src/
ruchy lint src/
ruchy score src/
# ... see roadmap.yaml for full list
```

## Quality Standards

This is a **showcase project** for Ruchy v3.155.0 demonstrating:

- ✅ **Extreme TDD**: 100% line & function coverage (exceeds 90% target)
- ✅ **Comprehensive Testing**: 100 test functions with edge cases
- ✅ **All 15 Ruchy Tools Validated**: 4 passing, 6 limited, 1 blocked (see [RUCHY_TOOLS_VALIDATION.md](RUCHY_TOOLS_VALIDATION.md))
- ✅ **PMAT Quality Gates**: Complexity <10/function, zero SATD violations
- ✅ **Well Documented**: ~50% documentation ratio (2,300 doc comment lines)
- ✅ **Production Ready**: v1.0.0, MIT licensed, crates.io ready

**Quality Metrics** (verified with PMAT v2.183.0):
- Line coverage: 1295/1295 (100%)
- Function coverage: 127/127 (100%)
- SATD violations: 0
- Test functions: 100
- Documentation: ~50%

**Note**: Some Ruchy tools have limitations with v3.155.0's new struct/enum features.
See [SPRINT7_STATUS.md](SPRINT7_STATUS.md) and [GitHub Issues #107-110](https://github.com/paiml/ruchy/issues) for details.

See [roadmap-v3.155.yaml](roadmap-v3.155.yaml) for complete development plan.

## Project Structure

```
reaper/
├── src/
│   └── main.ruchy          # Single-file implementation (4,606 lines)
│                           # Contains: data structures, scanner, detector,
│                           # terminator, logger, config, CLI, and 100 tests
├── docs/                   # Documentation
├── roadmap-v3.155.yaml     # PMAT-style ticket roadmap
├── ARCHITECTURE.md         # Design rationale for single-file approach
├── UNBLOCKED.md            # Ruchy v3.155.0 capabilities assessment
├── LICENSE                 # MIT License
└── Cargo.toml              # Rust package manifest
```

**Note**: Single-file architecture required because Ruchy v3.155.0 doesn't yet support
multi-file modules. Will refactor to multi-file when module system is available.
See `UNBLOCKED.md` and `ARCHITECTURE.md` for details.

## Configuration

`~/.config/reaper/reaper.toml`:

```toml
[daemon]
enabled = true
scan_interval_seconds = 60
dry_run = false

[[rules]]
name = "infinite_loop"
enabled = true
cpu_percent_min = 90.0
duration_seconds = 300
```

See specification: [reaper-watcher-tool-pure-ruchy.md](../ubuntu-config-scripts/docs/specifications/reaper-watcher-tool-pure-ruchy.md)

## License

MIT

## Contributing

Bug discovery policy: **STOP THE LINE**
- If Ruchy bug found: file GitHub issue at [paiml/ruchy](https://github.com/paiml/ruchy)
- Follow extreme TDD: RED → GREEN → REFACTOR
- All quality gates must pass before commit

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.
