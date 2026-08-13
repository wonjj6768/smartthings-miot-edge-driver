# Zhimi Air Purifier SA4

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.sa4`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.sa4`
- specModel: `zhimi-sa4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-sa4:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirSa4Mode`
- `concertmirror08464.zhimiAirSa4FanLevel`
- `concertmirror08464.zhimiAirSa4FavoriteFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.zhimiAirSa4Buzzer`
- `concertmirror08464.zhimiAirSa4ChildLock`
- `concertmirror08464.zhimiAirSa4DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirSa4Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirSa4FanLevel` |
| favoriteFanLevel (0-9) | RW | `siid=15`, `piid=1` | `concertmirror08464.zhimiAirSa4FavoriteFanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Formaldehyde | R | `siid=3`, `piid=11` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirSa4Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.zhimiAirSa4ChildLock` |
| displayLevel | RW | `siid=7`, `piid=2` | `concertmirror08464.zhimiAirSa4DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
