#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y

docker compose pull --ignore-pull-failures
docker compose up -d
docker system prune -af

# podman system df
podman system prune -af
