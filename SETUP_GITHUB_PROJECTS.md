# GitHub Projects Setup - Step by Step

Follow these steps to set up GitHub Projects for Modern POS.

---

## Prerequisites

### 1. Install GitHub CLI

You're on Fedora, so install gh CLI:

```bash
sudo dnf install gh
```

Or using snap:
```bash
sudo snap install gh
```

### 2. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts:
- What account do you want to log into? **GitHub.com**
- What is your preferred protocol? **HTTPS**
- Authenticate Git with your GitHub credentials? **Yes**
- How would you like to authenticate? **Login with a web browser**

Copy the one-time code and paste in browser.

### 3. Verify Authentication

```bash
gh auth status
```

Should show: ✓ Logged in to github.com

---

## Step 1: Create GitHub Repository

```bash
cd /home/kevinlam/Documents/projects/pos

# Create repository (replace YOUR_USERNAME with your GitHub username)
gh repo create modern-pos --public --source=. --remote=origin --description "Modern POS System for Quick Service Restaurants"

# This will:
# - Create repository on GitHub
# - Add origin remote
# - Push code (after we commit)
```

**Alternative**: Create manually at https://github.com/new
- Repository name: `modern-pos`
- Description: "Modern POS System for Quick Service Restaurants"
- Public or Private
- Don't initialize with README (we already have one)

Then connect locally:
```bash
git remote add origin https://github.com/YOUR_USERNAME/modern-pos.git
```

---

## Step 2: Initial Commit

```bash
cd /home/kevinlam/Documents/projects/pos

# Add all files
git add .

# Create initial commit
git commit -m "feat: initial Modern POS project setup

- Complete documentation for all 4 sprints
- 64 user story task files
- Service specifications and design documents
- Sprint board automation scripts
- GitHub Projects setup guides
"

# Push to GitHub
git push -u origin main
```

---

## Step 3: Get Your GitHub Username

```bash
gh api user --jq '.login'
```

Save this - you'll need it for the next steps.

---

## Step 4: Create GitHub Project Board

```bash
# Create project (replace YOUR_USERNAME)
gh project create --owner YOUR_USERNAME --title "Modern POS - Sprints" --format Board

# This creates a Kanban board
# Save the project number shown (usually 1)
```

**Output will look like**:
```
https://github.com/users/YOUR_USERNAME/projects/1
```

The number at the end is your **PROJECT_NUMBER** (usually 1).

---

## Step 5: Configure Environment Variables

Edit the automation scripts with your GitHub details:

```bash
# Set your GitHub username
export GITHUB_USERNAME="your-github-username"

# Update scripts
cd /home/kevinlam/Documents/projects/pos
sed -i "s/YOUR_USERNAME/$GITHUB_USERNAME/g" scripts/*.sh
```

Or manually edit these files:
- `scripts/sync-tasks-to-github.sh` - Change line 6
- `scripts/update-sprint-board.sh` - Change line 6
- `scripts/sprint-report.sh` - Change line 6

Replace:
```bash
REPO_OWNER="${REPO_OWNER:-YOUR_USERNAME}"
```

With:
```bash
REPO_OWNER="${REPO_OWNER:-your-actual-username}"
```

---

## Step 6: Sync Task Files to GitHub Issues

This creates 64 GitHub issues (one for each task file):

```bash
cd /home/kevinlam/Documents/projects/pos

# Set environment variables
export REPO_OWNER="your-github-username"
export REPO_NAME="modern-pos"

# Run sync
make sync-tasks
```

This will:
- Read all 64 task files from `docs/implementation/tasks/`
- Create GitHub issue for each one
- Add labels: `sprint-X`, `story-points-Y`, `PX - Priority`
- Extract user story and acceptance criteria

**Expected output**:
```
🚀 Syncing task files to GitHub Issues...
Processing sprint-1...
Creating issue: S1.1-setup-monorepo.md
Creating issue: S1.2-configure-docker.md
...
Processing sprint-2...
Creating issue: S2.1-proto-contract-enhancements.md
...
✅ Done! Check your issues at: https://github.com/YOUR_USERNAME/modern-pos/issues
```

---

## Step 7: Configure Project Board

Open your project board:
```
https://github.com/users/YOUR_USERNAME/projects/1
```

### Delete Default Columns

The board starts with "Todo", "In Progress", "Done". Delete these.

### Create New Columns

Click "+ Add column" for each:

1. **Backlog**
   - Description: Stories not yet started

2. **Ready**
   - Description: Stories refined and ready to start

3. **In Progress**
   - Description: Currently being worked on
   - Set automation: When PR opened → Move here

4. **Review**
   - Description: Code review and testing
   - Set automation: When PR marked "Ready for review" → Move here

5. **Done**
   - Description: Completed and deployed
   - Set automation: When issue closed → Move here

### Add Custom Fields

Click ⚙️ (Settings) → Custom fields → + New field:

1. **Sprint**
   - Type: Single select
   - Options: Sprint 1, Sprint 2, Sprint 3, Sprint 4, Backlog

2. **Story Points**
   - Type: Number
   - Description: Fibonacci estimation (1, 2, 3, 5, 8, 13)

3. **Priority**
   - Type: Single select
   - Options:
     - 🔴 P0 - Critical
     - 🟠 P1 - High
     - 🟡 P2 - Medium
     - 🟢 P3 - Low

4. **Blocked**
   - Type: Single select
   - Options: Yes, No

---

## Step 8: Add Issues to Project Board

```bash
cd /home/kevinlam/Documents/projects/pos

# Set environment variables
export REPO_OWNER="your-github-username"
export REPO_NAME="modern-pos"
export PROJECT_NUMBER=1  # Use number from Step 4

# Add all issues to project board
make update-board
```

This adds all 64 GitHub issues to your project board!

---

## Step 9: Create Multiple Views

In your project board, create these views:

### View 1: Sprint 1 Board
- Click current view → Duplicate
- Name: "Sprint 1 Board"
- Layout: Board
- Group by: Status
- Filter: `sprint:"Sprint 1"`
- Sort: Priority

### View 2: Sprint 2 Board
- Duplicate Sprint 1 Board
- Name: "Sprint 2 Board"
- Filter: `sprint:"Sprint 2"`

### View 3: Sprint 3 Board
- Duplicate Sprint 1 Board
- Name: "Sprint 3 Board"
- Filter: `sprint:"Sprint 3"`

### View 4: Sprint 4 Board
- Duplicate Sprint 1 Board
- Name: "Sprint 4 Board"
- Filter: `sprint:"Sprint 4"`

### View 5: Backlog (Table View)
- Click "+" → New view
- Name: "Backlog"
- Layout: Table
- Filter: `status:"Backlog"`
- Show: All fields
- Sort: Priority, Story Points

### View 6: Team View
- Click "+" → New view
- Name: "Team View"
- Layout: Board
- Group by: Assignees
- Filter: `-status:"Done"`

### View 7: Roadmap
- Click "+" → New view
- Name: "Roadmap"
- Layout: Roadmap
- Group by: Sprint
- Shows timeline of all sprints

---

## Step 10: Test Sprint Report

```bash
# Generate Sprint 1 report
make sprint-report SPRINT=1
```

Should show:
```
📈 Sprint 1 Report
==========================

Total Stories: 16
Done: 0
In Progress: 0
Pending: 16

Completion: 0%
Progress: [--------------------] 0%

Open Stories:
  #1: S1.1 - Setup Monorepo (@unassigned) [no-status]
  #2: S1.2 - Configure Docker (@unassigned) [no-status]
  ...
```

---

## Step 11: Organize Sprint 1 Stories

1. Open Sprint 1 Board view
2. Drag 16 Sprint 1 stories from "Backlog" to "Ready"
3. Assign team members to stories
4. Verify story points are set correctly

---

## Step 12: Set Up GitHub Actions (Optional)

The automation workflow is already in `.github/workflows/sync-sprint-board.yml`.

To enable:
1. Push to GitHub: `git push`
2. Go to repo → Actions → Enable workflows
3. Workflow will auto-run when task files change

---

## ✅ Verification Checklist

- [ ] GitHub CLI installed and authenticated
- [ ] Repository created on GitHub
- [ ] Initial commit pushed
- [ ] Project board created with 5 columns
- [ ] Custom fields added (Sprint, Story Points, Priority, Blocked)
- [ ] All 64 issues created
- [ ] All 64 issues added to project board
- [ ] 7 views created (4 sprint boards + backlog + team + roadmap)
- [ ] Sprint reports working
- [ ] Team members invited to repository
- [ ] GitHub Actions enabled (optional)

---

## Quick Commands Reference

```bash
# Daily sprint report
make sprint-report SPRINT=1

# Re-sync if you update task files
make sync-tasks

# Update board statuses
make update-board

# View all commands
make help
```

---

## Your Board URLs

After setup, bookmark these:

```
Main Project: https://github.com/users/YOUR_USERNAME/projects/1

Sprint 1: https://github.com/users/YOUR_USERNAME/projects/1/views/1
Sprint 2: https://github.com/users/YOUR_USERNAME/projects/1/views/2
Sprint 3: https://github.com/users/YOUR_USERNAME/projects/1/views/3
Sprint 4: https://github.com/users/YOUR_USERNAME/projects/1/views/4
Backlog: https://github.com/users/YOUR_USERNAME/projects/1/views/5
Team View: https://github.com/users/YOUR_USERNAME/projects/1/views/6
Roadmap: https://github.com/users/YOUR_USERNAME/projects/1/views/7
```

---

## Troubleshooting

### Issue: "gh: command not found"
```bash
sudo dnf install gh
# or
sudo snap install gh
```

### Issue: "Permission denied"
```bash
gh auth login
# Follow prompts to authenticate
```

### Issue: "Project number not found"
```bash
# List your projects to get the number
gh project list --owner YOUR_USERNAME
```

### Issue: "Can't create issues"
```bash
# Check authentication has repo scope
gh auth status
gh auth refresh -h github.com -s repo,project
```

---

## Next Steps

1. **Install GitHub CLI**: `sudo dnf install gh`
2. **Authenticate**: `gh auth login`
3. **Run these commands** in order from Step 1-11
4. **Start Sprint 1** on Monday, Nov 4, 2025!

---

**Need help?** Check:
- GitHub CLI docs: https://cli.github.com/manual/
- GitHub Projects docs: https://docs.github.com/en/issues/planning-and-tracking-with-projects

**Ready to build Modern POS!** 🚀
