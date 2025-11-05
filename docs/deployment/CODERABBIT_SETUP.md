# CodeRabbit Integration Guide

CodeRabbit is an AI-powered code review assistant integrated with this repository.

## What CodeRabbit Does

- **Automated Code Reviews**: Reviews every pull request automatically
- **Security Analysis**: Identifies potential security vulnerabilities
- **Performance Suggestions**: Spots performance issues
- **Best Practices**: Enforces coding standards and best practices
- **Test Coverage**: Checks for proper test coverage
- **Documentation**: Suggests documentation improvements

---

## Configuration

CodeRabbit is configured via `.coderabbit.yaml` in the repository root.

### Current Settings

**Review Profile**: `chill` (balanced, not overly strict)

**Auto-review enabled for**:
- Pull requests to `main` branch
- Non-draft PRs only

**Path-specific instructions**:
- **Proto files** - Breaking changes, backward compatibility
- **Go backend** - Error handling, race conditions, security
- **TypeScript frontend** - Type safety, XSS, accessibility, performance
- **Tests** - Coverage, edge cases, table-driven tests
- **Workflows** - Security, caching, error handling

**Tools enabled**:
- shellcheck (bash scripts)
- gitleaks (secret scanning)
- hadolint (Dockerfiles)
- ESLint (JavaScript/TypeScript)
- golangci-lint (Go)
- buf (protobuf)

---

## How to Use

### 1. Create a Pull Request

```bash
git checkout -b feature/my-feature
# Make changes
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature
gh pr create --fill
```

### 2. CodeRabbit Reviews Automatically

Within 1-2 minutes, CodeRabbit will:
- Review all changed files
- Post a summary comment
- Add inline comments on specific issues
- Suggest improvements

### 3. Respond to CodeRabbit

You can interact with CodeRabbit using comments:

#### Ask for clarification:
```
@coderabbitai explain this suggestion
```

#### Request changes:
```
@coderabbitai please review this file again
```

#### Ask questions:
```
@coderabbitai what's the security issue here?
@coderabbitai can you suggest an alternative approach?
```

#### Request specific analysis:
```
@coderabbitai check for performance issues
@coderabbitai review for race conditions
@coderabbitai check test coverage
```

### 4. Address Feedback

- Review CodeRabbit's comments
- Make necessary changes
- Push updates to the PR
- CodeRabbit will re-review automatically

### 5. Resolve Conversations

After addressing feedback:
- Click "Resolve conversation" on each comment
- CodeRabbit tracks which issues are fixed

---

## Commands

### In PR Comments

#### General Commands:
- `@coderabbitai summary` - Generate PR summary
- `@coderabbitai review` - Trigger manual review
- `@coderabbitai pause` - Pause auto-reviews for this PR
- `@coderabbitai resume` - Resume auto-reviews

#### Specific Analysis:
- `@coderabbitai security` - Security-focused review
- `@coderabbitai performance` - Performance analysis
- `@coderabbitai tests` - Test coverage analysis

#### Conversation:
- `@coderabbitai explain` - Explain a suggestion
- `@coderabbitai help` - Show available commands

---

## Best Practices

### 1. Create Focused PRs

- Smaller PRs get better reviews
- One feature/fix per PR
- Easier to address feedback

### 2. Write Descriptive PR Descriptions

CodeRabbit uses PR descriptions for context:
```markdown
## Summary
Add tax calculation to order processing

## Changes
- Add TaxService with rate lookup
- Update Order model with tax fields
- Add tax calculation tests

## Testing
- Unit tests for TaxService
- Integration tests for order flow
```

### 3. Respond to Important Feedback

Focus on:
- Security issues (always address)
- Performance problems (evaluate impact)
- Breaking changes (discuss with team)
- Best practices (apply when reasonable)

### 4. Mark Issues as Resolved

After fixing issues:
- Update code
- Explain changes in reply
- Mark conversation as resolved

### 5. Provide Context

If CodeRabbit misunderstands:
```
@coderabbitai This is intentional because [reason].
The [pattern] is required for [use case].
```

---

## Common Scenarios

### CodeRabbit Flags False Positive

```
@coderabbitai This is a false positive because we're using
a prepared statement here, which prevents SQL injection.
```

### Need Explanation

```
@coderabbitai Can you explain why this is a race condition?
```

### Request Alternative

```
@coderabbitai What's a better way to handle this error?
```

### Disagree with Suggestion

```
We discussed this pattern as a team and decided it fits
our use case better than the suggested approach because
[specific reasons].
```

---

## Configuration Options

### Adjust Review Tone

Edit `.coderabbit.yaml`:

```yaml
reviews:
  profile: assertive  # More strict
  # or
  profile: chill      # More relaxed (current)
```

### Disable Auto-review for Specific Paths

```yaml
ignore:
  - "experiments/**"
  - "docs/**"
```

### Add Path-specific Instructions

```yaml
reviews:
  path_instructions:
    - path: "backend/services/**/*.go"
      instructions: |
        Focus on service-level concerns:
        - Business logic correctness
        - Transaction handling
        - Error propagation
```

---

## Troubleshooting

### CodeRabbit Didn't Review My PR

**Check:**
1. Is it a draft PR? (Auto-review disabled for drafts)
2. Is the base branch `main`? (Only reviews PRs to main)
3. Are all files in ignored paths?

**Solution:**
```
@coderabbitai review
```

### CodeRabbit Review is Too Strict

**Temporary:**
```
@coderabbitai Use a more relaxed tone for this PR
```

**Permanent:**
Update `.coderabbit.yaml`:
```yaml
reviews:
  profile: chill
```

### Want to Exclude Certain Checks

Update `.coderabbit.yaml`:
```yaml
checks:
  documentation:
    enabled: false  # Skip docs checks
```

---

## Integration with CI/CD

CodeRabbit complements (doesn't replace) CI checks:

| Tool | Purpose | When |
|------|---------|------|
| **CodeRabbit** | AI code review, suggestions | Every PR |
| **golangci-lint** | Go linting, enforced rules | Every PR (CI) |
| **gosec** | Security scanning | Every PR (CI) |
| **Tests** | Functional correctness | Every PR (CI) |

**Workflow:**
1. CodeRabbit reviews code (1-2 min)
2. CI runs automated checks (3-5 min)
3. Human reviewer approves (manual)
4. Merge after all checks pass

---

## Privacy & Security

- CodeRabbit only accesses public repository data
- Reviews are stored for learning improvements
- Sensitive data in code should already be protected (secrets, credentials)
- CodeRabbit detects and flags exposed secrets

---

## Tips for Better Reviews

### Write Clear Commit Messages

```bash
# Good
git commit -m "feat(orders): add tax calculation with lookup table"

# Bad
git commit -m "fix stuff"
```

### Add Comments for Complex Logic

```go
// We use a custom retry strategy here because the payment gateway
// has specific backoff requirements documented in their API guide.
func retryPayment(ctx context.Context, ...) error {
```

### Keep PRs Under 500 Lines

- Better reviews (human and AI)
- Faster feedback
- Easier to debug

### Include Test Cases

CodeRabbit recognizes well-tested code:
```go
func TestTaxCalculation(t *testing.T) {
    tests := []struct {
        name     string
        subtotal decimal.Decimal
        rate     decimal.Decimal
        want     decimal.Decimal
    }{
        // Test cases...
    }
    // ...
}
```

---

## Verification

### Check if CodeRabbit is Installed

1. Go to: https://github.com/kevin07696/modern-pos/settings/installations
2. Look for "CodeRabbit" in installed apps
3. Verify it has access to the repository

### Test the Integration

Create a simple test PR:
```bash
git checkout -b test/coderabbit
echo "# Test" >> README.md
git add README.md
git commit -m "test: verify coderabbit integration"
git push origin test/coderabbit
gh pr create --title "Test: CodeRabbit Integration" --body "Testing CodeRabbit"
```

Wait 1-2 minutes for CodeRabbit to comment.

---

## Support

**CodeRabbit Documentation**: https://docs.coderabbit.ai/

**Common Issues**: https://docs.coderabbit.ai/guides/troubleshooting

**Repository Settings**: https://github.com/kevin07696/modern-pos/settings/installations

---

## Example Review

Here's what a typical CodeRabbit review looks like:

```
🐰 CodeRabbit Review

## Summary
Added tax calculation feature with rate lookup table.
3 files changed, 150 additions, 20 deletions.

## ✅ Highlights
- Good test coverage (95%)
- Proper error handling
- Well-documented code

## 🔍 Issues Found
- backend/services/tax.go:45 - Potential SQL injection
- backend/services/tax.go:78 - Missing context timeout
- frontend/components/TaxDisplay.tsx:12 - Unsafe HTML rendering

## 💡 Suggestions
- Consider caching tax rates (hit DB on every request)
- Add index on tax_rates.zip_code for faster lookups
- Add validation for negative tax amounts

---

For more details, see inline comments above. ⬆️
```

---

**Ready to Use**: CodeRabbit is now configured and ready to review your pull requests! 🚀
