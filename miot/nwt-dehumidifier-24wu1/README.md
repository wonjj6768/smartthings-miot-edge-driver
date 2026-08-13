# NWT Dehumidifier 24WU1

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `nwt.derh.24wu1`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.derh.24wu1`
- specModel: `nwt-24wu1`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-24wu1:1`
- Basis: current `hass-xiaomi-miot` lists exact model `nwt.derh.24wu1` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.nwtDerh24wuMode`
- `concertmirror08464.nwtDerh24wuTargetHumidity`
- `concertmirror08464.nwtDerh24wuFanLevel`
- `concertmirror08464.nwtDerh24wuDryClothes`
- `concertmirror08464.nwtDerh24wuSwing`
- `concertmirror08464.nwtDerh24wuUv`
- `concertmirror08464.nwtDerh24wuIndicatorLight`
- `concertmirror08464.nwtDerh24wuAlarm`
- `concertmirror08464.nwtDerh24wuChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `0=auto`, `1=dry`, `2=circle`, `3=close` | `nwtDerh24wuMode.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..70 %, step 10 | `nwtDerh24wuTargetHumidity.targetHumidity` |
| Fan level | RW | `siid=2`, `piid=7`; `0=low`, `1=medium`, `2=high` | `nwtDerh24wuFanLevel.fanLevel` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Buzzer | RW | `siid=4`, `piid=1` | `nwtDerh24wuAlarm.alarm` |
| Indicator light | RW | `siid=5`, `piid=1` | `nwtDerh24wuIndicatorLight.indicatorLight` |
| Child lock | RW | `siid=6`, `piid=1` | `nwtDerh24wuChildLock.childLock` |
| Clothes drying | RW | `siid=7`, `piid=1`; `0=automatic`, `1=weak`, `2=strong`, `3=close` | `nwtDerh24wuDryClothes.dryClothes` |
| Swing | RW | `siid=7`, `piid=2`; `0=automatic`, `1=leftRight`, `2=upDown`, `3=cancel` | `nwtDerh24wuSwing.swing` |
| UV sterilization | RW | `siid=7`, `piid=3`; `0=automatic`, `1=weak`, `2=strong`, `3=close` | `nwtDerh24wuUv.uv` |

Not exposed: device fault only reports `E2`/`E4`/`E5`/`E9` diagnostic codes, and the read-only flags at `siid=7`, `piid=5` and `piid=6` are undocumented auxiliary values in the exact spec.
