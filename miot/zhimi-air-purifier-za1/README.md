# Zhimi Air Purifier ZA1

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier za1 model `zhimi.airpurifier.za1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.za1`
- specModel: `zhimi-za1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-za1:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_ZA1; use the air-purifier URN and za1-specific piid mapping.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirZa1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirZa1Buzzer`
- `concertmirror08464.zhimiAirZa1ChildLock`
- `concertmirror08464.zhimiAirZa1LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Za1 Air Purifier Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirZa1AirPurifierMode` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Za1 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirZa1Buzzer` |
| zhimi Air Za1 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirZa1ChildLock` |
| zhimi Air Za1 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirZa1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
