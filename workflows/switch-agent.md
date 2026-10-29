# Workflow — Switch Agent

Use when handing work to another agent, model, provider, machine, or when a usage
limit is near.

## 1. Finish the checkpoint

Update the project's `.ai/HANDOFF.md` Resume block, which must be readable by an
agent that has never seen this session:

- Repository state: branch, HEAD, working tree clean or dirty, with files listed.
- Last goal, in one line.
- What was done, in outcomes rather than activity.
- Exact next action, concrete enough to execute without rediscovery.
- Blocked by, or `None.`
- Annotation language in force.

## 2. Commit and push

A handoff that exists only in a local working tree is lost. Commit the context
updates and push the branch.

## 3. Hand over

- Branch and commit that the next agent should start from.
- What was validated and what was not.
- Anything the next agent must not redo, and why.

## 4. Continue

The receiving agent reads the contract, the project's `AGENTS.md`, then the Resume
block. It continues from there and does not rediscover context.

## Rule

Only the primary agent writes `HANDOFF.md`, `TASKS.md`, and `LEARNINGS.md`.
Subagents report back; the primary integrates.
