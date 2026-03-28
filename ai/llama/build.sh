#!/usr/bin/env bash
set -e

if [ ! -d 'llama.cpp' ]; then
    git clone --depth 1 https://github.com/ggerganov/llama.cpp.git
fi

pushd llama.cpp

git reset --hard HEAD
git clean -fdx
git pull

# RPC: git format-patch -1 HEAD
git apply ../0001-RPC.patch

# RDMA: https://github.com/ggml-org/llama.cpp/pull/20590
curl -sL https://github.com/ggerganov/llama.cpp/pull/20590.patch | git apply

if [[ "$(uname -n)" == "ms-s1-max-0" || "$(uname -n)" == "ms-s1-max-1" ]]; then
    docker build . \
        -f .devops/vulkan.Dockerfile \
        --target server \
        --tag llama:server-vulkan
    docker build . \
        -f .devops/rocm.Dockerfile \
        --target server \
        --tag llama:server-rocm
elif [[ "$(uname -n)" == "mithras-pc" ]]; then
    docker build . \
        -f .devops/cuda-new.Dockerfile \
        --target server \
        --tag llama:server-cuda
else
    echo "Unknown environment."
fi

popd
