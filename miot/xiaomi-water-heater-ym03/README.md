# Xiaomi Water Heater YM03

SmartThings Edge LAN driver for the Xiaomi MIoT water heater model `xiaomi.waterheater.ym03`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.waterheater.ym03`
- specModel: `xiaomi-ym03`
- URN: `urn:miot-spec-v2:device:water-heater:0000A02A:xiaomi-ym03:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.waterheater.ym03` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.xiaomiWhYm03Status`
- `concertmirror08464.xiaomiWhYm03Mode`
- `concertmirror08464.xiaomiWhYm03WaterLevel`
- `concertmirror08464.xiaomiWhYm03Sterilize`
- `concertmirror08464.xiaomiWhYm03Screen`
- `concertmirror08464.xiaomiWhYm03FilterLife`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=6` | `switch` |
| Target temperature | RW | `siid=2`, `piid=2`; 30..80 C | `thermostatHeatingSetpoint` |
| Water temperature | R | `siid=2`, `piid=3`; celsius | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=4`; `0=single`, `1=largeVolume` | `xiaomiWhYm03Mode.mode` |
| Operating status | R | `siid=2`, `piid=5`; `0=close`, `1=keepWarm`, `2=heating`, `3=disinfect` | `xiaomiWhYm03Status.operatingStatus` |
| Water level | R | `siid=2`, `piid=8`; `0..4` levels | `xiaomiWhYm03WaterLevel.waterLevel` |
| Screen brightness | RW | `siid=3`, `piid=2`; `0=levelOne`, `1=levelTwo`, `2=levelThree` | `xiaomiWhYm03Screen.screenBrightness` |
| Sterilization | RW | `siid=4`, `piid=1` | `xiaomiWhYm03Sterilize.sterilization` |
| Filter life | R | `siid=5`, `piid=1`; % | `xiaomiWhYm03FilterLife.filterLifeLevel` |

Not exposed: the fault property reports a raw 32-bit code with no documented enum, preheat and staggered timers plus the sterilization schedule are scheduling values, anti-icing status is a protection flag, and power consumption is a cumulative statistic.
