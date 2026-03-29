#!/bin/bash

docker compose pull --ignore-pull-failures
docker compose up -d
docker system prune -af --filter "label=mcp-npx" --filter "label=mcp-npx"
