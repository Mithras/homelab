FROM ubuntu as base

RUN apt-get update \
    && apt-get -y install curl git cmake libibverbs-dev ibverbs-utils rdma-core


# Vulkan
RUN curl -sSL https://packages.lunarg.com/lunarg-signing-key-pub.asc > /etc/apt/trusted.gpg.d/lunarg.asc \
    && curl -sSL http://packages.lunarg.com/vulkan/lunarg-vulkan-noble.list > /etc/apt/sources.list.d/lunarg-vulkan-noble.list \
    && apt-get update \
    && apt-get -y install vulkan-sdk


# HIP (https://rocm.nightlies.amd.com/tarball/ -> "linux-gfx1151")
# https://repo.amd.com/rocm/tarball/
ARG AMDGPU_FAMILY=gfx1151
ARG VERSION=7.13.0a20260328
ARG RELEASE_TYPE=nightlies
# ARG VERSION=7.11.0
# ARG RELEASE_TYPE=stable

# Install system dependencies (auto-detects the distribution and uses the appropriate package manager)
RUN curl -sSL https://raw.githubusercontent.com/ROCm/TheRock/main/dockerfiles/install_rocm_deps.sh | \
    bash -s -- \
    "$VERSION" \
    "$AMDGPU_FAMILY" \
    "$RELEASE_TYPE"

# Install ROCm from tarball (extracts to /opt/rocm-{VERSION}/, with symlink /opt/rocm -> /opt/rocm-{VERSION})
RUN curl -sSL https://raw.githubusercontent.com/ROCm/TheRock/main/dockerfiles/install_rocm_tarball.sh | \
    bash -s -- \
    "$VERSION" \
    "$AMDGPU_FAMILY" \
    "$RELEASE_TYPE"

# Configure environment variables
ENV ROCM_PATH=/opt/rocm \
    HIP_PATH=/opt/rocm \
    HIPCXX=/opt/rocm/llvm/bin/clang \
    PATH=/opt/rocm/bin:$PATH


# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#hip
FROM base as hip 

ARG AMDGPU_FAMILY=gfx1151

WORKDIR /opt/llama.cpp

RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp.git .
# RDMA: https://github.com/ggml-org/llama.cpp/pull/20590
RUN curl -sL https://github.com/ggerganov/llama.cpp/pull/20590.patch | git apply -v # 2

# Build: https://github.com/ggml-org/llama.cpp/blob/master/.github/workflows/release.yml#L684
RUN cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_TESTS=OFF \
    -DGGML_HIP=ON \
    -DHIP_PLATFORM=amd \
    -DGPU_TARGETS="$AMDGPU_FAMILY" \
    -DGGML_HIP_ROCWMMA_FATTN=ON \
    -DGGML_RPC=ON \
    -DGGML_RPC_RDMA=ON \
    && cmake --build build --config Release -j $(nproc) \
    && cmake --install build --config Release
# -DGGML_CUDA_ENABLE_UNIFIED_MEMORY=ON \

# LD
RUN echo "/opt/rocm/lib" > /etc/ld.so.conf.d/local.conf \
    && ldconfig

WORKDIR /usr/local/bin

CMD ["/bin/bash"]


# https://github.com/ggml-org/llama.cpp/blob/master/docs/build.md#for-linux-users
FROM base as vulkan

WORKDIR /opt/llama.cpp

RUN git clone --depth 1 https://github.com/ggerganov/llama.cpp.git .
# RDMA: https://github.com/ggml-org/llama.cpp/pull/20590
RUN curl -sL https://github.com/ggerganov/llama.cpp/pull/20590.patch | git apply -v # 2

# Build: https://github.com/ggml-org/llama.cpp/blob/master/.github/workflows/release.yml#L205
RUN cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLAMA_BUILD_TESTS=OFF \
    -DGGML_VULKAN=ON \
    -DGGML_HIP_ROCWMMA_FATTN=ON \
    -DGGML_CUDA_ENABLE_UNIFIED_MEMORY=ON \
    -DGGML_RPC=ON \
    -DGGML_RPC_RDMA=ON \
    && cmake --build build --config Release -j $(nproc) \
    && cmake --install build --config Release
    # -DCMAKE_INSTALL_RPATH='$ORIGIN' \
    # -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \

# LD
RUN echo "/opt/rocm/lib" > /etc/ld.so.conf.d/local.conf \
    && ldconfig

WORKDIR /usr/local/bin

CMD ["/bin/bash"]

# LD_PRELOAD=libvma.so
