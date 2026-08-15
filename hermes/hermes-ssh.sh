#!/bin/sh

export PATH="/opt/hermes/bin:/opt/hermes/.venv/bin:/opt/data/.local/bin:$PATH"
export HOME=/opt/data
export HERMES_HOME=/opt/data
export HERMES_TUI_DIR=/opt/hermes/ui-tui
export TERM=xterm-256color

if [ -f /etc/hermes-compose.env ]; then
    set -a
    . /etc/hermes-compose.env
    set +a
fi

exec hermes "$@"
