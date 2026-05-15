#!/bin/bash

# DOCKER_BUILDKIT=1 docker build . --tag opencode
DOCKER_BUILDKIT=1 docker build . --tag opencode --pull --no-cache

docker volume rm opencode
