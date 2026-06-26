#!/bin/bash
set -e

for p in mithras dina; do
    mkdir -p "./${p}/.config/brv"
    ln -f "./config.yaml" "./${p}/config.yaml"
    ln -f "./brv-providers.json" "./${p}/.config/brv/providers.json"
done
