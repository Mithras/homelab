import globals


STEP = 100
THRESHOLD = 1000
THRESHOLD_STEP = THRESHOLD // STEP


class Co2SensorAlarm(globals.Hass):
    _step: int

    async def initialize(self):
        await super().initialize()
        
        config = self.args["config"]
        sensor = config["sensor"]

        self._step = 0
        self._friendly_name = await self.friendly_name(sensor)
        await self.listen_state(self._state_callback_async,
                                entity_id=sensor)

    async def _state_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new or old == "unavailable" or new == "unavailable":
            return
        # self.log(f"{old} -> {new}")
        old_step, self._step = self._step, float(new) // STEP
        # self.log(f"\t{old_step} -> {self._step}")
        if self._step == old_step or self._step < THRESHOLD_STEP and old_step < THRESHOLD_STEP:
            return
        if self._step > old_step:
            await self.common.send_alarm_async(
                f"*{self._friendly_name}* is above {int(self._step * STEP)}ppm.")
        else:
            await self.common.send_alarm_async(
                f"*{self._friendly_name}* is below {int((self._step + 1) * STEP)}ppm.")
