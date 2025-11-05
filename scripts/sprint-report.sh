#!/bin/bash
set -euo pipefail

# Modern POS - Generate Sprint Progress Report
# Usage: ./sprint-report.sh [sprint_number]

REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
REPO_NAME="${REPO_NAME:-modern-pos}"
SPRINT="${1:-1}"

echo "📈 Sprint ${SPRINT} Report"
echo "=========================="
echo ""

# Count stories by status
total=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT}" --json number 2>/dev/null | jq '. | length' || echo "0")
done=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-done" --json number 2>/dev/null | jq '. | length' || echo "0")
in_progress=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-in-progress" --json number 2>/dev/null | jq '. | length' || echo "0")
pending=$(gh issue list --repo "${REPO_OWNER}/${REPO_NAME}" --label "sprint-${SPRINT},status-pending" --json number 2>/dev/null | jq '. | length' || echo "0")

echo "Total Stories: ${total}"
echo "Done: ${done}"
echo "In Progress: ${in_progress}"
echo "Pending: ${pending}"
echo ""

# Calculate completion percentage
if [ "$total" -gt 0 ]; then
    completion=$((done * 100 / total))
    echo "Completion: ${completion}%"

    # Visual progress bar
    filled=$((completion / 5))
    empty=$((20 - filled))
    printf "Progress: ["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] ${completion}%%\n"
fi

# List open stories
echo ""
echo "Open Stories:"
gh issue list \
    --repo "${REPO_OWNER}/${REPO_NAME}" \
    --label "sprint-${SPRINT}" \
    --state open \
    --json number,title,assignees,labels \
    --jq '.[] | "  #\(.number): \(.title) (@\(.assignees[0].login // "unassigned")) [\(.labels | map(select(.name | startswith("status-"))) | .[0].name // "no-status")]"' 2>/dev/null || echo "  No open stories found"

echo ""
echo "---"
echo "💡 Tip: Run 'make sprint-report SPRINT=${SPRINT}' to regenerate this report"
