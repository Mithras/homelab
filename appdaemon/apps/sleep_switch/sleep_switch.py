import globals


class SleepSwitch(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._input = config["input"]
        self.topic = config["topic"]
        self._turn_on = config["turn_on"]
        self._turn_off = config["turn_off"]

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
        if payload == "single":
            services = self._turn_off if await self.get_state(self._input) == "on" else self._turn_on
            for x in services:
                await self.call_service(x["service"],
                                        **x["data"])
