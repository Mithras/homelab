#!/bin/bash

sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y

podman system prune -af

# podman system df


# sudo loginctl enable-linger mithras
# loginctl show-user mithras | grep Linger
