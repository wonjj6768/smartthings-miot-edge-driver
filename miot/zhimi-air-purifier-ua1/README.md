# Zhimi Air Purifier UA1

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.ua1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.ua1`
- specModel: `zhimi-ua1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-ua1:4`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirUa1Mode`
- `concertmirror08464.zhimiAirUa1FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.zhimiAirUa1Uv`
- `concertmirror08464.zhimiAirUa1Plasma`
- `concertmirror08464.zhimiAirUa1Buzzer`
- `concertmirror08464.zhimiAirUa1ChildLock`
- `concertmirror08464.zhimiAirUa1Display`
- `concertmirror08464.zhimiUa1DisplayBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirUa1Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirUa1FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Formaldehyde | R | `siid=3`, `piid=6` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.zhimiAirUa1Uv` |
| plasma | RW | `siid=2`, `piid=6` | `concertmirror08464.zhimiAirUa1Plasma` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirUa1Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirUa1ChildLock` |
| display | RW | `siid=13`, `piid=1` | `concertmirror08464.zhimiAirUa1Display` |
| Display brightness level | R | `siid=9`, `piid=12`, 0..4 | `concertmirror08464.zhimiUa1DisplayBrightness` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
