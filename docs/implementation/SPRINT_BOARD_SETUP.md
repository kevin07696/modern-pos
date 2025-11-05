# Sprint Board Setup - Jira-Style Team Board

**Version**: 1.0
**Last Updated**: November 4, 2025
**Purpose**: Visual sprint board for team planning and tracking

---

## Overview

This guide sets up a **Jira-style sprint board** using GitHub Projects V2 for the Modern POS development team. The board provides:

- 📋 **Backlog Management**: Organize all stories across 4 sprints
- 🏃 **Sprint Planning**: Visual board with swim lanes for each sprint
- 📊 **Progress Tracking**: Story points, velocity, burndown
- 👥 **Team Collaboration**: Assignment, comments, status updates
- 🎯 **Workflow States**: Backlog → Ready → In Progress → Review → Done

---

## Quick Start (5 Minutes)

### Option 1: GitHub Projects (Recommended for Teams)

**Why**: Free, integrated with GitHub, Jira-like interface, automation built-in

#### Step 1: Create Project Board

1. Go to: https://github.com/users/YOUR_USERNAME/projects
2. Click **"New project"**
3. Choose **"Board"** template
4. Name it: **"Modern POS - Sprints"**
5. Click **"Create"**

#### Step 2: Configure Board Columns

Delete default columns and create:

**Board Layout** (Kanban-style):
```
┌─────────────┬─────────────┬─────────────┬─────────────┬─────────────┐
│   Backlog   │    Ready    │ In Progress │   Review    │    Done     │
├─────────────┼─────────────┼─────────────┼─────────────┼─────────────┤
│ Sprint 1    │ Sprint 1    │ Sprint 1    │ Sprint 1    │ Sprint 1    │
│ Sprint 2    │ Sprint 2    │ Sprint 2    │ Sprint 2    │ Sprint 2    │
│ Sprint 3    │ Sprint 3    │ Sprint 3    │ Sprint 3    │ Sprint 3    │
│ Sprint 4    │ Sprint 4    │ Sprint 4    │ Sprint 4    │ Sprint 4    │
└─────────────┴─────────────┴─────────────┴─────────────┴─────────────┘
```

**Column Configuration**:
1. **Backlog**: Stories not yet started
2. **Ready**: Stories ready to be picked up (refined, estimated)
3. **In Progress**: Currently being worked on
4. **Review**: Code review, testing, QA
5. **Done**: Completed and deployed

#### Step 3: Add Custom Fields

Click **⚙️ Settings** → **Custom fields** → **New field**

| Field Name | Type | Values |
|------------|------|--------|
| Sprint | Select | Sprint 1, Sprint 2, Sprint 3, Sprint 4, Backlog |
| Story Points | Number | 1, 2, 3, 5, 8, 13 |
| Priority | Select | 🔴 P0 - Critical, 🟠 P1 - High, 🟡 P2 - Medium, 🟢 P3 - Low |
| Assignee | Assignees | (GitHub users) |
| Status | Status | Backlog, Ready, In Progress, Review, Done |
| Sprint Goal | Text | Brief sprint objective |
| Blocked | Select | Yes, No |

#### Step 4: Create Sprint Views

GitHub Projects supports multiple views. Create these:

**View 1: Sprint Board** (Default)
- Layout: Board
- Group by: Status
- Filter: Sprint = "Sprint 1" (change per sprint)
- Sort by: Priority

**View 2: Backlog**
- Layout: Table
- Filter: Status = "Backlog"
- Sort by: Priority, Story Points
- Show: All fields

**View 3: Sprint Planning**
- Layout: Table
- Group by: Sprint
- Show: Story Points sum per sprint
- Use for: Capacity planning

**View 4: Team View**
- Layout: Board
- Group by: Assignee
- Filter: Status ≠ "Done"
- Show: Current sprint only

**View 5: Roadmap**
- Layout: Roadmap (timeline)
- Group by: Sprint
- Show: All 4 sprints on timeline

---

## Sprint Planning Workflow

### Before Sprint (Planning Meeting)

**1. Refine Backlog** (1 week before sprint)
```
Team reviews:
- User stories complete?
- Acceptance criteria clear?
- Story points estimated?
- Dependencies identified?
- Technical questions answered?

Action: Move refined stories to "Ready" column
```

**2. Sprint Planning** (Day 1 of sprint)
```
Team capacity:
- 5 developers × 5 days = 25 dev-days
- Assume 70% capacity = 17.5 dev-days
- Story points per day ≈ 2-3
- Sprint capacity ≈ 35-50 story points

Steps:
1. Set sprint goal (e.g., "Complete core sale creation flow")
2. Drag stories from "Ready" to sprint
3. Verify total story points ≤ capacity
4. Assign stories to team members
5. Identify sprint risks
6. Set sprint dates in Sprint field
```

**3. Daily Standup** (Every morning, 15 min)
```
Each team member:
1. What did I complete yesterday? (move cards to Review/Done)
2. What am I working on today? (update In Progress)
3. Any blockers? (set Blocked = Yes)

Sprint Board shows real-time progress
```

**4. Sprint Review** (Last day of sprint)
```
Demonstrate:
- Move completed stories to "Done"
- Demo features to stakeholders
- Collect feedback
- Update acceptance criteria if needed
```

**5. Sprint Retrospective** (Last day of sprint)
```
Discuss:
- What went well?
- What can improve?
- Action items for next sprint

Update team processes based on learnings
```

---

## Team Workflow

### Developer Daily Workflow

**Morning**:
```bash
1. Open sprint board: https://github.com/users/YOU/projects/1/views/1
2. Check assigned stories in "Ready" or "In Progress"
3. Move card to "In Progress" when starting work
4. Update card with comment: "Working on [specific task]"
```

**During Development**:
```bash
1. Reference story card in commits:
   git commit -m "feat: implement sale creation endpoint

   Implements acceptance criteria for #123

   - Add CreateSale RPC endpoint
   - Validate sale items
   - Calculate tax amounts
   "

2. Link PRs to story card:
   - PR title: "[S1.9] Implement sale creation with tax"
   - PR body: "Closes #123" (auto-links to issue/card)
```

**Code Review**:
```bash
1. Move card to "Review" column
2. Request review from team member
3. Address feedback
4. Merge when approved
```

**Completion**:
```bash
1. Deploy to staging/production
2. Verify acceptance criteria
3. Move card to "Done"
4. Add comment: "✅ Deployed to production"
```

### Handling Blocked Stories

When blocked:
```
1. Set "Blocked" = Yes
2. Add comment explaining blocker
3. Tag person who can unblock
4. Bring up in daily standup
5. Work on different story if possible
```

---

## Story Point Estimation

Use **Planning Poker** in sprint planning:

| Points | Complexity | Time Estimate | Example |
|--------|------------|---------------|---------|
| 1 | Trivial | < 2 hours | Add field to proto, update docs |
| 2 | Simple | 2-4 hours | Create basic CRUD endpoint |
| 3 | Medium | 4-8 hours | Implement tax calculation logic |
| 5 | Complex | 1-2 days | Build offline sync queue |
| 8 | Very Complex | 2-3 days | Implement entire service with tests |
| 13 | Epic | 3-5 days | Complete feature (break into smaller stories) |

**Rule**: If story is 13 points, break it down into smaller stories!

---

## Velocity Tracking

### Measure Team Velocity

**After Sprint 1**:
```
Completed story points: 42
Velocity: 42 points/sprint
```

**Use for Sprint 2 Planning**:
```
Last sprint velocity: 42 points
Team capacity this sprint: Same (5 devs)
Plan for: ~40-45 points (±10% variance)
```

**After 3 Sprints**:
```
Sprint 1: 42 points
Sprint 2: 38 points
Sprint 3: 45 points
Average velocity: 42 points/sprint

Use average for Sprint 4 planning
```

---

## Sprint 1-4 Plan Overview

### Sprint 1 (Nov 4-8) - Foundation
**Goal**: "Complete backend infrastructure and core proto contracts"
**Capacity**: 45 story points
**Stories**: 16 stories (S1.1 - S1.16)

**Focus**:
- Infrastructure setup (Docker, Buf, monorepo)
- Proto contracts (common, item, order, platform)
- Database setup
- Core sale creation flow

### Sprint 2 (Nov 11-15) - Services
**Goal**: "Implement Item Management and Platform services"
**Capacity**: 45 story points
**Stories**: 14 stories (S2.1 - S2.14)

**Focus**:
- Item Management service (CRUD, categories, modifiers)
- Platform service (auth, users, locations)
- Service integration
- Testing

### Sprint 3 (Nov 18-22) - Advanced Features
**Goal**: "Build offline mode and kitchen display"
**Capacity**: 45 story points
**Stories**: 15 stories (S3.1 - S3.15)

**Focus**:
- Offline transaction handling
- Kitchen display system
- Reports and analytics
- Advanced payment flows

### Sprint 4 (Nov 25-29) - Polish & Deploy
**Goal**: "Production readiness and deployment"
**Capacity**: 45 story points
**Stories**: 12 stories (S4.1 - S4.12)

**Focus**:
- Performance optimization
- Security hardening
- CI/CD pipelines
- Production deployment

---

## GitHub Projects Features for Teams

### Automation Rules

Set up automatic card movement:

**Rule 1: Auto-move to In Progress**
```
When: PR opened
Then: Move linked issue to "In Progress"
```

**Rule 2: Auto-move to Review**
```
When: PR marked "Ready for review"
Then: Move linked issue to "Review"
```

**Rule 3: Auto-move to Done**
```
When: PR merged
Then: Move linked issue to "Done"
```

**Rule 4: Label-based status**
```
When: Label "status-blocked" added
Then: Set Blocked = Yes
```

### Notifications

Team members get notified:
- When assigned to story
- When mentioned in comments
- When story moves to Review
- When blockers are resolved

### Integration with GitHub

Stories (GitHub Issues) link to:
- Pull requests
- Code commits
- Code reviews
- CI/CD runs

One click to see all related code changes.

---

## Alternative: Linear (Premium Option)

If budget allows, **Linear** is excellent for sprint planning:

**Pros**:
- Beautiful, fast UI
- Built-in cycles (sprints)
- Keyboard shortcuts everywhere
- Better UX than GitHub Projects
- Slack/Discord integration

**Cons**:
- $8/user/month after free tier
- Not integrated with GitHub (requires sync)

**Setup**: https://linear.app → Create workspace → Import from GitHub

---

## Sprint Board Best Practices

### For Product Owner
```
✅ Keep backlog groomed (always 2 sprints ahead refined)
✅ Prioritize stories by business value
✅ Write clear acceptance criteria
✅ Available for questions during sprint
✅ Demo stories as they complete
```

### For Scrum Master
```
✅ Facilitate daily standups (keep to 15 min)
✅ Remove blockers quickly
✅ Track velocity trends
✅ Run retrospectives
✅ Protect team from scope creep
```

### For Developers
```
✅ Update cards daily (move to correct column)
✅ Comment on progress/blockers
✅ Link PRs to stories
✅ Ask questions early
✅ Help unblock teammates
```

### For Team
```
✅ Don't change sprint scope mid-sprint
✅ Focus on sprint goal
✅ Mob program on complex stories
✅ Pair program for knowledge sharing
✅ Celebrate completed sprints! 🎉
```

---

## Using the Automation Scripts

Once board is set up, use scripts to sync:

```bash
# Initial setup: Sync all task files to GitHub Issues
make sync-tasks

# This creates:
# - Issue #1: S1.1 - Setup Monorepo
# - Issue #2: S1.2 - Configure Docker
# - ... (all 57 stories)

# Add all issues to project board
make update-board

# Daily: Check sprint progress
make sprint-report SPRINT=1
```

**Output**:
```
📈 Sprint 1 Report
==========================

Total Stories: 16
Done: 5
In Progress: 3
Pending: 8

Completion: 31%
Progress: [======--------------] 31%

Open Stories:
  #4: S1.4 - Proto Common Types (@alice) [status-in-progress]
  #5: S1.5 - Proto Item Service (@bob) [status-in-progress]
  #6: S1.6 - Proto Order Service (@charlie) [status-in-progress]
  #7: S1.7 - Proto Platform Service (@unassigned) [no-status]
  ...
```

---

## Example: Sprint 1 Board View

```
Modern POS - Sprint 1 Board
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sprint Goal: Complete backend infrastructure and core proto contracts
Sprint Dates: Nov 4-8, 2025
Capacity: 45 points | Committed: 44 points | Velocity: TBD

┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│   Backlog    │    Ready     │ In Progress  │    Review    │     Done     │
│              │              │              │              │              │
├──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│              │ S1.7         │ S1.4         │ S1.8         │ ✅ S1.1      │
│              │ Proto        │ Proto Common │ Generate     │ Setup Mono   │
│              │ Platform     │ Types        │ Proto Code   │ @alice       │
│              │ 5pts         │ @alice       │ @bob         │ 5pts         │
│              │              │ 3pts         │ 2pts         │              │
│              │              │              │              │ ✅ S1.2      │
│              │ S1.11        │ S1.5         │              │ Docker       │
│              │ Publish      │ Proto Item   │              │ @alice       │
│              │ Events       │ Service      │              │ 3pts         │
│              │ 3pts         │ @bob         │              │              │
│              │              │ 5pts         │              │ ✅ S1.3      │
│              │              │              │              │ Buf Setup    │
│              │              │ S1.6         │              │ @charlie     │
│              │              │ Proto Order  │              │ 3pts         │
│              │              │ Service      │              │              │
│              │              │ @charlie     │              │              │
│              │              │ 5pts         │              │              │
│              │              │              │              │              │
└──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘

Team Status:
👤 Alice: In Progress (S1.4) | Completed: 2 stories (8pts)
👤 Bob: In Progress (S1.5) | Completed: 0 stories
👤 Charlie: In Progress (S1.6) | Completed: 1 story (3pts)

Blockers: None
Burndown: On track (Day 2 of 5)
```

---

## Next Steps

1. **Choose platform**: GitHub Projects (recommended) or Linear
2. **Create project board** (5 minutes)
3. **Configure columns and fields** (10 minutes)
4. **Run initial sync**: `make sync-tasks` (5 minutes)
5. **Add team members** as collaborators
6. **Schedule Sprint 1 planning** meeting (Nov 4, 2025)
7. **Start Sprint 1!** 🚀

---

**Questions?**
- GitHub Projects docs: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- Linear docs: https://linear.app/docs
- Agile best practices: https://www.atlassian.com/agile/scrum

**Ready to build Modern POS!** 💪
