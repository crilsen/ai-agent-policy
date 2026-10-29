# Deploys

## One rule

Git is the only source of production builds and deploys. The artifact that
reaches production was built from a commit, by the platform or by CI.

## Consequences

- No `vercel --prod`, `vercel deploy --prod`, `wrangler deploy`, `netlify deploy
  --prod`, `firebase deploy`, `aws s3 sync` to a live bucket, or equivalent from
  a laptop, an agent, or a hotfix shell.
- Preview and staging environments are created from branches, not from local builds.
- Production is reached by merging to the deploy branch, and that merge needs approval.
- Environment variables and secrets are provisioned as configuration, not typed
  into a dashboard mid-incident.

## If a deploy is broken

Diagnose from logs. Fix forward with a commit. Never patch production by hand,
and never re-run a deploy with a different artifact than the one on the branch.

## When a project legitimately differs

A monorepo may deploy through CI calling the provider CLI. That still satisfies
this rule: the artifact comes from a commit. What is forbidden is a human or agent
promoting an uncommitted build.

Record the deviation in the project's `.ai/DECISIONS.md`.
