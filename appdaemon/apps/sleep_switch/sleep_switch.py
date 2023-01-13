import globals


class SleepSwitch(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._input = config["input"]
        self.topic = config["topic"]

        await self.call_service("mqtt/subscribe",
                                topic=self.topic,
                                namespace="mqtt",
                                return_result=True)
        await self.listen_event(self._action_callback_async, "MQTT_MESSAGE",
                                namespace="mqtt",
                                topic=self.topic)

    async def terminate(self):
        await self.call_service("mqtt/unsubscribe",
                                topic=self.topic,
                                namespace="mqtt",
                                return_result=True)

    async def _action_callback_async(self, event_name, data, kwargs):
        payload = data["payload"]
        if payload == "single":
            await self.common.toggle_async(self._input)
