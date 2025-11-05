# CI/CD Next Steps - Configuration Guide

**Status**: ✅ Workflows configured | ⚠️ Secrets & branch protection needed

---

## Current Status

### ✅ What's Already Done

- **9 GitHub Actions workflows** configured and active
- **Staging environment** created
- **CI/CD labels** added to repository
- **CodeRabbit** integrated for code review
- **Dependabot** configured for dependency updates

### ⚠️ What Needs Configuration

1. **GitHub Secrets** (5-10 minutes) - REQUIRED for deployments
2. **Branch Protection** (3-5 minutes) - RECOMMENDED for safety
3. **Production Environment** (5 minutes) - Needed for production deploys
4. **Test CI/CD Pipeline** (10 minutes) - Verify everything works

---

## Step 1: Configure GitHub Secrets (REQUIRED)

### Why Needed?
- Enable AWS deployments
- Send Slack notifications
- Run security scans (Snyk)
- Push deployment markers to Datadog

### How to Configure

#### Method 1: GitHub Web UI (Recommended)

1. Go to: https://github.com/kevin07696/modern-pos/settings/secrets/actions

2. Click **"New repository secret"** for each:

**Required for AWS Deployments:**
```
Name: AWS_ACCESS_KEY_ID
Value: <your-aws-access-key-id>

Name: AWS_SECRET_ACCESS_KEY
Value: <your-aws-secret-access-key>
```

**Optional but Recommended:**
```
Name: SLACK_WEBHOOK
Value: <your-slack-webhook-url>

Name: DATADOG_API_KEY
Value: <your-datadog-api-key>

Name: SNYK_TOKEN
Value: <your-snyk-api-token>
```

**Production Deployment (add when ready):**
```
Name: PROD_LISTENER_ARN
Value: <alb-listener-arn>

Name: GREEN_TARGET_GROUP_ARN
Value: <green-target-group-arn>

Name: BLUE_TARGET_GROUP_ARN
Value: <blue-target-group-arn>
```

#### Method 2: GitHub CLI

```bash
# AWS credentials
gh secret set AWS_ACCESS_KEY_ID --repo kevin07696/modern-pos
gh secret set AWS_SECRET_ACCESS_KEY --repo kevin07696/modern-pos

# Optional
gh secret set SLACK_WEBHOOK --repo kevin07696/modern-pos
gh secret set DATADOG_API_KEY --repo kevin07696/modern-pos
gh secret set SNYK_TOKEN --repo kevin07696/modern-pos
```

### Getting the Credentials

**AWS**:
1. Go to AWS Console → IAM → Users
2. Create user with programmatic access
3. Attach policies: `AmazonECS_FullAccess`, `AmazonEC2ContainerRegistryFullAccess`
4. Save access key ID and secret

**Slack**:
1. Go to your Slack workspace
2. Create incoming webhook: https://api.slack.com/messaging/webhooks
3. Copy webhook URL

**Datadog**:
1. Go to Datadog → Organization Settings → API Keys
2. Create new API key
3. Copy key

**Snyk**:
1. Sign up at https://snyk.io/
2. Go to Account Settings → API Token
3. Copy token

---

## Step 2: Configure Branch Protection (RECOMMENDED)

### Why Needed?
- Prevent direct pushes to main
- Require PR reviews before merge
- Ensure CI checks pass before merge
- Require conversation resolution

### How to Configure

1. Go to: https://github.com/kevin07696/modern-pos/settings/branches

2. Click **"Add branch protection rule"**

3. Configure:

**Branch name pattern:**
```
main
```

**Protect matching branches - Enable:**
- ✅ Require a pull request before merging
  - Required approvals: **1**
  - ✅ Dismiss stale pull request approvals when new commits are pushed
  - ✅ Require review from Code Owners

- ✅ Require status checks to pass before merging
  - ✅ Require branches to be up to date before merging
  - **Search for and add these checks:**
    - `Proto Validation`
    - `Go Lint`
    - `Go Test`
    - `Go Build`
    - `Lint and Test`
    - `Build Next.js App`
    - `Container Security Scan`
    - `Secret Scanning`
    - `CodeRabbit`

- ✅ Require conversation resolution before merging

- ✅ Do not allow bypassing the above settings
  - ⚠️ Uncheck "Include administrators" (allows emergency fixes)

4. Click **"Create"**

---

## Step 3: Create Production Environment (Optional)

### When Needed?
- Before first production deployment (Sprint 2+)
- Adds protection to production deploys
- Allows environment-specific secrets

### How to Configure

1. Go to: https://github.com/kevin07696/modern-pos/settings/environments

2. Click **"New environment"**

3. Name: `production`

4. Configure:

**Protection rules:**
- ✅ Required reviewers: Add yourself
- ✅ Wait timer: 0 minutes (or add delay)
- ✅ Deployment branches: Only `main` and tags matching `v*`

**Environment secrets:**
- Add production-specific secrets here
- Override repository secrets if needed

5. Click **"Save protection rules"**

---

## Step 4: Test CI/CD Pipeline

### 4.1: Create Test Branch

```bash
cd /home/kevinlam/Documents/projects/pos

# Create test branch
git checkout -b test/cicd-verification

# Make a simple change
echo "# CI/CD Test" >> test-cicd.md

# Commit
git add test-cicd.md
git commit -m "test: verify CI/CD pipeline"

# Push
git push origin test/cicd-verification
```

### 4.2: Create Pull Request

```bash
gh pr create \
  --title "test: Verify CI/CD pipeline" \
  --body "This PR tests the CI/CD pipeline setup.

## What to Test

- [ ] Proto Validation workflow
- [ ] Backend CI (lint, test, build)
- [ ] Frontend CI (lint, test, build)
- [ ] Security scans
- [ ] CodeRabbit review
- [ ] Docker build (if Dockerfile changes)

## Expected Results

All checks should pass (may skip some if no relevant files changed)."
```

### 4.3: Watch Workflows

```bash
# Watch in terminal
gh run watch

# Or view in browser
# https://github.com/kevin07696/modern-pos/actions
```

### 4.4: Verify Results

Expected workflows to run:
- ✅ Security Scan (should pass)
- ⏭️ Proto Validation (may skip - no proto changes)
- ⏭️ Backend CI (may skip - no Go changes)
- ⏭️ Frontend CI (may skip - no TypeScript changes)
- ⏭️ Docker Build (may skip - no Dockerfile changes)
- ✅ CodeRabbit (should review)

### 4.5: Clean Up

```bash
# After verification, close PR
gh pr close <pr-number>

# Delete branch
git checkout main
git branch -D test/cicd-verification
git push origin --delete test/cicd-verification
```

---

## Step 5: Test with Real Code Change

### Create a Real Feature PR

```bash
# Start Sprint 1, Story 1
git checkout -b feature/s1-1-setup-monorepo

# Create basic directory structure
mkdir -p backend/cmd/item-service
mkdir -p backend/internal
mkdir -p frontend/app
mkdir -p proto/common

# Add placeholder files
echo "package main\n\nfunc main() {}" > backend/cmd/item-service/main.go
echo "# Frontend" > frontend/README.md
echo "syntax = \"proto3\";\npackage common;" > proto/common/types.proto

# Commit
git add .
git commit -m "feat: initialize monorepo structure

- Add backend service directory
- Add frontend directory
- Add proto directory structure"

# Push and create PR
git push origin feature/s1-1-setup-monorepo
gh pr create --fill
```

### Expected Workflows

This PR should trigger:
- ✅ Proto Validation (proto files changed)
- ✅ Backend CI (Go files changed)
- ✅ Frontend CI (frontend files changed)
- ✅ Security Scan
- ✅ CodeRabbit review
- ⏭️ Docker Build (skipped - no Dockerfile yet)

---

## Verification Checklist

After completing all steps:

### Configuration
- [ ] AWS_ACCESS_KEY_ID secret added
- [ ] AWS_SECRET_ACCESS_KEY secret added
- [ ] Branch protection enabled for `main`
- [ ] Required status checks configured
- [ ] Staging environment exists
- [ ] Production environment created (optional)

### Testing
- [ ] Created test PR
- [ ] All relevant workflows ran
- [ ] Workflows passed successfully
- [ ] CodeRabbit reviewed the PR
- [ ] Branch protection blocked merge (if configured)

### Production Ready
- [ ] All secrets configured
- [ ] Branch protection active
- [ ] Workflows running smoothly
- [ ] Team familiar with PR workflow

---

## Common Issues & Solutions

### Issue: Workflows Don't Trigger

**Symptoms**: No workflows run when PR is created

**Solutions**:
1. Check if branch protection requires status checks
2. Ensure workflows have proper triggers in YAML
3. Check Actions tab for errors
4. Verify repository has Actions enabled

**Check**:
```bash
gh run list --limit 5
```

### Issue: Secrets Not Available

**Symptoms**: Deployment fails with "secret not found"

**Solutions**:
1. Verify secret name matches exactly (case-sensitive)
2. Check secret is repository secret (not environment)
3. Ensure workflow has permission to access secrets

**Check**:
```bash
gh secret list
```

### Issue: Required Checks Don't Show Up

**Symptoms**: Can't select checks in branch protection

**Solutions**:
1. Run workflows at least once to register checks
2. Wait a few minutes for GitHub to update
3. Ensure check names match workflow job names
4. Create a test PR to trigger workflows

**Workaround**: Skip check selection, add after first workflow run

### Issue: Docker Build Fails

**Symptoms**: docker-build.yml fails with errors

**Solutions**:
1. Ensure Dockerfiles exist in expected locations
2. Check Dockerfile syntax
3. Verify base images are accessible
4. Review build logs in Actions tab

**Debug**:
```bash
gh run view <run-id> --log
```

---

## Workflow Triggers Reference

| Workflow | Trigger | Required Files |
|----------|---------|----------------|
| Proto Validation | PR with proto/** changes | proto/*.proto |
| Backend CI | PR with backend/** changes | backend/**/*.go |
| Frontend CI | PR with frontend/** changes | frontend/**/*.{ts,tsx} |
| Docker Build | PR with Dockerfile changes | Dockerfile* |
| Security Scan | All PRs, main push, weekly | Any code |
| Deploy Staging | Push to main | N/A |
| Deploy Production | Version tags (v*) | N/A |

---

## Next Actions

### Immediate (Sprint 1, Day 1)
1. ✅ Configure GitHub secrets (AWS, Slack, etc.)
2. ✅ Enable branch protection for main
3. ✅ Test CI/CD with dummy PR
4. ✅ Verify all workflows pass

### Sprint 1 (This Week)
1. Create feature branches for stories
2. Make PRs for each story
3. Review CodeRabbit feedback
4. Merge after CI passes + approval
5. Monitor staging deployments

### Sprint 2 (Next Week)
1. Set up production environment
2. Configure production secrets
3. Test blue-green deployment
4. Create first production release (v1.0.0)

---

## Support Resources

**GitHub Actions Documentation**:
- https://docs.github.com/en/actions

**Branch Protection**:
- https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches

**Secrets Management**:
- https://docs.github.com/en/actions/security-guides/encrypted-secrets

**Troubleshooting**:
- Check Actions logs: https://github.com/kevin07696/modern-pos/actions
- Review workflow files: .github/workflows/
- See complete guide: docs/deployment/CI_CD_SETUP.md

---

## Quick Commands

```bash
# Check CI/CD status
bash scripts/setup-cicd.sh

# Add secret via CLI
gh secret set SECRET_NAME

# List current secrets
gh secret list

# Watch workflow run
gh run watch

# View recent runs
gh run list --limit 10

# View specific run logs
gh run view <run-id> --log

# Create test PR
gh pr create --title "test: CI/CD" --body "Testing"

# Check PR status
gh pr checks
```

---

**Your CI/CD pipeline is configured and ready to test!** 🚀

Start with Step 1 (Secrets) and Step 2 (Branch Protection), then test with Step 4.
