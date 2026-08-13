# Viomi V5 Heater

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `viomi.heater.v5`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.heater.v5`
- specModel: `viomi-v5`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:viomi-v5:1`
- Driver path: `miot/viomi-heater-v5`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.viomiV5Mode`
- `concertmirror08464.viomiV5Humidifier`
- `concertmirror08464.viomiV5Screen`
- `concertmirror08464.viomiV5Buzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 5..35 C, step 1 | `thermostatHeatingSetpoint` |
| Measured temperature | R | `siid=2`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=4`; `1=auto`, `2=strong` | `concertmirror08464.viomiV5Mode` |
| Humidifier | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.viomiV5Humidifier` |
| Screen | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.viomiV5Screen` |
| Buzzer | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.viomiV5Buzzer` |

Not exposed: countdown scheduling, fault, status, working time, and the humidifier fault field are diagnostic or auxiliary values and are not exposed.
