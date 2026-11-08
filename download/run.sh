#!/bin/bash

podman run -it --rm --env-file .env -v ./download:/download hf-cli /bin/bash

# hf download 'istupakov/parakeet-tdt-0.6b-v3-onnx' --local-dir /download/parakeet-tdt-0.6b-v3-onnx --include '*'

# hf download 'nvidia/Qwen3.6-35B-A3B-NVFP4' --local-dir ./download/nvidia/Qwen3.6-35B-A3B-NVFP4

# ---

# curl -sL -o download/glm_chat_template.jinja https://raw.githubusercontent.com/MiaAI-Lab/GLM-5.3-Flash-EXL3-2x-DGX-Sparks/refs/heads/main/files/chat_template.jinja

# rsync -a --delete --append-verify --info=progress2 /home/mithras/homelab/ai/download/download/ mithras@192.168.100.2:/home/mithras/homelab/ai/download/download/

# podman run -it --rm -v ./download/download:/download --entrypoint /bin/bash ghcr.io/ggml-org/llama.cpp:full
#   ./llama-gguf-split --merge /download/gpt-oss-120b/Q4_K_M/gpt-oss-120b-Q4_K_M-00001-of-00002.gguf /download/gpt-oss-120b-Q4_K_M.gguf
#   ./llama-gguf-split --merge /download/minimax-m2.5/UD-Q4_K_XL/MiniMax-M2.5-UD-Q4_K_XL-00001-of-00004.gguf /download/UD-Q4_K_XL/MiniMax-M2.5-UD-Q4_K_XL.gguf
