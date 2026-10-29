# Git

## Default flow

1. Create or switch to a branch.
2. Commit after each logical change, small and reviewable.
3. Push the branch.
4. Open a PR when the work is complete.

Commits and branch pushes need no approval. They are checkpoints, not decisions.

## Needs approval, per action

- Push to `main` or `master`.
- Merge a PR, including squash and rebase merges.
- `git push --force` or `--force-with-lease`.
- History rewrite: `rebase` of shared commits, `commit --amend` after push.
- Tagging or publishing a release.

## Never

- Commit secrets, tokens, keys, or `.env` files with real values.
- Commit generated artifacts the project ignores.
- Bypass hooks with `--no-verify`.
- Commit unrelated work in the same change.

## Interaction with deploys

If the platform deploys production on push to `main`, then "always push" would be
a production deploy. Push to branches only; merging is the deploy gate.

## Commit messages

Imperative subject, at most 72 characters, explaining why rather than what the
diff already shows. Body only when the change is not self-evident.
