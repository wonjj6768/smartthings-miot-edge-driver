# Xiaomi Air Purifier UA3

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.ua3`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.ua3`
- specModel: `xiaomi-ua3`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-ua3:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirUa3Mode`
- `concertmirror08464.xiaomiAirUa3FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `carbonDioxideMeasurement`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.xiaomiAirUa3Uv`
- `concertmirror08464.xiaomiAirUa3Plasma`
- `concertmirror08464.xiaomiAirUa3Buzzer`
- `concertmirror08464.xiaomiAirUa3ChildLock`
- `concertmirror08464.xiaomiAirUa3Display`
- `concertmirror08464.xiaomiUa3AutoBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirUa3Mode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirUa3FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor` |
| PM10 | R | `siid=3`, `piid=5` | `dustSensor` |
| CO2 | R | `siid=3`, `piid=8` | `carbonDioxideMeasurement` |
| Formaldehyde | R | `siid=3`, `piid=10` | `formaldehydeMeasurement` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| uv | RW | `siid=2`, `piid=7` | `concertmirror08464.xiaomiAirUa3Uv` |
| plasma | RW | `siid=2`, `piid=9` | `concertmirror08464.xiaomiAirUa3Plasma` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirUa3Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirUa3ChildLock` |
| display | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirUa3Display` |
| Automatic display brightness | RW | `siid=7`, `piid=2` | `concertmirror08464.xiaomiUa3AutoBrightness` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
