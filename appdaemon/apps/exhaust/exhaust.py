import globals


class Exhaust(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._input = config["input"]
        self._temperature = config["temperature"]
        self._min_temperature = float(config["min_temperature"])
        self._max_temperature = float(config["max_temperature"])

        await self.listen_state(self._temperature_callback_async,
                                entity_id=self._temperature)
        await self._ensure_state_async()

    async def _temperature_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        # self.log(f"TemperatureChange: old = {old}, new = {new}")
        await self._ensure_state_async()

    async def _ensure_state_async(self):
        temperature_str = await self.get_state(self._temperature)
        if temperature_str == "unavailable" or temperature_str == "unknown":
            return
        temperature = float(temperature_str)
        input = await self.get_state(self._input)
        # self.log(f"EnsureState: input = {input}, temperature = {temperature}")
        if temperature < self._min_temperature and input == "on":
            # self.log("turn_off")
            await self.common.turn_off_async(self._input)
        elif temperature > self._max_temperature and input == "off":
            # self.log("turn_on")
            await self.common.turn_on_async(self._input)
