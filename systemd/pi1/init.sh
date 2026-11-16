#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/homelab"

source "$BASE/systemd/lib/ssh.sh"


# Hermes voice
mkdir -p "$BASE/hermes-voice/.ssh"
ensure_known_hosts "$BASE/hermes-voice/.ssh/known_hosts" '192.168.2.208' '/etc/ssh'
ensure_key "$BASE/hermes-voice/.ssh/id_rsa" rsa 4096

# Manual
# `cat /home/mithras/homelab/hermes-voice/.ssh/id_rsa.pub >> /home/mithras/.ssh/authorized_keys`
# rsync -a --delete --info=progress2 /home/mithras/homelab/hermes-voice/.ssh/ mithras@192.168.1.4:/home/mithras/homelab/hermes-voice/.ssh/
