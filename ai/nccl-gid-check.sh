#!/bin/bash
# nccl-gid-check.sh — verify valid RoCEv2 GID index before starting vLLM
set -euo pipefail

HCAs=(rocep1s0f0 roceP2p1s0f0)
FOUND=0

for HCA in "${HCAs[@]}"; do
  printf "=== %s ===\n" "$HCA"
  for i in $(seq 0 15); do
    t=$(cat /sys/class/infiniband/${HCA}/ports/1/gid_attrs/types/${i} 2>/dev/null || true)
    g=$(cat /sys/class/infiniband/${HCA}/ports/1/gids/${i} 2>/dev/null || true)
    if [[ "$t" == *"RoCE v2"* ]] && [[ "$g" == *0000:0000:0000:0000:0000:ffff:* ]]; then
      printf "%-20s idx=%-2d gid=%s ✓\n" "$HCA" "$i" "$g"
    fi
  done
done
