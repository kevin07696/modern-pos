# Sprint Planning Template

Use this template for each sprint planning session.

---

## Sprint [NUMBER] Planning

**Sprint Dates**: [START DATE] - [END DATE]
**Sprint Goal**: _[1-2 sentence description of what we want to achieve]_
**Planning Date**: [DATE]
**Team Present**: [LIST TEAM MEMBERS]

---

## Team Capacity

### Team Members

| Name | Role | Days Available | Capacity % | Story Points/Day | Total Points |
|------|------|----------------|------------|------------------|--------------|
| Alice | Backend Dev | 5 | 80% | 3 | 12 |
| Bob | Backend Dev | 5 | 70% | 3 | 10.5 |
| Charlie | Frontend Dev | 4 | 100% | 2.5 | 10 |
| David | Full Stack | 5 | 80% | 3 | 12 |
| Eve | DevOps | 3 | 100% | 3 | 9 |
| **Total** | | **22 days** | **86%** | | **53.5 points** |

**Notes**:
- Alice: 1 day off (Friday)
- Bob: Partially assigned to support
- Charlie: Available only Mon-Thu
- Eve: Part-time (3 days/week)

**Sprint Capacity**: **50 story points** (buffer for unexpected work)

---

## Velocity History

| Sprint | Planned | Completed | Velocity | Notes |
|--------|---------|-----------|----------|-------|
| Sprint 1 | 45 | 42 | 42 | First sprint, learning curve |
| Sprint 2 | 45 | 38 | 38 | 2 blockers, lost time |
| Sprint 3 | 40 | 45 | 45 | Team hit stride |
| **Average** | | | **42** | Use for planning |

**Planned Capacity for This Sprint**: **42 points** (based on average velocity)

---

## Sprint Backlog

### Committed Stories

| Story | Title | Assignee | Points | Priority | Dependencies |
|-------|-------|----------|--------|----------|--------------|
| S[X].1 | [Story title] | Alice | 5 | P0 | None |
| S[X].2 | [Story title] | Bob | 3 | P0 | S[X].1 |
| S[X].3 | [Story title] | Charlie | 8 | P1 | None |
| S[X].4 | [Story title] | David | 5 | P1 | S[X].2 |
| S[X].5 | [Story title] | Eve | 3 | P2 | None |
| S[X].6 | [Story title] | Alice | 5 | P2 | S[X].3 |
| ... | ... | ... | ... | ... | ... |
| **Total** | | | **42** | | |

### Stretch Goals (if capacity allows)

| Story | Title | Assignee | Points | Notes |
|-------|-------|----------|--------|-------|
| S[X].X | [Story title] | TBD | 5 | Only if ahead of schedule |
| S[X].Y | [Story title] | TBD | 3 | Nice to have |

---

## Sprint Risks

| Risk | Impact | Mitigation | Owner |
|------|--------|------------|-------|
| Holiday on Day 3 | High | Front-load critical work | Scrum Master |
| New technology (Buf) | Medium | Pair programming, spike on Day 1 | Alice + Bob |
| External API dependency | High | Mock responses, test early | Charlie |
| Database migration | Medium | Test on staging first | David |

---

## Definition of Done

Stories are only "Done" when:
- ✅ Code written and reviewed
- ✅ Unit tests written (>80% coverage)
- ✅ Integration tests passing
- ✅ Documentation updated
- ✅ Deployed to staging
- ✅ Acceptance criteria met
- ✅ Product owner approved

---

## Sprint Goal Breakdown

**Goal**: _[Restate sprint goal]_

**Success Criteria**:
1. ✅ [Specific measurable outcome 1]
2. ✅ [Specific measurable outcome 2]
3. ✅ [Specific measurable outcome 3]

**Out of Scope**:
- ❌ [Feature explicitly not in this sprint]
- ❌ [Technical debt to defer]
- ❌ [Nice-to-have deferred to next sprint]

---

## Daily Standup Schedule

**Time**: 9:00 AM daily
**Duration**: 15 minutes max
**Location**: [Zoom link / Meeting room]

**Format**:
1. Each person: Yesterday / Today / Blockers (2 min each)
2. Update sprint board live during standup
3. Resolve blockers after standup (not during)

---

## Sprint Review & Demo

**Date**: [LAST DAY OF SPRINT]
**Time**: [TIME]
**Attendees**: Team + stakeholders + product owner

**Demo Order**:
1. [Feature 1] - Presented by [Name]
2. [Feature 2] - Presented by [Name]
3. [Feature 3] - Presented by [Name]

---

## Sprint Retrospective

**Date**: [LAST DAY OF SPRINT]
**Time**: [TIME] (after review)
**Duration**: 45 minutes

**Agenda**:
1. What went well? (15 min)
2. What could improve? (15 min)
3. Action items for next sprint (15 min)

**Retro Format**: [Starfish / Sailboat / 4Ls / etc.]

---

## Notes from Planning Session

**Discussions**:
- [Key discussion point 1]
- [Key discussion point 2]
- [Decision made about architecture]

**Action Items**:
- [ ] [Action item] - Owner: [Name] - Due: [Date]
- [ ] [Action item] - Owner: [Name] - Due: [Date]

**Questions for Product Owner**:
- [ ] [Question about requirement]
- [ ] [Clarification needed on acceptance criteria]

---

## Sign-off

**Team Commitment**: We commit to delivering [X] story points this sprint, focused on achieving the sprint goal.

**Signatures**:
- [ ] Product Owner: _________________
- [ ] Scrum Master: _________________
- [ ] Development Team: _________________

**Sprint Start**: [DATE & TIME]

---

## Example: Sprint 1 Planning (Completed)

**Sprint Dates**: Nov 4-8, 2025
**Sprint Goal**: Complete backend infrastructure and core proto contracts
**Planning Date**: Nov 3, 2025
**Team Present**: Alice (Backend), Bob (Backend), Charlie (Frontend), David (DevOps)

### Team Capacity

| Name | Role | Days Available | Capacity % | Story Points/Day | Total Points |
|------|------|----------------|------------|------------------|--------------|
| Alice | Backend Lead | 5 | 100% | 3 | 15 |
| Bob | Backend Dev | 5 | 80% | 3 | 12 |
| Charlie | Frontend Dev | 5 | 70% | 2 | 7 |
| David | DevOps | 5 | 60% | 2 | 6 |
| **Total** | | **20 days** | **78%** | | **40 points** |

**Sprint Capacity**: **45 story points** (first sprint, being optimistic)

### Committed Stories

| Story | Title | Assignee | Points | Priority |
|-------|-------|----------|--------|----------|
| S1.1 | Setup Monorepo | Alice | 5 | P0 |
| S1.2 | Configure Docker | David | 3 | P0 |
| S1.3 | Setup Buf | Alice | 3 | P0 |
| S1.4 | Proto Common Types | Bob | 3 | P0 |
| S1.5 | Proto Item Service | Alice | 5 | P0 |
| S1.6 | Proto Order Service | Bob | 5 | P0 |
| S1.7 | Proto Platform Service | Alice | 5 | P1 |
| S1.8 | Generate Proto Code | David | 2 | P1 |
| S1.9 | Create Sale with Tax | Bob | 5 | P1 |
| S1.10 | Record Payment | Bob | 3 | P2 |
| S1.11 | Publish Sale Events | Alice | 3 | P2 |
| **Total** | | | **42** | |

### Sprint Goal Breakdown

**Goal**: Complete backend infrastructure and core proto contracts

**Success Criteria**:
1. ✅ Monorepo structure set up with all services
2. ✅ Proto contracts defined for all services
3. ✅ Code generation working for Go and TypeScript
4. ✅ Core sale creation endpoint functional

**Out of Scope**:
- ❌ Frontend UI implementation (Sprint 2)
- ❌ Offline mode (Sprint 3)
- ❌ Production deployment (Sprint 4)

---

**Use this template for Sprint 2, 3, and 4 planning!**
