# Smartmi Heater MA5

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.ma5`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.ma5`
- specModel: `zhimi-ma5`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-ma5:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.heater.ma5` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterMa5Mode`
- `concertmirror08464.zhimiHeaterMa5Buzzer`
- `concertmirror08464.zhimiHeaterMa5ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`, `16..28 C` | `thermostatHeatingSetpoint` |
| Mode | RW | `siid=2`, `piid=7`, `0=Auto`, `1=LL Heating`, `2=Continus Heating` | `zhimiHeaterMa5Mode.heaterMode` |
| Current temperature | R | `siid=4`, `piid=7`, Celsius | `temperatureMeasurement` |
| Relative humidity | R | `siid=4`, `piid=1`, percent | `relativeHumidityMeasurement` |
| Child lock | RW | `siid=5`, `piid=1` | `zhimiHeaterMa5ChildLock.childLock` |
| Buzzer | RW | `siid=6`, `piid=1` | `zhimiHeaterMa5Buzzer.buzzer` |

Not exposed: fault/status, duplicate heater temperature, countdown, cron expression/log, serial number, and device use time are auxiliary, duplicate, or internal values.
