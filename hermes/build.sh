#!/usr/bin/env sh
set -e

podman build . --tag hermes-agent --tag hermes-agent:$(date +%Y%m%d) --pull
