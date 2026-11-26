#!/bin/sh

PATH=/command \
exec with-contenv env \
    HOME=/opt/data \
    TERM=xterm-256color \
    HERMES_TUI_DIR=/opt/hermes/ui-tui \
    LANG=C.UTF-8 \
    tmux set -s default-terminal xterm-256color \; set -g default-command /bin/bash \; new -As hermes hermes
