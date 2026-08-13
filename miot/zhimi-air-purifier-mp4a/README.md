# Zhimi Air Purifier MP4A

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.mp4a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mp4a`
- specModel: `zhimi-mp4a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mp4a:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMp4aMode`
- `concertmirror08464.zhimiAirMp4aFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMp4aAnion`
- `concertmirror08464.zhimiAirMp4aBuzzer`
- `concertmirror08464.zhimiAirMp4aChildLock`
- `concertmirror08464.zhimiAirMp4aDisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirMp4aMode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirMp4aFanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| anion | RW | `siid=2`, `piid=6` | `concertmirror08464.zhimiAirMp4aAnion` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirMp4aBuzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirMp4aChildLock` |
| displayLevel | RW | `siid=13`, `piid=2` | `concertmirror08464.zhimiAirMp4aDisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
