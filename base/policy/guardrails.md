# Guardrails

Portable policy for what agents may and may not do, independent of harness.
Loaded with the contract on every session.

## Allowed

- Read, search, and understand any repository.
- Scoped, reversible edits tied to the task.
- Formatters, linters, tests, type checks, and local dry runs that contact no
  provider.
- Local `plan`, `diff`, and `--dry-run`.
- Updating the project's context layer.

## Denied until approved

- Any invasive action before both authorizations in `authorization.md`.
- External reads — cloud APIs, S3, databases, remote logs, secret stores,
  internal services — before their scope is confirmed.
- Destructive or irreversible operations.
- Any production or infrastructure mutation.
- Credential, secret, IAM, or billing changes.
- Creating paid resources.
- Egress of repository content.

## Escalation

When a guardrail blocks a step that looks necessary, stop and report: what you
wanted to do, why, the blast radius, and a safer alternative. Never route around
a guardrail silently, and never split a denied action into smaller allowed ones.
A read confirmation is not approval to write.

## Enforcement levels

1. **Advisory** — stated in the contract and this file. Nothing blocks it.
2. **Scoped** — harness rules matched by path.
3. **Enforced** — harness permissions and hooks.

Prefer enforcement for irreversible actions. A rule in a prompt is intent.
A credential is the actual limit: if the agent holds admin, the rule is theater.
