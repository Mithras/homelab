#!/usr/bin/env bash

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
    local out="$1" host="$2" dir="$3" port="${4:-}" key prefix
    rm -f "$out" "$out.old"
    if [ -n "$port" ]; then prefix="[$host]:$port"; else prefix="$host"; fi
    for key in "$dir/"*.pub; do
        printf '%s ' "$prefix" >> "$out"
        cat "$key" >> "$out"
    done
    ssh-keygen -H -f "$out" 2>/dev/null
    rm -f "$out.old"
    chmod 600 "$out"
}
