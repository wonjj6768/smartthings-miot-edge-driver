# Zhimi Air Purifier MA1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier ma1 model `zhimi.airpurifier.ma1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.ma1`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; no exact air-purifier MIoT URN was found in the local catalog.
- Evidence: confirmed. Source: python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMa1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirMa1FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirMa1Buzzer`
- `concertmirror08464.zhimiAirMa1ChildLock`
- `concertmirror08464.zhimiAirMa1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Ma1 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa1AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirMa1FavoriteFanLevel` |
| Filter life | R / Action | `filter1_life`, %; `reset_filter1` with no arguments | `filterState` |
| zhimi Air Ma1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa1Buzzer` |
| zhimi Air Ma1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa1ChildLock` |
| zhimi Air Ma1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMa1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
