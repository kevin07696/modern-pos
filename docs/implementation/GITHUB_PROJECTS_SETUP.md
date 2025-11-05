# GitHub Projects Setup Guide

**Platform**: GitHub Projects V2
**Setup Time**: 20 minutes
**Last Updated**: November 4, 2025

---

## Quick Setup (Follow These Steps)

### Step 1: Create GitHub Repository (if not exists)

```bash
# Initialize git repo
cd /home/kevinlam/Documents/projects/pos
git init

# Create GitHub repo (requires gh CLI)
gh repo create modern-pos --public --source=. --remote=origin

# Or create manually at: https://github.com/new
```

### Step 2: Create GitHub Project Board

1. **Go to**: https://github.com/users/YOUR_USERNAME/projects
2. **Click**: "New project" (green button)
3. **Select Template**: "Board" (Kanban-style)
4. **Name**: "Modern POS - Sprints"
5. **Click**: "Create project"

**Result**: Empty board with default columns (Todo, In Progress, Done)

### Step 3: Configure Board Columns

**Delete default columns and create new ones:**

Click column menu (⋮) → Delete for each default column

**Create these 5 columns** (click "+ Add column"):

1. **Backlog**
   - Description: Stories not yet started
   - Automation: None

2. **Ready**
   - Description: Stories refined and ready to pick up
   - Automation: None

3. **In Progress**
   - Description: Currently being worked on
   - Automation: When issue status changes to "In Progress"

4. **Review**
   - Description: Code review, testing, QA
   - Automation: When PR is opened

5. **Done**
   - Description: Completed and deployed
   - Automation: When issue is closed

### Step 4: Add Custom Fields

Click **⚙️ (Settings)** in top right → **Custom fields**

**Add these fields** (click "+ New field"):

#### Field 1: Sprint
- **Name**: Sprint
- **Type**: Single select
- **Options**:
  - Sprint 1
  - Sprint 2
  - Sprint 3
  - Sprint 4
  - Backlog

#### Field 2: Story Points
- **Name**: Story Points
- **Type**: Number
- **Description**: Fibonacci estimation (1, 2, 3, 5, 8, 13)

#### Field 3: Priority
- **Name**: Priority
- **Type**: Single select
- **Options**:
  - 🔴 P0 - Critical
  - 🟠 P1 - High
  - 🟡 P2 - Medium
  - 🟢 P3 - Low

#### Field 4: Team Member
- **Name**: (Use built-in Assignees field)

#### Field 5: Blocked
- **Name**: Blocked
- **Type**: Single select
- **Options**:
  - Yes
  - No

### Step 5: Create Multiple Views

GitHub Projects supports multiple views. Create these:

#### View 1: Sprint 1 Board (Default)
- Click current view name → "Duplicate view"
- Name: "Sprint 1 Board"
- Layout: Board
- Group by: Status
- Filter: `sprint:"Sprint 1"`
- Sort: Priority (P0 first)

#### View 2: Sprint 2 Board
- Duplicate "Sprint 1 Board"
- Name: "Sprint 2 Board"
- Filter: `sprint:"Sprint 2"`

#### View 3: Sprint 3 Board
- Duplicate "Sprint 1 Board"
- Name: "Sprint 3 Board"
- Filter: `sprint:"Sprint 3"`

#### View 4: Sprint 4 Board
- Duplicate "Sprint 1 Board"
- Name: "Sprint 4 Board"
- Filter: `sprint:"Sprint 4"`

#### View 5: Backlog (Table)
- Click "+" next to views
- Name: "Backlog"
- Layout: Table
- Filter: `status:"Backlog"`
- Sort: Priority, Story Points
- Show all fields

#### View 6: Team View
- Click "+" next to views
- Name: "Team View"
- Layout: Board
- Group by: Assignees
- Filter: `-status:"Done"`
- Shows who's working on what

#### View 7: All Sprints (Roadmap)
- Click "+" next to views
- Name: "Roadmap"
- Layout: Roadmap
- Group by: Sprint
- Shows timeline view

### Step 6: Configure Repository Settings

Update repository to reference REPO_OWNER and REPO_NAME:

```bash
# Set environment variables
export REPO_OWNER="YOUR_GITHUB_USERNAME"
export REPO_NAME="modern-pos"

# Update scripts with your values
cd /home/kevinlam/Documents/projects/pos
sed -i "s/YOUR_USERNAME/$REPO_OWNER/g" scripts/*.sh
sed -i "s/modern-pos/$REPO_NAME/g" scripts/*.sh
```

Or manually edit:
- `scripts/sync-tasks-to-github.sh`
- `scripts/update-sprint-board.sh`
- `scripts/sprint-report.sh`

Change:
```bash
REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"  # Change YOUR_USERNAME
REPO_NAME="${REPO_NAME:-modern-pos}"       # Change modern-pos
```

### Step 7: Get Project Number

You need your project number for automation scripts:

```bash
# List your projects
gh project list --owner YOUR_USERNAME

# Output shows:
# NUMBER  TITLE                       STATE
# 1       Modern POS - Sprints       OPEN
```

**Update scripts** with PROJECT_NUMBER:
```bash
export PROJECT_NUMBER=1  # Use the number from gh project list
```

### Step 8: Sync Task Files to GitHub Issues

```bash
cd /home/kevinlam/Documents/projects/pos

# Set environment variables
export REPO_OWNER="your-github-username"
export REPO_NAME="modern-pos"
export PROJECT_NUMBER=1

# Run initial sync
make sync-tasks
```

This creates **57 GitHub issues** (one for each task file):
- 16 issues for Sprint 1
- 14 issues for Sprint 2
- 15 issues for Sprint 3
- 12 issues for Sprint 4

Each issue will have:
- Title: Story name (e.g., "S1.1: Setup Monorepo")
- Body: User story + acceptance criteria
- Labels: `sprint-1`, `story-points-5`, `P0 - Critical`
- Assignee: From task file

### Step 9: Add Issues to Project Board

```bash
# Add all issues to the project board
make update-board
```

This automatically adds all 57 issues to your project board!

### Step 10: Organize Sprint 1 Stories

1. **Open Sprint 1 Board view**
2. **Drag stories** from "Backlog" to "Ready"
3. **Assign team members** to stories
4. **Verify story points** total ≤ team capacity
5. **Set sprint start date**

---

## Team Setup

### Add Team Members

1. Go to repository: `https://github.com/YOUR_USERNAME/modern-pos`
2. Click **Settings** → **Collaborators**
3. Click **Add people**
4. Enter GitHub usernames
5. Set role: **Write** (for developers) or **Maintain** (for leads)

### Invite to Project

1. Go to project: `https://github.com/users/YOUR_USERNAME/projects/1`
2. Click **⋮ (menu)** → **Settings**
3. Click **Manage access**
4. Click **Invite collaborators**
5. Add team members

---

## Daily Team Workflow

### For Developers

**Morning**:
```bash
# Open sprint board
# URL: https://github.com/users/YOUR_USERNAME/projects/1/views/1

1. Check "Ready" column for available stories
2. Drag story to "In Progress"
3. Assign yourself
4. Start working
```

**During Development**:
```bash
# Create branch
git checkout -b feature/s1-9-create-sale

# Make changes, commit
git commit -m "feat: implement sale creation endpoint

Implements #9 (S1.9 - Create Sale with Tax)

- Add CreateSale RPC endpoint
- Implement tax calculation
- Add database transaction
"

# Push and create PR
git push origin feature/s1-9-create-sale
gh pr create --title "[S1.9] Create Sale with Tax" --body "Closes #9"
```

**Card automatically moves** to "Review" when PR is opened!

**After Merge**:
```bash
# PR merged → Card automatically moves to "Done"
# Issue automatically closes
```

### For Scrum Master

**Daily Standup** (9 AM):
```bash
# Generate sprint report
make sprint-report SPRINT=1

# Review with team:
# - Progress (% complete)
# - Stories in each column
# - Blockers
# - Velocity trending
```

**Update Board**:
```bash
# Sync any manual changes
make update-board
```

---

## Automation Features

### Auto-move Cards

GitHub Projects automatically moves cards:

✅ **Issue opened** → Backlog
✅ **PR opened** → In Progress
✅ **PR in review** → Review
✅ **PR merged** → Done
✅ **Issue closed** → Done

### Auto-assign

Configure workflows in `.github/workflows/` to:
- Auto-assign based on file paths
- Auto-label based on directories
- Auto-milestone based on sprint

---

## Project URLs

Save these bookmarks for your team:

```
Sprint 1 Board:
https://github.com/users/YOUR_USERNAME/projects/1/views/1

Sprint 2 Board:
https://github.com/users/YOUR_USERNAME/projects/1/views/2

Backlog:
https://github.com/users/YOUR_USERNAME/projects/1/views/5

Team View:
https://github.com/users/YOUR_USERNAME/projects/1/views/6

Roadmap:
https://github.com/users/YOUR_USERNAME/projects/1/views/7
```

---

## Keyboard Shortcuts

GitHub Projects has excellent keyboard shortcuts:

| Key | Action |
|-----|--------|
| `?` | Show keyboard shortcuts |
| `c` | Create new item |
| `e` | Edit selected item |
| `Cmd/Ctrl + K` | Command palette |
| `←` `→` | Navigate columns |
| `↑` `↓` | Navigate items |
| `Cmd/Ctrl + Enter` | Save and close |

---

## Mobile Access

GitHub Projects works on mobile:

1. **Install GitHub mobile app**
2. **Open**: Menu → Projects
3. **Select**: "Modern POS - Sprints"
4. **View**: Board, update cards, comment

Perfect for daily standups!

---

## Troubleshooting

### Issue: Scripts can't find GitHub CLI

```bash
# Install gh CLI
# macOS
brew install gh

# Linux
sudo apt install gh

# Authenticate
gh auth login
```

### Issue: Permission denied when creating issues

```bash
# Check authentication
gh auth status

# Re-authenticate with correct scopes
gh auth login --scopes "repo,project"
```

### Issue: Project number not found

```bash
# List projects
gh project list --owner YOUR_USERNAME

# Use the NUMBER from output
export PROJECT_NUMBER=1
```

### Issue: Can't see project board

- **Check**: Are you logged into GitHub?
- **Check**: Is project set to "Public" or do you have access?
- **Check**: URL correct? Should be `/users/` not `/orgs/`

---

## Next Steps

✅ Repository created
✅ Project board configured
✅ Custom fields added
✅ Views created
✅ Scripts configured
✅ Issues synced
✅ Team members added

**Now you're ready for Sprint 1 Planning!**

📅 Schedule planning meeting
📋 Review backlog together
🎯 Set sprint goal
👥 Assign stories
🚀 Start Sprint 1 (Nov 4, 2025)

---

**Need help?** Check docs:
- GitHub Projects: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- GitHub CLI: https://cli.github.com/manual/
