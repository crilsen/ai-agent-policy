# Vercel

## Deploy model

Production deploys only from the deploy branch through Git integration, or from
CI building a commit. Preview deploys per pull request.

## Never

- `vercel --prod`, `vercel deploy --prod`, or `vercel promote` from a laptop or agent.
- `--force` to rebuild over an existing artifact.
- Editing environment variables in the dashboard during an incident.
- Using `vercel env pull` output with real secrets into a tracked file.
- Disabling or bypassing a failing build.

## Inspect freely

`vercel ls`, `vercel logs`, `vercel inspect`, `vercel env ls` are read-only and
need no approval.

## Configuration

Project settings that matter belong in `vercel.json` or in the project's context
layer, so they are reviewable. Anything changed only in the dashboard is drift.

## Tokens

An agent token must be able to read and create previews, not promote to
production. If a token can promote, the guardrail is not the rule.
