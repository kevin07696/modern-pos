# CI/CD Setup Guide

This document describes the CI/CD pipeline for Modern POS.

## Overview

The CI/CD pipeline is implemented using GitHub Actions and consists of:

1. **Proto Validation** - Validates protobuf contracts
2. **Backend CI** - Tests and builds Go services
3. **Frontend CI** - Tests and builds Next.js application
4. **Docker Build** - Builds container images
5. **Security Scanning** - Scans for vulnerabilities
6. **Deployment** - Deploys to staging and production

---

## Workflows

### 1. Proto Validation (`proto-validation.yml`)

**Triggers:**
- Pull requests affecting `proto/**`
- Pushes to `main` affecting proto files

**Jobs:**
- Format checking with `buf format`
- Linting with `buf lint`
- Breaking change detection (PRs only)
- Code generation verification

**Required for:** All proto contract changes

---

### 2. Backend CI (`backend-ci.yml`)

**Triggers:**
- Pull requests affecting `backend/**`
- Pushes to `main` affecting backend

**Jobs:**

#### Lint
- golangci-lint with timeout 5m
- Checks code style, best practices, potential bugs

#### Test
- Runs with PostgreSQL 16 and Redis 7
- Executes `go vet` and `staticcheck`
- Runs unit tests with race detection
- Generates coverage report
- Uploads coverage to Codecov

#### Build
- Compiles all service binaries
- Verifies successful compilation

**Database Services:**
- PostgreSQL 16 (port 5432)
- Redis 7 (port 6379)

---

### 3. Frontend CI (`frontend-ci.yml`)

**Triggers:**
- Pull requests affecting `frontend/**`
- Pushes to `main` affecting frontend

**Jobs:**

#### Lint and Test
- ESLint for code quality
- TypeScript type checking
- Jest unit tests with coverage
- Uploads coverage to Codecov

#### Build
- Next.js production build
- Bundle size analysis
- Build verification

**Node.js Version:** 20 LTS

---

### 4. Docker Build (`docker-build.yml`)

**Triggers:**
- Pull requests with Docker changes
- Pushes to `main`
- Version tags (`v*`)

**Images Built:**
- `ghcr.io/kevin07696/modern-pos/item-service`
- `ghcr.io/kevin07696/modern-pos/order-service`
- `ghcr.io/kevin07696/modern-pos/platform-service`
- `ghcr.io/kevin07696/modern-pos/frontend`

**Features:**
- Multi-platform builds (amd64, arm64)
- Layer caching with GitHub Actions cache
- Automatic tagging based on branch/tag/PR
- Integration tests after build

**Image Tags:**
- `latest` - Latest main branch build
- `main-<sha>` - Specific commit on main
- `pr-<number>` - Pull request builds
- `v1.0.0` - Semantic version releases

---

### 5. Security Scan (`security-scan.yml`)

**Triggers:**
- Pushes to `main`
- Pull requests
- Weekly schedule (Sundays)

**Scans:**

#### Gosec
- Go security scanner
- Checks for common security issues
- Uploads SARIF results to GitHub Security

#### Trivy
- Container and filesystem vulnerability scanning
- Checks for CVEs in dependencies
- SARIF output

#### Dependency Check
- Snyk scanning for dependency vulnerabilities
- Only high-severity issues block PRs

#### Secret Scanning
- TruffleHog for leaked secrets
- Scans entire commit history

---

### 6. Deploy to Staging (`deploy-staging.yml`)

**Triggers:**
- Pushes to `main`
- Manual dispatch

**Environment:** staging
**URL:** https://staging.modern-pos.example.com

**Steps:**
1. Configure AWS credentials
2. Login to Amazon ECR
3. Update ECS services with force new deployment
4. Wait for services to be stable
5. Run smoke tests
6. Notify via Slack

**Services Deployed:**
- item-service
- order-service
- platform-service

---

### 7. Deploy to Production (`deploy-production.yml`)

**Triggers:**
- Version tags (`v*.*.*`)
- Manual dispatch with version input

**Environment:** production
**URL:** https://modern-pos.example.com

**Deployment Strategy:** Blue-Green

**Steps:**
1. Verify version tag format
2. Create database backup snapshot
3. Deploy to green environment
4. Wait for green to be healthy
5. Run health checks on green
6. Switch traffic to green
7. Run production smoke tests
8. Update monitoring (Datadog event)
9. Create GitHub Release
10. Notify via Slack
11. Rollback on failure

**Rollback:** Automatic on deployment failure

---

## Required Secrets

Configure these secrets in GitHub repository settings:

### AWS Deployment
```
AWS_ACCESS_KEY_ID          - AWS access key for deployments
AWS_SECRET_ACCESS_KEY      - AWS secret access key
PROD_LISTENER_ARN          - Production ALB listener ARN
GREEN_TARGET_GROUP_ARN     - Green target group ARN
BLUE_TARGET_GROUP_ARN      - Blue target group ARN
```

### Monitoring & Notifications
```
DATADOG_API_KEY           - Datadog API key for deployment markers
SLACK_WEBHOOK             - Slack webhook URL for notifications
```

### Security Scanning
```
SNYK_TOKEN                - Snyk API token for dependency scanning
```

### Application
```
NEXT_PUBLIC_API_URL       - Frontend API URL
```

---

## Branch Protection Rules

Recommended branch protection for `main`:

1. **Require pull request reviews**
   - Required approvals: 1
   - Dismiss stale reviews: Yes

2. **Require status checks to pass**
   - Proto Validation
   - Backend CI (lint, test, build)
   - Frontend CI (lint-and-test, build)
   - Security Scan (gosec, trivy)

3. **Require branches to be up to date**
   - Yes

4. **Require linear history**
   - Yes (no merge commits)

5. **Include administrators**
   - No (allow admin bypass for hotfixes)

---

## Environment Setup

### Staging Environment
- **AWS ECS Cluster:** modern-pos-staging
- **Database:** RDS PostgreSQL (staging)
- **Cache:** ElastiCache Redis (staging)
- **Domain:** staging.modern-pos.example.com

### Production Environment
- **AWS ECS Cluster:** modern-pos-production
- **Database:** RDS PostgreSQL (production) with automated backups
- **Cache:** ElastiCache Redis (production) with Multi-AZ
- **Domain:** modern-pos.example.com
- **Blue-Green:** Enabled via ALB target groups

---

## Release Process

### 1. Development

```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/new-feature
gh pr create
```

### 2. Code Review

- CI checks must pass (all workflows green)
- Security scans must pass
- At least 1 approval required
- No unresolved conversations

### 3. Merge to Main

```bash
# Squash merge via GitHub UI
# This triggers staging deployment automatically
```

### 4. Staging Testing

- Staging deployment runs automatically
- QA team tests on staging environment
- Smoke tests must pass

### 5. Production Release

```bash
# Create version tag
git checkout main
git pull
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# This triggers production deployment
```

### 6. Production Verification

- Blue-green deployment executes
- Health checks on green environment
- Traffic switch to green
- Smoke tests on production
- Monitor for 30 minutes

### 7. Rollback (if needed)

```bash
# Automatic rollback on deployment failure
# Manual rollback by re-running previous version

gh workflow run deploy-production.yml \
  -f version=v1.0.0-previous
```

---

## Monitoring

### Deployment Notifications

All deployments send Slack notifications with:
- Status (success/failure)
- Version/commit
- Author
- Environment

### Deployment Markers

Production deployments create events in Datadog:
- Event title: "Production Deployment"
- Tags: env:production, service:modern-pos
- Links to GitHub commit

### Health Checks

Smoke tests verify:
- `/health` endpoint responds 200
- Core API endpoints functional
- Database connectivity
- Redis connectivity

---

## Troubleshooting

### CI Failures

**Proto validation fails:**
```bash
# Run locally
buf format -w
buf lint
buf generate
git add .
git commit -m "fix: regenerate proto code"
```

**Go tests fail:**
```bash
# Run tests locally with services
docker-compose up -d postgres redis
export DB_HOST=localhost
export REDIS_HOST=localhost
go test ./...
```

**Frontend build fails:**
```bash
cd frontend
npm ci
npm run build
```

### Deployment Failures

**Staging deployment stuck:**
1. Check ECS service events in AWS Console
2. Check CloudWatch logs for errors
3. Verify ECR images exist
4. Check task definition

**Production rollback:**
```bash
# Switch traffic back to blue
aws elbv2 modify-listener \
  --listener-arn $PROD_LISTENER_ARN \
  --default-actions Type=forward,TargetGroupArn=$BLUE_TARGET_GROUP_ARN
```

---

## Performance

### Build Times (Approximate)

- Proto Validation: ~2 minutes
- Backend CI: ~5 minutes (with tests)
- Frontend CI: ~4 minutes
- Docker Build: ~8 minutes per service
- Staging Deployment: ~10 minutes
- Production Deployment: ~15 minutes (with blue-green)

### Optimizations

- Docker layer caching reduces build time by 50%
- Go module caching reduces dependency download time
- npm ci cache reduces frontend build time
- Parallel job execution where possible

---

## Cost Optimization

- Use GitHub Actions included minutes (2000/month free)
- Cache Docker layers to reduce build time
- Use spot instances for non-critical test runs
- Schedule security scans weekly instead of daily

---

## Future Enhancements

1. **Canary Deployments** - Gradual traffic shift to new version
2. **Auto-scaling** - Based on metrics from Datadog
3. **Multi-region** - Deploy to multiple AWS regions
4. **Performance Testing** - Load testing before production
5. **Automated Rollback** - Based on error rates and latency

---

## Support

For CI/CD issues:
1. Check GitHub Actions logs
2. Review this documentation
3. Check AWS CloudWatch logs
4. Contact DevOps team

**Repository:** https://github.com/kevin07696/modern-pos
**Project Board:** https://github.com/users/kevin07696/projects/2
