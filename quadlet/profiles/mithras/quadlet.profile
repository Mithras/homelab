PROFILE=mithras

HERMES_PUBLISH_PORTS='PublishPort=2222:22
PublishPort=9121:9119'  # ssh/cdp + dashboard (NPM 9119 -> host:9121)

SANDBOX_EXTRA_VOLUMES='Volume=/home/mithras/homelab/syncthing/Obsidian/Main:/home/hermes/obsidian
Volume=/home/mithras/homelab:/home/hermes/homelab:ro
Volume=tmpfs:/home/hermes/homelab/hermes/.ssh:ro'

BROWSER_PUBLISH_PORTS='PublishPort=3101:3000'
