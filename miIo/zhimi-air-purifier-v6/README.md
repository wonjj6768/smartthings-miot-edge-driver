# Xiaomi Mi Air Purifier Pro (AC-M3-CA)

SmartThings Edge LAN driver for the Xiaomi Mi Air Purifier Pro product code `AC-M3-CA`, model `zhimi.airpurifier.v6`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.v6`
- Product code: `AC-M3-CA`
- Basis: `python-miio` lists `zhimi.airpurifier.v6` in the classic Zhimi air purifier miIO integration and documents `favorite_level` with `set_level_favorite` range `0..17`.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirV6AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `concertmirror08464.zhimiAirV6FavoriteFanLevel`
- `filterState`
- `concertmirror08464.zhimiAirV6Buzzer`, `concertmirror08464.zhimiAirV6ChildLock`, `concertmirror08464.zhimiAirV6LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Mode | RW | `mode`, `set_mode`; `auto`, `silent`, `favorite` | `zhimiAirPurifierClassicMode.airPurifierMode` |
| Favorite speed | RW | `favorite_level`, `set_level_favorite`; `0..17` raw level | `concertmirror08464.zhimiAirV6FavoriteFanLevel` |
| PM2.5 | R | `aqi` | `fineDustSensor` |
| Humidity | R | `humidity`; % | `relativeHumidityMeasurement` |
| Temperature | R | `temp_dec`; celsius x10 | `temperatureMeasurement` |
| Filter life | R | `filter1_life`, %; exact v6 rejects `reset_filter1` with `-6009 not_support` | `filterState` |
| LED brightness | RW | `led`, `led_b`, `set_led`, `set_led_b`; `0=bright`, `1=dim`, `2=off` | `xiaomiDeviceControls.ledBrightness` |
| Buzzer | RW | `buzzer`, `set_buzzer` | `xiaomiDeviceControls.buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` | `xiaomiDeviceControls.childLock` |

Not exposed: average AQI, motor RPM, usage time, purify volume, RFID/filter metadata, sound volume, learn mode, and auto-detect settings because they are diagnostic, auxiliary, or not core controls for this port.
