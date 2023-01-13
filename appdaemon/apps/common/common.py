import hassapi as hass
import csv
from collections import namedtuple


Profile = namedtuple(
    "Profile", ["profile", "x_color", "y_color", "brightness"])
with open("/conf/light_profiles.csv") as profiles_file:
    profiles_reader = csv.reader(profiles_file)
    next(profiles_reader)
    LIGHT_PROFILES = [Profile(row[0], float(row[1]), float(
        row[2]), int(row[3])) for row in profiles_reader]


class Common(hass.Hass):
    async def initialize(self):
        config = self.args["config"]
        self.telegram_mithras = config["telegram_mithras"]
        self.telegram_debug_chat = config["telegram_debug_chat"]
        self.telegram_state_chat_mithras = config["telegram_state_chat_mithras"]
        self.telegram_state_chat_diana = config["telegram_state_chat_diana"]
        self.telegram_alarm_chat = config["telegram_alarm_chat"]

    async def is_sleep_async(self):
        return await self.get_state("input_boolean.sleep") == "on"

    async def send_state_async(self, person: str, message: str, **kwargs):
        # if person == "person.mithras":
        #     target = self.telegram_state_chat_mithras
        # elif person == "person.diana":
        if person == "person.diana":
            target = self.telegram_state_chat_diana
        else:
            return
        await self.call_service("telegram_bot/send_message",
                                target=[target],
                                message=message,
                                return_result=True,
                                **kwargs)

    async def send_alarm_async(self, message: str, **kwargs):
        await self.call_service("telegram_bot/send_message",
                                target=[self.telegram_alarm_chat],
                                message=message,
                                return_result=True,
                                **kwargs)

    async def send_debug_async(self, message: str, **kwargs):
        await self.call_service("telegram_bot/send_message",
                                target=[self.telegram_debug_chat],
                                message=message,
                                return_result=True,
                                **kwargs)

    async def turn_on_async(self, entity: str, **kwargs):
        [domain, _] = entity.split(".")
        await self.call_service(f"{domain}/turn_on",
                                entity_id=entity,
                                return_result=True,
                                **kwargs)

    async def turn_off_async(self, entity: str, **kwargs):
        [domain, _] = entity.split(".")
        await self.call_service(f"{domain}/turn_off",
                                entity_id=entity,
                                return_result=True,
                                **kwargs)

    async def toggle_async(self, entity: str, **kwargs):
        [domain, _] = entity.split(".")
        await self.call_service(f"{domain}/toggle",
                                entity_id=entity,
                                return_result=True,
                                **kwargs)

    async def light_turn_bright_async(self, light_group: str, **kwargs):
        await self.light_turn_profile_async(light_group, "bright", **kwargs)

    async def light_turn_dimmed_async(self, light_group: str, **kwargs):
        await self.light_turn_profile_async(light_group, "dimmed", **kwargs)

    async def light_turn_nightlight_async(self, light_group: str, **kwargs):
        await self.light_turn_profile_async(light_group, "nightlight", **kwargs)

    async def light_turn_profile_async(self, light_group: str, profile: str, **kwargs):
        if profile == "off":
            await self.turn_off_async(light_group)
        else:
            await self.call_service("light/turn_on",
                                    entity_id=light_group,
                                    profile=profile,
                                    return_result=True,
                                    **kwargs)

    async def light_flash_async(self, light: str, **kwargs):
        await self.call_service("light/turn_on",
                                entity_id=light,
                                brightness=255,
                                flash="short",
                                return_result=True,
                                **kwargs)
