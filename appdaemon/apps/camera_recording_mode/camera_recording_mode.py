import globals
from security import ARMED_AWAY, ARMED_HOME, ARMED_SLEEP, DISARMED


class CameraRecordingMode(globals.Hass):
    async def initialize(self):
        config = self.args["config"]
        self._recording_mode = config["recording_mode"]
        self._security_recording_mode_map = dict([
            (ARMED_AWAY, config["armed_away"]),
            (ARMED_HOME, config["armed_home"]),
            (ARMED_SLEEP, config["armed_sleep"]),
            (DISARMED, config["disarmed"]),
        ])

        await self.listen_state(self._security_callback_async,
                                entity_id="appdaemon.security")
        await self._update_camera_motion_recording_async()

    async def _security_callback_async(self, entity, attribute, old, new, kwargs):
        if old == new:
            return
        await self._update_camera_motion_recording_async()

    async def _update_camera_motion_recording_async(self):
        security = await self.get_state("appdaemon.security")
        if security is None:
            return
        recording_mode = self._security_recording_mode_map[security]
        # self.log(f"recording_mode = {recording_mode}")
        await self.set_state(self._recording_mode,
                             state=recording_mode)
