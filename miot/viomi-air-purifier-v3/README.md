# Viomi Air Purifier V3

SmartThings Edge LAN driver for the Viomi MIoT air purifier model `viomi.airp.v3`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.airp.v3`
- specModel: `viomi-v3`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:viomi-v3:1`
- Basis: current `hass-xiaomi-miot` lists exact model `viomi.airp.v3` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.viomiAirV3Mode`
- `dustSensor`
- `concertmirror08464.viomiAirV3FilterLife`
- `concertmirror08464.viomiAirV3Uv`
- `concertmirror08464.viomiAirV3Indicator`
- `concertmirror08464.viomiAirV3Buzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=strong`, `1=smart`, `2=sleep` | `viomiAirV3Mode.airPurifierMode` |
| PM2.5 | R | `siid=3`, `piid=1` | `dustSensor.fineDustLevel` |
| Filter life | R | `siid=7`, `piid=1`; percent | `viomiAirV3FilterLife.filterLife` |
| UV sterilization | RW | `siid=2`, `piid=7` | `viomiAirV3Uv.uv` |
| Indicator light | RW | `siid=5`, `piid=1` | `viomiAirV3Indicator.indicatorLight` |
| Buzzer | RW | `siid=6`, `piid=1` | `viomiAirV3Buzzer.buzzer` |

Not exposed: the fault property reports a raw code, the air quality enum restates the PM2.5 density that `dustSensor` already reports, the standard filter service declares no properties on this model, and the strainer hour counter is a cumulative stat.
