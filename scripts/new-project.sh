#!/usr/bin/env bash
# Create a project skeleton wired to this central policy.
# usage: new-project.sh <path>
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/platform.sh
source "$ROOT_DIR/scripts/lib/platform.sh"
[[ -f "$ROOT_DIR/overlay/config.sh" ]] && source "$ROOT_DIR/overlay/config.sh"
CENTRAL_DIR="${CENTRAL_DIR:-$ROOT_DIR}"
RELAY_PATH="${RELAY_PATH:-}"

TARGET="${1:?usage: new-project.sh <path>}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

if [[ -n "$(ls -A "$TARGET" 2>/dev/null)" ]]; then
  echo "error: $TARGET is not empty" >&2
  exit 1
fi

if [[ -z "$RELAY_PATH" || ! -d "$RELAY_PATH" ]]; then
  echo "error: RELAY_PATH not set or missing in overlay/config.sh" >&2
  exit 1
fi

# Copy the project context template, without its git history.
mirror "$RELAY_PATH" "$TARGET"

# Point the project at the central policy before anything else.
NOTICE="> Global policy: \`AGENTS.md\` in \`${CENTRAL_DIR}\`. Read it before this file."
printf '%s\n\n' "$NOTICE" | cat - "$TARGET/AGENTS.md" > "$TARGET/AGENTS.md.tmp"
mv "$TARGET/AGENTS.md.tmp" "$TARGET/AGENTS.md"

cd "$TARGET"
if [[ ! -d .git ]]; then
  git init -q
fi

cat > .ai/TASKS.md <<'EOF'
# Tasks

## Now

- Bootstrap: replace the placeholders in `.ai/` with observed facts.

## Next

- None.

## Done

- None.
EOF

git add -A
git commit -q -m "chore: bootstrap project context layer"
echo "created $TARGET"
echo "next: fill .ai/PROJECT.md, ARCHITECTURE.md, CONVENTIONS.md, VALIDATION.md, TOOLS.md"
