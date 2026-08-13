# Xiaomi Fan P43

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p43`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p43`
- specModel: `xiaomi-p43`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p43:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.fan.p43` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP43FanMode`
- `concertmirror08464.xiaomiFanP43IndicatorLight`
- `concertmirror08464.xiaomiFanP43Buzzer`
- `concertmirror08464.xiaomiFanP43ChildLock`
- `concertmirror08464.xiaomiFanP43HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=2`, `piid=6`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature`, `2=smart` | `xiaomiFanP43FanMode.fanMode` |
| Indicator light | RW | `siid=4`, `piid=1` | `xiaomiFanP43IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiFanP43Buzzer.buzzer` |
| Child lock | RW | `siid=6`, `piid=1` | `xiaomiFanP43ChildLock.childLock` |
| Horizontal angle | RW | `siid=2`, `piid=5`, `30/60/90` | `xiaomiFanP43HorizontalAngleV2.horizontalAngle` |

Not exposed: level bucket, fan status, power-off delay, and toggle actions because they are auxiliary values or physical shortcut helpers rather than core SmartThings fan controls.
