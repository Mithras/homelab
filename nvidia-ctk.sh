#!/bin/bash
set -euo pipefail

sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml

# cdiVersion 0.7.0 -> 0.6.0 for podman 4.9.3
# sudo python3 - <<'PY'
# import os, yaml
# def strip(o):
#     if isinstance(o, dict):
#         o.pop('additionalGids', None); o.pop('intelRdt', None)
#         for v in o.values(): strip(v)
#     elif isinstance(o, list):
#         for v in o: strip(v)
# for p in ('/etc/cdi/nvidia.yaml', '/var/run/cdi/nvidia.yaml'):
#     if not os.path.exists(p):
#         print('absent', p); continue
#     s = yaml.safe_load(open(p))
#     s['cdiVersion'] = '0.6.0'
#     strip(s)
#     yaml.safe_dump(s, open(p, 'w'), sort_keys=False)
#     print('patched', p, s['cdiVersion'])
# PY

# podman run --rm --device nvidia.com/gpu=all --entrypoint sh \
#   localhost/tensorfold-dsv41:exl3-tp2-03d5b88f05ef -c 'nvidia-smi -L'
