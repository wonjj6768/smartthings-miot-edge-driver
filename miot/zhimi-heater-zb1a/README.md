# Smartmi Heater ZB1A

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.zb1a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.zb1a`
- specModel: `zhimi-zb1a`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-zb1a:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.heater.zb1a` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterZb1aBuzzer`
- `concertmirror08464.zhimiHeaterZb1aChildLock`
- `concertmirror08464.zhimiZb1aIndicatorBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=2` | `switch` |
| Target temperature | RW | `siid=2`, `piid=6`, `16..28 C` | `thermostatHeatingSetpoint` |
| Buzzer | RW | `siid=3`, `piid=1` | `zhimiHeaterZb1aBuzzer.buzzer` |
| Relative humidity | R | `siid=5`, `piid=7`, percent | `relativeHumidityMeasurement` |
| Current temperature | R | `siid=5`, `piid=8`, Celsius | `temperatureMeasurement` |
| Child lock | RW | `siid=7`, `piid=1` | `zhimiHeaterZb1aChildLock.childLock` |
| Indicator brightness | RW | `siid=6`, `piid=1`, `0..2 %`, step 1 | `zhimiZb1aIndicatorBrightness.indicatorBrightness` |

Not exposed: broad fault range, countdown, button, and use time are auxiliary or internal.
