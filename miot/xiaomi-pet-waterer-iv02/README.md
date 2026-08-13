# Xiaomi Pet Waterer IV02

SmartThings Edge LAN driver for the Xiaomi MIoT pet drinking fountain model `xiaomi.pet_waterer.iv02`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.pet_waterer.iv02`
- specModel: `xiaomi-iv02`
- URN: `urn:miot-spec-v2:device:pet-drinking-fountain:0000A067:xiaomi-iv02:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.pet_waterer.iv02` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `battery`
- `concertmirror08464.xiaomiPetWaterIv02Mode`
- `concertmirror08464.xiaomiPetWaterIv02Interval`
- `concertmirror08464.xiaomiPetWaterIv02Status`
- `concertmirror08464.xiaomiPetWaterIv02WaterShortage`
- `concertmirror08464.xiaomiPetWaterIv02FilterLife`
- `concertmirror08464.xiaomiPetWaterIv02PumpBlock`
- `concertmirror08464.xiaomiPetWaterIv02ChildLock`
- `concertmirror08464.xiaomiPetWaterIv02NoDisturb`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Operating status | R | `siid=2`, `piid=3`; `1=waterless`, `2=watering` | `xiaomiPetWaterIv02Status.operatingStatus` |
| Mode | RW | `siid=2`, `piid=4`; `0=auto`, `1=interval`, `2=constant` | `xiaomiPetWaterIv02Mode.mode` |
| Water shortage | R | `siid=2`, `piid=10`; `true=shortage`, `false=normal` | `xiaomiPetWaterIv02WaterShortage.waterShortage` |
| Water out interval | RW | `siid=2`, `piid=11`; 10..120 min, step 5 | `xiaomiPetWaterIv02Interval.outWaterInterval` |
| Filter life | R | `siid=3`, `piid=1`; % | `xiaomiPetWaterIv02FilterLife.filterLifeLevel` |
| Child lock | RW | `siid=4`, `piid=1` | `xiaomiPetWaterIv02ChildLock.childLock` |
| Battery level | R | `siid=5`, `piid=1`; % | `battery` |
| Do not disturb | RW | `siid=6`, `piid=1` | `xiaomiPetWaterIv02NoDisturb.noDisturb` |
| Pump blocked | R | `siid=9`, `piid=12`; `true=blocked`, `false=normal` | `xiaomiPetWaterIv02PumpBlock.pumpBlock` |

Not exposed: the legacy `siid=2`, `piid=7` interval duplicates `piid=11` with a coarser step, filter left time and reset action are maintenance values, charging state duplicates battery reporting, and the remaining `siid=9` properties are event timestamps, timezone offsets, and factory-mode diagnostics.
