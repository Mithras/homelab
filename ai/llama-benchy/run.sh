#!/bin/bash

docker run -it --rm \
    -v llama-benchy-cache:/home/llama-benchy/.cache \
    --network host \
    llama-benchy \
    --pp 2048 \
    --tg 128 \
    --concurrency 1 \
    --depth 16384 \
    "$@"

# ./run.sh --base-url 'http://localhost:8000/v1' --model 'deepseek-v4-flash-0731'
# ./run.sh --base-url 'http://mithras-pc:8001/v1' --model 'qwen38-27'
