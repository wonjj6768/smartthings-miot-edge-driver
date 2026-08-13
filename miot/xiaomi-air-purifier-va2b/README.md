# Xiaomi Air Purifier VA2B

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.va2b`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.va2b`
- specModel: `xiaomi-va2b`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-va2b:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirVa2bMode`
- `concertmirror08464.xiaomiAirVa2bFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirVa2bAnion`
- `concertmirror08464.xiaomiAirVa2bBuzzer`
- `concertmirror08464.xiaomiAirVa2bChildLock`
- `concertmirror08464.xiaomiAirVa2bDisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirVa2bMode` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.xiaomiAirVa2bFanLevel` |
| Humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| anion | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirVa2bAnion` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirVa2bBuzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirVa2bChildLock` |
| displayLevel | RW | `siid=13`, `piid=1` | `concertmirror08464.xiaomiAirVa2bDisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
