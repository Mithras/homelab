import globals


class Dark(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._illuminance = config["illuminance"]
        self._illuminance_threshold = config["illuminance_threshold"]
        self._illuminance_delay = config["illuminance_delay"]
        self._timer = None

        await self._set_dark_async(None)
        await self.listen_state(self._illuminance_callback_async,
                                entity_id=self._illuminance)

    async def _illuminance_callback_async(self, entity, attribute, old, new, kwargs):
        # self.log("_illuminance_callback_async")
        if old == "unknown" or old == "unavailable" or new == "unavailable":
            await self._set_dark_async(None)
            return
        old_int = int(old)
        new_int = int(new)
        dark = await self.get_state(globals.DARK_STATE) == "on"
        oldDark = old_int < self._illuminance_threshold
        newDark = new_int < self._illuminance_threshold
        # self.log(
        #     f"\t old_int = {old_int}, new_int = {new_int}, oldDark = {oldDark}, newDark = {newDark}, dark = {dark}")
        if oldDark != newDark:
            # self.log("\t cancel_timer")
            await self.cancel_timer(self._timer)
            if newDark != dark:
                # self.log("\t run_in")
                self._timer = await self.run_in(self._set_dark_async, self._illuminance_delay)

    async def _set_dark_async(self, kwargs):
        # self.log("_set_dark_async")
        illuminance = await self.get_state(self._illuminance)
        if not illuminance or illuminance == "unknown" or illuminance == "unavailable":
            await self.set_state(globals.DARK_STATE, state="on")
            return
        illuminance_int = int(illuminance)
        dark = "on" if illuminance_int < self._illuminance_threshold else "off"
        await self.set_state(globals.DARK_STATE, state=dark)
