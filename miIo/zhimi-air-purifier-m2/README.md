# Zhimi Air Purifier M2

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier m2 model `zhimi.airpurifier.m2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.m2`
- Basis: An exact `zhimi.airpurifier.m2` v1.4.3_105 device returned its status through authenticated LAN `get_prop`; python-miio also lists this model under classic `AirPurifier(Device)` support.
- Evidence: confirmed. Source: real-device+python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirM2AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirM2FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirM2Buzzer`
- `concertmirror08464.zhimiAirM2ChildLock`
- `concertmirror08464.zhimiAirM2LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Mode | RW | `mode`, `set_mode`; `auto`, `silent`, `favorite` | `concertmirror08464.zhimiAirM2AirPurifierMode` |
| Temperature | R | `temp_dec`, divide by 10 for °C | `temperatureMeasurement` |
| Humidity | R | `humidity`, % | `relativeHumidityMeasurement` |
| PM2.5 | R | `aqi`, µg/m³ | `fineDustSensor` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirM2FavoriteFanLevel` |
| Filter life | R / Action | `filter1_life`, %; `reset_filter1` with no arguments | `filterState` |
| Buzzer | RW | `buzzer`, `set_buzzer` | `concertmirror08464.zhimiAirM2Buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` | `concertmirror08464.zhimiAirM2ChildLock` |
| LED brightness | RW | `led` / `led_b`, `set_led` / `set_led_b` | `concertmirror08464.zhimiAirM2LedBrightness` |
| Refresh | Action | `get_prop` for the status property list | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
