#!/usr/bin/env bash
# Import the agent instructions that already exist on this machine into
# overlay/imported/, so nothing is lost when the global contract takes over.
#
# Imported content is inert: it is not loaded, not linked, and not published.
# It is raw material to review and promote deliberately.
#
# Dry run by default. Pass --apply to write.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/targets.sh
source "$ROOT_DIR/scripts/lib/targets.sh"

APPLY="no"
[[ "${1:-}" == "--apply" ]] && APPLY="yes"
DEST_DIR="$ROOT_DIR/overlay/imported"
found=0

for row in "${TARGETS[@]}"; do
  IFS='|' read -r tool _src dest <<<"$row"
  [[ -e "$dest" || -L "$dest" ]] || continue
  [[ -L "$dest" ]] && continue          # already ours
  [[ -f "$dest" ]] || continue          # skip directories and oddities

  found=$((found + 1))
  out="$DEST_DIR/$tool.md"

  if [[ "$APPLY" == "yes" ]]; then
    mkdir -p "$DEST_DIR"
    {
      echo "<!-- Imported from: $dest"
      echo "     On: $(date '+%Y-%m-%d')"
      echo "     Inert: not loaded, not linked, not published."
      echo "     Review and promote what is still true into base/ or overlay/. -->"
      echo
      cat "$dest"
    } > "$out"
    echo "imported  $tool -> ${out#"$ROOT_DIR"/}"
  else
    echo "would import  $tool  ($dest)"
  fi
done

if [[ "$found" == 0 ]]; then
  echo "nothing to import: no existing agent instructions found"
  exit 0
fi

if [[ "$APPLY" != "yes" ]]; then
  echo
  echo "dry run. re-run with --apply to copy them into overlay/imported/."
fi
