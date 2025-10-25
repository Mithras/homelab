#!/bin/bash

docker compose pull
docker compose up -d
docker system prune -af --filter "label=mcp-npx" --filter "label=mcp-npx"

# pushd mcp-npx
# ./build.sh
# popd

# pushd mcp-uvx
# ./build.sh
# popd
