# Viomi Heater V9

SmartThings Edge LAN driver for exact model `viomi.heater.v9`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.heater.v9`
- specModel: `viomi-v9`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:viomi-v9:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `temperatureMeasurement`
- `concertmirror08464.viomiHeatV9Mode`
- `concertmirror08464.viomiHeatV9Humidifier`
- `concertmirror08464.viomiHeatV9Screen`
- `concertmirror08464.viomiHeatV9Buzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 5..35 C, step 1 | `thermostatHeatingSetpoint` |
| Temperature | R | `siid=2`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=4`; 1=auto, 2=strong | `concertmirror08464.viomiHeatV9Mode` |
| Humidifier | RW | `siid=4`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV9Humidifier` |
| Screen | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV9Screen` |
| Buzzer | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.viomiHeatV9Buzzer` |

Not exposed: countdown, working time, and ambiguous duplicate E fault codes are omitted. The secondary humidifier switch remains a separate exact control. Generic device fault/fault-code and operating-status diagnostics are not exposed.
