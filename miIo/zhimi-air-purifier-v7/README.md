# Zhimi Air Purifier V7

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier v7 model `zhimi.airpurifier.v7`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.v7`
- Basis: python-miio lists this under classic AirPurifier(Device) miIO support; MIoT spec exists but does not determine the LAN helper.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirV7AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirV7FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirV7Buzzer`
- `concertmirror08464.zhimiAirV7ChildLock`
- `concertmirror08464.zhimiAirV7IndicatorLight`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air V7 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirV7AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirV7FavoriteFanLevel` |
| Filter life | R | `filter1_life`, %; exact V7 sources expose no reset action | `filterState` |
| zhimi Air V7 Buzzer | RW | `volume`, `set_volume`; `0` = off, `100` = on | `concertmirror08464.zhimiAirV7Buzzer` |
| zhimi Air V7 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirV7ChildLock` |
| Indicator light | RW | `led`, `set_led`; `on` / `off` | `concertmirror08464.zhimiAirV7IndicatorLight` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
