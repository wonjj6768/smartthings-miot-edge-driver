# Zhimi Air Purifier MEA1

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.mea1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mea1`
- specModel: `zhimi-mea1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mea1:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMea1Mode`
- `concertmirror08464.zhimiAirMea1FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMea1Uv`
- `concertmirror08464.zhimiAirMea1Plasma`
- `concertmirror08464.zhimiAirMea1Buzzer`
- `concertmirror08464.zhimiAirMea1ChildLock`
- `concertmirror08464.zhimiAirMea1DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirMea1Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirMea1FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=8` | `dustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.zhimiAirMea1Uv` |
| plasma | RW | `siid=2`, `piid=6` | `concertmirror08464.zhimiAirMea1Plasma` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirMea1Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirMea1ChildLock` |
| displayLevel | RW | `siid=13`, `piid=2` | `concertmirror08464.zhimiAirMea1DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
