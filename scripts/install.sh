#!/usr/bin/env bash
# Link the generated contract into each harness's global location.
#
# Dry run by default. Pass --apply to write.
#
# On a machine that already has agent instructions, this stops and asks. It will
# not replace existing files until you choose to import or discard them.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/targets.sh
source "$ROOT_DIR/scripts/lib/targets.sh"

APPLY="no"
MODE=""

usage() {
  cat <<'EOF'
usage: install.sh [--apply] [--import | --discard]

  (no flags)   dry run: show what would happen
  --apply      write the symlinks
  --import     first copy existing instructions into overlay/imported/, then link
  --discard    replace existing instructions, keeping <file>.bak alongside
EOF
}

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY="yes" ;;
    --import) MODE="import" ;;
    --discard) MODE="discard" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
  esac
done

[[ -f "$ROOT_DIR/dist/agents.md" ]] || "$ROOT_DIR/scripts/build.sh"

# ---- detect existing, unmanaged instructions --------------------------------
CONFLICTS=()
for row in "${TARGETS[@]}"; do
  IFS='|' read -r tool src dest <<<"$row"
  [[ -e "$dest" || -L "$dest" ]] || continue
  [[ -L "$dest" && "$(readlink "$dest")" == "$ROOT_DIR/$src" ]] && continue
  CONFLICTS+=("$tool|$dest")
done

if [[ "${#CONFLICTS[@]}" -gt 0 && -z "$MODE" ]]; then
  cat <<EOF
This machine already has agent instructions at the global locations.

EOF
  for row in "${CONFLICTS[@]}"; do
    IFS='|' read -r tool dest <<<"$row"
    printf '  %-9s %s\n' "$tool" "$dest"
  done
  cat <<EOF

Linking would replace them. Choose one, then re-run:

  --import    copy their content into overlay/imported/ first, then link
  --discard   replace them, keeping a .bak next to each original

Nothing has been changed.
EOF
  exit 3
fi

if [[ "${#CONFLICTS[@]}" -gt 0 && "$MODE" == "import" ]]; then
  if [[ "$APPLY" == "yes" ]]; then
    "$ROOT_DIR/scripts/import.sh" --apply
  else
    "$ROOT_DIR/scripts/import.sh"
  fi
  echo
fi

# ---- link ------------------------------------------------------------------
for row in "${TARGETS[@]}"; do
  IFS='|' read -r tool src dest <<<"$row"
  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$ROOT_DIR/$src" ]]; then
    echo "ok      $tool -> $dest"
    continue
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "replace $tool  $dest (backup: $dest.bak)"
    [[ "$APPLY" == "yes" ]] && cp -P "$dest" "$dest.bak"
  else
    echo "create  $tool  $dest"
  fi

  [[ "$APPLY" == "yes" ]] && ln -sfn "$ROOT_DIR/$src" "$dest"
done

if [[ "$APPLY" != "yes" ]]; then
  echo
  echo "dry run. re-run with --apply to write."
fi
