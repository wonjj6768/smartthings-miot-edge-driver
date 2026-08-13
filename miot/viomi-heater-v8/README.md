# Viomi Heater V8

SmartThings Edge LAN driver for exact model `viomi.heater.v8`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.heater.v8`
- specModel: `viomi-v8`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:viomi-v8:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `temperatureMeasurement`
- `concertmirror08464.viomiHeatV8Mode`
- `concertmirror08464.viomiHeatV8Screen`
- `concertmirror08464.viomiHeatV8Buzzer`
- `concertmirror08464.viomiHeatV8ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 10..35 C, step 1 | `thermostatHeatingSetpoint` |
| Temperature | R | `siid=2`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=4`; 3=low, 4=high | `concertmirror08464.viomiHeatV8Mode` |
| Screen | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV8Screen` |
| Buzzer | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV8Buzzer` |
| Child lock | RW | `siid=8`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV8ChildLock` |

Not exposed: countdown, working time, and ambiguous duplicate E fault codes are omitted. Generic device fault/fault-code and operating-status diagnostics are not exposed.
