#!/usr/bin/env bash
set -euo pipefail

PROFILES=(mithras dina mom)

for p in "${PROFILES[@]}"; do
    PROFILE_ROOT="./${p}"

    ln -f "./config.yaml" "$PROFILE_ROOT/config.yaml"

    mkdir -p "$PROFILE_ROOT/.config/brv"
    ln -f "./brv-providers.json" "$PROFILE_ROOT/.config/brv/providers.json"

    mkdir -p "$PROFILE_ROOT/.ssh"
    cp -f "../sandbox/config/.ssh/id_rsa" "$PROFILE_ROOT/.ssh/id_rsa"
    chmod 600 "$PROFILE_ROOT/.ssh/id_rsa"

    if [ ! -f "$PROFILE_ROOT/.ssh/ssh_host_ed25519_key" ]; then
        ssh-keygen -t ed25519 -f "$PROFILE_ROOT/.ssh/ssh_host_ed25519_key" -N ""
    fi

    if [ ! -f "$PROFILE_ROOT/.ssh/id_hermes" ]; then
        ssh-keygen -t ed25519 -f "$PROFILE_ROOT/.ssh/id_hermes" -N "" -C "hermes@hermes-$p"
        cp "$PROFILE_ROOT/.ssh/id_hermes.pub" "$PROFILE_ROOT/.ssh/authorized_keys"
    fi
done
