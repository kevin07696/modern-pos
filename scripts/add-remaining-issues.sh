#!/bin/bash
set -euo pipefail

# Modern POS - Add Remaining Issues to Project Board
# This script adds issues #22-65 that failed in the previous attempt

OWNER="@me"
REPO_NAME="modern-pos"
PROJECT_NUMBER=2

echo "🚀 Adding remaining issues #22-65 to project board..."
echo ""

# Check REST API rate limit (project item-add uses REST, not GraphQL)
REST_REMAINING=$(gh api rate_limit | jq -r '.resources.core.remaining')
echo "📊 REST API requests remaining: $REST_REMAINING"

if [ "$REST_REMAINING" -lt 50 ]; then
    echo "⚠️  Low REST API requests. May hit rate limit."
fi

echo ""

# Add issues one by one with proper error handling
for i in {22..65}; do
    echo -n "Adding issue #${i}... "

    RESULT=$(gh project item-add $PROJECT_NUMBER \
        --owner $OWNER \
        --url "https://github.com/kevin07696/${REPO_NAME}/issues/${i}" \
        --format json 2>&1)

    if echo "$RESULT" | jq -e '.id' > /dev/null 2>&1; then
        ITEM_ID=$(echo "$RESULT" | jq -r '.id')
        echo "✅ (Item ID: ${ITEM_ID:0:8}...)"
    else
        echo "❌ Failed"
        echo "   Error: $RESULT"
    fi

    sleep 0.3  # Rate limiting delay
done

echo ""
echo "✅ Finished adding issues!"
echo ""
echo "🔍 To verify, check your board:"
echo "   https://github.com/users/kevin07696/projects/2"
echo ""
echo "📝 Next step: Run set-sprint-fields.sh after 3:33 AM to set Sprint values"
