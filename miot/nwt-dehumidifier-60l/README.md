# NWT Dehumidifier 60L

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `nwt.derh.60l`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.derh.60l`
- specModel: `nwt-60l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-60l:1`
- Basis: current `hass-xiaomi-miot` lists exact model `nwt.derh.60l` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.nwtDerh60lMode`
- `concertmirror08464.nwtDerh60lTargetHumidity`
- `concertmirror08464.nwtDerh60lFanLevel`
- `concertmirror08464.nwtDerh60lIndicatorLight`
- `concertmirror08464.nwtDerh60lAlarm`
- `concertmirror08464.nwtDerh60lChildLock`
- `concertmirror08464.nwtDerh60lDrainage`
- `concertmirror08464.nwtDerh60lTankStatus`
- `concertmirror08464.nwtDerh60lDefrost`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `0=clothesDrying`, `1=dry`, `2=circle` | `nwtDerh60lMode.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..70 %, step 5 | `nwtDerh60lTargetHumidity.targetHumidity` |
| Fan level | RW | `siid=2`, `piid=7`; `0=low`, `1=medium`, `2=high` | `nwtDerh60lFanLevel.fanLevel` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Buzzer | RW | `siid=4`, `piid=1` | `nwtDerh60lAlarm.alarm` |
| Indicator light | RW | `siid=5`, `piid=1` | `nwtDerh60lIndicatorLight.indicatorLight` |
| Continuous drainage | RW | `siid=6`, `piid=1` | `nwtDerh60lDrainage.drainage` |
| Water tank full | R | `siid=6`, `piid=2`; `true=full`, `false=normal` | `nwtDerh60lTankStatus.tankStatus` |
| Defrosting | R | `siid=6`, `piid=3`; `true=defrosting`, `false=idle` | `nwtDerh60lDefrost.defrostStatus` |
| Child lock | RW | `siid=7`, `piid=1` | `nwtDerh60lChildLock.childLock` |

Not exposed: device fault only reports `E2`/`E4`/`E5` diagnostic codes, and the screen reminder flag at `siid=6`, `piid=4` is an auxiliary display hint rather than a core SmartThings control.
