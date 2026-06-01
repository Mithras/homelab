#!/bin/bash

docker build . --target agent --tag openclaw-workspace:agent
docker build . --target full --tag openclaw-workspace:full
