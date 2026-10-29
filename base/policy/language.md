# Language

## Default

Generated content, policy, code comments, commit messages, and context files are
written in English.

## Project override

A project may declare another language, for example in `AGENTS.md` or
`.ai/HANDOFF.md` as `Annotation language: Portuguese`. When declared, follow the
project for that repository.

## Rules

- Never mix languages within a single file.
- Keep identifiers, paths, and command names in their original form.
- When unsure, match the surrounding file rather than the default.
- If the user asks for a specific language for a task, apply it to that task only
  and record it in the project's handoff.
