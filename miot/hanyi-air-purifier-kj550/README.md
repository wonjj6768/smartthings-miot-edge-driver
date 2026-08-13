# Hanyi Air Purifier KJ550

SmartThings Edge LAN driver for the Hanyi MIoT air purifier model `hanyi.airpurifier.kj550`.

## Protocol Decision

- Protocol: MIoT
- Model: `hanyi.airpurifier.kj550`
- specModel: `hanyi-kj550`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:hanyi-kj550:1`
- Basis: current `hass-xiaomi-miot` lists exact model `hanyi.airpurifier.kj550` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.hanyiAirKj550Mode`
- `concertmirror08464.hanyiAirKj550FanSpeed`
- `dustSensor`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.hanyiAirKj550FilterTime`
- `concertmirror08464.hanyiAirKj550Anion`
- `concertmirror08464.hanyiAirKj550Indicator`
- `concertmirror08464.hanyiAirKj550ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=auto`, `1=sleep`, `2=manual` | `hanyiAirKj550Mode.airPurifierMode` |
| Fan speed | RW | `siid=2`, `piid=5`; 0..100 stepless | `hanyiAirKj550FanSpeed.fanSpeed` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor.fineDustLevel` |
| Room temperature | R | `siid=3`, `piid=5`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=3`, `piid=6`; percent | `relativeHumidityMeasurement` |
| Filter left time | R | `siid=4`, `piid=2`; hours | `hanyiAirKj550FilterTime.filterLeftTime` |
| Anion | RW | `siid=2`, `piid=6` | `hanyiAirKj550Anion.anion` |
| Indicator brightness | RW | `siid=5`, `piid=1`; `0=off`, `1=bright`, `2=dim` | `hanyiAirKj550Indicator.indicatorBrightness` |
| Child lock | RW | `siid=6`, `piid=1` | `hanyiAirKj550ChildLock.childLock` |

The fan level on this model is a stepless 0..100 range rather than discrete stages, so it uses a slider capability instead of a level enum.

Not exposed: the fault property carries a single no-fault value, and the custom service reset flag, timer setters, and remaining countdown values are maintenance and schedule fields.
