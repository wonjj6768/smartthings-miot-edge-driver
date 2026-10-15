# Mijia Smart Air Purifier Max

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.mb6`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.mb6`
- specModel: `xiaomi-mb6`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mb6:1:0000D050`
- Basis: [openHAB's exact MB6 implementation](https://github.com/openhab/openhab-addons/blob/bc92359394b0d3b86b3b29b076811edb76a28648/bundles/org.openhab.binding.miio/src/main/resources/database/xiaomi.airp.mb6-miot.json) maps local `get_properties`, `set_properties`, and `action` calls to explicit `siid`/`piid`/`aiid`. Its direct connection uses the configured host and token. Reads preserve its `maxProperties=1` contract.
- Evidence: confirmed. Source: `openhab-local+miot-spec+xiaomi-product`. [Upstream PR #21935](https://github.com/openhab/openhab-addons/pull/21935), merged October 12, 2026, marks this mapping **experimental and not tested on hardware**. This driver has not been verified on an installed hub or physical MB6.
- Contract: [exact MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn%3Amiot-spec-v2%3Adevice%3Aair-purifier%3A0000A007%3Axiaomi-mb6%3A1%3A0000D050). Product identity: [Xiaomi product page](https://www.mi.com/global/product/mijia-air-purifier-max/) and [FAQ](https://www.mi.com/global/support/faq/details/KA-649478/).

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirMb6Mode`
- `concertmirror08464.xiaomiAirMb6FanLevel`
- `concertmirror08464.xiaomiAirMb6FavoriteFanLevel`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `dustSensor`
- `veryFineDustSensor`
- `formaldehydeMeasurement`
- `concertmirror08464.xiaomiAirMb6AirQuality`
- `filterState`
- `concertmirror08464.xiaomiAirMb6Uv`
- `concertmirror08464.xiaomiAirMb6Display`
- `concertmirror08464.xiaomiAirMb6DisplayLevel`
- `concertmirror08464.xiaomiAirMb6Buzzer`
- `concertmirror08464.xiaomiAirMb6ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `2/1`, boolean | `switch` |
| Mode | RW | `2/3`; `0=auto`, `3=sleep`, `5=favorite`, `6=level` | `xiaomiAirMb6Mode.mode` |
| Fan level | RW | `2/4`; `0=level1`, `1=level2`, `2=level3` | `xiaomiAirMb6FanLevel.fanLevel` |
| Favorite fan level | RW | `9/1`; integers `0..10` | `xiaomiAirMb6FavoriteFanLevel.favoriteFanLevel` |
| Humidity | R | `3/1`; `0..100 %`, step 1 | `relativeHumidityMeasurement` |
| Temperature | R | `3/2`; `-30..100 C`, step 0.1 | `temperatureMeasurement` |
| PM2.5 / PM10 | R | `3/4` (`0..600`) / `3/5` (`0..100`); μg/m³ | `dustSensor.fineDustLevel` / `dustLevel` |
| PM1 | R | `3/9`; `0..1000 μg/m³` | `veryFineDustSensor.veryFineDustLevel` |
| Formaldehyde | R | `3/6`; `0..1 mg/m³`, step 0.001; no concentration conversion | `formaldehydeMeasurement.formaldehydeLevel`, unit `mg/m^3` |
| Air quality | R | `3/3`; `0=excellent` through `5=hazardous` | `xiaomiAirMb6AirQuality.airQuality` |
| Filter life | R | `4/1`; `0..100 %` | `filterState.filterLifeRemaining` |
| Reset filter | Action | `siid=4`, `aiid=1`, empty input array | `filterState.resetFilter` |
| UV | RW | `2/6`, boolean | `xiaomiAirMb6Uv.uv` |
| Display | RW | `6/1`, boolean | `xiaomiAirMb6Display.display` |
| Display brightness | RW | `6/2`; `0=dim`, `1=normal`, `2=medium` | `xiaomiAirMb6DisplayLevel.displayLevel` |
| Buzzer | RW | `7/1`, boolean | `xiaomiAirMb6Buzzer.buzzer` |
| Child lock | RW | `8/1`, boolean | `xiaomiAirMb6ChildLock.childLock` |

The spec labels mode `6` as `None`; the exact upstream mapping and Xiaomi's speed-level UI identify it as the level mode. Fan-level and favorite-level commands change their own settings; select the corresponding mode to use them. Successful writes and filter reset are followed by a fresh read. Failed reads preserve the previous state and log the property and error.

Not exposed: raw device fault diagnostics, filter-hour counters, RFID tags, debug writes, motor RPM, reboot causes, country settings, AQI heartbeat, private formaldehyde/debug data, and toggle actions that duplicate explicit controls. This exact model has no anion property.
