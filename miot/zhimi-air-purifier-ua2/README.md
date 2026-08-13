# Zhimi Air Purifier UA2

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.ua2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.ua2`
- specModel: `zhimi-ua2`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-ua2:3`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirUa2Mode`
- `concertmirror08464.zhimiAirUa2FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.zhimiAirUa2Uv`
- `concertmirror08464.zhimiAirUa2Buzzer`
- `concertmirror08464.zhimiAirUa2ChildLock`
- `concertmirror08464.zhimiAirUa2Display`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirUa2Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirUa2FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Formaldehyde | R | `siid=3`, `piid=6` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.zhimiAirUa2Uv` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirUa2Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirUa2ChildLock` |
| display | RW | `siid=7`, `piid=1` | `concertmirror08464.zhimiAirUa2Display` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
