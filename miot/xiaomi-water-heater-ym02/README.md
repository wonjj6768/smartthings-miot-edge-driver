# Xiaomi Water Heater YM02

SmartThings Edge LAN driver for the Xiaomi MIoT water heater model `xiaomi.waterheater.ym02`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.waterheater.ym02`
- specModel: `xiaomi-ym02`
- URN: `urn:miot-spec-v2:device:water-heater:0000A02A:xiaomi-ym02:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.waterheater.ym02` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiWhYm02Status`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.xiaomiWhYm02Mode`
- `concertmirror08464.xiaomiWhYm02WaterLevel`
- `concertmirror08464.xiaomiWhYm02AntiIcing`
- `concertmirror08464.xiaomiWhYm02Sterilize`
- `concertmirror08464.xiaomiWhYm02SterilizeTimer`
- `concertmirror08464.xiaomiWhYm02SterilizeCycle`
- `concertmirror08464.xiaomiWhYm02Screen`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=6` | `switch` |
| Status | R | `siid=2`, `piid=5`; `0=off`, `1=keep warm`, `2=heating`, `3=disinfect` | `xiaomiWhYm02Status.heaterStatus` |
| Water temperature | R | `siid=2`, `piid=3`; celsius | `temperatureMeasurement` |
| Target temperature | RW | `siid=2`, `piid=2`; 30..75 C | `thermostatHeatingSetpoint.heatingSetpoint` |
| Heating mode | RW | `siid=2`, `piid=4`; `0=quick`, `1=eco` | `xiaomiWhYm02Mode.heatMode` |
| Water level | R | `siid=2`, `piid=8`; `0..4` | `xiaomiWhYm02WaterLevel.waterLevel` |
| Antifreeze | R | `siid=2`, `piid=9`; `0=normal`, `1=active` | `xiaomiWhYm02AntiIcing.antiIcing` |
| Sterilization | RW | `siid=4`, `piid=1` | `xiaomiWhYm02Sterilize.sterilize` |
| Sterilization timer | RW | `siid=4`, `piid=2` | `xiaomiWhYm02SterilizeTimer.sterilizeTimer` |
| Sterilization interval | RW | `siid=4`, `piid=3`; 1..120 hours | `xiaomiWhYm02SterilizeCycle.sterilizeCycle` |
| Display brightness | RW | `siid=3`, `piid=2`; three levels | `xiaomiWhYm02Screen.screenBrightness` |

Not exposed: the fault property reports a raw 32-bit code, the preheat and staggered timers carry schedule strings, `power-consumption` is a cumulative counter, and the sterilization start time is a minute-of-day schedule value.
