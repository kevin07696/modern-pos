#!/bin/bash
set -euo pipefail

# Modern POS - Add Issues to Project Board and Set Sprint Fields
# This script adds all issues to the project and sets Sprint custom field

OWNER="kevin07696"
REPO_NAME="modern-pos"
PROJECT_NUMBER=2

echo "🚀 Adding issues to project board and setting Sprint fields..."
echo ""

# Get project ID
PROJECT_ID=$(gh project list --owner $OWNER --format json | jq -r ".projects[] | select(.number == $PROJECT_NUMBER) | .id")
echo "📋 Project ID: $PROJECT_ID"

# Get Sprint field ID
SPRINT_FIELD_ID=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .id')
echo "📋 Sprint Field ID: $SPRINT_FIELD_ID"

# Get Sprint field options
SPRINT_OPTIONS=$(gh project field-list $PROJECT_NUMBER --owner $OWNER --format json | jq -r '.fields[] | select(.name == "Sprint") | .options')

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

# Function to add issue to project and set sprint
add_and_set_sprint() {
    local issue_number=$1
    local sprint_option_id=$2
    local sprint_name=$3

    echo "  Processing issue #${issue_number} → ${sprint_name}..."

    # Add issue to project and get item ID
    ITEM_ID=$(gh project item-add $PROJECT_NUMBER --owner $OWNER --url "https://github.com/${OWNER}/${REPO_NAME}/issues/${issue_number}" --format json | jq -r '.id')

    if [ -z "$ITEM_ID" ] || [ "$ITEM_ID" == "null" ]; then
        echo "    ⚠️  Could not add issue #${issue_number} to project"
        return
    fi

    echo "    ✅ Added to project (Item ID: $ITEM_ID)"

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
    " > /dev/null 2>&1

    echo "    ✅ Sprint field set to ${sprint_name}"

    # Rate limiting - wait 0.5 seconds between requests
    sleep 0.5
}

echo "📝 Processing Sprint 1 (Issues #2-17)..."
for i in {2..17}; do
    add_and_set_sprint $i "$SPRINT_1_ID" "Sprint 1"
done

echo ""
echo "📝 Processing Sprint 2 (Issues #18-33)..."
for i in {18..33}; do
    add_and_set_sprint $i "$SPRINT_2_ID" "Sprint 2"
done

echo ""
echo "📝 Processing Sprint 3 (Issues #34-49)..."
for i in {34..49}; do
    add_and_set_sprint $i "$SPRINT_3_ID" "Sprint 3"
done

echo ""
echo "📝 Processing Sprint 4 (Issues #50-65)..."
for i in {50..65}; do
    add_and_set_sprint $i "$SPRINT_4_ID" "Sprint 4"
done

echo ""
echo "✅ All issues added to project board with Sprint fields set!"
echo ""
echo "🎨 Your board views should now show:"
echo "  - Sprint 1: 16 issues (#2-17)"
echo "  - Sprint 2: 16 issues (#18-33)"
echo "  - Sprint 3: 16 issues (#34-49)"
echo "  - Sprint 4: 16 issues (#50-65)"
echo ""
echo "🚀 Open board: https://github.com/users/$OWNER/projects/$PROJECT_NUMBER"
