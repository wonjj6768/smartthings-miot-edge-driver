# Dmaker Air Purifier F20

SmartThings Edge LAN driver for the Dmaker MIoT air purifier model `dmaker.airpurifier.f20`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.airpurifier.f20`
- specModel: `dmaker-f20`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:dmaker-f20:2`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.airpurifier.f20` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.dmakerAirF20Mode`
- `dustSensor`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.dmakerAirF20DoorOpen`
- `concertmirror08464.dmakerAirF20Screen`
- `concertmirror08464.dmakerAirF20Brightness`
- `concertmirror08464.dmakerAirF20Buzzer`
- `concertmirror08464.dmakerAirF20Volume`
- `concertmirror08464.dmakerAirF20ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=auto`, `1=sleep`, `2..4=level1..3`, `5=favorite` | `dmakerAirF20Mode.airPurifierMode` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor.fineDustLevel` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor.dustLevel` |
| Room temperature | R | `siid=3`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=3`, `piid=1`; percent | `relativeHumidityMeasurement` |
| Filter life | R | `siid=4`, `piid=1`; percent; exact spec has no reset action | `filterState.filterLifeRemaining` |
| Cover open | R | `siid=2`, `piid=6` | `dmakerAirF20DoorOpen.doorOpen` |
| Display | RW | `siid=7`, `piid=1` | `dmakerAirF20Screen.screen` |
| Display brightness | RW | `siid=7`, `piid=2`; 0..100 | `dmakerAirF20Brightness.screenBrightness` |
| Buzzer | RW | `siid=6`, `piid=1` | `dmakerAirF20Buzzer.buzzer` |
| Buzzer volume | RW | `siid=6`, `piid=2`; 0..100 | `dmakerAirF20Volume.buzzerVolume` |
| Child lock | RW | `siid=8`, `piid=1` | `dmakerAirF20ChildLock.childLock` |

Not exposed: the fault property reports a raw 16-bit code, `siid=2` `piid=7` mirrors the same mode enum so it would duplicate one device setting with two controls, the filter time and airflow counters are cumulative stats, and the `dm-sevice` favorite speed, motor feedback, filter events, and PM debug values are vendor tuning fields.
