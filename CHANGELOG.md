# Changelog

## Unreleased

- Policy: `base/policy/authorization.md`. Invasive actions need double
  authorization (plan then execution); external reads need scope confirmation.
- Contract and guardrails aligned with the new gates.

## 0.1.0

- Initial split: `base/` (publishable) + `overlay/` (private).
- Contract with explicit precedence, per-action approval, git-only deploys.
- Policy files: guardrails, git, deploy, language.
- Rules: vercel, terraform.
- Workflows: feature, review, new-project, switch-agent.
- Scripts: build, install, doctor, publish, new-project.
- Adapters generated for opencode, claude, codex, gemini, cursor.
