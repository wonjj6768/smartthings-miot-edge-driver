# Xiaomi Air Conditioner C38

SmartThings Edge LAN driver for the Xiaomi MIoT air conditioner model `xiaomi.aircondition.c38`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.aircondition.c38`
- specModel: `xiaomi-c38`
- URN: `urn:miot-spec-v2:device:air-conditioner:0000A004:xiaomi-c38:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.aircondition.c38` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `airConditionerMode`
- `thermostatCoolingSetpoint`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `airConditionerFanMode`
- `concertmirror08464.xiaomiAcC38Humidity`
- `concertmirror08464.xiaomiAcC38HSwing`
- `concertmirror08464.xiaomiAcC38VSwing`
- `concertmirror08464.xiaomiAcC38Vane`
- `concertmirror08464.xiaomiAcC38Eco`
- `concertmirror08464.xiaomiAcC38Heater`
- `concertmirror08464.xiaomiAcC38Sleep`
- `concertmirror08464.xiaomiAcC38Dryer`
- `concertmirror08464.xiaomiAcC38SoftWind`
- `concertmirror08464.xiaomiAcC38Alarm`
- `concertmirror08464.xiaomiAcC38Indicator`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=2`; `2=cool`, `3=dry`, `4=fanOnly`, `5=heat` | `airConditionerMode` |
| Target temperature | RW | `siid=2`, `piid=4`; 16..31 C, step 0.5 | `thermostatCoolingSetpoint` |
| ECO | RW | `siid=2`, `piid=7` | `xiaomiAcC38Eco.eco` |
| Auxiliary heater | RW | `siid=2`, `piid=9` | `xiaomiAcC38Heater.auxHeater` |
| Auto dry | RW | `siid=2`, `piid=10` | `xiaomiAcC38Dryer.dryer` |
| Sleep mode | RW | `siid=2`, `piid=11` | `xiaomiAcC38Sleep.sleepMode` |
| Target humidity | RW | `siid=2`, `piid=14`; 0..100 % | `xiaomiAcC38Humidity.targetHumidity` |
| Indirect airflow | RW | `siid=2`, `piid=15` | `xiaomiAcC38SoftWind.softWind` |
| Fan level | RW | `siid=3`, `piid=2`; `0=auto`, `1..7` levels, `8=max` | `airConditionerFanMode` |
| Horizontal swing | RW | `siid=3`, `piid=3` | `xiaomiAcC38HSwing.horizontalSwing` |
| Vertical swing | RW | `siid=3`, `piid=4` | `xiaomiAcC38VSwing.verticalSwing` |
| Horizontal vane | RW | `siid=3`, `piid=5`; `0=off`, `1=leftSweep`, `2=freezeLeft`, `3=middleSweep`, `4=freezeRight`, `5=rightSweep` | `xiaomiAcC38Vane.vanePosition` |
| Room temperature | R | `siid=4`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=4`, `piid=9`; percent | `relativeHumidityMeasurement` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiAcC38Alarm.alarm` |
| Indicator light | RW | `siid=6`, `piid=1` and `piid=2`; `off` plus `1=medium`, `2=high` | `xiaomiAcC38Indicator.indicatorBrightness` |

The indicator capability combines the light switch and its brightness enum: selecting `off` turns the light off, and any brightness value turns it on before applying the level.

Not exposed: the enhance `fan-percent` duplicates the fan level, the enhance `timer` and `sleep-diy` values carry schedule blobs, `room-size` and `maxfan-select` are comfort presets, `power-consumption` is a cumulative counter, and the machine-state, flag-bit, iot-linkage, countdown, electricity, maintenance, and single-smart-scene services expose vendor diagnostics or automation state.
