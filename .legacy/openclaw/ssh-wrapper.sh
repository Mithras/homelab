#!/usr/bin/env sh
set -e

# Intercept and short circut `check` and `remove`
if echo "$@" | grep -qE "openclaw-sandbox-(check|remove)"; then
  echo "$@" >> ~/.openclaw/logs/ssh.log
  echo "" >> ~/.openclaw/logs/ssh.log
  printf '1\n'
  exit 0
fi

# Intercept and short circut `clear` for non-skills paths
if echo "$@" | grep -q "openclaw-sandbox-clear" && echo "$@" | grep -qv "sandbox-skills"; then
  echo "$@" >> ~/.openclaw/logs/ssh.log
  echo "" >> ~/.openclaw/logs/ssh.log
  printf '1\n'
  exit 0
fi

# Intercept and short circut `upload` for non-skills paths
if echo "$@" | grep -q "openclaw-sandbox-upload" && echo "$@" | grep -qv "sandbox-skills"; then
  echo "$@" >> ~/.openclaw/logs/ssh.log
  echo "" >> ~/.openclaw/logs/ssh.log
  exec cat >/dev/null
fi

exec ssh "$@"
