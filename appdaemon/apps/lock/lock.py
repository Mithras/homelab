import globals
from random import randint


DOMAIN = "appdaemon"
EVENT = f"{DOMAIN}_lock_rotate"


class Lock(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        state = config["state"]
        lock_device_id = config["lock_device_id"]
        self._lock = config["lock"]
        self._code_slot = config["code_slot"]
        self._state = f"{DOMAIN}.{state}"

        await self.listen_event(self._rotate_event_callback_async,
                                event=EVENT,
                                state=state)
        await self.listen_event(self._lock_event_callback_async,
                                event="zwave_js_notification",
                                device_id=lock_device_id)

    async def _lock_event_callback_async(self, event_name, data, kwargs):
        self.log(f"zwave_js_notification: {data}")
        event_label = data["event_label"]

        await self.common.send_debug_async(f"*{await self.friendly_name(self._lock)}*: {event_label}.")

        if event_label == "Keypad unlock operation":
            userId = data["parameters"]["userId"]
            if userId == self._code_slot:
                await self.call_service("zwave_js/clear_lock_usercode",
                                        entity_id=self._lock,
                                        code_slot=self._code_slot,
                                        return_result=True)
                await self.set_state(self._state,
                                     state="")
                await self.common.send_debug_async(f"*User Code #{self._code_slot}* has been cleared.")

    async def _rotate_event_callback_async(self, event_name, data, kwargs):
        usercode = str(randint(0, 9999)).zfill(4)
        await self.call_service("zwave_js/set_lock_usercode",
                                entity_id=self._lock,
                                code_slot=self._code_slot,
                                usercode=usercode,
                                return_result=True)
        await self.set_state(self._state,
                             state=usercode)
        await self.common.send_debug_async(f"*User Code #{self._code_slot}* has been changed.")
