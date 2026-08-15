#!/bin/bash

docker compose pull --ignore-pull-failures
docker compose up -d
docker system prune -af # --filter "xxx"
