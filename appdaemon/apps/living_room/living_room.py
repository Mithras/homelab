import globals


class LivingRoom(globals.Hass):
    async def initialize(self):
        await super().initialize()
        
        config = self.args["config"]
        self._mithras_desktop = config["mithras_desktop"]
        self._jotunheim = config["jotunheim"]
        self._speakers = config["speakers"]
        self._tv_input = config["tv_input"]
        self._living_room_main_light = config["living_room_main_light"]
        self._light_strip = config["light_strip"]
        self._tv_delay = config["tv_delay"]
        self._tv_timer = None

        await self.listen_state(self._mithras_desktop_callback_async,
                                entity_id=self._mithras_desktop)
        await self.listen_state(self._person_home_callback_async,
                                entity_id=config["person"],
                                new="home")
        await self.listen_state(self._person_not_home_callback_async,
                                entity_id=config["person"],
                                new="not_home")
        await self.listen_state(self._sleep_callback_async,
                                entity_id=config["sleep_input"])

    async def _mithras_desktop_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        if new == "on":
            await self._activate_async()
        else:
            await self._deactivate_async()

    async def _person_home_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        await self._activate_async()
        await self.common.turn_on_async(self._mithras_desktop)

    async def _person_not_home_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new: # or await self.anyone_home(person=True):
            return
        await self._deactivate_async()

    async def _sleep_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        if new == "on":
            await self._deactivate_async()
        else:
            await self._activate_async()
            await self.common.turn_on_async(self._mithras_desktop)

    async def _activate_async(self):
        await self.common.turn_on_async(self._jotunheim)
        await self.common.turn_on_async(self._speakers)
        await self.common.light_turn_bright_async(self._living_room_main_light)
        await self.common.turn_on_async(self._tv_input)
        await self.cancel_timer(self._tv_timer)

    async def _deactivate_async(self):
        await self.common.turn_off_async(self._jotunheim)
        await self.common.turn_off_async(self._speakers)
        await self.common.turn_off_async(self._light_strip)
        await self.cancel_timer(self._tv_timer)
        self._tv_timer = await self.run_in(self._turn_off_tv_async, self._tv_delay)

    async def _turn_off_tv_async(self, kwargs):
        await self.common.turn_off_async(self._tv_input)
