#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

BASE="$HOME/homelab"
PROFILES_DIR="$BASE/quadlet/profiles"

SYSTEMD=0; [ "${1:-}" = "--systemd" ] && SYSTEMD=1


ensure_host_keys() {
    local dir="$1" t
    mkdir -p "$dir" && chmod 700 "$dir"
    for t in ed25519 ecdsa rsa; do
        [ -f "$dir/ssh_host_${t}_key" ] || ssh-keygen -t "$t" -f "$dir/ssh_host_${t}_key" -N ''
    done
}

ensure_key() {
    [ -f "$1" ] || ssh-keygen -t "$2" -b "$3" -f "$1" -N ''
    chmod 600 "$1"
}

ensure_known_hosts() {
    local out="$1" host="$2" dir="$3" key
    rm -f "$out" "$out.old"
    for key in "$dir/"*.pub; do
        printf '[%s]:2222 ' "$host" >> "$out"
        cat "$key" >> "$out"
    done
    ssh-keygen -H -f "$out" > /dev/null
    rm -f "$out.old"
    chmod 600 "$out"
}

HERMES="$BASE/hermes"
SANDBOX="$BASE/sandbox"
BROWSER="$BASE/browser"

COMPONENT_DIRS=("$BROWSER/quadlet" "$SANDBOX/quadlet" "$HERMES/quadlet")
QUADLET_DIRS=("${COMPONENT_DIRS[@]}" "$BASE/quadlet" "$BASE/firecrawl/quadlet" "$BASE/litellm/quadlet")

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
SYSTEMD_DIR="$BASE/quadlet/systemd"
LINK_DIR="$HOME/.config/containers/systemd/homelab"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_DIR"
mkdir -p "$SYSTEMD_USER_DIR"

keep=" "
for quadlet_dir in "${QUADLET_DIRS[@]}"; do
    for t in "$quadlet_dir"/*.container "$quadlet_dir"/*.network; do
        keep+="$(basename "$t") "
        ln -sf "$t" "$SYSTEMD_DIR/$(basename "$t")"
    done
    for t in "$quadlet_dir"/*.target; do
        keep+="$(basename "$t") "
        ln -sf "$t" "$SYSTEMD_USER_DIR/$(basename "$t")"
    done
done
for profile_dir in "${PROFILE_DIRS[@]}"; do
    profile="$(basename "$profile_dir")"
    keep+="sandbox@$profile.network browser@$profile.network "
    for quadlet_dir in "${COMPONENT_DIRS[@]}"; do
        comp="$(basename "$(dirname "$quadlet_dir")")"
        conf="$profile_dir/$comp.conf"
        if [ -f "$conf" ]; then
            keep+="$comp@$profile.container $comp@$profile.container.d "
            ln -sf "$comp@.container" "$SYSTEMD_DIR/$comp@$profile.container"
            drop="$SYSTEMD_DIR/$comp@$profile.container.d"
            mkdir -p "$drop"
            ln -sfn "$conf" "$drop/$comp.conf"
        fi
    done
    ln -sf sandbox@.network "$SYSTEMD_DIR/sandbox@$profile.network"
    ln -sf browser@.network "$SYSTEMD_DIR/browser@$profile.network"
done

if [ "$SYSTEMD" = 1 ]; then
    # podman >= 6 (--application): this whole block collapses to
    #   quadlet rm --recursive --force + quadlet install --application=homelab
    for f in "$SYSTEMD_DIR"/*; do
        name="$(basename "$f")"
        case "$keep" in *" $name "*) ;;
            *)
                if [ -d "$f" ]; then rm -rf "$f"
                else
                    podman quadlet rm --force --ignore "$name"
                    rm -f "$f"
                fi
            ;;
        esac
    done
    for f in "$SYSTEMD_USER_DIR"/*.target; do
        name="$(basename "$f")"
        case "$keep" in *" $name "*) ;; *) rm -f "$f" ;; esac
    done

    ln -sfn "$SYSTEMD_DIR" "$LINK_DIR"
    systemctl --user daemon-reload
    systemctl --user enable homelab.target
    systemctl --user restart homelab.target

    systemctl --user enable --now podman-auto-update.timer
fi


# /usr/lib/systemd/system-generators/podman-system-generator --user --dryrun
# systemctl --user list-dependencies homelab.target
# journalctl --user -u xxx --no-pager -n 100

# find ~/homelab -name '*.env' -exec chmod 600 {} +

# rsync -ax --delete --info=progress2 /home/mithras/homelab/ mithras@192.168.1.2:/home/mithras/Documents/backup/ubuntu1/homelab/


# TODO: add kaicho
