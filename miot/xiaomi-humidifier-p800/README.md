# Xiaomi Humidifier P800

SmartThings Edge LAN driver for the Xiaomi/MIoT xiaomi humidifier p800 model `xiaomi.humidifier.p800`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.p800`
- specModel: `xiaomi-p800`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-p800:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.humidifier.p800` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. This model is not `deerma.humidifier.jsq5`.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.xiaomiHumP800FanMode`
- `concertmirror08464.xiaomiHumP800TargetHumidity`
- `concertmirror08464.xiaomiHumP800Buzzer`
- `concertmirror08464.xiaomiHumP800ChildLock`
- `concertmirror08464.xiaomiHumP800LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| xiaomi Hum P800 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.xiaomiHumP800FanMode` |
| xiaomi Hum P800 Target Humidity | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.xiaomiHumP800TargetHumidity` |
| xiaomi Hum P800 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.xiaomiHumP800Buzzer` |
| xiaomi Hum P800 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.xiaomiHumP800ChildLock` |
| xiaomi Hum P800 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.xiaomiHumP800LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
