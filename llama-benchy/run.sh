#!/bin/bash

podman run -it --rm \
    -v llama-benchy-cache:/home/llama-benchy/.cache \
    --network host \
    llama-benchy \
    --pp 2048 \
    --tg 256 \
    --exact-tg \
    --depth 16384 \
    --enable-prefix-caching \
    --concurrency 1 2 3 \
    --latency-mode generation \
    --runs 2 \
    "$@"

# ./run.sh --base-url 'http://mithras-pc:8000/v1' --model 'qwen3.6-35b-a3b'
# ./run.sh --base-url 'http://localhost:8000/v1' --model 'deepseek-v41-flash-1017'
