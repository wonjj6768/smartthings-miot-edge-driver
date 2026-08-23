# Zhimi Air Purifier M1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier m1 model `zhimi.airpurifier.m1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.m1`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; MIoT spec exists but does not determine the LAN helper.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirM1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirM1FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirM1Buzzer`
- `concertmirror08464.zhimiAirM1ChildLock`
- `concertmirror08464.zhimiAirM1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air M1 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirM1AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirM1FavoriteFanLevel` |
| Filter life | R / Action | `filter1_life`, %; `reset_filter1` with no arguments | `filterState` |
| zhimi Air M1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirM1Buzzer` |
| zhimi Air M1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirM1ChildLock` |
| zhimi Air M1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirM1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
