#!/usr/bin/env bash
set -euo pipefail

read -r PRIV PUB < <(docker run --rm ghcr.io/xtls/xray-core x25519 |
  awk '/Private/{p=$NF} /Public/{q=$NF} END{print p, q}')
[[ -n "$PRIV" && -n "$PUB" ]] || { echo "x25519 failed — no keys generated" >&2; exit 1; }
UUID=$(cat /proc/sys/kernel/random/uuid)
SID=$(openssl rand -hex 4)

cat > config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{ "id": "$UUID", "flow": "xtls-rprx-vision" }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "reality",
      "realitySettings": {
        "dest": "www.samsung.com:443",
        "serverNames": ["www.samsung.com"],
        "privateKey": "$PRIV",
        "shortIds": ["$SID"]
      }
    }
  }],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ]
}
EOF

mkdir -p sing-box
cat > sing-box/config.json <<EOF
{
  "log": { "level": "warn" },
  "inbounds": [{
    "type": "tun",
    "tag": "tun-in",
    "address": ["172.19.0.1/30"],
    "auto_route": true,
    "strict_route": true
  }],
  "outbounds": [
    {
      "type": "vless",
      "tag": "proxy",
      "server": "mithras.app",
      "server_port": 443,
      "uuid": "$UUID",
      "flow": "xtls-rprx-vision",
      "tls": {
        "enabled": true,
        "server_name": "www.samsung.com",
        "utls": { "enabled": true, "fingerprint": "chrome" },
        "reality": { "enabled": true, "public_key": "$PUB", "short_id": "$SID" }
      }
    },
    { "type": "direct", "tag": "direct" }
  ],
  "route": {
    "rules": [
      { "action": "sniff" },
      { "protocol": "dns", "action": "hijack-dns" },
      { "ip_is_private": true, "outbound": "direct" }
    ],
    "auto_detect_interface": true
  },
  "dns": { "servers": [{ "type": "tls", "tag": "cloudflare", "server": "1.1.1.1", "detour": "proxy" }] }
}
EOF

echo "vless://$UUID@mithras.app:8443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.samsung.com&fp=chrome&pbk=$PUB&sid=$SID&type=tcp#mithras-xray"

# openssl s_client -connect localhost:443 -servername www.samsung.com </dev/null 2>/dev/null | grep -E "subject=|TLSv1.3"

# paru -S sing-box
# sudo sing-box check -c /etc/sing-box/config.json
# sudo systemctl enable --now sing-box
