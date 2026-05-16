#!/bin/bash

DOCKER_BUILDKIT=1 docker build . --pull --tag openclaw
# DOCKER_BUILDKIT=1 docker build . --tag openclaw
