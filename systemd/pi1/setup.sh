sudo apt update && sudo apt full-upgrade -y

sudo apt install -y podman git
sudo apt install -y pipewire pipewire-pulse wireplumber alsa-utils pulseaudio-utils

mkdir -p ~/.config/wireplumber/wireplumber.conf.d
cat > ~/.config/wireplumber/wireplumber.conf.d/51-disable-suspend.conf <<'EOF'
monitor.alsa.rules = [
  {
    matches = [ { node.name = "~alsa_output.*" } ]
    actions = { update-props = { session.suspend-timeout-seconds = 0 } }
  }
  {
    matches = [ { node.name = "~alsa_input.*" } ]
    actions = { update-props = { session.suspend-timeout-seconds = 0 } }
  }
]
EOF
systemctl --user restart pipewire pipewire-pulse wireplumber

systemctl --user enable --now pipewire pipewire-pulse wireplumber
sudo loginctl enable-linger

sudo iw dev wlan0 set power_save off
sudo nmcli con modify "$(nmcli -t -f NAME con show --active | head -1)" wifi.powersave 2

# pactl info
# pactl list short sources
# pactl list short sinks
# paplay /usr/share/sounds/alsa/Front_Center.wav
