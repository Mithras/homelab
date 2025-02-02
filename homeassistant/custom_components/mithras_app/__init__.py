"""The app integration."""

from __future__ import annotations

import voluptuous as vol

from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
import homeassistant.helpers.config_validation as cv
import logging

from .const import DOMAIN


# "mqtt": [
#   "zigbee2mqtt/tradfri_01/action",
#   "zigbee2mqtt/smart_switch_01/action",
#   "zigbee2mqtt/symfonisk_01/action",
#   "zigbee2mqtt/symfonisk_02/action",
#   "zigbee2mqtt/symfonisk_03/action"
# ]

_LOGGER = logging.getLogger(__name__)

CONFIG_SCHEMA = vol.Schema(
    {
        DOMAIN: vol.Schema(
            {
                vol.Required("test"): cv.string,
            }
        )
    },
    extra=vol.ALLOW_EXTRA,
)

FIRE_EVENT_SCHEMA = vol.Schema(
    {vol.Required("event"): cv.string},
    extra=vol.ALLOW_EXTRA,
)


async def async_setup(hass: HomeAssistant, config: ConfigEntry) -> bool:
    """Set up app from a config entry."""

    async def async_fire_event(call):
        event = call.data["event"]
        test = config["mithras_app"]["test"]
        hass.bus.async_fire(event, call.data)
        _LOGGER.warning(event)

    hass.services.async_register(
        DOMAIN,
        "fire_event",
        async_fire_event,
        schema=FIRE_EVENT_SCHEMA,
    )

    return True
