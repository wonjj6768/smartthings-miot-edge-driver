# Xiaomi Air Conditioner R09

SmartThings Edge LAN driver for the Xiaomi MIoT air conditioner model `xiaomi.airc.r09h00`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airc.r09h00`
- specModel: `xiaomi-r09h00`
- URN: `urn:miot-spec-v2:device:air-conditioner:0000A004:xiaomi-r09h00:4`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.airc.r09h00` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `airConditionerMode`
- `thermostatCoolingSetpoint`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `airConditionerFanMode`
- `concertmirror08464.xiaomiAcR09Humidity`
- `concertmirror08464.xiaomiAcR09VSwing`
- `concertmirror08464.xiaomiAcR09Vane`
- `concertmirror08464.xiaomiAcR09Eco`
- `concertmirror08464.xiaomiAcR09Heater`
- `concertmirror08464.xiaomiAcR09Sleep`
- `concertmirror08464.xiaomiAcR09Dryer`
- `concertmirror08464.xiaomiAcR09SoftWind`
- `concertmirror08464.xiaomiAcR09Filter`
- `concertmirror08464.xiaomiAcR09Alarm`
- `concertmirror08464.xiaomiAcR09Indicator`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=2`; `2=cool`, `3=dry`, `4=fanOnly`, `5=heat` | `airConditionerMode` |
| Target temperature | RW | `siid=2`, `piid=4`; 16..31 C, step 0.5 | `thermostatCoolingSetpoint` |
| ECO | RW | `siid=2`, `piid=7` | `xiaomiAcR09Eco.eco` |
| Auxiliary heater | RW | `siid=2`, `piid=9` | `xiaomiAcR09Heater.auxHeater` |
| Auto dry | RW | `siid=2`, `piid=10` | `xiaomiAcR09Dryer.dryer` |
| Sleep mode | RW | `siid=2`, `piid=11` | `xiaomiAcR09Sleep.sleepMode` |
| Target humidity | RW | `siid=2`, `piid=14`; 0..100 % | `xiaomiAcR09Humidity.targetHumidity` |
| Indirect airflow | RW | `siid=2`, `piid=15` | `xiaomiAcR09SoftWind.softWind` |
| Fan level | RW | `siid=3`, `piid=2`; `0=auto`, `1..8` levels | `airConditionerFanMode` |
| Vertical swing | RW | `siid=3`, `piid=4` | `xiaomiAcR09VSwing.verticalSwing` |
| Vertical vane | RW | `siid=3`, `piid=6`; `0=off`, `1=topRating`, `2=top`, `3=middle`, `4=bottom`, `5=lowerRating`, `6=surround`, `7=upper`, `8=lower` | `xiaomiAcR09Vane.vanePosition` |
| Room temperature | R | `siid=4`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=4`, `piid=9`; percent | `relativeHumidityMeasurement` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiAcR09Alarm.alarm` |
| Indicator light | RW | `siid=6`, `piid=1` and `piid=2`; `off` plus `0=auto`, `1=medium`, `2=high` | `xiaomiAcR09Indicator.indicatorBrightness` |
| Filter life | R | `siid=21`, `piid=1`; 0..101 %, clamped to 100 | `xiaomiAcR09Filter.filterLife` |

The indicator capability combines the light switch and its brightness enum: selecting `off` turns the light off, and any brightness value turns it on before applying the level.

Not exposed: `siid=22` repeats the same filter contract for the second filter element, `power-consumption` and the electricity service are cumulative counters, the air-conditioner-dev-mode, machine-state, flag-bit, system-parm, and favorite-type-data services expose factory tuning or diagnostics, the enhance service duplicates the fan level and carries schedule blobs, and mosquito-repellent applies to a consumable accessory.
