# Zhimi Air Purifier MC2

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier mc2 model `zhimi.airpurifier.mc2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.mc2`
- Basis: python-miio lists this under classic AirPurifier miIO support; MIoT spec exists but does not determine the LAN helper.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMc2AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `fanSpeedPercent`
- `filterState`
- `concertmirror08464.zhimiAirMc2Buzzer`
- `concertmirror08464.zhimiAirMc2ChildLock`
- `concertmirror08464.zhimiAirMc2LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Mc2 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc2AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` mapped to `0..100 %` | `fanSpeedPercent` |
| filter State | R | Model-specific property/method constants in `src/init.lua` | `filterState` |
| zhimi Air Mc2 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc2Buzzer` |
| zhimi Air Mc2 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc2ChildLock` |
| zhimi Air Mc2 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
