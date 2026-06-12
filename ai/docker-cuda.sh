#!/bin/bash

sudo nvidia-ctk runtime configure --runtime=docker
sudo nvidia-ctk cdi generate --output=/etc/cdi/nvidia.yaml
sudo nvidia-ctk config --in-place --set nvidia-container-runtime.mode=cdi

sudo tee /etc/systemd/system/docker.service.d/after-nvidia.conf > /dev/null << 'EOF'
[Unit]
After=modprobe@nvidia.conf
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
