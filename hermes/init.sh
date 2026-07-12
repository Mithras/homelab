#!/bin/bash
set -e

for p in mithras dina mom; do
    ln -f "./config.yaml" "./${p}/config.yaml"

    mkdir -p "./${p}/.config/brv"
    ln -f "./brv-providers.json" "./${p}/.config/brv/providers.json"

    mkdir -p "./${p}/.ssh"
    cp -f "../sandbox/config/.ssh/id_rsa" "./${p}/.ssh/id_rsa"
    chmod 600 "./${p}/.ssh/id_rsa"
done
