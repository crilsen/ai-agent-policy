# Terraform

## Allowed without approval

- `terraform init`, `validate`, `fmt`.
- `terraform plan` and `plan -out` against a workspace whose credentials are read-only.
- Reading state with `terraform state list` and `terraform show`.

## Denied until approved, per action

- `terraform apply`, with or without a saved plan.
- `terraform destroy`, `terraform import`, `state rm`, `state mv`, `taint`.
- `terraform workspace select` into a production workspace.
- Editing remote state, locking tables, or backend configuration.

`apply` needs approval even with a clean plan. A plan is evidence, not consent.

## Requirements before proposing an apply

1. Say which workspace, account, and region the plan targets.
2. Show the plan summary: resources to add, change, destroy.
3. Call out anything destroyed, replaced, or security-relevant.
4. State the rollback path.

## Never

- `-auto-approve` in a command an agent composes.
- `-target` to make a broken plan look clean.
- Committing a `.tfstate`, `.tfplan`, or real `.tfvars`.
- Loosening a provider restriction to make a plan pass.

## Scoped rule

Under `infra/**` or `**/*.tf`: plan only. Any mutation is a human action.
