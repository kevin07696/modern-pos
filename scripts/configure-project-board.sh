#!/bin/bash
set -euo pipefail

# Modern POS - Configure GitHub Project Board
# This script sets up custom fields and views for the sprint board

OWNER="kevin07696"
PROJECT_NUMBER=2

echo "🎨 Configuring Modern POS Sprint Board..."
echo ""

# Step 1: Add custom fields
echo "📋 Adding custom fields..."

# Add Sprint field (single select)
echo "  - Adding Sprint field..."
gh project field-create $PROJECT_NUMBER \
    --owner $OWNER \
    --name "Sprint" \
    --data-type "SINGLE_SELECT" 2>/dev/null || echo "    (Sprint field may already exist)"

# Add Story Points field (number)
echo "  - Adding Story Points field..."
gh project field-create $PROJECT_NUMBER \
    --owner $OWNER \
    --name "Story Points" \
    --data-type "NUMBER" 2>/dev/null || echo "    (Story Points field may already exist)"

# Add Priority field (single select)
echo "  - Adding Priority field..."
gh project field-create $PROJECT_NUMBER \
    --owner $OWNER \
    --name "Priority" \
    --data-type "SINGLE_SELECT" 2>/dev/null || echo "    (Priority field may already exist)"

# Add Blocked field (single select)
echo "  - Adding Blocked field..."
gh project field-create $PROJECT_NUMBER \
    --owner $OWNER \
    --name "Blocked" \
    --data-type "SINGLE_SELECT" 2>/dev/null || echo "    (Blocked field may already exist)"

echo ""
echo "✅ Custom fields configured!"
echo ""
echo "📊 Current project fields:"
gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | "  - \(.name) (\(.type))"'

echo ""
echo "⚠️  Note: Status field options and field option values must be configured manually in the web UI"
echo ""
echo "Next steps to complete in web UI (https://github.com/users/$OWNER/projects/$PROJECT_NUMBER):"
echo ""
echo "1. Configure Status field options:"
echo "   - Remove: Todo"
echo "   - Keep: In Progress, Done"
echo "   - Add: Backlog, Ready, Review"
echo ""
echo "2. Configure Sprint field options:"
echo "   - Add: Sprint 1, Sprint 2, Sprint 3, Sprint 4, Backlog"
echo ""
echo "3. Configure Priority field options:"
echo "   - Add: P0 - Critical, P1 - High, P2 - Medium, P3 - Low"
echo ""
echo "4. Configure Blocked field options:"
echo "   - Add: Yes, No"
echo ""
echo "5. Create views:"
echo "   - Sprint 1 Board (filter by Sprint = Sprint 1)"
echo "   - Sprint 2 Board (filter by Sprint = Sprint 2)"
echo "   - Sprint 3 Board (filter by Sprint = Sprint 3)"
echo "   - Sprint 4 Board (filter by Sprint = Sprint 4)"
echo "   - Backlog (table view)"
echo "   - Team View (group by Assignees)"
echo ""
echo "🚀 Open project board: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
