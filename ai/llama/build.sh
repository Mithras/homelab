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
git apply ../0001-RPC-RDMA.patch

# gfx1151: git format-patch -1 HEAD
git apply ../0001-gfx1151.patch

# XXX: https://github.com/ggml-org/llama.cpp/pull/XXX
# curl -sL https://github.com/ggerganov/llama.cpp/pull/XXX.patch | git apply

if [[ "$(uname -n)" == "ms-s1-max-0" || "$(uname -n)" == "ms-s1-max-1" ]]; then
    DOCKER_BUILDKIT=1 docker build . \
        -f .devops/vulkan.Dockerfile \
        --target server \
        --tag llama:server-vulkan
    DOCKER_BUILDKIT=1 docker build . \
        -f .devops/rocm.Dockerfile \
        --target server \
        --tag llama:server-rocm
elif [[ "$(uname -n)" == "mithras-pc" ]]; then
    # DOCKER_BUILDKIT=1 docker build . \
    #     -f .devops/vulkan.Dockerfile \
    #     --target server \
    #     --tag llama:server-vulkan
    DOCKER_BUILDKIT=1 docker build . \
        -f .devops/cuda.Dockerfile \
        --target server \
        --tag llama:server-cuda
else
    echo "Unknown environment."
fi

popd
