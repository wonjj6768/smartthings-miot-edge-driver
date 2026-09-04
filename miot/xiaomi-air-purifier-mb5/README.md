# Mijia Smart Air Purifier 6

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.mb5`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.mb5`
- specModel: `xiaomi-mb5`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mb5:1:0000D050`
- Basis: `mi_home_cli` records a Mijia Smart Air Purifier 6 LAN response to `get_properties`; the exact-model `com.xiaomi-miio` profile sends local `get_properties` and `set_properties` with explicit `siid`/`piid` mappings.
- Evidence: confirmed. Source: `real-device+homey-miot-local+miot-spec+xiaomi-product`.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirMb5Mode`
- `concertmirror08464.xiaomiAirMb5FanLevel`
- `concertmirror08464.xiaomiAirMb5FavoriteFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `veryFineDustSensor`
- `concertmirror08464.xiaomiAirMb5AirQuality`
- `filterState`
- `concertmirror08464.xiaomiAirMb5Anion`
- `concertmirror08464.xiaomiAirMb5Uv`
- `concertmirror08464.xiaomiAirMb5Buzzer`
- `concertmirror08464.xiaomiAirMb5ChildLock`
- `concertmirror08464.xiaomiAirMb5Display`
- `concertmirror08464.xiaomiAirMb5DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=auto`, `3=sleep`, `5=favorite`, `6=idle` (spec label `None`) | `concertmirror08464.xiaomiAirMb5Mode` |
| Fan level | RW | `siid=2`, `piid=5`; `0=level1`, `1=level2`, `2=level3` | `concertmirror08464.xiaomiAirMb5FanLevel` |
| Favorite fan level | RW | `siid=9`, `piid=1`; `0..11`, step `1` | `concertmirror08464.xiaomiAirMb5FavoriteFanLevel` |
| Humidity | R | `siid=3`, `piid=1`; `0..100%`, step `1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7`; `-30..100 C`, step `0.1` | `temperatureMeasurement` |
| Air quality grade | R | `siid=3`, `piid=3`; `0..5` from Excellent to Hazardous | `concertmirror08464.xiaomiAirMb5AirQuality` |
| PM2.5 | R | `siid=3`, `piid=4`; `0..1000 μg/m³`, step `1` | `dustSensor.fineDustLevel` |
| PM10 | R | `siid=3`, `piid=5`; `0..100`, step `1` | `dustSensor.dustLevel` |
| PM1 | R | `siid=3`, `piid=9`; `0..1000 μg/m³`, step `1` | `veryFineDustSensor` |
| Filter life | R | `siid=4`, `piid=1`; `0..100%`, step `1` | `filterState.filterLifeRemaining` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| Anion | RW | `siid=2`, `piid=6` | `concertmirror08464.xiaomiAirMb5Anion` |
| UV | RW | `siid=2`, `piid=7` | `concertmirror08464.xiaomiAirMb5Uv` |
| Buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirMb5Buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirMb5ChildLock` |
| Display | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirMb5Display` |
| Display brightness | RW | `siid=7`, `piid=2`; `0=dim`, `1=normal` | `concertmirror08464.xiaomiAirMb5DisplayLevel` |

Not exposed: fault diagnostics, filter hour counters, filter/debug tags, AQI heartbeat, country code, motor RPM, reboot cause, private metadata, and device events; the exact spec exposes no separate pet-lock property.
