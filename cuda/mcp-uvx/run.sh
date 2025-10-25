#!/bin/bash

docker run -i --rm \
    -v $PWD:/home/mcp \
    mcp-uvx \
    "$@"
