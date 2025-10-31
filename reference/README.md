# Reference Modules

These `.ruchy` files are **reference documentation only** - they represent what the Reaper project SHOULD look like when Ruchy supports necessary language features.

**Status**: NOT COMPILED - Moved here because Ruchy v3.154.0 lacks required features

## Files

- `scanner.ruchy` - Process enumeration (requires: pub struct, separate files)
- `detector.ruchy` - Rogue detection rules (requires: pub enum, pub struct)
- `terminator.ruchy` - Safe process termination (requires: pub struct)
- `config.ruchy` - TOML configuration (requires: pub struct)
- `logger.ruchy` - Audit trail logging (requires: pub struct)
- `cli.ruchy` - Command-line interface (requires: pub enum)

## Why Not Implemented?

Ruchy currently doesn't support:
1. `pub struct` - Cannot define custom data types
2. `pub enum` - Cannot use type-safe variants
3. `mod name;` - Cannot have separate module files

See: https://github.com/paiml/ruchy/issues/106

## When Will This Work?

When Ruchy adds:
- Multi-file module support
- Custom struct support
- Enum support

Then these files can be moved back to `src/` and the project can proceed.

## Current Workaround

`src/main.ruchy` contains a minimal placeholder that compiles and runs, demonstrating the project is blocked waiting for language features.
