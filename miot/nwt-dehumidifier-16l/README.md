# NWT Dehumidifier 16L

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `nwt.fan.16l`.

## Protocol Decision

- Protocol: MIoT
- Model: `nwt.fan.16l`
- specModel: `nwt-16l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:nwt-16l:2`
- Basis: current `hass-xiaomi-miot` lists exact model `nwt.fan.16l` in `MIOT_LOCAL_MODELS` and has no `MIIO_TO_MIOT_SPECS` conversion for it, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract; the model id says `fan` but the exact device type is a dehumidifier.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.nwtDerh16lMode`
- `concertmirror08464.nwtDerh16lTargetHumidity`
- `concertmirror08464.nwtDerh16lIndicatorLight`
- `concertmirror08464.nwtDerh16lAlarm`
- `concertmirror08464.nwtDerh16lTankStatus`
- `concertmirror08464.nwtDerh16lDefrost`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target humidity | RW | `siid=2`, `piid=3`; 30..90 %, step 5 | `nwtDerh16lTargetHumidity.targetHumidity` |
| Mode | RW | `siid=2`, `piid=4`; `1=dry`, `2=clothesDrying` | `nwtDerh16lMode.mode` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Buzzer | RW | `siid=4`, `piid=1` | `nwtDerh16lAlarm.alarm` |
| Indicator light | RW | `siid=5`, `piid=1` | `nwtDerh16lIndicatorLight.indicatorLight` |
| Water tank full | R | `siid=6`, `piid=1`; `true=full`, `false=normal` | `nwtDerh16lTankStatus.tankStatus` |
| Defrosting | R | `siid=6`, `piid=2`; `true=defrosting`, `false=idle` | `nwtDerh16lDefrost.defrostStatus` |

Not exposed: device fault only reports `E1`/`E2`/`E4` diagnostic codes, and filter-cleaning reminder at `siid=6`, `piid=3` is an auxiliary maintenance flag rather than a core SmartThings control.
