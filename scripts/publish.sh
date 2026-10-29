#!/usr/bin/env bash
# Port the dev repository to the published one.
#
# Nothing is copied because it exists. Content ships only when registry.yaml
# declares it public. Files that are not referenced, and entries marked
# `visibility: private`, never leave this repository.
#
# --push commits and pushes the public repo. Without it, the export is staged
# and synced for review.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/overlay/config.sh" 2>/dev/null || true
# shellcheck source=lib/platform.sh
source "$ROOT_DIR/scripts/lib/platform.sh"
DENY_PATTERNS=("${DENY_PATTERNS[@]:-}")
: "${PUBLIC_REPO:=$HOME/Projects/ai-agent-policy}"
DO_PUSH="no"
[[ "${1:-}" == "--push" ]] && DO_PUSH="yes"

STAGE="$ROOT_DIR/dist/publish"
rm -rf "$STAGE"
mkdir -p "$STAGE"

"$ROOT_DIR/scripts/build.sh" public >/dev/null

# ---- registry: drop everything marked private -----------------------------
awk '
  function flush() { if (buf != "" && buf !~ /visibility: private/) printf "%s", buf; buf = "" }
  /^(  - |    id: |    kind: |    path: |    when: |    visibility: )/ { buf = buf $0 "\n"; next }
  { flush(); print }
  END { flush() }
' "$ROOT_DIR/registry.yaml" > "$STAGE/registry.yaml"

# ---- allowlist: only paths the public registry points at -------------------
# Two shapes exist: "- path: x" in the `always` list, and "path: x" as an entry
# field. Both must be read, or the export silently ships an empty catalog.
PUBLIC_PATHS="$(grep -E '^[[:space:]]+(- )?path: ' "$STAGE/registry.yaml" \
  | sed -E 's/^[[:space:]]+(- )?path:[[:space:]]*//; s/[[:space:]]+$//')"
if [[ -z "$PUBLIC_PATHS" ]]; then
  echo "error: public registry declares no paths" >&2
  exit 1
fi

shipped=0
while IFS= read -r p; do
  [[ -z "$p" ]] && continue
  if [[ ! -f "$ROOT_DIR/$p" ]]; then
    echo "error: registry path missing in dev repo: $p" >&2
    exit 1
  fi
  mkdir -p "$STAGE/$(dirname "$p")"
  cp "$ROOT_DIR/$p" "$STAGE/$p"
  shipped=$((shipped + 1))
done <<< "$PUBLIC_PATHS"

# ---- infrastructure needed to build and adopt --------------------------------
mkdir -p "$STAGE/base"
cp "$ROOT_DIR/base/contract.md" "$STAGE/base/contract.md"
cp -R "$ROOT_DIR/scripts" "$STAGE/scripts"
cp -R "$ROOT_DIR/templates" "$STAGE/templates"
mkdir -p "$STAGE/skills" && touch "$STAGE/skills/.gitkeep"
for f in LICENSE CHANGELOG.md README.md .gitignore; do
  [[ -f "$ROOT_DIR/$f" ]] && cp "$ROOT_DIR/$f" "$STAGE/$f"
done
cp "$ROOT_DIR/dist/public/AGENTS.md" "$STAGE/AGENTS.md"
cp "$ROOT_DIR/overlay/config.example.sh" "$STAGE/config.example.sh"

# ---- invariant: nothing in the catalog directories is unreferenced -----------
# The catalog is copied file by file, so this cannot fire today. It fires if
# someone later reintroduces a bulk copy, which is how private material leaks.
while IFS= read -r f; do
  rel="${f#"$STAGE"/}"
  grep -qxF "$rel" <<< "$PUBLIC_PATHS" || {
    echo "error: staged file not declared public: $rel" >&2
    exit 1
  }
done < <(find "$STAGE"/rules "$STAGE"/workflows "$STAGE"/skills -type f ! -name '.gitkeep' 2>/dev/null)

# ---- report what was withheld -----------------------------------------------
for dir in base/policy rules workflows skills; do
  [[ -d "$ROOT_DIR/$dir" ]] || continue
  while IFS= read -r f; do
    rel="${f#"$ROOT_DIR"/}"
    grep -qxF "$rel" <<< "$PUBLIC_PATHS" || echo "withheld  $rel"
  done < <(find "$ROOT_DIR/$dir" -type f ! -name '.gitkeep')
done

# ---- deny-list ---------------------------------------------------------------
# LICENSE is excluded: the copyright holder is meant to be published.
leaks=0
for pat in "${DENY_PATTERNS[@]}"; do
  [[ -z "$pat" ]] && continue
  hits="$(grep -rIni --exclude=LICENSE -- "$pat" "$STAGE" 2>/dev/null | head -5 || true)"
  if [[ -n "$hits" ]]; then
    echo "LEAK  pattern '$pat' found in staged output:" >&2
    echo "$hits" >&2
    leaks=1
  fi
done
[[ "$leaks" == 0 ]] || { echo "publish aborted: private content would be published." >&2; exit 1; }

# ---- sync --------------------------------------------------------------------
if [[ ! -d "$PUBLIC_REPO/.git" ]]; then
  echo "error: $PUBLIC_REPO is not a git repository" >&2
  echo "create it, or set PUBLIC_REPO in overlay/config.sh" >&2
  exit 1
fi

mirror "$STAGE" "$PUBLIC_REPO"
echo "shipped: $shipped registry paths, deny-list clean ($OS)"
echo "synced:  $PUBLIC_REPO"
git -C "$PUBLIC_REPO" status --short

if [[ "$DO_PUSH" == "yes" ]]; then
  if [[ -z "$(git -C "$PUBLIC_REPO" status --porcelain)" ]]; then
    echo "nothing to publish"
    exit 0
  fi
  git -C "$PUBLIC_REPO" add -A
  git -C "$PUBLIC_REPO" commit -m "chore: sync published template from dev"
  git -C "$PUBLIC_REPO" push
  echo "pushed"
else
  echo
  echo "review the diff, then re-run with --push"
fi
