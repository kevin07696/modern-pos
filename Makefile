# Modern POS - Project Makefile
# Sprint Management and Automation

.PHONY: help sync-tasks update-board sprint-report

# Default target: Show help
help:
	@echo "Modern POS - Available Commands"
	@echo "================================"
	@echo ""
	@echo "Project Management:"
	@echo "  make sync-tasks       - Sync task files to GitHub issues"
	@echo "  make update-board     - Update sprint board with latest issue statuses"
	@echo "  make sprint-report    - Generate sprint progress report (default: Sprint 1)"
	@echo "  make sprint-report SPRINT=2  - Generate report for specific sprint"
	@echo ""
	@echo "Environment Variables:"
	@echo "  REPO_OWNER   - GitHub repository owner (default: YOUR_USERNAME)"
	@echo "  REPO_NAME    - GitHub repository name (default: modern-pos)"
	@echo "  PROJECT_NUMBER - GitHub project number (default: 1)"
	@echo "  SPRINT       - Sprint number for reporting (default: 1)"
	@echo ""

# Project Management Commands

sync-tasks:
	@echo "🚀 Syncing tasks to GitHub issues..."
	@bash scripts/sync-tasks-to-github.sh

update-board:
	@echo "📊 Updating sprint board..."
	@bash scripts/update-sprint-board.sh

sprint-report:
	@echo "📈 Generating sprint report..."
	@bash scripts/sprint-report.sh $(SPRINT)

# Quick alias for current sprint (Sprint 1)
.PHONY: status
status: sprint-report
