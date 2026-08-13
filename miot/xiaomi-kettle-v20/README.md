# Xiaomi Kettle V20

SmartThings Edge LAN driver for the Xiaomi MIoT electric kettle model `xiaomi.kettle.v20`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.kettle.v20`
- specModel: `xiaomi-v20`
- URN: `urn:miot-spec-v2:device:kettle:0000A009:xiaomi-v20:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.kettle.v20` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiKettleV20Status`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.xiaomiKettleV20KeepWarm`
- `concertmirror08464.xiaomiKettleV20WarmTemp`
- `concertmirror08464.xiaomiKettleV20WarmTime`
- `concertmirror08464.xiaomiKettleV20Lifted`
- `concertmirror08464.xiaomiKettleV20NoDisturb`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=7` | `switch` |
| Status | R | `siid=2`, `piid=1`; `0=idle`, `1=heating`, `2=boiling`, `3=cooling`, `4=keep warm` | `xiaomiKettleV20Status.kettleStatus` |
| Water temperature | R | `siid=2`, `piid=3`; celsius | `temperatureMeasurement` |
| Target temperature | RW | `siid=2`, `piid=4`; 40..99 C | `thermostatHeatingSetpoint.heatingSetpoint` |
| Auto keep warm | RW | `siid=2`, `piid=5` | `xiaomiKettleV20KeepWarm.autoKeepWarm` |
| Keep warm temperature | RW | `siid=2`, `piid=6`; 0..100 C | `xiaomiKettleV20WarmTemp.keepWarmTemperature` |
| Keep warm duration | RW | `siid=3`, `piid=1`; 60..1440 minutes | `xiaomiKettleV20WarmTime.keepWarmTime` |
| Kettle lifted | R | `siid=3`, `piid=7` | `xiaomiKettleV20Lifted.lifted` |
| Do not disturb | RW | `siid=6`, `piid=1` | `xiaomiKettleV20NoDisturb.noDisturb` |

Heating starts only when the power property is written, so setting the target temperature stores the goal without starting a boil on its own. The lifted flag reports whether the kettle sits on its base.

Not exposed: the fault property reports a raw code, the custom knob temperature, lift-remember, boiling and keep-warm reminders, extended mode, warming time, target mode, and the heat and boil mode strings are app preferences or opaque vendor blobs, the stop-work action duplicates writing power to false, and the knob-setting and local-timing services store button presets and schedules.
