# Implementation Tasks

This directory contains individual task files for each sprint, written in agile user story format.

## Directory Structure

```
tasks/
├── README.md (this file)
├── sprint-1/
│   ├── S1.1-setup-monorepo.md
│   ├── S1.2-configure-docker.md
│   ├── ...
│   └── S1.16-demo-preparation.md
├── sprint-2/
│   ├── S2.1-modifier-entities.md
│   ├── ...
├── sprint-3/
│   └── ...
└── sprint-4/
    └── ...
```

## Task Naming Convention

**Format**: `SX.Y-short-description.md`

- `S` = Story
- `X` = Sprint number (1-4)
- `Y` = Story number within sprint (1-16)
- `short-description` = Kebab-case summary

**Examples**:
- `S1.1-setup-monorepo.md`
- `S2.5-payment-service-integration.md`
- `S3.13-real-printer-adapter.md`

## Task File Template

Each task file must follow this structure:

```markdown
# SX.Y: Story Title

**Sprint**: X  
**Story Points**: Y  
**Assignee**: Developer A | Developer B | Both  
**Priority**: P0-Critical | P1-High | P2-Medium | P3-Low  
**Dependencies**: SX.Y, SX.Z (or None)

---

## User Story

As a **[role]**, I want **[feature]** so that **[benefit]**.

---

## Description

2-3 paragraph description of what needs to be built and why.

---

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] ...

Use Given/When/Then format where appropriate:
- [ ] Given [context], When [action], Then [outcome]

---

## Definition of Done

- [x] Code written and tested
- [x] Unit tests passing (>80% coverage)
- [x] Integration tests passing
- [x] Documentation updated
- [x] Code reviewed
- [x] Deployed to dev environment

---

## Technical Details

### Relevant schemas, code snippets, API contracts

---

## Implementation Steps

1. Step 1
2. Step 2
...

---

## Testing

### Test cases with examples

---

## Time Estimate

**Estimated**: X hours  
**Actual**: ___ hours (filled during retro)

---

## Notes

Additional context, gotchas, or considerations

---

## Related Stories

- **SX.Y**: Related story
- **SX.Z**: Dependency
```

## Story Point Scale

Use Fibonacci sequence for estimation:

| Points | Complexity | Time |
|--------|-----------|------|
| 1 | Trivial | < 1 hour |
| 2 | Simple | 1-2 hours |
| 3 | Medium | 2-4 hours |
| 5 | Complex | 4-8 hours |
| 8 | Very Complex | 1-2 days |
| 13 | Needs Breaking Down | Should split into smaller stories |

If a story is 13+ points, split it into multiple stories.

## Priority Levels

- **P0 - Critical**: Must have for MVP, blocks other work
- **P1 - High**: Important for release, affects user experience
- **P2 - Medium**: Should have, improves system
- **P3 - Low**: Nice to have, can be deferred

## Creating New Tasks

When creating a new task:

1. Copy the template above
2. Fill in all sections thoroughly
3. Ensure user story follows "As a... I want... So that..." format
4. Write specific, testable acceptance criteria
5. Include technical details (schemas, APIs, etc.)
6. List clear implementation steps
7. Add testing strategy
8. Estimate story points (use planning poker if team)
9. Identify dependencies

## Task Lifecycle

```
[Backlog] → [Ready] → [In Progress] → [In Review] → [Testing] → [Done]
```

### Backlog
- Story written but not estimated or refined

### Ready
- Story meets Definition of Ready
- Estimated and dependencies resolved
- Can be pulled into sprint

### In Progress
- Developer actively working on story
- Updates Actual hours daily

### In Review
- Code review requested
- Waiting for approval

### Testing
- Code merged, deployed to dev
- QA testing acceptance criteria

### Done
- All acceptance criteria met
- Definition of Done checklist complete
- Stakeholder accepted

## Daily Updates

Developers should update tasks daily:

```markdown
## Daily Log

**2025-11-04**:
- Completed monorepo setup
- Started Platform Service schema
- Blocked: Need PostgreSQL Docker image decision

**2025-11-05**:
- Unblocked: Using postgres:15-alpine
- Completed Platform Service schema
- Started JWT implementation
```

## Example Tasks

See these examples for reference:

- **Infrastructure**: `sprint-1/S1.1-setup-monorepo.md`
- **Backend API**: `sprint-1/S1.9-create-sale-with-tax.md`
- **Frontend UI**: `sprint-1/S1.14-kitchen-display-ui.md`

---

**Questions?** See [SPRINT_PLAN.md](../SPRINT_PLAN.md) for overview or ask in standup.
