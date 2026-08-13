# Xiaomi Heater MA8

SmartThings Edge LAN driver for exact model `xiaomi.heater.ma8`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.heater.ma8`
- specModel: `xiaomi-ma8`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:xiaomi-ma8:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `temperatureMeasurement`
- `fanOscillationMode`
- `concertmirror08464.xiaomiHeatMa8Mode`
- `concertmirror08464.xiaomiHeatMa8ChildLock`
- `concertmirror08464.xiaomiHeatMa8Buzzer`
- `concertmirror08464.xiaomiHeatMa8IndicatorLight`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 22..28 C, step 1 | `thermostatHeatingSetpoint` |
| Temperature | R | `siid=4`, `piid=1` | `temperatureMeasurement` |
| Horizontal swing | RW | `siid=8`, `piid=3`; bool | `fanOscillationMode` |
| Mode | RW | `siid=2`, `piid=4`; 0=constantTemperature, 1=naturalWind, 2=warm, 3=heat | `concertmirror08464.xiaomiHeatMa8Mode` |
| Child lock | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa8ChildLock` |
| Buzzer | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa8Buzzer` |
| Indicator light | RW | `siid=10`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa8IndicatorLight` |

Not exposed: delay service and private crontab strings are omitted. The exact boolean horizontal-swing property maps to standard fanOscillationMode off/horizontal. Generic device fault/fault-code and operating-status diagnostics are not exposed.
