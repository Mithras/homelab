FROM python

RUN pip install -U "huggingface_hub[cli]"

# docker build . --tag hf-cli

# docker run -it --rm -v ./download:/download hf-cli /bin/bash
#   hf download 'unsloth/GLM-4.5-Air-GGUF' --local-dir /download --include 'IQ4_XS/*'
#   hf download 'unsloth/gpt-oss-120b-GGUF' --local-dir /download/gpt-oss-120b --include 'Q4_K_M/*'

# docker run -it --rm -v ./download:/download --entrypoint /bin/bash ghcr.io/ggml-org/llama.cpp:full
#   ./llama-gguf-split --merge /download/IQ4_XS/GLM-4.5-Air-IQ4_XS-00001-of-00002.gguf /download/IQ4_XS/GLM-4.5-Air-IQ4_XS.gguf
#   ./llama-gguf-split --merge /download/gpt-oss-120b/Q4_K_M/gpt-oss-120b-Q4_K_M-00001-of-00002.gguf /download/gpt-oss-120b/Q4_K_M/gpt-oss-120b-Q4_K_M.gguf
