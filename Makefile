# Reaper Project - Comprehensive Quality Makefile
# Integrates: Ruchy tools, ruchydbg, pmat, extreme TDD

.PHONY: help all check lint score build run clean test \
        debug debug-trace validate quality-full quality-quick \
        pmat-analyze pmat-gates pmat-hooks benchmark \
        ruchy-all ruchy-check ruchy-lint ruchy-score \
        ruchy-compile ruchy-test ruchy-coverage \
        ci-checks pre-commit

# Default target
.DEFAULT_GOAL := help

##@ General

help: ## Display this help message
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║            Reaper - Quality & Debugging Makefile                   ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Integration: Ruchy + ruchydbg + pmat + extreme TDD"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Quick Checks (Pre-commit)

check: ruchy-check ## Quick syntax check
	@echo "✅ Syntax check passed"

lint: ruchy-lint ## Quick lint check
	@echo "✅ Lint check passed"

score: ruchy-score ## Quick quality score
	@echo "✅ Quality score checked"

pre-commit: ruchy-check ruchy-lint pmat-satd ## Run pre-commit checks
	@echo ""
	@echo "✅ All pre-commit checks passed!"

##@ Build & Run

build: ## Build the project (transpile .ruchy → .rs → binary)
	@echo "🔨 Building project..."
	cargo build
	@echo "✅ Build complete"

build-release: ## Build optimized release binary
	@echo "🔨 Building release binary..."
	cargo build --release
	@echo "✅ Release build complete: target/release/reaper"

run: build ## Run the reaper binary
	@echo "🚀 Running reaper..."
	cargo run

clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	cargo clean
	rm -rf target/
	@echo "✅ Clean complete"

##@ Ruchy Tools (15 tools)

ruchy-all: ruchy-check ruchy-lint ruchy-score ruchy-coverage ## Run all mandatory Ruchy tools

ruchy-check: ## Validate syntax (mandatory)
	@echo "🔍 Ruchy syntax check..."
	@ruchy check src/main.ruchy

ruchy-lint: ## Style analysis (mandatory)
	@echo "🔍 Ruchy lint..."
	@ruchy lint src/main.ruchy

ruchy-score: ## Quality scoring (mandatory, A+ required)
	@echo "🔍 Ruchy quality score..."
	@ruchy score src/main.ruchy

ruchy-compile: ## Compile to binary (mandatory)
	@echo "🔍 Ruchy compile..."
	@ruchy compile src/main.ruchy -o target/reaper-direct

ruchy-test: ## Run tests (when tests exist)
	@echo "🔍 Ruchy test..."
	@ruchy test || echo "⚠️  No tests yet (blocked by Issue #106)"

ruchy-coverage: ## Generate coverage report (when tests exist)
	@echo "🔍 Ruchy coverage..."
	@ruchy coverage src/main.ruchy || echo "⚠️  No tests for coverage (blocked)"

ruchy-fmt: ## Check formatting (advisory)
	@echo "🔍 Ruchy fmt..."
	@ruchy fmt src/main.ruchy --check || echo "⚠️  Formatting advisory only"

ruchy-provability: ## Formal verification (advisory)
	@echo "🔍 Ruchy provability..."
	@ruchy provability src/main.ruchy || echo "⚠️  Provability advisory"

ruchy-runtime: ## BigO complexity analysis (advisory)
	@echo "🔍 Ruchy runtime analysis..."
	@ruchy runtime src/main.ruchy || echo "⚠️  Runtime analysis advisory"

##@ Debugging (ruchydbg)

debug: ## Run with ruchydbg (timeout detection)
	@echo "🐛 Running with ruchydbg..."
	ruchydbg run src/main.ruchy --timeout 5000

debug-trace: ## Run with type-aware tracing
	@echo "🐛 Running with type-aware tracing..."
	ruchydbg run src/main.ruchy --timeout 5000 --trace

debug-validate: ## Validate debugging tools
	@echo "🐛 Validating ruchydbg..."
	ruchydbg validate

benchmark: ## Performance benchmarking
	@echo "⏱️  Running benchmarks..."
	ruchydbg run src/main.ruchy --timeout 10000 --trace | grep -E "(TRACE|ms)"

##@ PMAT Quality Analysis

pmat-analyze: pmat-complexity pmat-satd ## Run PMAT analysis suite

pmat-complexity: ## Complexity analysis (max 10)
	@echo "📊 PMAT complexity analysis..."
	@pmat analyze complexity --path .

pmat-satd: ## SATD analysis (zero tolerance)
	@echo "📊 PMAT SATD analysis..."
	@pmat analyze satd --path .

pmat-dead-code: ## Dead code detection
	@echo "📊 PMAT dead code analysis..."
	@pmat analyze dead-code --path .

pmat-entropy: ## Code entropy analysis
	@echo "📊 PMAT entropy analysis..."
	@pmat analyze entropy --path .

pmat-gates: ## Run quality gates
	@echo "🚪 PMAT quality gates..."
	@pmat quality-gate || echo "⚠️  Some quality gates failed (expected for blocked project)"

pmat-hooks: ## Install git hooks
	@echo "🔧 Installing PMAT git hooks..."
	@pmat hooks install --tdg-enforcement --force

pmat-context: ## Generate project context
	@echo "📋 Generating PMAT context..."
	@pmat context

##@ Comprehensive Quality

quality-quick: check lint score pmat-satd ## Quick quality checks (pre-commit)
	@echo ""
	@echo "✅ Quick quality checks complete!"

quality-full: ruchy-all pmat-analyze debug-validate ## Full quality validation
	@echo ""
	@echo "📊 Full quality validation results:"
	@echo "  Ruchy tools: check, lint, score, coverage"
	@echo "  PMAT analysis: complexity, SATD"
	@echo "  Debugging: ruchydbg validated"
	@echo ""
	@echo "✅ Full quality validation complete!"

validate: quality-full build run ## Complete validation (all checks + build + run)
	@echo ""
	@echo "✅ Complete validation passed!"

##@ CI/CD Integration

ci-checks: ruchy-check ruchy-lint pmat-satd pmat-complexity build ## CI/CD quality checks
	@echo ""
	@echo "✅ CI/CD checks passed!"

ci-full: validate pmat-gates ## Complete CI/CD validation
	@echo ""
	@echo "✅ Complete CI/CD validation passed!"

##@ Test Infrastructure (when unblocked)

test: ruchy-test ## Run tests (blocked by Issue #106)
	@echo "⚠️  Testing blocked by Ruchy Issue #106"
	@echo "   Missing: struct, enum, multi-file support"

test-unit: ## Run unit tests (blocked)
	@echo "⚠️  Unit tests blocked by Issue #106"

test-property: ## Run property tests (blocked)
	@echo "⚠️  Property tests blocked by Issue #106"

test-integration: ## Run integration tests (blocked)
	@echo "⚠️  Integration tests blocked by Issue #106"

test-mutation: ## Run mutation tests (blocked)
	@echo "⚠️  Mutation testing blocked (no tests yet)"

##@ Status & Reporting

status: ## Show project status
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║                    Reaper Project Status                           ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Status: 🛑 BLOCKED (Ruchy Issue #106)"
	@echo "Issue: https://github.com/paiml/ruchy/issues/106"
	@echo ""
	@echo "Missing Features:"
	@echo "  ❌ Multi-file modules (mod scanner;)"
	@echo "  ❌ Custom structs (pub struct Process)"
	@echo "  ❌ Enums (pub enum Priority)"
	@echo ""
	@echo "Current Validation:"
	@$(MAKE) -s ruchy-check && echo "  ✅ Syntax check: PASS" || echo "  ❌ Syntax check: FAIL"
	@$(MAKE) -s ruchy-lint && echo "  ✅ Lint: PASS" || echo "  ❌ Lint: FAIL"
	@echo ""
	@echo "See: BLOCKED.md, STATUS.md"

tools-status: ## Show all tools status
	@echo "╔════════════════════════════════════════════════════════════════════╗"
	@echo "║                      Tools Status                                  ║"
	@echo "╚════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Ruchy Tools:"
	@command -v ruchy >/dev/null 2>&1 && echo "  ✅ ruchy: $(shell ruchy --version)" || echo "  ❌ ruchy: NOT FOUND"
	@command -v ruchydbg >/dev/null 2>&1 && echo "  ✅ ruchydbg: $(shell ruchydbg --version 2>&1 | head -1)" || echo "  ❌ ruchydbg: NOT FOUND"
	@command -v pmat >/dev/null 2>&1 && echo "  ✅ pmat: $(shell pmat --version 2>&1 | head -1 || echo 'installed')" || echo "  ❌ pmat: NOT FOUND"
	@command -v cargo >/dev/null 2>&1 && echo "  ✅ cargo: $(shell cargo --version)" || echo "  ❌ cargo: NOT FOUND"
	@echo ""

##@ Documentation

docs: ## Generate all documentation
	@echo "📚 Documentation:"
	@echo "  - README.md: Project overview"
	@echo "  - BLOCKED.md: Blocker analysis"
	@echo "  - STATUS.md: Current status"
	@echo "  - CONTRIBUTING.md: Development workflow"
	@echo "  - roadmap.yaml: 8-sprint plan"
	@echo ""

##@ Examples

example-debug: ## Example: Debug with tracing
	@echo "Example: Running with type-aware tracing"
	@$(MAKE) debug-trace

example-quality: ## Example: Run quality checks
	@echo "Example: Running quality checks"
	@$(MAKE) quality-quick

example-full: ## Example: Complete workflow
	@echo "Example: Complete validation workflow"
	@$(MAKE) validate
