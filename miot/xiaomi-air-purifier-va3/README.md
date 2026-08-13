# Xiaomi Air Purifier VA3

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.va3`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.va3`
- specModel: `xiaomi-va3`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-va3:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirVa3Mode`
- `concertmirror08464.xiaomiAirVa3FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.xiaomiAirVa3Anion`
- `concertmirror08464.xiaomiAirVa3Uv`
- `concertmirror08464.xiaomiAirVa3Buzzer`
- `concertmirror08464.xiaomiAirVa3ChildLock`
- `concertmirror08464.xiaomiAirVa3Display`
- `concertmirror08464.xiaomiAirVa3DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirVa3Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirVa3FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Formaldehyde | R | `siid=3`, `piid=11` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| anion | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirVa3Anion` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.xiaomiAirVa3Uv` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirVa3Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirVa3ChildLock` |
| display | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirVa3Display` |
| displayLevel | RW | `siid=7`, `piid=2` | `concertmirror08464.xiaomiAirVa3DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
