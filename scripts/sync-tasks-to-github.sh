#!/bin/bash
set -euo pipefail

# Modern POS - Sync Task Files to GitHub Issues
# This script creates GitHub issues from task markdown files

REPO_OWNER="${REPO_OWNER:-kevin07696}"
REPO_NAME="${REPO_NAME:-modern-pos}"
TASKS_DIR="docs/implementation/tasks"

echo "🚀 Syncing task files to GitHub Issues..."

# Function to extract metadata from markdown file
extract_metadata() {
    local file=$1
    local key=$2
    grep "^\*\*${key}\*\*:" "$file" | sed "s/^\*\*${key}\*\*: *//" | sed 's/[[:space:]]*$//' || echo ""
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

    # Create issue without labels or assignees (can be set manually later)
    gh issue create \
        --repo "${REPO_OWNER}/${REPO_NAME}" \
        --title "${title}" \
        --body "${issue_body}"
}

# Process all task files for each sprint
for sprint in sprint-1 sprint-2 sprint-3 sprint-4; do
    if [ -d "${TASKS_DIR}/${sprint}" ]; then
        echo "Processing ${sprint}..."
        find "${TASKS_DIR}/${sprint}" -name "*.md" -type f | while read -r file; do
            create_issue "$file"
        done
    fi
done

echo "✅ Done! Check your issues at: https://github.com/${REPO_OWNER}/${REPO_NAME}/issues"
