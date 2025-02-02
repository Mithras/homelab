import globals
from common import Profile, LIGHT_PROFILES


ROTATE_PROFILES = [
    ("nightlight", "off"),
    ("dimmed", "off"),
    ("bright", "off"),
    ("bright", "dimmed"),
    ("bright", "bright"),
]


class LivingRoomCube(globals.Hass):
    async def initialize(self):
        return
        config = self.args["config"]
        self.topic = config["topic"]
        self._light_kitchen = config["light_kitchen"]
        self._light_kitchen_app = config["light_kitchen_app"]
        self._light_living_room_main = config["light_living_room_main"]
        self._light_living_room_back = config["light_living_room_back"]
        self._light_kitchen_main = config["light_kitchen_main"]

        light_profiles_map = {
            x.profile: x
            for x in LIGHT_PROFILES
        }
        self.rotate_profiles_main = [
            light_profiles_map.get(x[0], None)
            for x in ROTATE_PROFILES
        ]
        self.rotate_profiles_back = [
            light_profiles_map.get(x[1], None)
            for x in ROTATE_PROFILES
        ]

        await self.call_service("mqtt/subscribe",
                                topic=self.topic,
                                namespace="mqtt",
                                return_result=True)
        await self.listen_event(self._action_callback_async, "MQTT_MESSAGE",
                                namespace="mqtt",
                                topic=self.topic)

    async def terminate(self):
        return
        await self.call_service("mqtt/unsubscribe",
                                topic=self.topic,
                                namespace="mqtt",
                                return_result=True)

    async def _action_callback_async(self, event_name, data, kwargs):
        payload = data["payload"]
        if payload == "wakeup":
            pass
        elif payload == "flip90":
            await self._flip_90_async()
        elif payload == "flip180":
            await self._flip_180_async()
        elif payload == "tap":
            await self._double_tap_async()
        elif payload == "shake":
            await self._shake_async()
        elif payload == "rotate_left":
            await self._rotate_profile_async(-1)
        elif payload == "rotate_right":
            await self._rotate_profile_async(1)
        elif payload == "slide":
            pass
        elif payload == "fall":
            pass

    async def _flip_90_async(self):
        if await self.get_state(self._light_kitchen) == "off":
            await self.common.light_turn_bright_async(self._light_kitchen)
        else:
            await self.common.turn_off_async(self._light_kitchen)

    async def _flip_180_async(self):
        await self.common.toggle_async(self._light_kitchen_app)

    async def _rotate_profile_async(self, shift: int):
        main_weights = await self._get_light_profile_weights_async(
            self._light_living_room_main, self.rotate_profiles_main)
        back_weights = await self._get_light_profile_weights_async(
            self._light_living_room_back, self.rotate_profiles_back)

        # self.log(f"main_weights = {main_weights}")
        # self.log(f"back_weights = {back_weights}")

        weights = (main_weight+back_weight
                   for main_weight, back_weight
                   in zip(main_weights, back_weights))
        sorted_weights = sorted(
            enumerate(weights),
            key=lambda i_weight: i_weight[1])
        min_index = sorted_weights[0][0]
        index = min_index + shift
        index = min(max(0, index), len(ROTATE_PROFILES) - 1)

        # self.log(f"sorted_weights = {sorted_weights}")
        # self.log(f"min_index = {min_index}")
        # self.log(f"index = {index}")

        main_profile, back_profile = ROTATE_PROFILES[index]
        await self.common.light_turn_profile_async(
            self._light_living_room_main, main_profile)
        await self.common.light_turn_profile_async(
            self._light_living_room_back, back_profile)

    async def _double_tap_async(self):
        if await self.get_state(self._light_living_room_main) != "off" or await self.get_state(self._light_living_room_back) != "off":
            await self.common.turn_off_async(self._light_living_room_main)
            await self.common.turn_off_async(self._light_living_room_back)
        else:
            await self.common.light_turn_bright_async(self._light_living_room_main)
            await self.common.turn_off_async(self._light_living_room_back)

    async def _shake_async(self):
        await self.common.toggle_async(self._light_kitchen_main)

    async def _get_light_profile_weights_async(self, light_group, light_profiles=LIGHT_PROFILES):
        state_profile = await self._get_light_profile_async(light_group)
        # self.log(f"state_profile = {state_profile}")
        return [self._get_diff(state_profile, light_profile)
                for light_profile in light_profiles]

    async def _get_light_profile_async(self, light_group):
        state = await self.get_state(light_group, attribute="all")
        if state["state"] == "off":
            return None
        attributes = state["attributes"]
        x_color, y_color = attributes.get("xy_color", [None, None])
        brightness = attributes["brightness"]
        return Profile(None, x_color, y_color, brightness)

    def _get_diff(self, profileA, profileB):
        if profileA is None and profileB is None:
            return 0
        if profileA is None or profileB is None:
            return 3000
        diff = 0
        diff += abs((profileA.x_color - profileB.x_color)*1000)
        diff += abs((profileA.y_color - profileB.y_color)*1000)
        diff += abs(profileA.brightness - profileB.brightness)
        return diff
