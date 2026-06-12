#!/usr/bin/env sh
set -e

OLD_SSH_BACKEND_SHA="7134fceb3403afb9b78eea851ff1a3518afd1bc1dece68c8493656a2afa6c292"
NEW_SSH_BACKEND_SHA=$(curl -sL "https://raw.githubusercontent.com/openclaw/openclaw/main/src/agents/sandbox/ssh-backend.ts" | sha256sum | awk '{print $1}')
if [ "$NEW_SSH_BACKEND_SHA" != "$OLD_SSH_BACKEND_SHA" ]; then
  echo "⚠️  ssh-backend.ts has changed! Review https://github.com/openclaw/openclaw/blob/main/src/agents/sandbox/ssh-backend.ts and make sure ssh-wrapper.sh still works."
  echo "      NEW_SSH_BACKEND_SHA: $NEW_SSH_BACKEND_SHA"
  exit 1
fi

DOCKER_BUILDKIT=1 docker build . --pull --tag openclaw:$(date +%Y%m%d)
# DOCKER_BUILDKIT=1 docker build . --tag openclaw:$(date +%Y%m%d)
