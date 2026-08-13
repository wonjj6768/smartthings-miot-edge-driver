# Xiaomi Heater MA7

SmartThings Edge LAN driver for exact model `xiaomi.heater.ma7`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.heater.ma7`
- specModel: `xiaomi-ma7`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:xiaomi-ma7:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `temperatureMeasurement`
- `concertmirror08464.xiaomiHeatMa7HeatLevel`
- `concertmirror08464.xiaomiHeatMa7ChildLock`
- `concertmirror08464.xiaomiHeatMa7Buzzer`
- `concertmirror08464.xiaomiHeatMa7Screen`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 16..28 C, step 1 | `thermostatHeatingSetpoint` |
| Temperature | R | `siid=4`, `piid=7` | `temperatureMeasurement` |
| Heat level | RW | `siid=2`, `piid=6`; 0=normal, 1=low, 2=high | `concertmirror08464.xiaomiHeatMa7HeatLevel` |
| Child lock | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa7ChildLock` |
| Buzzer | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa7Buzzer` |
| Screen | RW | `siid=10`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHeatMa7Screen` |

Not exposed: delay service, crontab strings, and private raw state are omitted. Generic device fault/fault-code and operating-status diagnostics are not exposed.
