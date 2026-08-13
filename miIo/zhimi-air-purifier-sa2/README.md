# Zhimi Air Purifier SA2

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier sa2 model `zhimi.airpurifier.sa2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.sa2`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; MIoT spec exists but does not determine the LAN helper.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirSa2AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirSa2Buzzer`
- `concertmirror08464.zhimiAirSa2ChildLock`
- `concertmirror08464.zhimiAirSa2LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Sa2 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa2AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific property/method constants in `src/init.lua` | `filterState` |
| zhimi Air Sa2 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa2Buzzer` |
| zhimi Air Sa2 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa2ChildLock` |
| zhimi Air Sa2 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirSa2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
