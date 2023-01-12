- adguard
  - disable DNSStubListener
    sudo nano /etc/systemd/resolved.conf
      DNS=127.0.0.1
      DNSStubListener=no
    sudo mv /etc/resolv.conf /etc/resolv.conf.backup
    sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
    sudo systemctl reload-or-restart systemd-resolved
  - Setup
    1. Run without specifying user
    2. Follow setup wizard
    3. Stop container
    4. Run `sudo chown -R mithras:mithras ./adguard/`
    5. Specify user
- mosquitto
- portainer
- rhasspy
