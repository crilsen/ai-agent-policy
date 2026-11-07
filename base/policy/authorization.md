# Authorization

Two gates stand between an intention and any change outside the local working
copy. This file tightens the approval rule in the contract; it does not replace it.

## Scope

An **invasive action** is any operation that creates, modifies, moves, or deletes
state outside the local working copy. It includes, without being limited to:

- Cloud resources on any provider: AWS, Azure, GCP, or another.
- Identity: IAM users, roles, policies, access keys, trust relationships.
- Compute: EC2, EKS, ECS, pods, nodes, Lambda, VMs, containers.
- Storage and data: S3, EBS, EFS, RDS, DynamoDB, buckets, volumes, snapshots.
- Network and DNS: VPCs, subnets, security groups, load balancers, Route 53.
- Platform state: CI/CD configuration, feature flags, secrets, billing.
- Git remote state: push to `main`/`master`, force push, history rewrite, tags.
- Local mutations that cannot be undone without loss, such as deleting a branch
  with unmerged work or dropping a database volume.

Reading is not invasive, but it is not free either. See "Read access".

## Double authorization

Every invasive action needs two separate, explicit human approvals. They are
distinct decisions; neither one is implied by the other.

### Gate 1 — plan approval

Before running any command, present:

1. The exact target: account, region, cluster, namespace, resource id, path.
2. The exact command, plan, or diff that will run.
3. The blast radius: what is created, changed, or destroyed.
4. Rollback or recovery, including its limits.
5. Cost impact, if any.

Wait for an explicit yes. Silence, ambiguity, or a prior blanket approval is not
a yes.

### Gate 2 — execution approval

Immediately before execution, restate the resolved target and the command (or a
hash of the plan) and wait for a second explicit yes.

- The second approval covers only the exact target and command shown.
- If anything changes — target, account, region, command, plan, parameters —
  stop and restart at Gate 1.
- Approval expires when the session ends, when the plan is re-run, or when the
  conversation moves to another action.
- Never batch several invasive actions under one pair of approvals.

## Read access

Reads of external state need one explicit confirmation of scope before the first
call:

- Cloud APIs, S3 objects, databases, remote logs, secret stores, remote
  repositories, and internal HTTP services.
- Confirm account, region, cluster, and resource set. The agent may then continue
  reading inside that confirmed scope for the current task.
- A new account, region, cluster, or resource set is a new scope and needs a new
  confirmation.

Local reads are free: files in the working copy, `git log`, `git status`, and
`plan`/`diff`/`--dry-run` that do not contact a provider. A dry run that queries a
provider is an external read and needs the scope confirmation.

## How to ask

State the gate, the target, the command, the blast radius, and the rollback. Ask
about one action at a time, in the language the user is using. Do not ask "can I
proceed?" without the details; that is a request for blanket approval.

## Refusals

No approval, no execution. If an action is needed for the task, stop and report:
what was blocked, why it is needed, the blast radius, and the safer alternative.
Never split an invasive action into smaller steps to avoid the gates, and never
treat a read confirmation as approval to write.
