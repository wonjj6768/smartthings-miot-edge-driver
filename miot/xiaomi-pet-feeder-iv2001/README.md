# Xiaomi Pet Feeder IV2001

SmartThings Edge LAN driver for the Xiaomi MIoT pet feeder model `xiaomi.feeder.iv2001`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.feeder.iv2001`
- specModel: `xiaomi-iv2001`
- URN: `urn:miot-spec-v2:device:pet-feeder:0000A06C:xiaomi-iv2001:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.feeder.iv2001` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties`, `set_properties`, and `action` with `siid`/`piid`/`aiid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `battery`
- `concertmirror08464.xiaomiFeederIv2001Measure`
- `concertmirror08464.xiaomiFeederIv2001FoodOut`
- `concertmirror08464.xiaomiFeederIv2001Status`
- `concertmirror08464.xiaomiFeederIv2001FoodLeft`
- `concertmirror08464.xiaomiFeederIv2001FoodStuck`
- `concertmirror08464.xiaomiFeederIv2001Desiccant`
- `concertmirror08464.xiaomiFeederIv2001ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Food left level | R | `siid=2`, `piid=6`; `0=normal`, `1=low` | `xiaomiFeederIv2001FoodLeft.foodLeftLevel` |
| Feeding amount | RW | `siid=2`, `piid=7`; 0..150 g | `xiaomiFeederIv2001Measure.targetFeedingMeasure` |
| Food stuck | R | `siid=2`, `piid=10`; `0=normal`, `1=abnormal` | `xiaomiFeederIv2001FoodStuck.foodStuckStatus` |
| Operating status | R | `siid=2`, `piid=26`; `0=idle`, `1=busy` | `xiaomiFeederIv2001Status.operatingStatus` |
| Feed now | Action | `siid=2`, `aiid=1` | `xiaomiFeederIv2001FoodOut.feedNow` |
| Child lock | RW | `siid=3`, `piid=1` | `xiaomiFeederIv2001ChildLock.childLock` |
| Battery level | R | `siid=4`, `piid=1`; % | `battery` |
| Desiccant life | R | `siid=6`, `piid=1`; % | `xiaomiFeederIv2001Desiccant.desiccantLeftLevel` |

Not exposed: the eaten-food counters and repeated status properties in `siid=2` are cumulative statistics, the manual weigh calibration and desiccant reset actions are maintenance-only, and the `siid=5` service holds feeding schedules, display preferences, timezone offsets, and factory-mode diagnostics.
