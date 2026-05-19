#!/usr/bin/env sh
set -e

# echo "$@" >> ~/.openclaw/logs/ssh.log
if echo "$@" | grep -q "openclaw-sandbox-check"; then
  # echo "    short circuit openclaw-sandbox-check" >> ~/.openclaw/logs/ssh.log
  printf '1\n'
  exit 0
fi

exec ssh "$@"
