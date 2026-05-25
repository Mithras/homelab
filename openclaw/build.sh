#!/usr/bin/env sh
set -e

OLD_SSH_BACKEND_SHA="18f388770c0dff1e0b35e86d4b9d6af668ab74e2cdb746be221db890767babab"
NEW_SSH_BACKEND_SHA=$(curl -sL "https://raw.githubusercontent.com/openclaw/openclaw/main/src/agents/sandbox/ssh-backend.ts" | sha256sum | awk '{print $1}')
if [ "$NEW_SSH_BACKEND_SHA" != "$OLD_SSH_BACKEND_SHA" ]; then
  echo "⚠️  ssh-backend.ts has changed! Review https://github.com/openclaw/openclaw/blob/main/src/agents/sandbox/ssh-backend.ts and make sure ssh-wrapper.sh still works."
  exit 1
fi

DOCKER_BUILDKIT=1 docker build . --pull --tag openclaw
# DOCKER_BUILDKIT=1 docker build . --tag openclaw
