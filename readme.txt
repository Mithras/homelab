- adguardhome
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
  - MQTT-Explorer
- portainer
- rhasspy
- swag
- homeassistant
  - wake_on_lan
    1. BIOS:
      APM Configuration\ErP Ready: DISABLED
      APM Configuration\Power on by PCI-E: ENABLED
    2. Device Manager -> NetworkAdapter
      2.1 Update driver
      2.2 Power Management
        Check everything
      2.3 Advanced
        Enable PME: Enabled
        Wake on Magic Packet: Enabled
    3. Power Options
      Fast Startup: false
  - RM3-Mini
    - https://play.google.com/store/apps/details?id=cn.com.broadlink.econtrol.plus
      1. Hold reset until start flashing in 3 quick series
      2. Follow wifi setup guide
- appdaemon

---

- z-wave
  - HUSBZB-1
    - /dev/ttyUSB1 # z-wave
      /dev/ttyUSB2 # zigbee
