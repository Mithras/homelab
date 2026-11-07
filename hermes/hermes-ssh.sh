#!/bin/sh

PATH="/command" \
exec with-contenv env \
    HOME=/opt/data \
    TERM=xterm-256color \
    HERMES_TUI_DIR=/opt/hermes/ui-tui \
    hermes "$@"
