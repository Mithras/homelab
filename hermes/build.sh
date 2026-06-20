#!/usr/bin/env sh
set -e

DOCKER_BUILDKIT=1 docker build . --pull --tag hermes-agent --tag hermes-agent:$(date +%Y%m%d)
