#!/bin/bash

podman build https://github.com/MiaAI-Lab/DeepSeek-v4.1-Flash-1017-2x-DGX-Sparks.git#31457d05f8917301bbf609c3d12c7f364af8a4a6 \
    -f zig/Dockerfile \
    -t tensorfold-dsv41:exl3-tp2-03d5b88f05ef \
    --build-arg BASE_IMAGE=nvcr.io/nvidia/pytorch:26.07-py3 \
    --build-arg TF_REPO=https://github.com/bertholomus/TensorFold.git \
    --build-arg TF_REF=fbbc97132cd004237d9887b8d3185896efaedc5c \
    --build-arg INPUTS_REF=59402086381a42c74d53053443224eec2790b4c5 \
    --build-arg ZIG_VERSION=0.17.0 \
    --build-arg ZIG_SHA256=9e8d11661d4ae3bd57702a3832781e23ad151dde5798e16a5ccd503f65234ff8 \
    --build-arg ZIG_MIRRORS=https://zig.linus.dev/zig \
    --build-arg PATCHES_HASH=03d5b88f05ef

# podman save tensorfold-dsv41:exl3-tp2-03d5b88f05ef | ssh mithras@192.168.1.9 podman load
