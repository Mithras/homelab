import globals
from datetime import datetime
from dateutil import parser
import pytz


OPEN_CMD = "/person-lock-open"
DO_NOTHING_CMD = "/person-lock-do-nothing"
MAX_DURATION = 180


class PersonLock(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._lock = config["lock"]
        self._person = config["person"]
        self._telegram_user_id = config["telegram_user_id"]

        await self.listen_state(self._person_callback_async,
                                entity_id=self._person,
                                new="home")
        await self.listen_event(self._telegram_callback_async, "telegram_callback")

        # await self.sleep(1)
        # await self.set_state(self._person,
        #                      state="not_home")
        # await self.sleep(1)
        # await self.set_state(self._person,
        #                      state="home")

    async def _person_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return

        friendly_name = await self.friendly_name(entity)
        self.log(
            f"_person_callback_async: {entity}, {old}, {new}, {friendly_name}")

        message_sent = datetime.now(pytz.utc)
        await self.call_service("telegram_bot/send_message",
                                target=[self.common.telegram_debug_chat],
                                message=f"*{friendly_name}*, you seem to be at home. Do you want to open the door?",
                                inline_keyboard=[[
                                    ["Yes", f"{OPEN_CMD}/{message_sent}"],
                                    ["No", DO_NOTHING_CMD]
                                ]],
                                return_result=True)

    async def _telegram_callback_async(self, event_name, data, kwargs):
        # self.log(f"_telegram_callback_async: {data}")
        telegram_data = data["data"]
        # telegram_user_id = data["user_id"]
        telegram_chat_id = data["chat_id"]
        telegram_message_id = data["message"]["message_id"]
        telegram_text = data["message"]["text"]
        time_fired = parser.parse(data["metadata"]["time_fired"])

        # if telegram_user_id != self._telegram_user_id:
        #     self.log(f"Wrong telegram_user_id: {telegram_user_id}")
        #     return

        if telegram_data == DO_NOTHING_CMD:
            await self._telegram_edit_message_async(
                telegram_chat_id, telegram_message_id, f"{telegram_text}\n(*No*)")
            return

        if telegram_data.startswith(OPEN_CMD):
            message_sent = parser.parse(telegram_data.split("/")[2])
            duration = (time_fired - message_sent).total_seconds()

            self.log(f"\t message_sent: {message_sent}")
            self.log(f"\t time_fired: {time_fired}")
            self.log(f"\t duration: {duration}")
            if duration > MAX_DURATION:
                await self._telegram_edit_message_async(
                    telegram_chat_id, telegram_message_id, f"{telegram_text}\n(*Too late*)")
                return

            await self._telegram_edit_message_async(
                telegram_chat_id, telegram_message_id, f"{telegram_text}\n(*Yes*)")
            await self.call_service("lock/unlock",
                                    entity_id=self._lock,
                                    return_result=True)

    async def _telegram_edit_message_async(self, telegram_chat_id, telegram_message_id, telegram_message):
        self.log(f"_telegram_edit_message_async: {telegram_message}")
        await self.call_service("telegram_bot/edit_message",
                                chat_id=telegram_chat_id,
                                message_id=telegram_message_id,
                                message=telegram_message,
                                inline_keyboard=[],
                                return_result=True)
