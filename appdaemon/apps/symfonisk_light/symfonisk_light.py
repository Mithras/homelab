from typing import List
import globals
from bisect import bisect_left


STEPS = [0, 1, 20, 40, 60, 80, 100]
STEP_DELAY = 0.5


class SymfoniskLight(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._topic = config["topic"]
        self._light = config["light"]
        self._secondary = config["secondary"]
        self._secondary_indication = config["secondary_indication"]

        brightness = await self.get_state(self._light, attribute="brightness") or 0
        brightness_pct = round(brightness / 255 * 100)
        self._step = 0
        self._index = self._closest(STEPS, brightness_pct)
        self._update_task = await self.create_task(self._update())

        await self.call_service("mqtt/subscribe",
                                topic=self._topic,
                                namespace="mqtt",
                                return_result=True)
        await self.listen_event(self._action_callback_async, "MQTT_MESSAGE",
                                namespace="mqtt",
                                topic=self._topic)

    async def terminate(self):
        await self.call_service("mqtt/unsubscribe",
                                topic=self._topic,
                                namespace="mqtt",
                                return_result=True)
        if self._update_task:
            self._update_task.cancel()

    async def _action_callback_async(self, event_name, data, kwargs):
        payload = data["payload"]
        self.log(f"payload: {payload}")

        if payload == "brightness_move_up":
            self._step = 1
            if self._update_task.done():
                self._update_task = await self.create_task(self._update())
        elif payload == "brightness_move_down":
            self._step = -1
            if self._update_task.done():
                self._update_task = await self.create_task(self._update())
        elif payload == "brightness_stop":
            self._step = 0
        elif payload == "toggle":
            await self.common.toggle_async(self._light)
        elif payload == "brightness_step_up":
            await self.common.toggle_async(self._secondary)
            secondary_state = await self.get_state(self._secondary)
            if self._secondary_indication:
                if secondary_state == "on":
                    await self.common.light_flash_async(self._light)
                    await self.sleep(0.5)
                    await self.common.light_flash_async(self._light)
                else:
                    await self.common.light_flash_async(self._light)
        # elif payload == "brightness_step_down":
        #     pass

    async def _update(self):
        try:
            while True:
                if self._step == 0:
                    return
                index = self._index + self._step
                if index < 0 or index >= len(STEPS):
                    return
                self.log(
                    f"index: {self._index} ({STEPS[self._index]}) -> {index} ({STEPS[index]})")
                self._index = index
                await self.common.turn_on_async(self._light,
                                                brightness_pct=STEPS[self._index],
                                                transition=STEP_DELAY)
                await self.sleep(STEP_DELAY)
        except Exception as ex:
            self.error(ex)

    def _closest(self, arr: List[any], value: any):
        pos = bisect_left(arr, value)
        if pos == 0:
            return 0
        if pos == len(arr):
            return len(arr) - 1
        if arr[pos] - value < value - arr[pos - 1]:
            return pos
        return pos - 1
