# NWT Dehumidifier 312EN

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `nwt.derh.312en`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.derh.312en`
- specModel: `nwt-312en`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-312en:2`
- Basis: current `hass-xiaomi-miot` lists exact model `nwt.derh.312en` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.nwtDehum312enMode`, `concertmirror08464.nwtDehum312enTargetHumidity`, `concertmirror08464.nwtDehum312enChildLock`, `concertmirror08464.nwtDehum312enIndicatorLight`, `concertmirror08464.nwtDehum312enAlarm`
- `concertmirror08464.nwtDerh312enStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `1=smart`, `2=clothesDrying` | `nwtDerh312enControls.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; `30=continuous`, `40/50/60/70 %` | `nwtDerh312enControls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7`; celsius | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `nwtDerh312enControls.alarm` |
| Indicator light | RW | `siid=5`, `piid=1` | `nwtDerh312enControls.indicatorLight` |
| Child lock | RW | `siid=6`, `piid=1` | `nwtDerh312enControls.childLock` |
| Water tank status | R | `siid=7`, `piid=3`; `true=fullOrRemoved`, `false=normal` | `nwtDerh312enStatus.tankStatus` |

Not exposed: fault only reports `0=noFaults` in the spec, fan level has only `0=auto` and `1=level1`, and coil/compressor/defrost diagnostics are auxiliary values rather than core SmartThings controls.
