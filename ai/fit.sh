# minimax-m25
./llama-fit-params \
    --rpc 192.168.100.2:50052,192.168.0.2:50052 \
    -dev RPC1,RPC2,Vulkan0,RPC0 \
    -ngl -1 \
    --model /download/minimax-m2.5/UD-Q4_K_XL/MiniMax-M2.5-UD-Q4_K_XL-00001-of-00004.gguf \
    --fit-ctx 196608 \
    --fit-target 2048,0,0,0 \
    --tensor-split 35,35,100,100
# -ot "(attn|ffn_norm|ffn_gate_inp)=RPC0[192.168.0.2:50052]" \
# -v


# gpt-oss
./llama-fit-params \
    --rpc 192.168.100.2:50052,192.168.0.2:50052 \
    -dev RPC1,RPC2,Vulkan0 \
    -ngl -1 \
    --model /download/gpt-oss-120b/Q4_K_M/gpt-oss-120b-Q4_K_M-00001-of-00002.gguf \
    --fit-ctx 131072 \
    --fit-target 2048,0,0 \
    --tensor-split 35,30,30


# step35-flash
./llama-fit-params \
    --rpc 192.168.100.2:50052,192.168.0.2:50052 \
    -dev RPC1,RPC2,Vulkan0,RPC0 \
    -ngl -1 \
    --model /download/step35-flash/stepfun-ai_Step-3.5-Flash-Q4_K_L/stepfun-ai_Step-3.5-Flash-Q4_K_L-00001-of-00004.gguf \
    --fit-ctx 262144 \
    --fit-target 2048,0,0,0 \
    --tensor-split 30,20,50,50


# qwen35
./llama-fit-params \
    --rpc 192.168.100.2:50052,192.168.0.2:50052 \
    -dev RPC1,RPC2,Vulkan0 \
    -ngl -1 \
    --model /download/qwen3.5-122/UD-Q4_K_XL/Qwen3.5-122B-A10B-UD-Q4_K_XL-00001-of-00003.gguf \
    --fit-ctx 262144 \
    --fit-target 2048,0,0 \
    --tensor-split 90,80,100
