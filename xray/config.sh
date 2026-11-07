#!/usr/bin/env bash
set -euo pipefail

RAW=$(podman run --rm ghcr.io/xtls/xray-core x25519)
echo "--- raw x25519 output ---"
echo "$RAW"

PRIV=$(echo "$RAW" | awk '/Private/{p=$NF} END{print p}')
PUB=$(echo "$RAW"  | awk '/Public/{p=$NF}  END{print p}')
echo "--- extracted ---"
echo "PRIV: $PRIV"
echo "PUB: $PUB"

[[ -n "$PRIV" && -n "$PUB" ]] || { echo "x25519 failed — no keys generated" >&2; exit 1; }
UUID=$(cat /proc/sys/kernel/random/uuid)
SID=$(openssl rand -hex 4)

cat > config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": 9443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "minClientVer": "0",
          "dest": "www.samsung.com:443",
          "serverNames": ["www.samsung.com"],
          "privateKey": "$PRIV",
          "shortIds": ["$SID"]
        }
      }
    }
  ],
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
  "inbounds": [
    {
      "type": "tun",
      "tag": "tun-in",
      "address": ["172.19.0.1/30"],
      "auto_route": true,
      "strict_route": true,
      "stack": "gvisor"
    }
  ],
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
        "reality": {
          "enabled": true,
          "public_key": "$PUB",
          "short_id": "$SID"
        }
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
    "default_domain_resolver": "cf-direct",
    "auto_detect_interface": true
  },
  "dns": {
    "servers": [
      {
        "type": "tls",
        "tag": "cf-via-proxy",
        "server": "1.1.1.1",
        "detour": "proxy"
      },
      {
        "type": "https",
        "tag": "cf-direct",
        "server": "1.1.1.1"
      }
    ]
  }
}
EOF

echo "vless://$UUID@mithras.app:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=www.samsung.com&fp=chrome&pbk=$PUB&sid=$SID&type=tcp#mithras-xray"

# openssl s_client -connect localhost:9443 -servername www.samsung.com </dev/null 2>/dev/null | grep -E "subject=|TLSv1.3"

# paru -S sing-box
# sudo sing-box check -c /etc/sing-box/config.json
# sudo systemctl enable --now sing-box
