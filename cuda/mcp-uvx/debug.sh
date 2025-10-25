#!/bin/bash

docker run -it --rm \
    -v $PWD:/home/mcp \
    --entrypoint /bin/bash \
    mcp-uvx
