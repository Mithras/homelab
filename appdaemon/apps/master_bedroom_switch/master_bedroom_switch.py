import globals


class MasterBedroomSwitch(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self.topic = config["topic"]
        self._master_bedroom_light = config["master_bedroom_light"]
        self.light_app_state = config["light_app_state"]

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

        if payload == "on":
            await self.common.light_turn_nightlight_async(self._master_bedroom_light)
        elif payload == "off":
            await self.common.turn_off_async(self._master_bedroom_light)
        elif payload == "brightness_move_up":
            await self.common.light_turn_bright_async(self._master_bedroom_light)
        elif payload == "brightness_move_down":
            full_state = await self.get_state(self.light_app_state, attribute="all")
            state, attributes = full_state["state"], full_state["attributes"]
            await self.set_state(self.light_app_state,
                                 state="on" if state != "on" else "off",
                                 attributes=attributes)
            if state == "on":
                await self.common.light_flash_async(self._master_bedroom_light)
            else:
                await self.common.light_flash_async(self._master_bedroom_light)
                await self.sleep(0.5)
                await self.common.light_flash_async(self._master_bedroom_light)
