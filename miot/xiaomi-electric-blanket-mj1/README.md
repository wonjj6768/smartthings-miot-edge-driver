# Xiaomi Electric Blanket MJ1

SmartThings Edge LAN driver for the Xiaomi MIoT electric blanket model `xiaomi.blanket.mj1`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.blanket.mj1`
- specModel: `xiaomi-mj1`
- URN: `urn:miot-spec-v2:device:electric-blanket:0000A069:xiaomi-mj1:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.blanket.mj1` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiBlanketMj1HeatLevel`
- `concertmirror08464.xiaomiBlanketMj1Mode`
- `concertmirror08464.xiaomiBlanketMj1ChildLock`
- `concertmirror08464.xiaomiBlanketMj1ScreenOff`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `0=common`, `1=miteRemoval` | `xiaomiBlanketMj1Mode.mode` |
| Heat level | RW | `siid=2`, `piid=7`; `0=off`, `1..6` levels | `xiaomiBlanketMj1HeatLevel.heatLevel` |
| Child lock | RW | `siid=3`, `piid=1` | `xiaomiBlanketMj1ChildLock.childLock` |
| Auto screen off | RW | `siid=8`, `piid=4` | `xiaomiBlanketMj1ScreenOff.autoScreenOff` |

Not exposed: device fault only reports `0=noFaults`, and the `siid=6` and `siid=7` services carry dual-zone gear values, 0..720 minute countdown timers, and sleep schedules rather than core SmartThings controls.
