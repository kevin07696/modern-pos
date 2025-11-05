# GitHub Projects Board Configuration Guide

**Project**: Modern POS - Sprints
**URL**: https://github.com/users/kevin07696/projects/2
**Status**: ✅ Fields partially configured - Manual steps needed

---

## ✅ Already Done

- ✅ 65 GitHub Issues created
- ✅ Story Points field added (Number type)
- ✅ All issues added to project board

---

## 🎯 Manual Configuration Steps (20 minutes)

### Step 1: Open Your Project Board

Click this link: **https://github.com/users/kevin07696/projects/2**

---

### Step 2: Configure Status Field (5 minutes)

The Status field controls your board columns.

1. Click **⚙️ Settings** (top right)
2. Scroll to **Fields** section
3. Find **"Status"** field
4. Click on it to edit

**Current options**: Backlog, In Progress, Ready

**Add these missing options** (click "+ Add option"):

**Review**
- Description: `Code review, testing, and QA. Pull request is open and needs approval.`

**Done**
- Description: `Completed, merged, and deployed. Acceptance criteria met.`

**Update existing options with descriptions** (click each option name to edit):

**📋 Backlog**
- Description: `Stories not yet started. Needs refinement or not in current sprint.`

**✅ Ready**
- Description: `Stories refined, estimated, and ready to be picked up by team members.`

**🏃 In Progress**
- Description: `Currently being worked on. Developer has started coding.`

**Final Status Options** (in order):
1. **Backlog** - Stories not yet started
2. **Ready** - Refined and ready to work
3. **In Progress** - Being developed
4. **Review** - Code review & testing
5. **Done** - Completed & deployed

Click **Save**

---

### Step 3: Add Sprint Field (3 minutes)

1. Still in Settings → Fields
2. Click **+ New field**
3. Field name: `Sprint`
4. Field type: **Single select**
5. Add options with descriptions:

   **Sprint 1**
   - Description: `Nov 4-8, 2025: Core Order Flow - Infrastructure and proto contracts`

   **Sprint 2**
   - Description: `Nov 11-15, 2025: Modifiers & Card Payments - POS UI and production deploy`

   **Sprint 3**
   - Description: `Nov 18-22, 2025: Offline Mode & Real Printer - Advanced features`

   **Sprint 4**
   - Description: `Nov 25-29, 2025: Production Readiness - RBAC, stock, reports, monitoring`

   **Backlog**
   - Description: `Future stories not yet assigned to a sprint`

6. Click **Save**

---

### Step 4: Add Priority Field (3 minutes)

1. Still in Settings → Fields
2. Click **+ New field**
3. Field name: `Priority`
4. Field type: **Single select**
5. Add options with descriptions:

   **🔴 P0 - Critical**
   - Description: `Must complete this sprint. Blockers for other stories. Infrastructure and core features.`

   **🟠 P1 - High**
   - Description: `Important for sprint goal. Should complete if possible. Key features.`

   **🟡 P2 - Medium**
   - Description: `Nice to have this sprint. Enhancements and improvements.`

   **🟢 P3 - Low**
   - Description: `Can defer to next sprint. Polish, minor features, documentation.`

6. Click **Save**

---

### Step 5: Add Blocked Field (2 minutes)

1. Still in Settings → Fields
2. Click **+ New field**
3. Field name: `Blocked`
4. Field type: **Single select**
5. Add options with descriptions:

   **🚫 Yes**
   - Description: `Story is blocked. Cannot proceed until blocker is resolved. Add comment explaining blocker.`

   **✅ No**
   - Description: `Story is not blocked. Team member can work on this freely.`

6. Click **Save**

---

### Step 6: Create Sprint 1 Board View (2 minutes)

Now let's create filtered views for each sprint.

1. Click the current view name (usually "Board" or "View 1")
2. Click **Duplicate view**
3. Name it: `Sprint 1 Board`
4. Click **Filter** (funnel icon at top)
5. Add filter: `Sprint` = `Sprint 1`
6. Click **Save**

**Board layout**:
- Group by: Status
- Sort by: Priority
- Show: Sprint, Story Points, Assignees, Priority

---

### Step 7: Create Sprint 2, 3, 4 Board Views (3 minutes)

Repeat Step 6 for Sprint 2, 3, and 4:

**Sprint 2 Board**:
- Duplicate Sprint 1 Board
- Name: `Sprint 2 Board`
- Filter: Sprint = Sprint 2

**Sprint 3 Board**:
- Duplicate Sprint 1 Board
- Name: `Sprint 3 Board`
- Filter: Sprint = Sprint 3

**Sprint 4 Board**:
- Duplicate Sprint 1 Board
- Name: `Sprint 4 Board`
- Filter: Sprint = Sprint 4

---

### Step 8: Create Backlog View (2 minutes)

For planning future sprints.

1. Click "+ New view"
2. Name: `Backlog`
3. Layout: **Table**
4. Filter: Sprint = "Backlog" OR Sprint is empty
5. Show all fields
6. Sort by: Priority, Story Points
7. Click **Save**

---

### Step 9: Create Team View (Optional, 1 minute)

See what each team member is working on.

1. Click "+ New view"
2. Name: `Team View`
3. Layout: **Board**
4. Group by: **Assignees**
5. Filter: Status ≠ "Done"
6. Click **Save**

---

## 🎨 Recommended View Order

After creating all views, drag them to this order:

1. Sprint 1 Board (⭐ main view)
2. Sprint 2 Board
3. Sprint 3 Board
4. Sprint 4 Board
5. Backlog
6. Team View

---

## 📝 Set Sprint Field on Issues (5 minutes)

Now assign issues to sprints:

1. Go to **Backlog** view (table layout)
2. For each issue, click the **Sprint** cell
3. Set the value:
   - Issues #2-17 → Sprint 1
   - Issues #18-33 → Sprint 2
   - Issues #34-49 → Sprint 3
   - Issues #50-65 → Sprint 4

**Tip**: You can select multiple rows (Shift+Click) and bulk edit!

---

## 📊 Set Story Points (Optional, 5 minutes)

Story points are documented in each issue body. To set them:

1. Open each issue
2. Find "Story Points" in the issue body (e.g., ⭐ **Story Points**: 5)
3. Click the **Story Points** field in the sidebar
4. Enter the value

**OR** use bulk editing in Backlog table view!

---

## 🎯 Set Priority (Optional, 5 minutes)

Priorities are documented in issue bodies. To set them:

1. In Backlog view, click **Priority** cell for each issue
2. Match the priority from the issue body:
   - **P0 - Critical** (infrastructure, core features)
   - **P1 - High** (important features)
   - **P2 - Medium** (enhancements)
   - **P3 - Low** (nice-to-haves)

---

## ✅ Verification Checklist

After completing all steps:

- [ ] Status field has 5 options (Backlog, Ready, In Progress, Review, Done)
- [ ] Sprint field exists with 5 options (Sprint 1-4, Backlog)
- [ ] Priority field exists with 4 options (P0-P3)
- [ ] Blocked field exists with 2 options (Yes, No)
- [ ] Story Points field exists (Number type)
- [ ] 7 views created (4 sprint boards + backlog + team + original)
- [ ] Sprint field set on all 65 issues
- [ ] Sprint 1 Board view shows only 16 issues
- [ ] Backlog view shows all issues in table format

---

## 🚀 Your Board is Ready!

Once completed, you'll have:

✅ **Jira-style sprint board** with 5 workflow columns
✅ **4 sprint-specific views** (filtered by sprint)
✅ **Backlog planning view** (table with all fields)
✅ **Team collaboration view** (grouped by assignee)
✅ **Custom fields** for tracking (Sprint, Points, Priority, Blocked)

---

## 🎥 Quick Video Tutorial (Optional)

If you get stuck, check GitHub's official guide:
https://docs.github.com/en/issues/planning-and-tracking-with-projects/customizing-views-in-your-project

---

## 💡 Tips for Using Your Board

### Daily Standup
1. Open Sprint 1 Board
2. Review cards in each column
3. Move cards as work progresses

### Picking Up Work
1. Go to "Ready" column
2. Drag card to "In Progress"
3. Assign yourself
4. Start coding!

### Code Review
1. When PR is ready, move card to "Review"
2. Tag reviewer
3. After merge, move to "Done"

### Sprint Planning
1. Go to Backlog view
2. Filter stories for next sprint
3. Drag to Sprint X Board
4. Set Sprint field

---

**Your board URL**: https://github.com/users/kevin07696/projects/2

**Start configuring now!** This will take about 15-20 minutes total. 🚀
