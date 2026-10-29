# Workflow — New Project

Use when starting a project that has no context layer yet.

## 1. Create the skeleton

Run `scripts/new-project.sh <path>`. It creates the directory, initializes git,
copies the context template, and points the project at this central repo.

## 2. Fill the context with observed facts

The template ships with placeholders. Replace them, do not leave them:

- `PROJECT.md` — what it is, stack, status.
- `ARCHITECTURE.md` — real components and data flow, only what exists today.
- `CONVENTIONS.md` — naming, layout, error handling, from the code that exists.
- `VALIDATION.md` — build, test, lint, format commands that actually run.
- `TOOLS.md` — how to invoke cloud, CI, and deploy tooling.

Mark inferences as inferred. Keep what cannot be determined explicitly unknown
rather than inventing a plausible answer.

## 3. Set the invariants early

Before the first deploy, decide and record:

- Which branch deploys production.
- Which environments exist and who can reach them.
- Where secrets live, and what the agent's credentials cannot do.

## 4. Then start the real task

Do not begin feature work while placeholders remain. The next session inherits
whatever is written here.

## Anti-pattern

Do not copy another project's context and rename it. Wrong facts are worse than
missing facts, because an agent will trust them.
