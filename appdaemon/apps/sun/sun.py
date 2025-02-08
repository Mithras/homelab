import globals


class Sun(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._sunset = config["sunset"]
        self._sunrise = config["sunrise"]

        await self.run_at_sunset(self._sunset_callback_async)
        await self.run_at_sunrise(self._sunrise_callback_async)

    async def _sunset_callback_async(self, kwargs):
        # self.log(f"_sunset_callback_async: {self._sunset}")
        for x in self._sunset:
            await self.call_service(x["service"],
                                    **x["data"])

    async def _sunrise_callback_async(self, kwargs):
        # self.log(f"_sunrise_callback_async: {self._sunrise}")
        for x in self._sunrise:
            await self.call_service(x["service"],
                                    **x["data"])
