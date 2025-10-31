# Reaper Architecture - Single-File Design
# Ruchy v3.155.0 (Structs + Enums Supported!)

**Version**: v0.2.0
**Date**: 2025-10-31
**Approach**: Single-file with clear sectioning
**Estimated LOC**: 500-1000

## Overview

Since Ruchy v3.155.0 doesn't yet support multi-file modules, we implement the entire
Reaper specification in a single file (`src/main.ruchy`) with clear logical sections.

**Key Design Principles**:
1. Clear section boundaries with banner comments
2. Top-down organization (data → logic → main)
3. Pure functions where possible for testability
4. Type-safe enums for all state/mode representations
5. Proper error handling throughout

## File Structure

```ruchy
// src/main.ruchy (~500-1000 lines)

// ============================================================================
// CONSTANTS & CONFIGURATION
// ============================================================================
// - Default values
// - Configuration constants

// ============================================================================
// DATA STRUCTURES
// ============================================================================
// - struct Process
// - struct DetectionRule
// - struct Config
// - struct LogEntry
// - enum Priority
// - enum ProcessStatus
// - enum ActionResult

// ============================================================================
// SCANNER - Process Enumeration
// ============================================================================
// - scan_processes() -> [Process]
// - parse_proc_status(pid: i32) -> Process
// - get_process_cpu_usage(pid: i32) -> f64
// - get_process_memory(pid: i32) -> i64
// - read_proc_file(path: String) -> String

// ============================================================================
// DETECTOR - Rogue Process Detection
// ============================================================================
// - apply_rules(procs: [Process], rules: [DetectionRule]) -> [Process]
// - detect_cpu_hog(proc: Process, rule: DetectionRule) -> bool
// - detect_memory_hog(proc: Process, rule: DetectionRule) -> bool
// - match_name_pattern(proc: Process, pattern: String) -> bool
// - filter_rogues(procs: [Process], rules: [DetectionRule]) -> [Process]

// ============================================================================
// TERMINATOR - Safe Process Termination
// ============================================================================
// - terminate_process(pid: i32, grace_period: i64) -> ActionResult
// - send_signal(pid: i32, signal: i32) -> bool
// - wait_for_exit(pid: i32, timeout: i64) -> bool
// - force_kill(pid: i32) -> bool

// ============================================================================
// LOGGER - Audit Trail
// ============================================================================
// - log_detection(proc: Process, rule: DetectionRule)
// - log_termination(proc: Process, result: ActionResult)
// - log_error(message: String)
// - write_log_entry(entry: LogEntry)

// ============================================================================
// CONFIG - Configuration Management
// ============================================================================
// - load_config(path: String) -> Config
// - parse_config_line(line: String) -> DetectionRule
// - default_config() -> Config
// - validate_config(config: Config) -> bool

// ============================================================================
// CLI - Command Line Interface & Main Loop
// ============================================================================
// - parse_args() -> Config
// - print_usage()
// - daemon_loop(config: Config)
// - handle_signal(signal: i32)
// - main()
```

## Data Structures

### Process
```ruchy
struct Process {
    pid: i32,              // Process ID
    name: String,          // Process name (from /proc/[pid]/comm)
    cmdline: String,       // Full command line
    cpu_usage: f64,        // CPU usage percentage (0.0-100.0)
    memory_mb: i64,        // Memory usage in MB
    status: ProcessStatus, // Current process status
}
```

**Responsibilities**:
- Represents a single process snapshot
- Contains all data needed for detection rules
- Immutable once created

### DetectionRule
```ruchy
struct DetectionRule {
    name: String,              // Rule name (e.g., "High CPU Hog")
    priority: Priority,        // Rule priority
    max_cpu_percent: f64,      // CPU threshold (0.0 = disabled)
    max_memory_mb: i64,        // Memory threshold (0 = disabled)
    name_pattern: String,      // Process name pattern (empty = any)
    cmdline_pattern: String,   // Command line pattern (empty = any)
    enabled: bool,             // Rule enabled/disabled
}
```

**Responsibilities**:
- Defines one detection rule
- Used by detector to identify rogue processes
- Configurable thresholds

### Config
```ruchy
struct Config {
    check_interval_secs: i64,    // How often to scan (default: 60)
    rules: [DetectionRule],       // Detection rules
    dry_run: bool,                // If true, log only, don't kill
    log_file: String,             // Log file path
    grace_period_secs: i64,       // Grace period before SIGKILL (default: 5)
}
```

**Responsibilities**:
- Application configuration
- Loaded from CLI args or config file
- Validated on load

### LogEntry
```ruchy
struct LogEntry {
    timestamp: String,     // ISO 8601 timestamp
    level: String,         // "INFO", "WARN", "ERROR"
    message: String,       // Log message
}
```

### Enums

#### Priority
```ruchy
enum Priority {
    High,      // Critical rules (kill immediately)
    Medium,    // Important rules (kill after one cycle)
    Low,       // Advisory rules (log only)
}
```

#### ProcessStatus
```ruchy
enum ProcessStatus {
    Running,   // Process is running
    Sleeping,  // Process is sleeping
    Stopped,   // Process is stopped
    Zombie,    // Process is zombie (dead but not reaped)
}
```

#### ActionResult
```ruchy
enum ActionResult {
    Success,              // Process terminated successfully
    AlreadyDead,          // Process was already dead
    PermissionDenied,     // Insufficient permissions
    NotFound,             // Process not found
    TimedOut,             // Termination timed out
    Failed,               // General failure
}
```

## Section Details

### CONSTANTS & CONFIGURATION

**Purpose**: Define system-wide constants

```ruchy
// Default configuration values
let DEFAULT_CHECK_INTERVAL: i64 = 60;
let DEFAULT_GRACE_PERIOD: i64 = 5;
let DEFAULT_LOG_FILE: String = "/var/log/reaper.log";

// System limits
let MAX_CPU_PERCENT: f64 = 95.0;
let MAX_MEMORY_MB: i64 = 4096;

// Signals
let SIGTERM: i32 = 15;
let SIGKILL: i32 = 9;
```

### SCANNER

**Purpose**: Enumerate and gather process information

**Key Functions**:

```ruchy
fun scan_processes() -> [Process]
```
- Reads /proc directory
- Returns list of all running processes
- Filters out kernel threads
- Handles errors gracefully

```ruchy
fun parse_proc_status(pid: i32) -> Process
```
- Reads /proc/[pid]/status
- Parses process metadata
- Returns Process struct

```ruchy
fun get_process_cpu_usage(pid: i32) -> f64
```
- Reads /proc/[pid]/stat
- Calculates CPU usage percentage
- Returns 0.0 on error

### DETECTOR

**Purpose**: Apply detection rules to identify rogue processes

**Key Functions**:

```ruchy
fun apply_rules(procs: [Process], rules: [DetectionRule]) -> [Process]
```
- Applies all enabled rules to process list
- Returns filtered list of rogue processes
- Respects rule priority

```ruchy
fun detect_cpu_hog(proc: Process, rule: DetectionRule) -> bool
```
- Returns true if process exceeds CPU threshold
- Returns false if rule disabled

```ruchy
fun match_name_pattern(proc: Process, pattern: String) -> bool
```
- Simple string matching (contains)
- Returns true if pattern matches process name
- Case-insensitive

### TERMINATOR

**Purpose**: Safely terminate rogue processes

**Key Functions**:

```ruchy
fun terminate_process(pid: i32, grace_period: i64) -> ActionResult
```
- Sends SIGTERM first
- Waits grace_period seconds
- Sends SIGKILL if still alive
- Returns termination result

```ruchy
fun send_signal(pid: i32, signal: i32) -> bool
```
- Sends Unix signal to process
- Returns true on success
- Handles permission errors

### LOGGER

**Purpose**: Maintain audit trail of all actions

**Key Functions**:

```ruchy
fun log_detection(proc: Process, rule: DetectionRule)
```
- Logs when rogue process detected
- Includes process details and rule name

```ruchy
fun log_termination(proc: Process, result: ActionResult)
```
- Logs termination attempts
- Records success/failure

### CONFIG

**Purpose**: Load and validate configuration

**Key Functions**:

```ruchy
fun load_config(path: String) -> Config
```
- Loads configuration from file
- Returns default config if file not found
- Validates all rules

```ruchy
fun default_config() -> Config
```
- Returns sensible default configuration
- Used when no config file specified

### CLI

**Purpose**: Command-line interface and main loop

**Key Functions**:

```ruchy
fun parse_args() -> Config
```
- Parses command-line arguments
- Returns Config struct
- Shows usage on invalid args

```ruchy
fun daemon_loop(config: Config)
```
- Main daemon loop
- Scans → Detects → Terminates → Sleeps
- Runs until interrupted

```ruchy
fun main()
```
- Entry point
- Parses args → Loads config → Starts daemon

## Function Signatures (Complete)

### Scanner (5 functions)
```ruchy
fun scan_processes() -> [Process]
fun parse_proc_status(pid: i32) -> Process
fun get_process_cpu_usage(pid: i32) -> f64
fun get_process_memory(pid: i32) -> i64
fun read_proc_file(path: String) -> String
```

### Detector (5 functions)
```ruchy
fun apply_rules(procs: [Process], rules: [DetectionRule]) -> [Process]
fun detect_cpu_hog(proc: Process, rule: DetectionRule) -> bool
fun detect_memory_hog(proc: Process, rule: DetectionRule) -> bool
fun match_name_pattern(proc: Process, pattern: String) -> bool
fun filter_rogues(procs: [Process], rules: [DetectionRule]) -> [Process]
```

### Terminator (4 functions)
```ruchy
fun terminate_process(pid: i32, grace_period: i64) -> ActionResult
fun send_signal(pid: i32, signal: i32) -> bool
fun wait_for_exit(pid: i32, timeout: i64) -> bool
fun force_kill(pid: i32) -> bool
```

### Logger (4 functions)
```ruchy
fun log_detection(proc: Process, rule: DetectionRule)
fun log_termination(proc: Process, result: ActionResult)
fun log_error(message: String)
fun write_log_entry(entry: LogEntry)
```

### Config (4 functions)
```ruchy
fun load_config(path: String) -> Config
fun parse_config_line(line: String) -> DetectionRule
fun default_config() -> Config
fun validate_config(config: Config) -> bool
```

### CLI (5 functions)
```ruchy
fun parse_args() -> Config
fun print_usage()
fun daemon_loop(config: Config)
fun handle_signal(signal: i32)
fun main()
```

## Testing Strategy

### Unit Tests (per function)
- Each function gets 3-5 unit tests
- Test happy path + error cases
- Use mock data for /proc reads

### Integration Tests
- Test full scan → detect → terminate flow
- Test with real /proc data (current process)
- Test dry-run mode

### Property-Based Tests
- CPU usage always 0.0-100.0
- PIDs always positive
- Memory usage always non-negative

## Estimated Size

| Section | Functions | LOC Est. |
|---------|-----------|----------|
| Constants | - | 30 |
| Data Structures | 6 structs, 3 enums | 100 |
| Scanner | 5 | 120 |
| Detector | 5 | 100 |
| Terminator | 4 | 100 |
| Logger | 4 | 80 |
| Config | 4 | 80 |
| CLI | 5 | 100 |
| Tests | ~50 tests | 200 |
| **TOTAL** | **~32 functions** | **~910 lines** |

## Quality Targets

- **Complexity**: Max 10 per function (target: <7)
- **Coverage**: Min 80%, target 90%
- **Mutation Score**: Min 80%
- **Quality Score**: A+ (0.95+)
- **SATD**: Zero tolerance
- **Lint**: Zero violations

## Future Refactoring (when multi-file supported)

When Ruchy adds multi-file support, easy refactoring:

```
src/main.ruchy → src/
  ├── main.ruchy          (CLI + main)
  ├── scanner.ruchy       (Scanner section)
  ├── detector.ruchy      (Detector section)
  ├── terminator.ruchy    (Terminator section)
  ├── logger.ruchy        (Logger section)
  ├── config.ruchy        (Config section)
  └── types.ruchy         (All structs/enums)
```

Simply cut sections and add `mod` declarations.

## References

- **Specification**: ../ubuntu-config-scripts/docs/specifications/reaper-watcher-tool-pure-ruchy.md
- **Roadmap**: roadmap-v3.155.yaml
- **Unblock Doc**: UNBLOCKED.md
- **Reference Modules**: reference/ (original multi-file design)

---

**Status**: Design complete, ready for implementation with extreme TDD
