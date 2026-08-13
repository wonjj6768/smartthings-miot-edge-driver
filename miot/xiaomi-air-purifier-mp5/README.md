# Xiaomi Air Purifier MP5

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.mp5`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.mp5`
- specModel: `xiaomi-mp5`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mp5:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirMp5Mode`
- `concertmirror08464.xiaomiAirMp5FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirMp5Anion`
- `concertmirror08464.xiaomiAirMp5Uv`
- `concertmirror08464.xiaomiAirMp5Buzzer`
- `concertmirror08464.xiaomiAirMp5ChildLock`
- `concertmirror08464.xiaomiAirMp5Display`
- `concertmirror08464.xiaomiAirMp5DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirMp5Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirMp5FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| anion | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirMp5Anion` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.xiaomiAirMp5Uv` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirMp5Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirMp5ChildLock` |
| display | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirMp5Display` |
| displayLevel | RW | `siid=7`, `piid=2` | `concertmirror08464.xiaomiAirMp5DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
