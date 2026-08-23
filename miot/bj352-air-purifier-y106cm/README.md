# BJ352 Air Purifier Y106CM

SmartThings Edge LAN driver for the BJ352 MIoT air purifier model `bj352.airp.y106cm`.

## Protocol Decision

- Protocol: MIoT
- Model: `bj352.airp.y106cm`
- specModel: `bj352-y106cm`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:bj352-y106cm:1`
- Basis: current `hass-xiaomi-miot` lists exact model `bj352.airp.y106cm` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.bj352AirY106Mode`
- `concertmirror08464.bj352AirY106FanLevel`
- `dustSensor`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `tvocMeasurement`
- `formaldehydeMeasurement`
- `filterState`
- `concertmirror08464.bj352AirY106FilterRight`
- `concertmirror08464.bj352AirY106Anion`
- `concertmirror08464.bj352AirY106Indicator`
- `concertmirror08464.bj352AirY106Screen`
- `concertmirror08464.bj352AirY106ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `1=auto`, `2=sleep`, `4=manual` | `bj352AirY106Mode.airPurifierMode` |
| Fan level | RW | `siid=2`, `piid=5`; `1..5` | `bj352AirY106FanLevel.fanLevel` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor.fineDustLevel` |
| Room temperature | R | `siid=3`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=3`, `piid=1`; percent | `relativeHumidityMeasurement` |
| TVOC | R | `siid=3`, `piid=9`; mg/m^3 | `tvocMeasurement.tvocLevel` |
| Formaldehyde | R | `siid=3`, `piid=11`; mg/m^3 | `formaldehydeMeasurement.formaldehydeLevel` |
| Left filter life | R | `siid=4`, `piid=1`; percent | `filterState.filterLifeRemaining` |
| Reset left filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| Right filter life | R | `siid=11`, `piid=1`; percent | `bj352AirY106FilterRight.filterLife` |
| Anion | RW | `siid=2`, `piid=6` | `bj352AirY106Anion.anion` |
| Indicator light | RW | `siid=5`, `piid=1` | `bj352AirY106Indicator.indicatorLight` |
| Display | RW | `siid=9`, `piid=2` | `bj352AirY106Screen.screen` |
| Child lock | RW | `siid=8`, `piid=1` | `bj352AirY106ChildLock.childLock` |

The device carries two filter elements, so the left filter uses the standard `filterState` capability and the right filter uses a dedicated read-only life level.

Not exposed: the air quality index and air quality enum restate the PM2.5 density that `dustSensor` already reports, `siid=2` `piid=7..12` are unnamed vendor status and fault codes, the `other-features` child lock duplicates `siid=8`, the filter serial strings are identifiers rather than device state, and the smart-mode PM and formaldehyde thresholds are automation configuration.
