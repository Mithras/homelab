#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y

docker compose pull
docker compose up -d
docker image prune -af
docker volume prune -f
