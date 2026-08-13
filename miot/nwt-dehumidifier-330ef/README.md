# NWT 330ef Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `nwt.derh.330ef`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.derh.330ef`
- specModel: `nwt-330ef`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-330ef:1`
- Driver path: `miot/nwt-dehumidifier-330ef`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.nwt330efMode`
- `concertmirror08464.nwt330efTargetHumidity`
- `concertmirror08464.nwt330efFanLevel`
- `concertmirror08464.nwt330efBuzzer`
- `concertmirror08464.nwt330efIndicatorLight`
- `concertmirror08464.nwt330efChildLock`
- `concertmirror08464.nwt330efTankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `1=auto`, `2=smart`, `3=clothesDrying` | `concertmirror08464.nwt330efMode` |
| Target humidity | RW | `siid=2`, `piid=5`; `30=h30`, `40=h40`, `50=h50`, `60=h60`, `70=h70` | `concertmirror08464.nwt330efTargetHumidity` |
| Fan level | RW | `siid=2`, `piid=7`; `0=off`, `1=levelOne`, `2=levelTwo`, `3=levelThree` | `concertmirror08464.nwt330efFanLevel` |
| Buzzer | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.nwt330efBuzzer` |
| Indicator light | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.nwt330efIndicatorLight` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.nwt330efChildLock` |
| Tank status | R | `siid=7`, `piid=3`; `false=normal`, `true=full` | `concertmirror08464.nwt330efTankStatus` |

Not exposed: the drainage pump, pump-pipe presence, undocumented timer/timer-setting enum, coil temperature, compressor/defrost/fall-down state, and fault are auxiliary or diagnostic and are not exposed.
