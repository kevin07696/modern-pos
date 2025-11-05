#!/bin/bash
set -euo pipefail

# Modern POS - CI/CD Setup Script
# This script helps configure GitHub repository settings for CI/CD

REPO="kevin07696/modern-pos"

echo "🚀 CI/CD Setup Script for Modern POS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if gh CLI is authenticated
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI authenticated"
echo ""

# Step 1: Create additional labels for CI/CD
echo "📋 Step 1: Creating CI/CD labels..."
echo ""

declare -A LABELS=(
    ["ci"]="Continuous Integration"
    ["cd"]="Continuous Deployment"
    ["security"]="Security related"
    ["performance"]="Performance improvements"
    ["documentation"]="Documentation updates"
    ["breaking-change"]="Breaking change"
    ["enhancement"]="New feature or enhancement"
    ["bug"]="Bug fix"
)

declare -A COLORS=(
    ["ci"]="2E7D32"
    ["cd"]="1976D2"
    ["security"]="D32F2F"
    ["performance"]="F57C00"
    ["documentation"]="0288D1"
    ["breaking-change"]="E91E63"
    ["enhancement"]="7B1FA2"
    ["bug"]="E53935"
)

for label in "${!LABELS[@]}"; do
    echo -n "  Creating label: $label... "
    gh label create "$label" \
        --description "${LABELS[$label]}" \
        --color "${COLORS[$label]}" \
        --repo "$REPO" 2>/dev/null && echo "✅" || echo "⚠️  (may exist)"
done

echo ""
echo "✅ Labels created"
echo ""

# Step 2: Check repository settings
echo "📋 Step 2: Checking repository settings..."
echo ""

REPO_INFO=$(gh api repos/$REPO)

echo "Repository settings:"
echo "  • Name: $(echo "$REPO_INFO" | jq -r '.name')"
echo "  • Private: $(echo "$REPO_INFO" | jq -r '.private')"
echo "  • Issues: $(echo "$REPO_INFO" | jq -r '.has_issues')"
echo "  • Projects: $(echo "$REPO_INFO" | jq -r '.has_projects')"
echo "  • Wiki: $(echo "$REPO_INFO" | jq -r '.has_wiki')"
echo "  • Default branch: $(echo "$REPO_INFO" | jq -r '.default_branch')"
echo ""

# Step 3: Check current workflows
echo "📋 Step 3: Checking GitHub Actions workflows..."
echo ""

WORKFLOWS=$(gh api repos/$REPO/actions/workflows | jq -r '.workflows[] | .name')
WORKFLOW_COUNT=$(echo "$WORKFLOWS" | wc -l)

echo "Found $WORKFLOW_COUNT workflows:"
echo "$WORKFLOWS" | while read -r workflow; do
    echo "  ✅ $workflow"
done
echo ""

# Step 4: Check secrets (without exposing values)
echo "📋 Step 4: Checking configured secrets..."
echo ""

SECRETS=$(gh secret list --repo "$REPO" 2>/dev/null || echo "")

if [ -z "$SECRETS" ]; then
    echo "⚠️  No secrets configured yet"
    echo ""
    echo "Required secrets for deployments:"
    echo "  • AWS_ACCESS_KEY_ID"
    echo "  • AWS_SECRET_ACCESS_KEY"
    echo "  • SLACK_WEBHOOK (optional)"
    echo "  • DATADOG_API_KEY (optional)"
    echo "  • SNYK_TOKEN (optional)"
    echo ""
    echo "To add secrets:"
    echo "  gh secret set SECRET_NAME --repo $REPO"
    echo "  or visit: https://github.com/$REPO/settings/secrets/actions"
else
    echo "Configured secrets:"
    echo "$SECRETS" | awk '{print "  ✅ " $1}'
fi

echo ""

# Step 5: Check environments
echo "📋 Step 5: Checking deployment environments..."
echo ""

ENVIRONMENTS=$(gh api repos/$REPO/environments 2>/dev/null | jq -r '.environments[]?.name' 2>/dev/null || echo "")

if [ -z "$ENVIRONMENTS" ]; then
    echo "⚠️  No environments configured yet"
    echo ""
    echo "Recommended environments:"
    echo "  • staging"
    echo "  • production"
    echo ""
    echo "To create: Visit https://github.com/$REPO/settings/environments"
else
    echo "Configured environments:"
    echo "$ENVIRONMENTS" | while read -r env; do
        echo "  ✅ $env"
    done
fi

echo ""

# Step 6: Check branch protection
echo "📋 Step 6: Checking branch protection..."
echo ""

PROTECTION=$(gh api repos/$REPO/branches/main/protection 2>/dev/null || echo "")

if [ -z "$PROTECTION" ]; then
    echo "⚠️  Branch protection not configured for 'main'"
    echo ""
    echo "Recommended settings:"
    echo "  • Require pull request reviews (1 approval)"
    echo "  • Require status checks to pass"
    echo "  • Require branches to be up to date"
    echo "  • Require conversation resolution"
    echo ""
    echo "To configure: Visit https://github.com/$REPO/settings/branches"
else
    echo "✅ Branch protection is configured for 'main'"

    # Check specific protections
    REQUIRES_PR=$(echo "$PROTECTION" | jq -r '.required_pull_request_reviews != null')
    REQUIRES_CHECKS=$(echo "$PROTECTION" | jq -r '.required_status_checks != null')

    if [ "$REQUIRES_PR" = "true" ]; then
        REVIEW_COUNT=$(echo "$PROTECTION" | jq -r '.required_pull_request_reviews.required_approving_review_count')
        echo "  • PR reviews required: $REVIEW_COUNT approval(s)"
    fi

    if [ "$REQUIRES_CHECKS" = "true" ]; then
        CHECK_COUNT=$(echo "$PROTECTION" | jq -r '.required_status_checks.checks | length')
        echo "  • Required status checks: $CHECK_COUNT checks"
    fi
fi

echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 CI/CD Setup Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Checklist
CHECKLIST=(
    "GitHub Actions workflows:$WORKFLOW_COUNT configured:true"
    "Repository labels:created:true"
    "Branch protection:configured:${REQUIRES_PR:-false}"
    "GitHub secrets:configured:$([ -n "$SECRETS" ] && echo true || echo false)"
    "Deployment environments:configured:$([ -n "$ENVIRONMENTS" ] && echo true || echo false)"
)

for item in "${CHECKLIST[@]}"; do
    IFS=':' read -r name status value <<< "$item"
    if [ "$value" = "true" ]; then
        echo "  ✅ $name: $status"
    else
        echo "  ⚠️  $name: Needs setup"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Next steps
echo "🎯 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -z "$SECRETS" ]; then
    echo "1. Configure GitHub Secrets (REQUIRED for deployments)"
    echo "   https://github.com/$REPO/settings/secrets/actions"
    echo ""
fi

if [ "$REQUIRES_PR" != "true" ]; then
    echo "2. Enable Branch Protection (RECOMMENDED)"
    echo "   https://github.com/$REPO/settings/branches"
    echo ""
fi

if [ -z "$ENVIRONMENTS" ]; then
    echo "3. Create Deployment Environments (RECOMMENDED)"
    echo "   https://github.com/$REPO/settings/environments"
    echo ""
fi

echo "4. Test CI/CD Pipeline"
echo "   • Create a test branch"
echo "   • Make a small change"
echo "   • Create a pull request"
echo "   • Watch workflows run"
echo ""

echo "📚 Documentation:"
echo "   • docs/deployment/CI_CD_SETUP.md - Complete guide"
echo "   • docs/deployment/QUICK_START.md - Quick reference"
echo ""

echo "✅ CI/CD setup check complete!"
