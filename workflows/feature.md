# Workflow — Feature

Use when implementing or changing code, configuration, or infrastructure.

## 1. Orient

- Read the project's `AGENTS.md` and `.ai/` context.
- Check `.ai/TASKS.md` and `.ai/DECISIONS.md` before changing an existing decision.
- Confirm the task is scoped enough to finish in one reviewable change.

## 2. Plan

State the approach in a few lines, including the files expected to change. If the
task needs a decision that a human owns, ask before writing code.

## 3. Implement

- Branch from the deploy branch.
- Change only task-related files.
- Match the surrounding style, naming, and patterns.
- Do not refactor unrelated code in the same change.

## 4. Validate

Run the checks the project declares in `.ai/VALIDATION.md`, or its documented
equivalents. Report anything not run.

## 5. Commit and hand off

- Commit with an imperative message explaining why.
- Push the branch.
- Update `.ai/TASKS.md` and `.ai/HANDOFF.md`.
- Do not merge. Say what should be reviewed and why.
