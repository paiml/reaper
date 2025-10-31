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

This is a **showcase project** for Ruchy demonstrating:

- ✅ **Extreme TDD**: 80%+ coverage, 80%+ mutation score
- ✅ **All 15 Ruchy Tools**: check, lint, score, provability, runtime, etc.
- ✅ **PMAT Quality Gates**: Complexity <10, TDG grade A+, zero SATD
- ✅ **Production Ready**: Single binary, crates.io publication

See [roadmap.yaml](roadmap.yaml) for complete development plan.

## Project Structure

```
reaper/
├── src/
│   ├── main.ruchy          # CLI entry point
│   ├── scanner.ruchy       # Process enumeration
│   ├── detector.ruchy      # Rogue detection rules
│   ├── terminator.ruchy    # Safe kill logic
│   ├── config.ruchy        # TOML configuration
│   ├── logger.ruchy        # Audit trail
│   └── cli.ruchy           # Command interface
├── tests/
│   ├── unit/               # Unit tests
│   ├── property/           # Property-based tests
│   └── integration/        # Integration tests
├── roadmap.yaml            # PMAT-style ticket roadmap
├── pmat.toml               # Quality gates config
└── Cargo.toml              # Rust package manifest
```

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
