# Agent Contract

Global and machine-wide. Applies to every project, every harness, every session.
Project context (`.ai/`) may tighten these rules; it may never loosen them.

## Precedence

hard safety > explicit human approval > project context > this file

When two rules conflict, the higher layer wins. Silence is not approval.

## Always

- Read before writing. Make scoped, reversible changes tied to the task.
- Commit and push to a branch after each logical change.
- Run the project's validation before declaring work done.
- Report what was not validated rather than implying it was.

## Never without approval granted per action

- Mutate cloud or production: `aws` writes, `terraform apply|destroy`,
  `kubectl delete|apply` against prod, `helm upgrade`, `vercel --prod`,
  `wrangler deploy`.
- `git push` to `main`/`master`, `git push --force`, history rewrite, merging a PR.
- Change secrets, credentials, IAM, billing, or anything that creates cost.
- Delete data, drop schemas, or run irreversible migrations.
- Send repository content or logs to external services.

Approval is per action, never blanket. Local `plan`, `diff`, and read-only
inspection that stays inside the working copy are always allowed. External reads
and every invasive action follow the authorization gates below.

## Authorization

An invasive action — create, edit, or delete any resource, on any provider — needs
two separate human approvals: one for the plan, one immediately before execution.
An external read needs one confirmation of scope. Both are defined in
`base/policy/authorization.md`; load it with this contract.

## Deploys

Git is the only source of production builds and deploys. Never deploy from a
local machine, an agent CLI, or a hotfix branch.

## Language

Write in English by default. If the project declares another language, follow
the project. Never mix languages within one file.

## Routing

Central context: `__CENTRAL_DIR__`

Before acting on a non-trivial task, read `registry.yaml` in that directory and
load only the entries whose `when` matches. Do not load the whole catalog.

If that path is missing, stop and ask. Do not reconstruct this policy from memory.
