#!/bin/bash
set -euo pipefail

# Modern POS - Update Sprint Board
# Move issues to correct sprint columns based on status

REPO_OWNER="${REPO_OWNER:-kevin07696}"
REPO_NAME="${REPO_NAME:-modern-pos}"
PROJECT_NUMBER="${PROJECT_NUMBER:-2}"

echo "📊 Updating sprint board..."

# Get all open issues
gh issue list \
    --repo "${REPO_OWNER}/${REPO_NAME}" \
    --state open \
    --json number,title,labels,assignees \
    --limit 1000 | \
jq -r '.[] | "\(.number)|\(.title)|\(.labels | map(.name) | join(","))"' | \
while IFS='|' read -r issue_number title labels; do
    # Determine sprint and status from labels
    sprint=$(echo "$labels" | grep -o 'sprint-[0-9]' | head -1 || echo "")
    status=$(echo "$labels" | grep -o 'status-[a-z-]*' | head -1 || echo "status-pending")

    if [ -n "$sprint" ]; then
        echo "Issue #${issue_number}: ${sprint} - ${status}"

        # Add to project (if not already added)
        gh project item-add "$PROJECT_NUMBER" \
            --owner "$REPO_OWNER" \
            --url "https://github.com/${REPO_OWNER}/${REPO_NAME}/issues/${issue_number}" \
            2>/dev/null || true
    fi
done

echo "✅ Sprint board updated!"
