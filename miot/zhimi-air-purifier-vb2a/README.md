# Zhimi Air Purifier VB2A

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.vb2a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.vb2a`
- specModel: `zhimi-vb2a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-vb2a:1`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirVb2aMode`
- `concertmirror08464.zhimiAirVb2aFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirVb2aBuzzer`
- `concertmirror08464.zhimiAirVb2aChildLock`
- `concertmirror08464.zhimiAirVb2aDisplay`
- `concertmirror08464.zhimiAirVb2aDisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=2` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirVb2aMode` |
| fanLevel | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirVb2aFanLevel` |
| Humidity | R | `siid=3`, `piid=7` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=8` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=6` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=3` | `filterState` |
| buzzer | RW | `siid=5`, `piid=1` | `concertmirror08464.zhimiAirVb2aBuzzer` |
| childLock | RW | `siid=7`, `piid=1` | `concertmirror08464.zhimiAirVb2aChildLock` |
| display | RW | `siid=6`, `piid=6` | `concertmirror08464.zhimiAirVb2aDisplay` |
| displayLevel | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirVb2aDisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
