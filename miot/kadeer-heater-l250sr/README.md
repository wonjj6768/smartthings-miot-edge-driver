# Kadeer L250 Heater

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `kadeer.heater.l250sr`.

## Protocol Decision

- Protocol: MIoT
- Model: `kadeer.heater.l250sr`
- specModel: `kadeer-l250sr`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:kadeer-l250sr:1`
- Driver path: `miot/kadeer-heater-l250sr`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `thermostatHeatingSetpoint`
- `concertmirror08464.kadeerL250HeatLevel`
- `concertmirror08464.kadeerL250ChildLock`
- `concertmirror08464.kadeerL250Screen`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=4`; 15..45 C, step 1 | `thermostatHeatingSetpoint` |
| Heat level | RW | `siid=2`, `piid=3`; 1..9, step 1 | `concertmirror08464.kadeerL250HeatLevel` |
| Child lock | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.kadeerL250ChildLock` |
| Screen | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.kadeerL250Screen` |

Not exposed: countdown scheduling, fault, and the undocumented atomization and drying-clothes properties are not exposed because they are auxiliary or their user-facing semantics are not established.
