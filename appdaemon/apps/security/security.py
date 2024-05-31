import globals

AUTO = "Auto"
ARMED_AWAY = "Armed Away"
ARMED_HOME = "Armed Home"
ARMED_SLEEP = "Armed Sleep"
DISARMED = "Disarmed"


class Security(globals.Hass):
    async def initialize(self):
        await super().initialize()

        await self.listen_state(self._state_callback_async,
                                entity_id="person")
        await self.listen_state(self._state_callback_async,
                                entity_id="input_select.security_override")
        await self.listen_state(self._state_callback_async,
                                entity_id="input_boolean.sleep")
        await self._update_security_async()

    async def _state_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        await self._update_security_async()

    async def _update_security_async(self):
        await self.set_state("appdaemon.security", state=await self._get_security_async())

    async def _get_security_async(self):
        security_override = await self.get_state("input_select.security_override")
        if security_override != AUTO:
            return security_override
        if await self.noone_home(person=True):
            return ARMED_AWAY
        if await self.common.is_sleep_async():
            return ARMED_SLEEP
        return ARMED_HOME
