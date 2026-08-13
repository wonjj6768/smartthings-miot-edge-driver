# Zhimi Air Purifier XA1

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airpurifier.xa1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.xa1`
- specModel: `zhimi-xa1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-xa1:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirXa1Mode`
- `concertmirror08464.zhimiAirXa1FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `tvocMeasurement`
- `concertmirror08464.zhimiAirXa1Anion`
- `concertmirror08464.zhimiAirXa1Buzzer`
- `concertmirror08464.zhimiAirXa1ChildLock`
- `concertmirror08464.zhimiAirXa1Display`
- `concertmirror08464.zhimiAirXa1DisplayLevel`
- `concertmirror08464.zhimiAirXa1ShutterAngle`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirXa1Mode` |
| fanLevel | RW | `siid=2`, `piid=3` | `concertmirror08464.zhimiAirXa1FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| TVOC | R | `siid=3`, `piid=8` | `tvocMeasurement` |
| anion | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirXa1Anion` |
| buzzer | RW | `siid=15`, `piid=1` | `concertmirror08464.zhimiAirXa1Buzzer` |
| childLock | RW | `siid=14`, `piid=1` | `concertmirror08464.zhimiAirXa1ChildLock` |
| display | RW | `siid=6`, `piid=2` | `concertmirror08464.zhimiAirXa1Display` |
| displayLevel | RW | `siid=6`, `piid=3` | `concertmirror08464.zhimiAirXa1DisplayLevel` |
| shutterAngle | RW | `siid=11`, `piid=10` | `concertmirror08464.zhimiAirXa1ShutterAngle` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
