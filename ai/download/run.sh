#!/bin/bash

docker run -it --rm -v ./download:/download hf-cli /bin/bash

# hf download 'unsloth/MiniMax-M2.5-GGUF' --local-dir /download/minimax-m2.5 --include 'UD-Q4_K_XL/*'
# hf download 'unsloth/Qwen3.5-397B-A17B-GGUF' --local-dir /download/qwen3.5 --include 'UD-Q4_K_XL/*'

# hf download 'unsloth/Qwen3.5-122B-A10B-GGUF' --local-dir /download/qwen3.5-122 --include 'UD-Q5_K_XL/*'
# hf download 'unsloth/Qwen3.5-122B-A10B-GGUF' --local-dir /download/qwen3.5-122 --include 'mmproj-BF16.gguf'

# hf download 'unsloth/Qwen3.5-27B-GGUF' --local-dir /download/qwen3.5-27 --include 'Qwen3.5-27B-UD-Q5_K_XL.gguf'
# hf download 'unsloth/Qwen3.5-27B-GGUF' --local-dir /download/qwen3.5-27 --include 'mmproj-BF16.gguf'

# hf download 'unsloth/Qwen3.5-0.8B-GGUF' --local-dir /download/qwen3.5-0.8 --include 'Qwen3.5-0.8B-UD-Q5_K_XL.gguf'

# hf download 'unsloth/Qwen3.6-35B-A3B-GGUF' --local-dir /download/qwen3.6-35 --include 'Qwen3.6-35B-A3B-UD-Q5_K_XL.gguf'
# hf download 'unsloth/Qwen3.6-35B-A3B-GGUF' --local-dir /download/qwen3.6-35 --include 'mmproj-BF16.gguf'


# docker run -it --rm -v ./download/download:/download --entrypoint /bin/bash ghcr.io/ggml-org/llama.cpp:full
#   ./llama-gguf-split --merge /download/gpt-oss-120b/Q4_K_M/gpt-oss-120b-Q4_K_M-00001-of-00002.gguf /download/gpt-oss-120b-Q4_K_M.gguf
#   ./llama-gguf-split --merge /download/minimax-m2.5/UD-Q4_K_XL/MiniMax-M2.5-UD-Q4_K_XL-00001-of-00004.gguf /download/UD-Q4_K_XL/MiniMax-M2.5-UD-Q4_K_XL.gguf
