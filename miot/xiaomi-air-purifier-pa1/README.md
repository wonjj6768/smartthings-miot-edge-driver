# Xiaomi Air Purifier PA1

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.pa1`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.pa1`
- specModel: `xiaomi-pa1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-pa1:2:0000D050`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirPa1Mode`
- `concertmirror08464.xiaomiAirPa1FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirPa1Anion`
- `concertmirror08464.xiaomiAirPa1Uv`
- `concertmirror08464.xiaomiAirPa1Buzzer`
- `concertmirror08464.xiaomiAirPa1ChildLock`
- `concertmirror08464.xiaomiAirPa1Display`
- `concertmirror08464.xiaomiAirPa1DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=3` | `concertmirror08464.xiaomiAirPa1Mode` |
| fanLevel | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirPa1FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| anion | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirPa1Anion` |
| uv | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirPa1Uv` |
| buzzer | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirPa1Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirPa1ChildLock` |
| display | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirPa1Display` |
| displayLevel | RW | `siid=6`, `piid=2` | `concertmirror08464.xiaomiAirPa1DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
