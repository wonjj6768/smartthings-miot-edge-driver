# Smartmi Heater MA2

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.ma2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.ma2`
- specModel: `zhimi-ma2`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-ma2:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.heater.ma2` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterMa2Buzzer`
- `concertmirror08464.zhimiHeaterMa2ChildLock`
- `concertmirror08464.zhimiMa2IndicatorBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`, `18..28 C` | `thermostatHeatingSetpoint` |
| Current temperature | R | `siid=4`, `piid=7`, Celsius | `temperatureMeasurement` |
| Child lock | RW | `siid=5`, `piid=1` | `zhimiHeaterMa2ChildLock.childLock` |
| Buzzer | RW | `siid=6`, `piid=1` | `zhimiHeaterMa2Buzzer.buzzer` |
| Indicator brightness | RW | `siid=7`, `piid=3`, `0..1 %`, step 1 | `zhimiMa2IndicatorBrightness.indicatorBrightness` |

Not exposed: fault range, countdown, button, hardware enable, and use time are auxiliary or internal.
