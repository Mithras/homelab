import globals


GARAGE_STATE_MESSAGE_MAP = {
    "opening": "opening",
    "open": "opened",
    "closing": "closing",
    "closed": "closed",
}


class SensorAlarm(globals.Hass):
    async def initialize(self):
        await super().initialize()
        
        for entity in self.args["config"]:
            await self.listen_state(self._state_callback_async,
                                    entity_id=entity)

    async def _state_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        device_type = await self.get_state(entity, attribute="device_class")
        if device_type == "opening":
            await self.common.send_alarm_async(
                f"*{await self.friendly_name(entity)}* has {'opened' if new=='on' else 'closed'}.")
        elif device_type == "motion":
            if new == "on":
                await self.common.send_alarm_async(
                    f"*{await self.friendly_name(entity)}* has detected motion.")
        elif device_type == "connectivity":
            await self.common.send_alarm_async(
                f"*{await self.friendly_name(entity)}* has {'connected' if new=='on' else 'disconnected'}.")
        elif device_type == "garage":
            await self.common.send_alarm_async(
                f"*{await self.friendly_name(entity)}* is {GARAGE_STATE_MESSAGE_MAP.get(new)}.")
        else:
            await self.common.send_alarm_async(
                f"*{await self.friendly_name(entity)}* is in {new} state.")
