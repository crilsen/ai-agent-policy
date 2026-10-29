# shellcheck shell=bash
# Example configuration. Copy to overlay/config.sh and adjust.
# Values can be overridden by environment variables.
#
# overlay/ is optional: without it, build.sh resolves the central path to the
# repository root and everything stays generic.

: "${CENTRAL_DIR:=$HOME/Projects/ai-agent-policy}"
: "${RELAY_PATH:=$HOME/Projects/ai-agent-relay}"
: "${PUBLIC_REPO:=$HOME/Projects/ai-agent-policy-public}"
