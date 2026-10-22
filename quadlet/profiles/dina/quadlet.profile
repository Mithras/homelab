PROFILE=dina

HERMES_PUBLISH_PORTS='PublishPort=2223:22
PublishPort=9122:9119'  # ssh + dashboard (NPM 9120 -> host:9122)

SANDBOX_EXTRA_VOLUMES='Volume=/home/mithras/homelab/syncthing/Obsidian-dina/main:/home/hermes/obsidian'

BROWSER_PUBLISH_PORTS='PublishPort=3102:3000'
