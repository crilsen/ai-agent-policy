# Project template

The per-project context layer is maintained as its own repository and copied in by
`scripts/new-project.sh`, which reads `RELAY_PATH` from `overlay/config.sh`. It is
deliberately not vendored here, so there is one upstream instead of two copies
drifting apart.

A project's `AGENTS.md` points back at this repository, so a new session in a fresh
clone finds the contract without any chat history.
