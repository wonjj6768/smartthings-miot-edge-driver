# Deye U20 Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `deye.derh.u20a3`.

## Protocol Decision

- Protocol: MIoT
- Model: `deye.derh.u20a3`
- specModel: `deye-u20a3`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:deye-u20a3:1`
- Driver path: `miot/deye-dehumidifier-u20a3`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deyeU20Mode`
- `concertmirror08464.deyeU20FanLevel`
- `concertmirror08464.deyeU20ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=dehumidify`, `1=purify`, `2=clothesDrying`, `3=auto`, `4=sleep` | `concertmirror08464.deyeU20Mode` |
| Fan level | RW | `siid=2`, `piid=7`; `1=low`, `2=medium`, `3=high`, `4=turbo` | `concertmirror08464.deyeU20FanLevel` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.deyeU20ChildLock` |

Not exposed: target humidity 0..11 and user-defined water values 0/1 have no documented semantic conversion and are intentionally not exposed. Fault, frost, fan-state, and anion are diagnostics or auxiliary controls.
