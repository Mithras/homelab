import globals
import string
import random
from datetime import datetime
import os


SYMBOLS = string.ascii_lowercase + string.digits
TMP_PATH = "/config/tmp"


class CameraAlarm(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._camera = config["camera"]
        for entity in config["sensors"]:
            await self.listen_state(self._sensor_callback_async,
                                    entity_id=entity)

    async def _sensor_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        if new == "on":
            await self._send_snapshot_async()

    async def _send_snapshot_async(self):
        name = self._get_name()
        filename = f"{TMP_PATH}/{name}.jpg"
        await self.call_service("camera/snapshot",
                                entity_id=self._camera,
                                filename=filename,
                                return_result=True)
        await self.call_service("telegram_bot/send_photo",
                                target=[self.common.telegram_alarm_chat],
                                file=filename,
                                return_result=True)
        os.remove(filename)

    def _get_name(self):
        now = datetime.now()
        random_string = self._random_string(10)
        return now.strftime(
            f"[{self._camera}][%Y-%m-%d][%H-%M-%S].{random_string}")

    def _random_string(self, length: int):
        return "".join(random.choice(SYMBOLS) for i in range(length))
