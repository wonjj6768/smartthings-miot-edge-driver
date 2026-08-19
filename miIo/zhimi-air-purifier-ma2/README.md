# Zhimi Air Purifier MA2

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier ma2 model `zhimi.airpurifier.ma2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.ma2`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; MIoT spec exists but does not determine the LAN helper.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMa2AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirMa2FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirMa2Buzzer`
- `concertmirror08464.zhimiAirMa2ChildLock`
- `concertmirror08464.zhimiAirMa2LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Ma2 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa2AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirMa2FavoriteFanLevel` |
| filter State | R | Model-specific property/method constants in `src/init.lua` | `filterState` |
| zhimi Air Ma2 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa2Buzzer` |
| zhimi Air Ma2 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa2ChildLock` |
| zhimi Air Ma2 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
