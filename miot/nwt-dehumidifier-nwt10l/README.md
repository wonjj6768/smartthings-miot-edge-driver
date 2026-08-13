# NWT 10l Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `nwt.derh.nwt10l`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.derh.nwt10l`
- specModel: `nwt-nwt10l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-nwt10l:1`
- Driver path: `miot/nwt-dehumidifier-nwt10l`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.nwt10lMode`
- `concertmirror08464.nwt10lTargetHumidity`
- `concertmirror08464.nwt10lBuzzer`
- `concertmirror08464.nwt10lIndicatorLight`
- `concertmirror08464.nwt10lTankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=dry`, `1=clothesDrying` | `concertmirror08464.nwt10lMode` |
| Target humidity | RW | `siid=2`, `piid=5`; `30=h30`, `40=h40`, `50=h50`, `60=h60` | `concertmirror08464.nwt10lTargetHumidity` |
| Buzzer | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.nwt10lBuzzer` |
| Indicator light | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.nwt10lIndicatorLight` |
| Tank status | R | `siid=7`, `piid=1`; `false=normal`, `true=full` | `concertmirror08464.nwt10lTankStatus` |

Not exposed: fault codes and defrosting are diagnostic values and are not exposed.
