# CI/CD Quick Start

Quick reference for common CI/CD tasks.

## First-Time Setup

### 1. Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions**

#### Required Secrets:
```bash
# AWS Deployment
AWS_ACCESS_KEY_ID=<your-aws-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret>

# Notifications (optional)
SLACK_WEBHOOK=<your-slack-webhook>

# Monitoring (optional)
DATADOG_API_KEY=<your-datadog-key>
```

#### Production Secrets (add when ready):
```bash
PROD_LISTENER_ARN=<alb-listener-arn>
GREEN_TARGET_GROUP_ARN=<green-tg-arn>
BLUE_TARGET_GROUP_ARN=<blue-tg-arn>
```

### 2. Enable Branch Protection

Go to **Settings → Branches → Add rule**

Branch name: `main`

Enable:
- ✅ Require pull request reviews (1 approval)
- ✅ Require status checks to pass
  - Proto Validation
  - Backend CI
  - Frontend CI
  - Security Scan
- ✅ Require branches to be up to date

---

## Common Workflows

### Making a Code Change

```bash
# 1. Create feature branch
git checkout -b feature/add-tax-calculation

# 2. Make changes
# Edit files...

# 3. Commit with conventional commit
git add .
git commit -m "feat: add tax calculation to orders"

# 4. Push and create PR
git push origin feature/add-tax-calculation
gh pr create --fill

# 5. Wait for CI checks to pass
# 6. Request review
# 7. Merge after approval
```

### CI Check Status

All PRs must pass:
- ✅ Proto Validation (if proto changed)
- ✅ Backend CI: lint, test, build
- ✅ Frontend CI: lint, test, build
- ✅ Security Scan: gosec, trivy, snyk
- ✅ Docker Build (if Dockerfile changed)

### Deploying to Staging

**Automatic:** Merges to `main` deploy to staging

```bash
# After PR approval
gh pr merge 123 --squash

# Staging deployment starts automatically
# Monitor: https://github.com/kevin07696/modern-pos/actions
```

### Deploying to Production

**Option 1: Version Tag (Recommended)**
```bash
# On main branch
git checkout main
git pull

# Create version tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Production deployment starts automatically
```

**Option 2: Manual Trigger**
```bash
gh workflow run deploy-production.yml -f version=v1.0.0
```

---

## Monitoring Deployments

### Check Workflow Status

```bash
# List recent workflow runs
gh run list --limit 5

# Watch specific workflow
gh run watch

# View logs
gh run view <run-id> --log
```

### Check Staging

```bash
# Health check
curl https://staging-api.modern-pos.example.com/health

# View logs (AWS)
aws logs tail /ecs/modern-pos-staging --follow
```

### Check Production

```bash
# Health check
curl https://api.modern-pos.example.com/health

# Deployment status
gh api repos/kevin07696/modern-pos/deployments
```

---

## Troubleshooting

### CI Tests Failing

**Backend tests:**
```bash
# Run tests locally
cd backend
docker-compose up -d postgres redis
export DB_HOST=localhost
export REDIS_HOST=localhost
go test ./...
```

**Frontend tests:**
```bash
cd frontend
npm ci
npm test
```

**Linting issues:**
```bash
# Backend
cd backend
golangci-lint run

# Frontend
cd frontend
npm run lint -- --fix
```

### Security Scan Failures

**View security issues:**
```bash
# Go to Security tab in GitHub
# Or check workflow logs
gh run view --log | grep -A 10 "security"
```

**Fix dependency vulnerabilities:**
```bash
# Go
go get -u ./...
go mod tidy

# npm
npm audit fix
```

### Deployment Stuck

**Check ECS:**
```bash
aws ecs describe-services \
  --cluster modern-pos-staging \
  --services item-service order-service
```

**Check logs:**
```bash
aws logs tail /ecs/item-service --follow
```

**Rollback staging:**
```bash
# Re-run previous successful deployment
gh run rerun <previous-run-id>
```

---

## Rollback Production

### Automatic Rollback

Production deployments rollback automatically on:
- Health check failures
- Smoke test failures
- Deployment timeout

### Manual Rollback

```bash
# Option 1: Re-deploy previous version
git tag -a v1.0.0-rollback -m "Rollback to v1.0.0"
git push origin v1.0.0-rollback

# Option 2: Manual traffic switch (emergency)
aws elbv2 modify-listener \
  --listener-arn <listener-arn> \
  --default-actions Type=forward,TargetGroupArn=<blue-tg-arn>
```

---

## Testing Locally

### Run Full CI Suite Locally

```bash
# Proto validation
buf format --diff --exit-code
buf lint
buf generate

# Backend
cd backend
golangci-lint run
go test -race ./...
go build ./cmd/item-service
go build ./cmd/order-service
go build ./cmd/platform-service

# Frontend
cd frontend
npm run lint
npm run type-check
npm test
npm run build
```

### Integration Tests

```bash
# Start all services
docker-compose -f docker-compose.test.yml up -d

# Wait for healthy
docker-compose -f docker-compose.test.yml ps

# Run integration tests
docker-compose -f docker-compose.test.yml exec backend-test \
  go test ./tests/integration/...

# Cleanup
docker-compose -f docker-compose.test.yml down -v
```

---

## Release Checklist

Before creating a production release:

- [ ] All CI checks pass on main
- [ ] Staging deployment successful
- [ ] QA testing complete on staging
- [ ] No critical bugs open
- [ ] Documentation updated
- [ ] Database migrations tested (if any)
- [ ] Rollback plan prepared
- [ ] Team notified of deployment
- [ ] Version tag follows semver (v1.2.3)

---

## Useful Commands

```bash
# View recent deployments
gh api repos/kevin07696/modern-pos/deployments | jq '.[0:5]'

# Cancel running workflow
gh run cancel

# Re-run failed workflow
gh run rerun

# List environments
gh api repos/kevin07696/modern-pos/environments | jq '.environments[].name'

# View deployment status
gh api repos/kevin07696/modern-pos/deployments/<id>/statuses | jq '.[0]'
```

---

## Support

**Documentation:**
- Full CI/CD Guide: `docs/deployment/CI_CD_SETUP.md`
- Sprint Plan: `docs/implementation/SPRINT_PLAN.md`

**Links:**
- Repository: https://github.com/kevin07696/modern-pos
- Actions: https://github.com/kevin07696/modern-pos/actions
- Project Board: https://github.com/users/kevin07696/projects/2

**Need Help?**
- Check GitHub Actions logs
- Review documentation
- Check AWS CloudWatch logs
