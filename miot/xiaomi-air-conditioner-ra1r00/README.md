# Xiaomi Air Conditioner RA1

SmartThings Edge LAN driver for the Xiaomi MIoT air conditioner model `xiaomi.airc.ra1r00`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airc.ra1r00`
- specModel: `xiaomi-ra1r00`
- URN: `urn:miot-spec-v2:device:air-conditioner:0000A004:xiaomi-ra1r00:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.airc.ra1r00` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `airConditionerMode`
- `thermostatCoolingSetpoint`
- `temperatureMeasurement`
- `airConditionerFanMode`
- `concertmirror08464.xiaomiAircRa1HSwing`
- `concertmirror08464.xiaomiAircRa1VSwing`
- `concertmirror08464.xiaomiAircRa1Eco`
- `concertmirror08464.xiaomiAircRa1Sleep`
- `concertmirror08464.xiaomiAircRa1Dryer`
- `concertmirror08464.xiaomiAircRa1Alarm`
- `concertmirror08464.xiaomiAircRa1Indicator`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=2`; `2=cool`, `3=dry`, `4=fanOnly` | `airConditionerMode` |
| Target temperature | RW | `siid=2`, `piid=4`; 16..31 C, step 0.5 | `thermostatCoolingSetpoint` |
| ECO | RW | `siid=2`, `piid=7` | `xiaomiAircRa1Eco.eco` |
| Auto dry | RW | `siid=2`, `piid=10` | `xiaomiAircRa1Dryer.dryer` |
| Sleep mode | RW | `siid=2`, `piid=11` | `xiaomiAircRa1Sleep.sleepMode` |
| Fan level | RW | `siid=3`, `piid=2`; `0=auto`, `1..7` levels | `airConditionerFanMode` |
| Horizontal swing | RW | `siid=3`, `piid=3` | `xiaomiAircRa1HSwing.horizontalSwing` |
| Vertical swing | RW | `siid=3`, `piid=4` | `xiaomiAircRa1VSwing.verticalSwing` |
| Room temperature | R | `siid=4`, `piid=7`; celsius | `temperatureMeasurement` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiAircRa1Alarm.alarm` |
| Indicator light | RW | `siid=6`, `piid=1` and `piid=2`; `off` plus `0=auto`, `1=medium`, `2=high` | `xiaomiAircRa1Indicator.indicatorBrightness` |

The indicator capability combines the light switch and its brightness enum: selecting `off` turns the light off, and any brightness value turns it on before applying the level.

Not exposed: the fault property reports a raw 32-bit code, soft wind and favorite settings plus max level and low-watt level are comfort presets, wind direction and the fixed vane positions duplicate the swing controls with vendor-specific vane names, and the electricity service only carries a runtime counter.
