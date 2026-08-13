# Viomi V10 Heater

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `viomi.heater.v10`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.heater.v10`
- specModel: `viomi-v10`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:viomi-v10:1`
- Driver path: `miot/viomi-heater-v10`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `concertmirror08464.viomiV10Mode`
- `concertmirror08464.viomiV10Screen`
- `concertmirror08464.viomiV10Buzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`; 5..35 C, step 1 | `thermostatHeatingSetpoint` |
| Mode | RW | `siid=2`, `piid=4`; `0=none`, `1=auto`, `2=high`, `3=low` | `concertmirror08464.viomiV10Mode` |
| Screen | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.viomiV10Screen` |
| Buzzer | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.viomiV10Buzzer` |

Not exposed: countdown scheduling, fault, status, working time, and the undocumented wet property are not exposed. This exact spec has no measured-temperature property.
