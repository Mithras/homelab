import globals


class LightSwitch(globals.Hass):
    async def initialize(self):
        await super().initialize()
        
        config = self.args["config"]
        self.topic = config["topic"]
        self.light = config["light"]

        await self.call_service("mqtt/subscribe",
                                topic=self.topic,
                                namespace="mqtt")
        await self.listen_event(self._action_callback_async, "MQTT_MESSAGE",
                                namespace="mqtt",
                                topic=self.topic)

    async def terminate(self):
        await self.call_service("mqtt/unsubscribe",
                                topic=self.topic,
                                namespace="mqtt")

    async def _action_callback_async(self, event_name, data, kwargs):
        payload = data["payload"]
        self.log(f"{payload}")
        if payload == "on":
            await self.common.turn_on_async(self.light)
        elif payload == "off":
            await self.common.turn_off_async(self.light)
