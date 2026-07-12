#!/bin/bash

docker build . --target agent --tag sandbox:agent
docker build . --target full --tag sandbox:full
