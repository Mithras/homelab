#!/bin/bash

docker run -it --rm \
    -v llama-benchy-cache:/home/llama-benchy/.cache \
    --network host \
    llama-benchy \
    --pp 2048 \
    --tg 128 \
    --concurrency 1 \
    --depth 16384 65536 131072 \
    "$@"

# ./run.sh --base-url 'http://localhost:8080/v1' --model 'qwen36-27'
# ./run.sh --base-url 'http://localhost:8000/v1' --model 'Qwen/Qwen3.6-35B-A3B-FP8'
