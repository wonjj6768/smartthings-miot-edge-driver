# Xiaomi Air Purifier RMB3

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.rmb3`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.rmb3`
- specModel: `xiaomi-rmb3`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-rmb3:2:0000D050`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirRmb3Mode`
- `concertmirror08464.xiaomiAirRmb3FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirRmb3Buzzer`
- `concertmirror08464.xiaomiAirRmb3ChildLock`
- `concertmirror08464.xiaomiAirRmb3DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=3` | `concertmirror08464.xiaomiAirRmb3Mode` |
| fanLevel | RW | `siid=9`, `piid=1` | `concertmirror08464.xiaomiAirRmb3FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| buzzer | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirRmb3Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirRmb3ChildLock` |
| displayLevel | RW | `siid=6`, `piid=2` | `concertmirror08464.xiaomiAirRmb3DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
