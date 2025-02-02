import globals


HVAC_IDLE = "idle"
FAN_AUTO = "Auto low"
FAN_LOW = "Low"


class Ventilation(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._climate = config["climate"]
        self._on_low_interval = config["on_low_interval"]
        self._on_auto_interval = config["on_auto_interval"]
        self._sleep_input = config["sleep_input"]

        self._fan_running = None
        self._timer_handle = None
        self._start_when_awake = False

        await self.listen_state(self._climate_callback_async,
                                entity_id=self._climate,
                                attribute="hvac_action")
        await self.listen_state(self._climate_callback_async,
                                entity_id=self._climate,
                                attribute="fan_mode")
        await self.listen_state(self._awake_callback_async,
                                entity_id=self._sleep_input,
                                new="off")
        await self._handle_climate_change_async()

    async def _climate_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        await self._handle_climate_change_async()

    async def _awake_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        if self._start_when_awake:
            self._start_when_awake = False
            await self.call_service("climate/set_fan_mode",
                                    entity_id=self._climate,
                                    fan_mode=FAN_LOW,
                                    return_result=True)

    async def _handle_climate_change_async(self):
        hvac_action = await self.get_state(self._climate, attribute="hvac_action")
        fan_mode = await self.get_state(self._climate, attribute="fan_mode")
        fan_running = fan_mode == FAN_LOW or hvac_action != HVAC_IDLE

        if self._fan_running == fan_running:
            return

        self.log(
            f"_handle_climate_change_async: hvac_action = {hvac_action}, fan_mode = {fan_mode}, self._fan_running = {self._fan_running}, fan_running = {fan_running}")
        self._fan_running = fan_running
        delay = self._on_low_interval if self._fan_running else self._on_auto_interval
        await self.cancel_timer(self._timer_handle)
        self._timer_handle = await self.run_in(self._set_fan_mode, delay)

    async def _set_fan_mode(self, kwargs):
        fan_mode = FAN_AUTO if self._fan_running else FAN_LOW
        if fan_mode == FAN_LOW and await self.get_state(self._sleep_input) == "on":
            self._start_when_awake = True
            return
        self.log(
            f"_set_fan_mode: fan_mode = {fan_mode}")
        await self.call_service("climate/set_fan_mode",
                                entity_id=self._climate,
                                fan_mode=fan_mode,
                                return_result=True)
