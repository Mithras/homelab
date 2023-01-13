import globals


class ToggleSwitch(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._input = config["input"]
        self._toggle_service = config["toggle_service"]
        self._toggle_payload = config["toggle_payload"]
        self._power = config["power"]
        self._power_on_threshold = float(config["power_on_threshold"])
        self._check_interval = float(config["check_interval"])

        self.ensure_state_task = await self.create_task(
            self._ensure_state_async(False))

        await self.listen_state(self._input_callback_async,
                                entity_id=self._input)

    async def terminate(self):
        # self.log("Terminate")
        self.ensure_state_task.cancel()

    async def _input_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        # self.log(f"InputChange: old = {old}, new = {new}")
        self.ensure_state_task.cancel()
        self.ensure_state_task = await self.create_task(self._ensure_state_async())

    async def _ensure_state_async(self, immediate=True):
        try:
            # self.log(f"EnsureState: immediate = {immediate}")
            if immediate:
                await self._toggle_async()
            while True:
                await self.sleep(self._check_interval)
                power = float(await self.get_state(self._power))
                input = await self.get_state(self._input)
                # self.log(
                #     f"EnsureState: input = {input}, power: {power}")
                if input == "on" and power < self._power_on_threshold or input == "off" and power > self._power_on_threshold:
                    await self._toggle_async()
        except Exception as ex:
            self.error(ex)

    async def _toggle_async(self):
        # self.log("Toggle")
        await self.call_service(self._toggle_service,
                                return_result=True,
                                **self._toggle_payload)
