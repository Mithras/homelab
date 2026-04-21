./llama-fit-params \
    --rpc 192.168.200.1:50052 \
    -dev CUDA0,RPC0 \
    -ngl all \
    --model /download/qwen3.5-122/UD-Q5_K_XL/Qwen3.5-122B-A10B-UD-Q5_K_XL-00001-of-00003.gguf \
    --fit-ctx 40000 \
    --fit-target 2048,0 \
    -ot "(attn_q\.|attn_k\.|attn_v\.|attn_output\.)=CUDA0" \
    -v


# qwen35
./llama-fit-params \
    --rpc 192.168.100.2:50052,192.168.0.2:50052 \
    -dev RPC1,RPC2,Vulkan0 \
    -ngl -1 \
    --model /download/qwen3.5-122/UD-Q4_K_XL/Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf \
    --fit-ctx 262144 \
    --fit-target 2048,0,0 \
    --tensor-split 90,80,100
