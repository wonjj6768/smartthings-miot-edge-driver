# Deye Z12 Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `deye.derh.z12a3`.

## Protocol Decision

- Protocol: MIoT
- Model: `deye.derh.z12a3`
- specModel: `deye-z12a3`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:deye-z12a3:2`
- Driver path: `miot/deye-dehumidifier-z12a3`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deyeZ12Mode`
- `concertmirror08464.deyeZ12TargetHumidity`
- `concertmirror08464.deyeZ12FanLevel`
- `concertmirror08464.deyeZ12ChildLock`
- `concertmirror08464.deyeZ12TankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=auto`, `2=clothesDrying` | `concertmirror08464.deyeZ12Mode` |
| Target humidity | RW | `siid=2`, `piid=5`; `25=h25`, `30=h30`, `35=h35`, `40=h40`, `45=h45`, `50=h50`, `55=h55`, `60=h60`, `65=h65`, `70=h70`, `75=h75`, `80=h80` | `concertmirror08464.deyeZ12TargetHumidity` |
| Fan level | RW | `siid=2`, `piid=7`; `1=low`, `3=high` | `concertmirror08464.deyeZ12FanLevel` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.deyeZ12ChildLock` |
| Tank status | R | `siid=7`, `piid=1`; `0=normal`, `1=full` | `concertmirror08464.deyeZ12TankStatus` |

Not exposed: fault codes, frost, and fan-state are diagnostic values and are not exposed.
