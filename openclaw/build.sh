#!/usr/bin/env sh
set -e

OLD_SSH_BACKEND_SHA="24ae9a187d3cea362e52d122747264f83c877c5f7f83a1c243d6d0a04cb6797e"
NEW_SSH_BACKEND_SHA=$(curl -sL "https://raw.githubusercontent.com/openclaw/openclaw/main/src/agents/sandbox/ssh-backend.ts" | sha256sum | awk '{print $1}')
if [ "$NEW_SSH_BACKEND_SHA" != "$OLD_SSH_BACKEND_SHA" ]; then
  echo "⚠️  ssh-backend.ts has changed! Review https://github.com/openclaw/openclaw/blob/main/src/agents/sandbox/ssh-backend.ts and make sure ssh-wrapper.sh still works."
  exit 1
fi

DOCKER_BUILDKIT=1 docker build . --pull --tag openclaw:$(date +%Y%m%d)
# DOCKER_BUILDKIT=1 docker build . --tag openclaw:$(date +%Y%m%d)
