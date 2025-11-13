.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove Python cache files
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true

.PHONY: configure
configure: install install-hooks ## Install dependencies and setup hooks
	@echo "Configuration complete"

.PHONY: install
install: ## Install Python dependencies
	@pip install -r requirements.txt

.PHONY: install-hooks
install-hooks: ## Install pre-commit hooks
	@pre-commit install

.PHONY: pre-commit
pre-commit: ## Run pre-commit hooks on all files
	@pre-commit run --all-files

.PHONY: validate-xml
validate-xml: ## Validate all XML files
	@echo "Validating XML files..."
	@python3 scripts/validate_xml.py
