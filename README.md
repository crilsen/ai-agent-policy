# agent-policy

One central, versioned source for how coding agents behave across every project on
a machine: rules, guardrails, workflows, and skills. Projects keep their own facts;
this repository owns the floor.

## Why

Agent instructions spread across `~/.config/opencode`, `~/.claude`, `~/.codex`,
`~/.cursor`, and `~/.gemini` drift immediately. Change a rule in one place and the
other four keep the old version. Here there is one source and generated adapters.

## Layers

| Layer | Lives in | Loaded |
| --- | --- | --- |
| Contract | `base/contract.md` + `overlay/personal.md` | Always, ~30 lines |
| Policy | `base/policy/*.md` | With the contract |
| Catalog | `registry.yaml` -> `rules/`, `workflows/`, `skills/` | On demand, matched by `when` |
| Project | each repo's `AGENTS.md` + `.ai/` | Per session |

The contract is the only file a harness reads automatically. It states the safety
floor, points at this directory, and tells the agent to consult `registry.yaml`
instead of loading everything.

Precedence: **hard safety > explicit human approval > project context > contract**.
A project may tighten these rules, never loosen them.

## Optional private source, public template

`base/` is generic and publishable. An optional `overlay/` holds what is yours:
machine paths, account profiles, personal preferences. `scripts/build.sh` composes
them into one file. `scripts/publish.sh` ships only what `registry.yaml` marks
`visibility: public`, drops the rest, and fails if a deny-listed string survives.

So: iterate privately, publish what has proven itself. A rule that is not declared
public does not exist for the published repository.

## Usage

```bash
./scripts/build.sh              # compose contract -> dist/ + root AGENTS.md
./scripts/install.sh            # dry run: show what would be linked
./scripts/install.sh --apply    # symlink into the 5 harness locations
./scripts/doctor.sh             # stale output, broken links, registry integrity
./scripts/publish.sh            # stage the public export, review the diff
./scripts/publish.sh --push     # publish
```

### First run on a machine that already has agent instructions

`install.sh --apply` refuses to run when a global instruction file already exists.
It lists the files, then asks for a decision:

```bash
./scripts/import.sh --apply               # copy them into overlay/imported/
./scripts/install.sh --apply --import     # import, then link
./scripts/install.sh --apply --discard    # replace, keeping <file>.bak
```

Imported files are inert: not linked, not loaded, not published. They are raw
material to review, keep what is still true, and promote into `base/` or `overlay/`.

Never import silently, and never import "just in case": an imported rule stays a
rule in the reader's mind even if the file is inert. Ask first, then act.

New project:

```bash
./scripts/new-project.sh ~/Projects/my-app
```

## Adding a rule or workflow

1. Write the file under `rules/`, `workflows/`, or `skills/`.
2. Add an entry to `registry.yaml` with a precise `when`.
3. Mark `visibility: private` if it must not be published.
4. Run `./scripts/doctor.sh`.

Prefer a narrow `when` over a broad rule that loads on every task: context is the
budget.

## What belongs here vs. in a project

- Here: safety floor, git and deploy policy, language default, cross-project workflows.
- Project: stack, commands, architecture, validation, decisions, current state.

A server name, hostname, account id, or client name belongs in `overlay/` or in the
project, never in `base/`.

The overlay is committed to the private repository. Never put a secret there: it is
for context, not credentials.

## License

MIT. See `LICENSE`.
