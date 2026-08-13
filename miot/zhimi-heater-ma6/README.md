# Smartmi Heater MA6

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.ma6`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.ma6`
- specModel: `zhimi-ma6`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-ma6:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.heater.ma6` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterMa6Mode`
- `concertmirror08464.zhimiHeaterMa6HeatLevel`
- `concertmirror08464.zhimiHeaterMa6LowWater`
- `concertmirror08464.zhimiHeaterMa6Buzzer`
- `concertmirror08464.zhimiHeaterMa6ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Low-water state | R | `siid=2`, `piid=2`, `0=normal`, `1=other fault`, `2=LowWater` | `zhimiHeaterMa6LowWater.lowWaterStatus` |
| Target temperature | RW | `siid=2`, `piid=3`, `16..28 C` | `thermostatHeatingSetpoint` |
| Raw mode | RW | `siid=2`, `piid=4`, `Mode1..Mode4` | `zhimiHeaterMa6Mode.heaterMode` |
| Heat level | RW | `siid=2`, `piid=5`, `0/Low/High` | `zhimiHeaterMa6HeatLevel.heatLevel` |
| Relative humidity | R | `siid=4`, `piid=1`, percent | `relativeHumidityMeasurement` |
| Current temperature | R | `siid=4`, `piid=2`, Celsius | `temperatureMeasurement` |
| Child lock | RW | `siid=5`, `piid=1` | `zhimiHeaterMa6ChildLock.childLock` |
| Buzzer | RW | `siid=6`, `piid=1` | `zhimiHeaterMa6Buzzer.buzzer` |

Not exposed: countdown, cron expression/log, delay-power-off internals, and private timer values are auxiliary; raw mode labels intentionally remain Mode 1 through Mode 4 because the spec provides no semantic names.
