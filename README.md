# reaper

A Ruchy Application with Cargo integration.

## About Ruchy

This project uses Ruchy, a modern systems programming language that transpiles to Rust.
Source files written in `.ruchy` syntax are automatically converted to `.rs` files during build.

## Building

```bash
# Build the project (auto-transpiles .ruchy → .rs)
cargo build

# Run the project
cargo run
cargo run

# Run tests
cargo test

# Clean generated files
cargo clean
```

## Project Structure

- `src/main.ruchy` - Ruchy source code (auto-transpiled)
- `build.rs` - Build script for transpilation
- `Cargo.toml` - Project dependencies

## Learn More

- Ruchy Language: https://github.com/paiml/ruchy
- Documentation: https://docs.rs/ruchy
