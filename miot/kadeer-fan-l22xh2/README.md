# Kadeer Fan L22XH2

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `kadeer.fan.l22xh2`.

## Protocol Decision

- Protocol: MIoT
- Model: `kadeer.fan.l22xh2`
- specModel: `kadeer-l22xh2`
- URN: `urn:miot-spec-v2:device:fan:0000A005:kadeer-l22xh2:1`
- Basis: current `hass-xiaomi-miot` lists exact model `kadeer.fan.l22xh2` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `concertmirror08464.kadeerFanL22xh2FanLevel`
- `fanOscillationMode`
- `concertmirror08464.kadeerFanL22xh2VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=2`, `1..24` | `kadeerFanL22xh2FanLevel.fanLevel` |
| Two-axis swing | RW | `siid=2`, `piid=3/4` | `fanOscillationMode`, `off/horizontal/vertical/all` |
| Vertical included angle | RW | `siid=2`, `piid=5`, `0=30`, `1=60`, `2=90` | `kadeerFanL22xh2VerticalAngleV2.verticalAngle` |

Not exposed: anion `siid=2`, `piid=6`, device identity values, and custom timing `siid=3`, `piid=1` are auxiliary rather than core fan controls.
