# Zhimi Air Purifier SA1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier sa1 model `zhimi.airpurifier.sa1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.sa1`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; no exact air-purifier MIoT URN was found in the local catalog.
- Evidence: confirmed. Source: python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirSa1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirSa1Buzzer`
- `concertmirror08464.zhimiAirSa1ChildLock`
- `concertmirror08464.zhimiAirSa1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Sa1 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa1AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific property/method constants in `src/init.lua` | `filterState` |
| zhimi Air Sa1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa1Buzzer` |
| zhimi Air Sa1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa1ChildLock` |
| zhimi Air Sa1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
