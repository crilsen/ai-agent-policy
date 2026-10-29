# shellcheck shell=bash
# Single source of harness destinations, shared by install.sh, import.sh and
# doctor.sh so the three can never disagree.
#
# format: tool|generated file (relative to repo root)|global destination

[[ -n "${TARGETS_LOADED:-}" ]] && return 0
TARGETS_LOADED=1

TARGETS=(
  "opencode|dist/opencode/AGENTS.md|$HOME/.config/opencode/AGENTS.md"
  "claude|dist/claude/CLAUDE.md|$HOME/.claude/CLAUDE.md"
  "codex|dist/codex/AGENTS.md|$HOME/.codex/AGENTS.md"
  "gemini|dist/gemini/GEMINI.md|$HOME/.gemini/GEMINI.md"
  "cursor|dist/cursor/rules/agent-policy.mdc|$HOME/.cursor/rules/agent-policy.mdc"
)
