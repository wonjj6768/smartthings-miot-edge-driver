# Zhimi Air Purifier UA1A

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.ua1a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.ua1a`
- specModel: `zhimi-ua1a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-ua1a:4`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirUa1aMode`
- `concertmirror08464.zhimiAirUa1aFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.zhimiAirUa1aUv`
- `concertmirror08464.zhimiAirUa1aPlasma`
- `concertmirror08464.zhimiAirUa1aBuzzer`
- `concertmirror08464.zhimiAirUa1aChildLock`
- `concertmirror08464.zhimiAirUa1aDisplay`
- `concertmirror08464.zhimiUa1aDisplayBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirUa1aMode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirUa1aFanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Formaldehyde | R | `siid=3`, `piid=6` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.zhimiAirUa1aUv` |
| plasma | RW | `siid=2`, `piid=6` | `concertmirror08464.zhimiAirUa1aPlasma` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirUa1aBuzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirUa1aChildLock` |
| display | RW | `siid=13`, `piid=1` | `concertmirror08464.zhimiAirUa1aDisplay` |
| Display brightness level | R | `siid=9`, `piid=12`, 0..4 | `concertmirror08464.zhimiUa1aDisplayBrightness` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
