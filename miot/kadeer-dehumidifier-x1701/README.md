# Kadeer X1701 Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `kadeer.derh.x1701`.

## Protocol Decision

- Protocol: MIoT
- Model: `kadeer.derh.x1701`
- specModel: `kadeer-x1701`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:kadeer-x1701:1`
- Driver path: `miot/kadeer-dehumidifier-x1701`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.kadeerX1701Mode`
- `concertmirror08464.kadeerX1701TargetHumidity`
- `concertmirror08464.kadeerX1701FanLevel`
- `concertmirror08464.kadeerX1701TankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=7` | `relativeHumidityMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=airy`, `1=ordinary`, `2=clothesDrying` | `concertmirror08464.kadeerX1701Mode` |
| Target humidity | RW | `siid=2`, `piid=4`; `30=h30`, `35=h35`, `40=h40`, `45=h45`, `50=h50`, `55=h55`, `60=h60`, `65=h65`, `70=h70`, `75=h75`, `80=h80` | `concertmirror08464.kadeerX1701TargetHumidity` |
| Fan level | RW | `siid=3`, `piid=6`; `0=low`, `1=high` | `concertmirror08464.kadeerX1701FanLevel` |
| Tank status | R | `siid=3`, `piid=3`; `0=normal`, `1=full` | `concertmirror08464.kadeerX1701TankStatus` |

Not exposed: close timer, defrost state, sleep toggle, anion, and fault are auxiliary or diagnostic values.
