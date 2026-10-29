## help: Display this help message
.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## up: Start development environment
.PHONY: up
up: create-dev-env
	@echo "Starting development environment..."
	@docker compose up --remove-orphans --build -d

## down: Stop all containers (and their volumes)
.PHONY: down
down:
	@echo "Stopping development environment..."
	@docker compose down -v --remove-orphans

## lint: Lint repo shell scripts and GitHub Actions workflows
.PHONY: lint
lint:
	@bash scripts/lint-repo.sh

## verify: Run every example project's verification gate
.PHONY: verify
verify:
	@bash scripts/verify-all.sh

.PHONY: create-dev-env
create-dev-env:
	@if [ ! -f .env ]; then \
		echo "Creating .env from template..."; \
		cp .env.example .env; \
	else \
		echo ".env already exists"; \
	fi
