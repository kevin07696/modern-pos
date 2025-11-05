# Project Management - Sprint Board Setup

**Version**: 1.0
**Last Updated**: November 4, 2025
**Status**: Automation Guide

---

## Overview

This guide explains how to set up and automate sprint boards for the Modern POS project using GitHub Projects, with scripts that Claude (or you) can run to sync task files to the board.

---

## Option 1: GitHub Projects (Recommended)

**Why**: Native GitHub integration, free, automatable with GitHub CLI

### Setup Steps

#### 1. Create GitHub Project

```bash
# Install GitHub CLI if needed
# https://cli.github.com/

# Authenticate
gh auth login

# Create project
gh project create --owner YOUR_USERNAME --title "Modern POS - Sprints"

# Or via web: https://github.com/users/YOUR_USERNAME/projects/new
```

#### 2. Configure Project Board

**Columns**:
- Backlog
- Sprint 1 - Ready
- Sprint 1 - In Progress
- Sprint 1 - Done
- Sprint 2 - Ready
- Sprint 2 - In Progress
- Sprint 2 - Done
- (etc. for Sprint 3 and 4)

**Custom Fields**:
- Sprint: Select (Sprint 1, Sprint 2, Sprint 3, Sprint 4, Backlog)
- Story Points: Number (1-8)
- Priority: Select (P0 - Critical, P1 - High, P2 - Medium, P3 - Low)
- Assignee: User
- Status: Select (Pending, In Progress, Blocked, Done)

---

## Option 2: Linear (Modern Alternative)

**Why**: Better UX, API-first, great for sprints

### Setup

1. Go to https://linear.app
2. Create workspace
3. Set up teams (Backend, Frontend, DevOps)
4. Configure sprints (1-week cycles)
5. Get API key from Settings → API

**Pros**: Beautiful UI, excellent keyboard shortcuts, built-in cycle/sprint management
**Cons**: Paid after free tier

---

## Automation Scripts

### Script 1: Sync Task Files to GitHub Issues

I'll create a script that reads your task markdown files and creates GitHub issues.

**File**: `scripts/sync-tasks-to-github.sh`

```bash
#!/bin/bash
set -euo pipefail

# Modern POS - Sync Task Files to GitHub Issues
# This script creates GitHub issues from task markdown files

REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
REPO_NAME="${REPO_NAME:-modern-pos}"
TASKS_DIR="docs/implementation/tasks"

echo "🚀 Syncing task files to GitHub Issues..."

# Function to extract metadata from markdown file
extract_metadata() {
    local file=$1
    local key=$2
    grep "^**${key}**:" "$file" | sed "s/^**${key}**: *//" || echo ""
}

# Function to create issue from task file
create_issue() {
    local file=$1
    local title=$(basename "$file" .md)
    local sprint=$(extract_metadata "$file" "Sprint")
    local points=$(extract_metadata "$file" "Story Points")
    local assignee=$(extract_metadata "$file" "Assignee")
    local priority=$(extract_metadata "$file" "Priority")

    # Extract user story
    local body=$(sed -n '/## User Story/,/---/p' "$file" | grep -v "^##" | grep -v "^---" | sed '/^$/d')

    # Extract acceptance criteria
    local acceptance=$(sed -n '/## Acceptance Criteria/,/---/p' "$file" | grep -v "^##" | grep -v "^---")

    # Build issue body
    local issue_body="# User Story

${body}

## Acceptance Criteria

${acceptance}

---

📋 **Sprint**: ${sprint}
⭐ **Story Points**: ${points}
🎯 **Priority**: ${priority}
👤 **Assignee**: ${assignee}

📄 **Task File**: [View in repo](https://github.com/${REPO_OWNER}/${REPO_NAME}/blob/main/${file})
"

    # Create issue
    echo "Creating issue: ${title}"
    gh issue create \
        --repo "${REPO_OWNER}/${REPO_NAME}" \
        --title "${title}" \
        --body "${issue_body}" \
        --label "sprint-${sprint},story-points-${points},${priority}" \
        --assignee "${assignee}"
}

# Process all task files
find "${TASKS_DIR}/sprint-1" -name "*.md" -type f | while read -r file; do
    create_issue "$file"
done

echo "✅ Done! Check your issues at: https://github.com/${REPO_OWNER}/${REPO_NAME}/issues"
```

### Script 2: Update Sprint Board

**File**: `scripts/update-sprint-board.sh`

```bash
#!/bin/bash
set -euo pipefail

# Move issues to correct sprint columns based on status

REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
REPO_NAME="${REPO_NAME:-modern-pos}"
PROJECT_NUMBER="${PROJECT_NUMBER:-1}"

echo "📊 Updating sprint board..."

# Get all open issues
gh issue list \
    --repo "${REPO_OWNER}/${REPO_NAME}" \
    --state open \
    --json number,title,labels,assignees \
    --limit 1000 | \
jq -r '.[] | "\(.number)|\(.title)|\(.labels[].name)"' | \
while IFS='|' read -r issue_number title labels; do
    # Determine sprint and status from labels
    sprint=$(echo "$labels" | grep -o 'sprint-[0-9]' | head -1)
    status=$(echo "$labels" | grep -o 'status-[a-z-]*' | head -1 || echo "status-pending")

    echo "Issue #${issue_number}: ${sprint} - ${status}"

    # Add to project (if not already added)
    gh project item-add "$PROJECT_NUMBER" \
        --owner "$REPO_OWNER" \
        --url "https://github.com/${REPO_OWNER}/${REPO_NAME}/issues/${issue_number}" \
        2>/dev/null || true
done

echo "✅ Sprint board updated!"
```

### Script 3: Generate Sprint Report

**File**: `scripts/sprint-report.sh`

```bash
#!/bin/bash
set -euo pipefail

# Generate sprint progress report

REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
REPO_NAME="${REPO_NAME:-modern-pos}"
SPRINT="${1:-1}"

echo "📈 Sprint ${SPRINT} Report"
echo "=========================="
echo ""

# Count stories by status
total=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT}" --json number | jq '. | length')
done=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-done" --json number | jq '. | length')
in_progress=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-in-progress" --json number | jq '. | length')
pending=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-pending" --json number | jq '. | length')

echo "Total Stories: ${total}"
echo "Done: ${done}"
echo "In Progress: ${in_progress}"
echo "Pending: ${pending}"
echo ""

# Calculate completion percentage
if [ "$total" -gt 0 ]; then
    completion=$((done * 100 / total))
    echo "Completion: ${completion}%"
fi

# List open stories
echo ""
echo "Open Stories:"
gh issue list \
    --repo "${REPO_OWNER}/${REPO_NAME}" \
    --label "sprint-${SPRINT}" \
    --state open \
    --json number,title,assignees \
    --jq '.[] | "  #\(.number): \(.title) (@\(.assignees[0].login // "unassigned"))"'
```

---

## Makefile Integration

**File**: `Makefile` (add these targets)

```makefile
# Project Management
.PHONY: sync-tasks update-board sprint-report

sync-tasks:
	@echo "🚀 Syncing tasks to GitHub..."
	@bash scripts/sync-tasks-to-github.sh

update-board:
	@echo "📊 Updating sprint board..."
	@bash scripts/update-sprint-board.sh

sprint-report:
	@echo "📈 Generating sprint report..."
	@bash scripts/sprint-report.sh $(SPRINT)

# Example: make sprint-report SPRINT=1
```

---

## Claude-Friendly Automation

### Using GitHub Actions (Automatic)

**File**: `.github/workflows/sync-sprint-board.yml`

```yaml
name: Sync Sprint Board

on:
  push:
    paths:
      - 'docs/implementation/tasks/**/*.md'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup GitHub CLI
        run: |
          gh --version

      - name: Sync tasks to issues
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO_OWNER: ${{ github.repository_owner }}
          REPO_NAME: ${{ github.event.repository.name }}
        run: |
          bash scripts/sync-tasks-to-github.sh

      - name: Update sprint board
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          REPO_OWNER: ${{ github.repository_owner }}
          REPO_NAME: ${{ github.event.repository.name }}
        run: |
          bash scripts/update-sprint-board.sh
```

### Manual Trigger (Claude can run this)

```bash
# Claude can execute these commands:

# 1. Sync all tasks to GitHub
make sync-tasks

# 2. Update board status
make update-board

# 3. Generate sprint report
make sprint-report SPRINT=1
```

---

## Task File Format (GitHub-Compatible)

Your task files already have the right format! Example:

```markdown
# S1.1: Setup Monorepo

**Sprint**: 1
**Story Points**: 5
**Assignee**: Developer A
**Priority**: P0 - Critical

## User Story
As a **developer**, I want **a well-structured monorepo** so that **all services are organized and easy to navigate**.

## Acceptance Criteria
- [ ] Directory structure created
- [ ] README files in each directory
- [ ] Go modules initialized
```

The sync script will automatically:
1. Create GitHub issue titled "S1.1: Setup Monorepo"
2. Add labels: `sprint-1`, `story-points-5`, `P0 - Critical`
3. Assign to "Developer A"
4. Include user story and acceptance criteria in body

---

## Daily Workflow

### Morning Standup
```bash
# Generate today's report
make sprint-report SPRINT=1

# View your assigned issues
gh issue list --assignee @me --label "sprint-1"
```

### During Development
```bash
# Start working on issue
gh issue edit 123 --add-label "status-in-progress"

# Mark as done
gh issue edit 123 --add-label "status-done"

# Or close when complete
gh issue close 123
```

### End of Sprint
```bash
# Generate final report
make sprint-report SPRINT=1 > reports/sprint-1-final.md

# Sync any remaining tasks to next sprint
# (manually relabel issues or update task files)
```

---

## Alternative: Simple Markdown Board

If you prefer to stay in the repo without external tools:

**File**: `docs/implementation/SPRINT_BOARD.md`

```markdown
# Sprint Board

## Sprint 1 (Nov 4-8)

### 🔴 Pending
- [ ] S1.1: Setup Monorepo (@Developer A)
- [ ] S1.2: Configure Docker (@Developer B)

### 🟡 In Progress
- [ ] S1.3: Setup Buf (@Developer A)

### 🟢 Done
- [x] S1.0: Initial Planning

### ⚫ Blocked
- [ ] S1.X: Waiting for design approval

---

## Sprint 2 (Nov 11-15)
...
```

Update via script:

```bash
#!/bin/bash
# scripts/update-markdown-board.sh

# Parse task files and update SPRINT_BOARD.md
# (simpler than GitHub, just text manipulation)
```

---

## Recommendation

**For this project, I recommend**:

1. **GitHub Projects** - Native integration, free, automatable
2. **GitHub Issues** - Create from task files
3. **GitHub Actions** - Auto-sync when task files change
4. **Makefile commands** - Manual sync when needed

**Setup time**: ~30 minutes
**Automation**: Full (GitHub Actions + scripts)
**Cost**: Free

---

## Next Steps

1. Choose your platform (GitHub Projects recommended)
2. Create the scripts directory
3. Add automation scripts
4. Run initial sync: `make sync-tasks`
5. Set up GitHub Actions for auto-sync

Would you like me to create these automation scripts in your repo?
