import hassapi as hass


DARK_STATE = "appdaemon.dark"


class Hass(hass.Hass):
    def __init__(self, ad, name, logging, args, config, app_config, global_vars):
        hass.Hass.__init__(self, ad, name, logging, args,
                           config, app_config, global_vars)

        self._setup_task = self.create_task(self._setup())

        self.register_constraint("constrain_arm")
        self.register_constraint("constrain_enabled")
        self.app_config[self.name]["constrain_enabled"] = None

    async def initialize(self):
        await (await self._setup_task)

    async def bright(self):
        dark = await self.get_state(DARK_STATE)
        return dark == "off"

    async def dark(self):
        dark = await self.get_state(DARK_STATE)
        return dark == "on"

    async def constrain_arm(self, value=None):
        await self._setup_task
        arm = await self.get_state("appdaemon.security")
        return arm != "Disarmed" if value is None else arm is not None and arm in value

    async def constrain_enabled(self, value):
        await self._setup_task
        state = await self.get_state(self._app_state_name)
        return state == "on"

    async def _setup(self):
        try:
            friendly_name_list = [self.name[0]]
            state_list = [*"appdaemon_app.", self.name[0].lower()]
            for x in self.name[1:]:
                if x.isupper():
                    friendly_name_list.append(" ")
                    state_list.append("_")
                friendly_name_list.append(x)
                state_list.append(x.lower())

            app_friendly_name = "".join(friendly_name_list)
            self._app_state_name = "".join(state_list)

            if await self.get_state(self._app_state_name) is None:
                await self.set_state(self._app_state_name,
                                     state="on",
                                     attributes={"friendly_name": app_friendly_name})

            self.common = await self.get_app("Common")
        except Exception as ex:
            self.error(ex)
