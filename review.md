Review the current uncommitted changes in this repository. Follow these steps:

1. Run `git diff HEAD` to get all staged and unstaged changes.
2. For each changed file, read the full file to understand the surrounding context.
3. Perform a thorough code review covering:

## Review Checklist

### Correctness
- Does the logic work as intended for all code paths?
- Are there off-by-one errors, null/undefined risks, or race conditions?
- Are edge cases handled (empty collections, disconnected state, concurrent operations)?

### Security
- Any injection risks, data leaks, or missing authorization checks?
- Is user input validated at system boundaries?

### Consistency
- Does the new code match the existing project's style and patterns?
- Are naming conventions consistent?

### Robustness
- Can this crash at runtime? Are there unhandled exceptions?
- What happens if external calls fail?
- Is state properly cleaned up on error paths?

### Performance
- Any unnecessary allocations, loops, or redundant operations?
- Could this cause memory leaks (e.g., timers not cleared, maps not cleaned)?

## Output Format

For each issue found, report:
- **Severity**: Critical / Warning / Suggestion
- **Location**: `file:line`
- **Problem**: What's wrong
- **Fix**: How to fix it

End with a summary: total issues by severity, and an overall assessment of whether the changes are ready to merge.
