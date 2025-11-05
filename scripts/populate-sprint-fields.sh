#!/bin/bash
set -euo pipefail

# Modern POS - Populate Sprint Fields on GitHub Project Board
# This script sets the Sprint custom field for all issues

OWNER="kevin07696"
REPO_NAME="modern-pos"
PROJECT_NUMBER=2

echo "🎯 Populating Sprint fields on project board..."
echo ""

# Get project ID
PROJECT_ID=$(gh project list --owner $OWNER --format json | jq -r ".projects[] | select(.number == $PROJECT_NUMBER) | .id")
echo "📋 Project ID: $PROJECT_ID"

# Get Sprint field ID
SPRINT_FIELD_ID=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .id')
echo "📋 Sprint Field ID: $SPRINT_FIELD_ID"

# Get Sprint field options
echo ""
echo "📊 Available Sprint options:"
SPRINT_OPTIONS=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .options')
echo "$SPRINT_OPTIONS" | jq -r '.[] | "  - \(.name) (ID: \(.id))"'

# Get option IDs for each sprint
SPRINT_1_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 1") | .id')
SPRINT_2_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 2") | .id')
SPRINT_3_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 3") | .id')
SPRINT_4_ID=$(echo "$SPRINT_OPTIONS" | jq -r '.[] | select(.name == "Sprint 4") | .id')

echo ""
echo "🔍 Sprint Option IDs:"
echo "  Sprint 1: $SPRINT_1_ID"
echo "  Sprint 2: $SPRINT_2_ID"
echo "  Sprint 3: $SPRINT_3_ID"
echo "  Sprint 4: $SPRINT_4_ID"
echo ""

# Function to set sprint field for an issue
set_sprint_field() {
    local issue_number=$1
    local sprint_option_id=$2
    local sprint_name=$3

    echo "  Setting issue #${issue_number} → ${sprint_name}..."

    # Get the project item ID for this issue
    ITEM_ID=$(gh project item-list $PROJECT_NUMBER --owner $OWNER --format json --limit 1000 | \
        jq -r ".items[] | select(.content.number == $issue_number) | .id")

    if [ -z "$ITEM_ID" ]; then
        echo "    ⚠️  Could not find project item for issue #${issue_number}"
        return
    fi

    # Set the Sprint field using GraphQL
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
    " > /dev/null

    echo "    ✅ Issue #${issue_number} set to ${sprint_name}"
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
echo "✅ All Sprint fields populated!"
echo ""
echo "🎨 Your board views should now show issues correctly:"
echo "  - Sprint 1 Board: 16 issues (#2-17)"
echo "  - Sprint 2 Board: 16 issues (#18-33)"
echo "  - Sprint 3 Board: 16 issues (#34-49)"
echo "  - Sprint 4 Board: 16 issues (#50-65)"
echo ""
echo "🚀 Open board: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
