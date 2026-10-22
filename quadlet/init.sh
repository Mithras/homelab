#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/homelab"
PROFILES_DIR="$BASE/quadlet/profiles"
DEFAULT_DEPLOY='sandbox browser'

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

render() {
    env -i PATH="$PATH" bash -c '
        set -a; . "$1"; set +a
        exec envsubst < "$2" > "$3"
    ' render "$1" "$2" "$3"
}

profile_get() {
    env -i PATH="$PATH" bash -c '
        set -a; . "$1"; set +a
        printf "%s\n" "${!2-$3}"
    ' profile_get "$1" "$2" "${3-}"
}


CONTAINERS=()
NETWORKS=()


# Hermes + Sandbox + Browser
HERMES="$BASE/hermes"
SANDBOX="$BASE/sandbox"
BROWSER="$BASE/browser"
shopt -s nullglob; PROFILE_DIRS=("$PROFILES_DIR"/*/); shopt -u nullglob

rm -rf "$HERMES/quadlet/rendered"
rm -rf "$SANDBOX/quadlet/rendered"
rm -rf "$BROWSER/quadlet/rendered"
mkdir -p "$HERMES/quadlet/rendered"
mkdir -p "$SANDBOX/quadlet/rendered"
mkdir -p "$BROWSER/quadlet/rendered"

for profile_dir in "${PROFILE_DIRS[@]}"; do
    profile="$(basename "$profile_dir")"
    PROFILE_ROOT="$HERMES/$profile"
    mkdir -p  "$PROFILE_ROOT/cache"
    mkdir -p  "$PROFILE_ROOT/kanban"
    mkdir -p  "$PROFILE_ROOT/plans"
    # rm -rf "$PROFILE_ROOT/skills"
    mkdir -p  "$PROFILE_ROOT/skills"
    mkdir -p  "$PROFILE_ROOT/price-watches"
    mkdir -p "$BROWSER/config/$profile"

    deploy="$(profile_get "$PROFILES_DIR/$profile/quadlet.profile" DEPLOY "$DEFAULT_DEPLOY")"

    # Gateway config
    ln -f "$HERMES/config.yaml" "$PROFILE_ROOT/config.yaml"

    # Gateway SSH
    ensure_host_keys "$HERMES/.ssh/$profile/host_keys"
    ensure_key "$HERMES/.ssh/$profile/id_rsa" rsa 4096

    # Gateway quadlets
    render "$PROFILES_DIR/$profile/quadlet.profile" "$HERMES/quadlet/hermes.container.tmpl"    "$HERMES/quadlet/rendered/hermes-$profile.container"
    CONTAINERS+=("$HERMES/quadlet/rendered/hermes-$profile.container")
    render "$PROFILES_DIR/$profile/quadlet.profile" "$SANDBOX/quadlet/sandbox.network.tmpl"   "$SANDBOX/quadlet/rendered/sandbox-$profile.network"
    NETWORKS+=("$SANDBOX/quadlet/rendered/sandbox-$profile.network")
    render "$PROFILES_DIR/$profile/quadlet.profile" "$BROWSER/quadlet/browser.network.tmpl"   "$BROWSER/quadlet/rendered/browser-$profile.network"
    NETWORKS+=("$BROWSER/quadlet/rendered/browser-$profile.network")

    # Sandbox
    case " $deploy " in *" sandbox "*)
        # Config
        echo "TERMINAL_SSH_HOST=sandbox-$profile" > "$PROFILE_ROOT/.env"
        echo "TERMINAL_SSH_USER=hermes" >> "$PROFILE_ROOT/.env"
        echo "TERMINAL_SSH_PORT=2222" >> "$PROFILE_ROOT/.env"
        # echo "TERMINAL_SSH_KEY=~/.ssh/id_rsa" >> "$PROFILE_ROOT/.env"
        
        # SSH
        ensure_host_keys "$SANDBOX/.ssh/$profile/host_keys"
        ensure_known_hosts "$SANDBOX/.ssh/$profile/known_hosts" "sandbox-$profile" "$SANDBOX/.ssh/$profile/host_keys"
        ensure_key "$SANDBOX/.ssh/$profile/id_rsa" rsa 4096

        # Quadlets
        render "$PROFILES_DIR/$profile/quadlet.profile" "$SANDBOX/quadlet/sandbox.container.tmpl" "$SANDBOX/quadlet/rendered/sandbox-$profile.container"
        CONTAINERS+=("$SANDBOX/quadlet/rendered/sandbox-$profile.container")
    ;; esac

    # Browser
    case " $deploy " in *" browser "*)
        # Quadlets
        render "$PROFILES_DIR/$profile/quadlet.profile" "$BROWSER/quadlet/browser.container.tmpl" "$BROWSER/quadlet/rendered/browser-$profile.container"
        CONTAINERS+=("$BROWSER/quadlet/rendered/browser-$profile.container")
    ;; esac
done

# Systemd
if [ "$SYSTEMD" = 1 ]; then
    LINK_DIR="$HOME/.config/containers/systemd/homelab"
    
    BEFORE=()
    shopt -s nullglob
    for f in "$LINK_DIR"/*.container; do
        BEFORE+=("$(basename "$f" .container)")
    done
    shopt -u nullglob
    
    rm -rf "$LINK_DIR"
    mkdir -p "$LINK_DIR"

    for src in "${CONTAINERS[@]}" "${NETWORKS[@]}" "$BASE/quadlet/homelab.network"; do
        # Podman < 5.3 doesn't support symlinks in nested dirs
        cp -f "$src" "$LINK_DIR/$(basename "$src")"
    done
    for name in "${BEFORE[@]}"; do
        if [ ! -f "$LINK_DIR/$name.container" ]; then
            systemctl --user stop "$name" || true
        fi
    done

    systemctl --user daemon-reload
    
    for container in "${CONTAINERS[@]}"; do
        name="$(basename "$container" .container)"
        systemctl --user restart $name
    done

    systemctl --user enable --now podman-auto-update.timer
fi


# /usr/lib/systemd/system-generators/podman-system-generator --user --dryrun

# find ~/homelab -name '*.env' -exec chmod 600 {} +


# TODO: install everything in $BASE/quadlet/homelab.network
# TODO: add restart unit/timer
# TODO: add kaicho
