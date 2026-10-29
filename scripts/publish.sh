#!/usr/bin/env bash
# Export the public template: base/ only, private overlay stripped,
# private registry entries removed, deny-list enforced.
# Never writes to the private repo. --push commits and pushes the public repo.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/overlay/config.sh" 2>/dev/null || true
DENY_PATTERNS=("${DENY_PATTERNS[@]:-}")
: "${PUBLIC_REPO:=$HOME/Projects/agent-policy-public}"
PUBLIC_REPO="${PUBLIC_REPO:-$HOME/Projects/agent-policy-public}"
DO_PUSH="no"
[[ "${1:-}" == "--push" ]] && DO_PUSH="yes"

STAGE="$ROOT_DIR/dist/publish"
rm -rf "$STAGE"
mkdir -p "$STAGE"

"$ROOT_DIR/scripts/build.sh" public

# ---- allowlist copy -------------------------------------------------------
for item in base rules workflows skills scripts templates; do
  cp -R "$ROOT_DIR/$item" "$STAGE/"
done
cp "$ROOT_DIR/LICENSE" "$STAGE/" 2>/dev/null || true
cp "$ROOT_DIR/CHANGELOG.md" "$STAGE/" 2>/dev/null || true
cp "$ROOT_DIR/README.md" "$STAGE/" 2>/dev/null || true
cp "$ROOT_DIR/.gitignore" "$STAGE/" 2>/dev/null || true
cp "$ROOT_DIR/dist/public/AGENTS.md" "$STAGE/AGENTS.md"
cp "$ROOT_DIR/overlay/config.example.sh" "$STAGE/config.example.sh"

# ---- strip private registry entries --------------------------------------
awk '
  function flush() { if (buf != "" && buf !~ /visibility: private/) printf "%s", buf; buf = "" }
  /^(  - |    id: |    kind: |    path: |    when: |    visibility: )/ { buf = buf $0 "\n"; next }
  { flush(); print }
  END { flush() }
' "$ROOT_DIR/registry.yaml" > "$STAGE/registry.yaml"

# ---- deny-list -----------------------------------------------------------
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
if [[ "$leaks" != 0 ]]; then
  echo "publish aborted: private content would be published." >&2
  exit 1
fi
echo "deny-list: clean"

# ---- sync ---------------------------------------------------------------
if [[ ! -d "$PUBLIC_REPO/.git" ]]; then
  echo "error: $PUBLIC_REPO is not a git repository" >&2
  echo "create it, or set PUBLIC_REPO in overlay/config.sh" >&2
  exit 1
fi

rsync -a --delete --exclude '.git/' "$STAGE/" "$PUBLIC_REPO/"
echo "synced -> $PUBLIC_REPO"
git -C "$PUBLIC_REPO" status --short

if [[ "$DO_PUSH" == "yes" ]]; then
  if [[ -z "$(git -C "$PUBLIC_REPO" status --porcelain)" ]]; then
    echo "nothing to publish"
    exit 0
  fi
  git -C "$PUBLIC_REPO" add -A
  git -C "$PUBLIC_REPO" commit -m "chore: publish template from private policy"
  git -C "$PUBLIC_REPO" push
  echo "pushed"
else
  echo
  echo "review the diff, then re-run with --push"
fi
