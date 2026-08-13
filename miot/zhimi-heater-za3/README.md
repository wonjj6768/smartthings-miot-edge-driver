# Smartmi Heater ZA3

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.za3`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.za3`
- specModel: `zhimi-za3`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-za3:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.heater.za3` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterZa3Mode`
- `concertmirror08464.zhimiHeaterZa3IndicatorLight`
- `concertmirror08464.zhimiHeaterZa3BuzzerV2`
- `concertmirror08464.zhimiHeaterZa3ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`, `18..28 C` | `thermostatHeatingSetpoint` |
| Mode | RW | `siid=2`, `piid=7`, `0=Auto`, `1=Continus Heating` | `zhimiHeaterZa3Mode.heaterMode` |
| Current temperature | R | `siid=4`, `piid=7`, Celsius | `temperatureMeasurement` |
| Child lock | RW | `siid=5`, `piid=1` | `zhimiHeaterZa3ChildLock.childLock` |
| Buzzer | RW | `siid=6`, `piid=1` | `zhimiHeaterZa3BuzzerV2.buzzer` |
| Indicator light | RW | `siid=7`, `piid=1` | `zhimiHeaterZa3IndicatorLight.indicatorLight` |

Not exposed: fault/status, duplicate heater temperature, countdown, cron expression/log, device use time, and plug temperature are auxiliary, duplicate, or diagnostic values.
