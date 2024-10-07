import globals
import string
import random
from datetime import datetime
import os


SYMBOLS = string.ascii_lowercase + string.digits
REMOTE_TMP_PATH = "/config/tmp"
LOCAL_TMP_PATH = "/conf/tmp"


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
        remote_filename = f"{REMOTE_TMP_PATH}/{name}.jpg"
        local_filename = f"{LOCAL_TMP_PATH}/{name}.jpg"
        await self.call_service("camera/snapshot",
                                entity_id=self._camera,
                                filename=remote_filename,
                                return_result=True)
        await self.call_service("telegram_bot/send_photo",
                                entity_id=[self.common.telegram_alarm_chat],
                                file=remote_filename,
                                return_result=True)
        os.remove(local_filename)

    def _get_name(self):
        now = datetime.now()
        random_string = self._random_string(10)
        return now.strftime(
            f"[{self._camera}][%Y-%m-%d][%H-%M-%S].{random_string}")

    def _random_string(self, length: int):
        return "".join(random.choice(SYMBOLS) for i in range(length))
