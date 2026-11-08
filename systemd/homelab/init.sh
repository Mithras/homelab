#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

BASE="$HOME/homelab"
APP="homelab"
APP_DIR="$BASE/systemd/$APP"
PROFILES_DIR="$APP_DIR/profiles"

source "$BASE/systemd/lib/quadlet.sh"


ensure_host_keys() {
    local dir="$1" t
    mkdir -p "$dir" && chmod 700 "$dir"
    for t in ed25519 ecdsa rsa; do
        [ -f "$dir/ssh_host_${t}_key" ] || ssh-keygen -t "$t" -f "$dir/ssh_host_${t}_key" -N '' -q
    done
}

ensure_key() {
    [ -f "$1" ] || ssh-keygen -t "$2" -b "$3" -f "$1" -N '' -q
    chmod 600 "$1"
}

ensure_known_hosts() {
    local out="$1" host="$2" dir="$3" key
    rm -f "$out" "$out.old"
    for key in "$dir/"*.pub; do
        printf '[%s]:2222 ' "$host" >> "$out"
        cat "$key" >> "$out"
    done
    ssh-keygen -H -f "$out" 2>/dev/null
    rm -f "$out.old"
    chmod 600 "$out"
}

HERMES="$BASE/hermes"
SANDBOX="$BASE/sandbox"
BROWSER="$BASE/browser"

COMPONENT_DIRS=("$BROWSER/quadlet" "$SANDBOX/quadlet" "$HERMES/quadlet")
QUADLET_DIRS=("${COMPONENT_DIRS[@]}" "$APP_DIR" "$BASE/firecrawl/quadlet" "$BASE/litellm/quadlet")

PROFILE_DIRS=("$PROFILES_DIR"/*/)
for profile_dir in "${PROFILE_DIRS[@]}"; do
    profile="$(basename "$profile_dir")"
    PROFILE_ROOT="$HERMES/$profile"

    # rm -rf "$PROFILE_ROOT/skills"
    mkdir -p "$PROFILE_ROOT"/{cache,kanban,plans,price-watches}

    # Gateway SSH
    ensure_host_keys "$HERMES/.ssh/$profile/host_keys"
    ensure_key "$HERMES/.ssh/$profile/id_rsa" rsa 4096

    # Sandbox
    if [ -f "$profile_dir/sandbox.conf" ]; then
        # Config
        echo 'TERMINAL_SSH_HOST=sandbox' > "$PROFILE_ROOT/.env"
        echo 'TERMINAL_SSH_USER=hermes' >> "$PROFILE_ROOT/.env"
        echo 'TERMINAL_SSH_PORT=2222' >> "$PROFILE_ROOT/.env"
        # echo "TERMINAL_SSH_KEY=~/.ssh/id_rsa" >> "$PROFILE_ROOT/.env"

        # SSH
        ensure_host_keys "$SANDBOX/.ssh/$profile/host_keys"
        ensure_known_hosts "$SANDBOX/.ssh/$profile/known_hosts" 'sandbox' "$SANDBOX/.ssh/$profile/host_keys"
        ensure_key "$SANDBOX/.ssh/$profile/id_rsa" rsa 4096
    fi

    # Browser
    if [ -f "$profile_dir/browser.conf" ]; then
        mkdir -p "$BROWSER/config/$profile"
    fi
done

# Systemd
qd_init "$APP"

for d in "${QUADLET_DIRS[@]}"; do
    qd_link_dir "$d"
done

for profile_dir in "${PROFILE_DIRS[@]}"; do
    profile="$(basename "$profile_dir")"
    for quadlet_dir in "${COMPONENT_DIRS[@]}"; do
        comp="$(basename "$(dirname "$quadlet_dir")")"
        conf="$profile_dir/$comp.conf"
        [ -f "$conf" ] && {
            qd_link_instance "$comp@.container" "$comp@$profile.container"
            qd_link_conf "$conf" "$comp@$profile.container"
        }
    done
    [ -f "$profile_dir/sandbox.conf" ] && qd_link_instance "sandbox@.network" "sandbox@$profile.network"
    [ -f "$profile_dir/browser.conf" ] && qd_link_instance "browser@.network" "browser@$profile.network"
done

if [ "${1:-}" = "--systemd" ]; then
    qd_sweep
    qd_apply "$APP.target"
fi


# /usr/lib/systemd/system-generators/podman-system-generator --user --dryrun
# systemctl --user list-dependencies homelab.target
# journalctl --user -u xxx --no-pager -n 100

# find ~/homelab -name '*.env' -exec chmod 600 {} +

# rsync -ax --delete --info=progress2 /home/mithras/homelab/ mithras@192.168.1.2:/home/mithras/Documents/backup/ubuntu1/homelab/


# TODO: migrate other hosts to podman
#  +. get rid of quadlet/systemd/ and link directly into host systemd dir
#  +. restructure into systemd/<host>/{a.container|b.target|c.network|init.sh|profiles}
#  +. extract reusable helpers from systemd/homelab/init.sh; systemd/homelab/init.sh becomes homelab specific; profiles stay homelab specific; helpers go into systemd/lib/
#  4. add systemd/pc/ with quadlets and init.sh (no profiles); move dirs from ai as needed
#  5. add other hosts; move dirs from ai as needed

# TODO: add kaicho
