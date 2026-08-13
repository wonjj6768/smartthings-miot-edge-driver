# Xiaomi Curtain ACN009

SmartThings Edge LAN driver for the Xiaomi MIoT curtain motor model `xiaomi.curtain.acn009`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.curtain.acn009`
- specModel: `xiaomi-acn009`
- URN: `urn:miot-spec-v2:device:curtain:0000A00C:xiaomi-acn009:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.curtain.acn009` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `windowShade`
- `windowShadeLevel`
- `concertmirror08464.xiaomiCurtainAcn009Speed`
- `concertmirror08464.xiaomiCurtainAcn009Reverse`
- `concertmirror08464.xiaomiCurtainAcn009ManualDraw`
- `concertmirror08464.xiaomiCurtainAcn009Indicator`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Open, close, pause | W | `siid=2`, `piid=2`; `0=pause`, `1=open`, `2=close` | `windowShade` |
| Motion status | R | `siid=2`, `piid=3`; `0=stop`, `1=opening`, `2=closing` | `windowShade` |
| Current position | R | `siid=2`, `piid=4`; 0..100 % | `windowShadeLevel` |
| Target position | RW | `siid=2`, `piid=5`; 0..100 % | `windowShadeLevel.setShadeLevel` |
| Motor reverse | RW | `siid=2`, `piid=6` | `xiaomiCurtainAcn009Reverse.motorReverse` |
| Speed level | RW | `siid=2`, `piid=8`; `0=low`, `1=medium`, `2=high` | `xiaomiCurtainAcn009Speed.speedLevel` |
| Manual draw | RW | `siid=2`, `piid=9`; `0=enable`, `1=disable` | `xiaomiCurtainAcn009ManualDraw.manualDraw` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiCurtainAcn009Indicator.indicatorLight` |

`windowShade` combines the motion status and current position: a stopped curtain resolves to open, closed, or partially open from the reported position.

Not exposed: wake-up mode, travel point, and whole-journey time are calibration values, the toggle motor-control option duplicates open and close, and the remote-control management, identify, and custom-function services hold pairing state, aging tests, rail length, and curtain weight diagnostics.
