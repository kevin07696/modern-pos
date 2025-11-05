#!/bin/bash
set -euo pipefail

# Modern POS - Add Issues to Project Board (Optimized for Rate Limits)
# Phase 1: Add all issues to project (REST API)
# Phase 2: Set Sprint fields (GraphQL API)

OWNER="kevin07696"
REPO_NAME="modern-pos"
PROJECT_NUMBER=2

echo "🚀 Phase 1: Adding all issues to project board..."
echo ""

# Phase 1: Add all issues to the project
echo "📝 Adding issues #2-65 to project..."
for i in {2..65}; do
    echo -n "  Adding issue #${i}... "
    gh project item-add $PROJECT_NUMBER --owner $OWNER --url "https://github.com/${OWNER}/${REPO_NAME}/issues/${i}" > /dev/null 2>&1 && echo "✅" || echo "⚠️  (may already exist)"
    sleep 0.2  # Small delay to avoid overwhelming the API
done

echo ""
echo "✅ Phase 1 complete! All issues added to project."
echo ""
echo "⏳ Waiting 5 seconds before Phase 2..."
sleep 5

echo "🚀 Phase 2: Setting Sprint custom fields..."
echo ""

# Get project and field IDs
PROJECT_ID=$(gh project list --owner $OWNER --format json | jq -r ".projects[] | select(.number == $PROJECT_NUMBER) | .id")
SPRINT_FIELD_ID=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .id')

# Get Sprint option IDs
SPRINT_OPTIONS=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .options')
SPRINT_1_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 1") | .id')
SPRINT_2_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 2") | .id')
SPRINT_3_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 3") | .id')
SPRINT_4_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 4") | .id')

echo "📋 Project ID: $PROJECT_ID"
echo "📋 Sprint Field ID: $SPRINT_FIELD_ID"
echo ""

# Get all project items in one call
echo "🔍 Fetching all project items..."
PROJECT_ITEMS=$(gh project item-list $PROJECT_NUMBER --owner $OWNER --format json --limit 1000)

# Function to set sprint field
set_sprint_field() {
    local issue_number=$1
    local sprint_option_id=$2
    local sprint_name=$3

    # Find the project item ID for this issue
    ITEM_ID=$(echo "$PROJECT_ITEMS" | jq -r ".items[] | select(.content.number == $issue_number) | .id")

    if [ -z "$ITEM_ID" ] || [ "$ITEM_ID" == "null" ]; then
        echo "  ⚠️  Issue #${issue_number}: Could not find project item"
        return
    fi

    # Set the Sprint field using GraphQL
    echo -n "  Setting issue #${issue_number} → ${sprint_name}... "
    gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(
                input: {
                    projectId: \"$PROJECT_ID\"
                    itemId: \"$ITEM_ID\"
                    fieldId: \"$SPRINT_FIELD_ID\"
                    value: {
                        singleSelectOptionId: \"$sprint_option_id\"
                    }
                }
            ) {
                projectV2Item {
                    id
                }
            }
        }
    " > /dev/null 2>&1 && echo "✅" || echo "❌"

    sleep 0.3  # Small delay between GraphQL calls
}

echo "📝 Setting Sprint 1 (Issues #2-17)..."
for i in {2..17}; do
    set_sprint_field $i "$SPRINT_1_ID" "Sprint 1"
done

echo ""
echo "📝 Setting Sprint 2 (Issues #18-33)..."
for i in {18..33}; do
    set_sprint_field $i "$SPRINT_2_ID" "Sprint 2"
done

echo ""
echo "📝 Setting Sprint 3 (Issues #34-49)..."
for i in {34..49}; do
    set_sprint_field $i "$SPRINT_3_ID" "Sprint 3"
done

echo ""
echo "📝 Setting Sprint 4 (Issues #50-65)..."
for i in {50..65}; do
    set_sprint_field $i "$SPRINT_4_ID" "Sprint 4"
done

echo ""
echo "✅ All done! Your project board is fully configured."
echo ""
echo "🎨 Check your board:"
echo "  https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
echo ""
echo "📊 Expected results:"
echo "  - Sprint 1 view: 16 issues (#2-17)"
echo "  - Sprint 2 view: 16 issues (#18-33)"
echo "  - Sprint 3 view: 16 issues (#34-49)"
echo "  - Sprint 4 view: 16 issues (#50-65)"
