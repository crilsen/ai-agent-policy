# Workflow — Review

Use when the user asks for a review, or before opening a PR for review.

## Order of inspection

1. Correctness: does it do what the task claims, including edge cases?
2. Safety: does it cross a guardrail, touch production, or handle secrets badly?
3. Reversibility: is a rollback possible without data loss?
4. Consistency: does it follow the project's conventions and decisions?
5. Testing: is the change actually covered, or only claimed to be?
6. Diff hygiene: unrelated edits, debug leftovers, commented code, lockfile noise.

## Output

- Findings first, ordered by severity, each with file and line.
- Separate must-fix from optional.
- State explicitly when something was not verifiable.
- No praise padding, no summary of what the diff already shows.

## Never

- Approve because tests pass if the tests do not cover the change.
- Suggest a fix that silently widens scope.
- Merge on the user's behalf.
