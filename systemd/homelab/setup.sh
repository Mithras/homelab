# --- update ---

sudo apt update && sudo apt full-upgrade -y

# --- app armor ---

sudo systemctl stop apparmor
sudo systemctl disable apparmor
sudo apt purge apparmor apparmor-utils -y
sudo apt autoremove -y

sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="apparmor=0"
sudo update-grub
sudo reboot

# --- podman ---

sudo apt install -y podman git

systemctl --user mask --now podman.socket
systemctl --user stop podman.service
systemctl --user enable --now podman-auto-update.timer

# ---

# sudo apt install -y pipewire pipewire-pulse wireplumber pulseaudio-utils bluez libspa-0.2-bluetooth
# sudo loginctl enable-linger
# systemctl --user enable --now pipewire pipewire-pulse wireplumber
# sudo systemctl enable --now bluetooth

# mkdir -p ~/.config/wireplumber/wireplumber.conf.d
# cat > ~/.config/wireplumber/wireplumber.conf.d/51-jabra.conf <<'EOF'
# monitor.bluez.properties = {
#   bluez5.roles = [ hfp_hf hsp_hs a2dp_sink ]
#   bluez5.enable-msbc = true
#   bluez5.auto-connect = [ hfp_hf hsp_hs a2dp_sink ]
# }
# monitor.bluez.rules = [
#   {
#     matches = [ { node.name = "~bluez_input.*" }, { node.name = "~bluez_output.*" } ]
#     actions = { update-props = { session.suspend-timeout-seconds = 0 } } 
#   }
# ]
# EOF
# systemctl --user restart pipewire pipewire-pulse wireplumber


# bluetoothctl power on
# bluetoothctl agent on
# bluetoothctl default-agent
# bluetoothctl --timeout 10 scan on
# bluetoothctl remove 50:C2:ED:51:7C:36
# bluetoothctl pair 50:C2:ED:51:7C:36
# bluetoothctl trust 50:C2:ED:51:7C:36
# bluetoothctl info 50:C2:ED:51:7C:36
# bluetoothctl connect 50:C2:ED:51:7C:36

# wpctl status
# wpctl set-default <sink-id>
# wpctl set-default <source-id>

# pactl info
# pactl list short sources
# pactl list short sinks

# paplay /usr/share/sounds/alsa/Front_Center.wav
