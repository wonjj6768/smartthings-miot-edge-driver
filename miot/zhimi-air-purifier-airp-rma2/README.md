# Zhimi Air Purifier AirP RMA2

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airp.rma2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.rma2`
- specModel: `zhimi-rma2`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-rma2:1`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirAirpRma2Mode`
- `concertmirror08464.zhimiAirAirpRma2FanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirAirpRma2Buzzer`
- `concertmirror08464.zhimiAirAirpRma2ChildLock`
- `concertmirror08464.zhimiAirAirpRma2DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.zhimiAirAirpRma2Mode` |
| fanLevel | RW | `siid=11`, `piid=1` | `concertmirror08464.zhimiAirAirpRma2FanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| buzzer | RW | `siid=5`, `piid=1` | `concertmirror08464.zhimiAirAirpRma2Buzzer` |
| childLock | RW | `siid=6`, `piid=1` | `concertmirror08464.zhimiAirAirpRma2ChildLock` |
| displayLevel | RW | `siid=7`, `piid=2` | `concertmirror08464.zhimiAirAirpRma2DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
