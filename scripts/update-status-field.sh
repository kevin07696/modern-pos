#!/bin/bash
set -euo pipefail

# Modern POS - Update Status Field with Descriptions
# This script adds missing status options and provides instructions for descriptions

OWNER="kevin07696"
PROJECT_NUMBER=2

echo "📝 Updating Status Field on GitHub Projects Board..."
echo ""

# Get project and field IDs
echo "🔍 Getting project details..."
PROJECT_ID=$(gh project list --owner $OWNER --format json | jq -r ".projects[] | select(.number == $PROJECT_NUMBER) | .id")
STATUS_FIELD_ID=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Status") | .id')

echo "   Project ID: $PROJECT_ID"
echo "   Status Field ID: $STATUS_FIELD_ID"
echo ""

# Get current status options
echo "📊 Current Status field options:"
gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Status") | .options[] | "   - \(.name) (ID: \(.id))"'
echo ""

# Note: GitHub CLI doesn't support adding descriptions to field options
# We need to use GraphQL API directly

echo "⚠️  GitHub CLI Limitation:"
echo "   The 'gh' CLI doesn't support adding descriptions to status field options."
echo "   Descriptions must be added manually in the web UI."
echo ""
echo "🎯 Manual Steps to Add Status Descriptions:"
echo ""
echo "1. Open your project: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
echo "2. Click ⚙️ Settings (top right)"
echo "3. Scroll to 'Fields' section"
echo "4. Click on 'Status' field"
echo "5. For each status option, click the option name to edit"
echo "6. Add the description below:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Backlog"
echo "   Description: Stories not yet started. Needs refinement or not in current sprint."
echo ""
echo "✅ Ready"
echo "   Description: Stories refined, estimated, and ready to be picked up by team members."
echo ""
echo "🏃 In Progress"
echo "   Description: Currently being worked on. Developer has started coding."
echo ""
echo "👀 Review"
echo "   Description: Code review, testing, and QA. Pull request is open and needs approval."
echo ""
echo "✨ Done"
echo "   Description: Completed, merged, and deployed. Acceptance criteria met."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Review and Done options exist
CURRENT_OPTIONS=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Status") | .options[].name')

if ! echo "$CURRENT_OPTIONS" | grep -q "Review"; then
    echo "⚠️  Missing status option: Review"
    echo "   Add this option in the web UI (Settings → Status field → + Add option)"
    echo ""
fi

if ! echo "$CURRENT_OPTIONS" | grep -q "Done"; then
    echo "⚠️  Missing status option: Done"
    echo "   Add this option in the web UI (Settings → Status field → + Add option)"
    echo ""
fi

echo "✅ Once configured, your Status field will have:"
echo "   • Backlog (Stories not started)"
echo "   • Ready (Refined and ready to work)"
echo "   • In Progress (Being developed)"
echo "   • Review (Code review & testing)"
echo "   • Done (Completed & deployed)"
echo ""
echo "🚀 Open project settings: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER/settings"
