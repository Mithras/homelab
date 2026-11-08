#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/homelab"
APP="spark-worker"
APP_DIR="$BASE/systemd/$APP"

source "$BASE/systemd/lib/quadlet.sh"

# Systemd
qd_init "$APP"
qd_link_dir "$APP_DIR"
if [ "${1:-}" = "--systemd" ]; then
    qd_sweep
    qd_apply "$APP.target"
fi


# /usr/lib/systemd/system-generators/podman-system-generator --user --dryrun
# systemctl --user list-dependencies spark-worker.target
# journalctl --user -u xxx --no-pager -n 100
