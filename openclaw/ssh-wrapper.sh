#!/usr/bin/env sh
set -e

# Intercept all openclaw sandbox commands that touch shared volumes
if echo "$@" | grep -qE "openclaw-sandbox-(check|remove|clear)"; then
  echo "$@" >> ~/.openclaw/logs/ssh.log
  printf '1\n'
  exit 0
fi

exec ssh "$@"
