import globals


class InputSwitch(globals.Hass):
    _ensure_state_task = None
    
    async def initialize(self):
        config = self.args["config"]
        self._input = config["input"]
        self._service = config["service"]
        self._toggle_payload = config.get("toggle_payload", None)
        self._on_payload = config.get("on_payload", None)
        self._off_payload = config.get("off_payload", None)
        self._power = config["power"]
        self._power_on_threshold = float(config["power_on_threshold"])
        self._power_off_threshold = float(config["power_off_threshold"])
        self._check_interval = float(config["check_interval"])

        self._ensure_state_task = await self.create_task(
            self._ensure_state_async())

        await self.listen_state(self._input_callback_async,
                                entity_id=self._input)

    async def terminate(self):
        # self.log("Terminate")
        if (self._ensure_state_task):
            self._ensure_state_task.cancel()

    async def _input_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        self._ensure_state_task.cancel()
        self._ensure_state_task = await self.create_task(self._ensure_state_async())

    async def _ensure_state_async(self):
        try:
            while True:
                power_str = await self.get_state(self._power)
                if power_str != "unknown":
                    power = float(power_str)
                    input = await self.get_state(self._input)
                    # self.log(
                    #     f"_ensure_state_async: input = {input}, power: {power}")
                    if input == "on" and power < self._power_on_threshold:
                        self.log("_ensure_state_async: _on_async()")
                        await self._on_async()
                    if input == "off" and power > self._power_off_threshold:
                        self.log("_ensure_state_async: _off_async()")
                        await self._off_async()
                await self.sleep(self._check_interval)
        except Exception as ex:
            self.error(ex)

    async def _on_async(self):
        if self._on_payload:
            await self.call_service(self._service,
                                    return_result=True,
                                    **self._on_payload)
        else:
            await self.call_service(self._service,
                                    return_result=True,
                                    **self._toggle_payload)
 
    async def _off_async(self):
        if self._off_payload:
            await self.call_service(self._service,
                                    return_result=True,
                                    **self._off_payload)
        else:
            await self.call_service(self._service,
                                    return_result=True,
                                    **self._toggle_payload)
 