#!/usr/bin/env bash
# Link the generated contract into each harness's global location.
# Dry run by default. Pass --apply to write.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY="no"
[[ "${1:-}" == "--apply" ]] && APPLY="yes"

[[ -f "$ROOT_DIR/dist/agents.md" ]] || "$ROOT_DIR/scripts/build.sh"

# tool | generated file | global destination
MAP=(
  "opencode|dist/opencode/AGENTS.md|$HOME/.config/opencode/AGENTS.md"
  "claude|dist/claude/CLAUDE.md|$HOME/.claude/CLAUDE.md"
  "codex|dist/codex/AGENTS.md|$HOME/.codex/AGENTS.md"
  "gemini|dist/gemini/GEMINI.md|$HOME/.gemini/GEMINI.md"
  "cursor|dist/cursor/rules/agent-policy.mdc|$HOME/.cursor/rules/agent-policy.mdc"
)

for row in "${MAP[@]}"; do
  IFS='|' read -r tool src dest <<<"$row"
  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$ROOT_DIR/$src" ]]; then
    echo "ok      $tool -> $dest"
    continue
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "replace $tool  $dest (backup: $dest.bak)"
    if [[ "$APPLY" == "yes" ]]; then
      cp -P "$dest" "$dest.bak"
    fi
  else
    echo "create  $tool  $dest"
  fi

  if [[ "$APPLY" == "yes" ]]; then
    ln -sfn "$ROOT_DIR/$src" "$dest"
  fi
done

if [[ "$APPLY" != "yes" ]]; then
  echo
  echo "dry run. re-run with --apply to write."
fi
