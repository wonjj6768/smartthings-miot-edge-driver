# Xiaomi Air Purifier MP4

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.mp4`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.mp4`
- specModel: `xiaomi-mp4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mp4:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirMp4Mode`
- `concertmirror08464.xiaomiAirMp4FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirMp4Anion`
- `concertmirror08464.xiaomiAirMp4Buzzer`
- `concertmirror08464.xiaomiAirMp4ChildLock`
- `concertmirror08464.xiaomiAirMp4DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirMp4Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirMp4FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| anion | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirMp4Anion` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirMp4Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirMp4ChildLock` |
| displayLevel | RW | `siid=13`, `piid=1` | `concertmirror08464.xiaomiAirMp4DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
