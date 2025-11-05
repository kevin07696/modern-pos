# Team Workflow - Quick Reference

**Modern POS Development Team**
**Sprint Board**: https://github.com/users/YOUR_USERNAME/projects/1

---

## Daily Workflow

### 🌅 Morning (9:00 AM)

**Daily Standup** (15 minutes)

```
1. Open sprint board
2. Each person (2 min max):
   - What I completed yesterday (show cards in Done)
   - What I'm working on today (move card to In Progress)
   - Any blockers? (set Blocked = Yes)
3. Update cards during standup
4. Resolve blockers after standup
```

**Standup Command** (Scrum Master runs):
```bash
make sprint-report SPRINT=1
```

### 💻 During Development

#### Pick Up New Story

```
1. Go to Sprint Board → "Ready" column
2. Find unassigned story
3. Drag to "In Progress"
4. Assign yourself
5. Read acceptance criteria
6. Ask questions if unclear
```

#### Start Coding

```bash
# Create feature branch
git checkout -b feature/s1-9-create-sale

# Reference issue number in commits
git commit -m "feat: implement sale creation endpoint

Implements #9 (S1.9 - Create Sale with Tax)

- Add CreateSale RPC endpoint
- Implement tax calculation logic
- Add unit tests
"
```

#### Create Pull Request

```bash
# Push branch
git push origin feature/s1-9-create-sale

# Create PR (auto-links to issue)
gh pr create \
  --title "[S1.9] Create Sale with Tax" \
  --body "Closes #9

## Changes
- Implemented CreateSale endpoint
- Added tax calculation
- Unit tests added

## Testing
- Run: make test-order-service
- Verified with Postman

## Acceptance Criteria
- [x] Endpoint accepts sale items
- [x] Calculates tax based on location
- [x] Returns sale with tax breakdown
"
```

**Card automatically moves to "Review"!** ✅

### 🔍 Code Review

**When assigned to review**:

```
1. Check PR on GitHub
2. Review code carefully
3. Test locally if needed
4. Leave comments/suggestions
5. Approve or request changes
```

**Commands**:
```bash
# Checkout PR locally
gh pr checkout 123

# Run tests
make test

# Approve PR
gh pr review 123 --approve --body "LGTM! Nice work."

# Or request changes
gh pr review 123 --request-changes --body "Please add error handling for edge case."
```

### ✅ Completing Story

**When PR approved and merged**:

```
1. Card automatically moves to "Done"! ✅
2. Issue automatically closes
3. Delete feature branch
4. Pick up next story from "Ready"
```

```bash
# Delete local branch
git branch -d feature/s1-9-create-sale

# Delete remote branch (usually auto-deleted)
git push origin --delete feature/s1-9-create-sale
```

---

## Story States

### Backlog
```
Stories not yet refined or not in current sprint
Action: Product Owner prioritizes
```

### Ready
```
Stories refined, estimated, ready to start
Action: Developers pick up when available
```

### In Progress
```
Actively being worked on
Action: Developer coding, writing tests
```

### Review
```
PR open, needs code review
Action: Team reviews, provides feedback
```

### Done
```
Merged, deployed, acceptance criteria met
Action: None (celebrate! 🎉)
```

---

## Common Scenarios

### 🚧 Blocked by Another Story

```
1. Set Blocked = Yes
2. Add comment: "Blocked by #12 (needs API endpoint)"
3. Mention blocking person: @alice
4. Pick up different story
5. Bring up in standup
```

### ❓ Requirements Unclear

```
1. Add comment on story card
2. Tag Product Owner: @product-owner
3. Ask in team chat
4. Don't guess - clarify first!
5. If urgent, schedule quick call
```

### 🐛 Bug Found During Development

```
Option 1: If minor, fix in same PR

Option 2: If major, create new issue:
gh issue create \
  --title "Bug: Sale creation fails with negative quantity" \
  --label "bug,P1 - High" \
  --assignee @me \
  --body "Steps to reproduce:..."
```

### 🔄 Story Taking Longer Than Expected

```
1. Update card with comment: "Story larger than expected, need +2 points"
2. Mention in standup
3. Consider splitting into 2 stories
4. Ask for pair programming help
5. Don't suffer in silence!
```

### ✨ Finishing Early

```
1. Check "Ready" column for next story
2. Help teammate with code review
3. Pick up stretch goal
4. Write documentation
5. Refactor/clean up code
6. Update team wiki
```

---

## Git Workflow

### Branch Naming

```
feature/s1-9-create-sale      ← New feature
fix/s2-3-payment-validation   ← Bug fix
refactor/s3-1-offline-sync    ← Refactoring
docs/update-api-readme        ← Documentation
```

### Commit Messages

**Format**: `type: description`

```
feat: add sale creation endpoint
fix: resolve tax calculation rounding error
refactor: simplify modifier logic
test: add unit tests for payment flow
docs: update API documentation
chore: update dependencies
```

**Good commit**:
```
feat: implement offline sync queue

Implements #45 (S3.2 - Offline Sync)

- Add IndexedDB queue for offline sales
- Implement exponential backoff retry
- Add sync status UI indicator

Tested:
- Offline creation works
- Sync retries on failure
- UI updates correctly
```

**Bad commit**:
```
fix stuff
```

### Pull Request Checklist

Before creating PR:

```
✅ Code compiles
✅ Tests pass locally
✅ No linting errors
✅ Documentation updated
✅ Acceptance criteria met
✅ PR description complete
✅ Issue number referenced
```

---

## Testing

### Run Tests Before Pushing

```bash
# Run all tests
make test

# Run specific service tests
make test-item-service
make test-order-service

# Run with coverage
make test-coverage
```

### Definition of Done

Story is only "Done" when:

```
✅ Code written and committed
✅ Unit tests written (>80% coverage)
✅ Integration tests passing
✅ Code reviewed by team member
✅ PR merged to main
✅ Deployed to staging
✅ Acceptance criteria verified
✅ Documentation updated
✅ Product Owner approved
```

---

## Communication

### Team Channels

```
📢 #team-modern-pos          - General discussion
🐛 #modern-pos-bugs          - Bug reports
❓ #modern-pos-questions     - Technical questions
🎉 #modern-pos-wins          - Celebrate deployments!
```

### Status Updates

**Update sprint board daily**:
- Move cards to correct columns
- Add comments on progress
- Set blockers when stuck
- Update estimates if wrong

**Don't**:
- Leave cards in same column for days
- Work on stories not assigned to you
- Close stories without PR
- Skip code review

---

## Sprint Schedule

### Sprint 1 (Nov 4-8, 2025)

```
Monday:     Sprint Planning (2 hours)
            - Review backlog
            - Estimate stories
            - Assign work
            - Set sprint goal

Tue-Thu:    Development
            - Daily standups (15 min)
            - Code, review, merge
            - Update sprint board

Friday:     Sprint Review (1 hour)
            - Demo completed stories
            - Get feedback

            Sprint Retrospective (45 min)
            - What went well?
            - What to improve?
            - Action items
```

---

## Useful Commands

### Sprint Management

```bash
# Sync task files to GitHub (one-time setup)
make sync-tasks

# Update sprint board
make update-board

# Generate sprint report
make sprint-report SPRINT=1

# Show all commands
make help
```

### GitHub CLI

```bash
# View sprint issues
gh issue list --label "sprint-1"

# View your assignments
gh issue list --assignee @me

# Create new issue
gh issue create --title "Story title" --label "sprint-1"

# View PR status
gh pr status

# Merge PR
gh pr merge 123 --squash
```

### Project Board

```bash
# Open sprint board in browser
gh project view 1 --web

# List all projects
gh project list
```

---

## Tips for Success

### Do's ✅

- ✅ Update sprint board daily
- ✅ Keep PRs small (<400 lines)
- ✅ Write clear commit messages
- ✅ Ask questions early
- ✅ Review others' code promptly
- ✅ Test before pushing
- ✅ Pair program when stuck
- ✅ Celebrate team wins

### Don'ts ❌

- ❌ Leave cards stale for days
- ❌ Work without assigned story
- ❌ Push without tests
- ❌ Ignore code review feedback
- ❌ Skip daily standups
- ❌ Change sprint scope mid-sprint
- ❌ Work in isolation
- ❌ Commit secrets/credentials

---

## Emergency Contacts

```
Product Owner:    @product-owner     (requirements, priorities)
Scrum Master:     @scrum-master      (process, blockers)
Tech Lead:        @tech-lead         (architecture, technical)
DevOps:           @devops            (deployment, infrastructure)
```

---

## Quick Links

📋 **Sprint Board**: https://github.com/users/YOUR_USERNAME/projects/1
📖 **Documentation**: /docs/
🔧 **Repository**: https://github.com/YOUR_USERNAME/modern-pos
💬 **Team Chat**: [Slack/Discord link]
📅 **Calendar**: [Google Calendar link]

---

**Print this page and keep it visible!** 📌

**Questions?** Ask in #team-modern-pos channel.

**Let's build amazing software together!** 💪
