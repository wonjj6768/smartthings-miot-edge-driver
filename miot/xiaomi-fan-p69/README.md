# Mijia Smart Desktop Air Circulation Fan

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p69`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p69`
- specModel: `xiaomi-p69`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p69:1:0000D062`
- Basis: user device report identifies the exact model as Mijia Smart Desktop Air Circulation Fan, and a real LAN MIoT response from that device confirmed the core siid/piid mapping in the exact MIoT spec.
- Evidence: confirmed. Source: real-device+miot-spec+user-device-report.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP69FanMode`
- `concertmirror08464.xiaomiFanP69IndicatorLight`
- `concertmirror08464.xiaomiFanP69Buzzer`
- `concertmirror08464.xiaomiFanP69ChildLock`
- `concertmirror08464.xiaomiFanP69HorizontalAngleV2`
- `concertmirror08464.xiaomiFanP69VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed percent | RW | `siid=2`, `piid=5`, `1..100` | `fanSpeedPercent` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `xiaomiFanP69FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=6` | `fanOscillationMode`: `horizontal` / `all` |
| Vertical swing | RW | `siid=2`, `piid=8` | `fanOscillationMode`: `vertical` / `all` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiFanP69IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFanP69Buzzer.buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiFanP69ChildLock.childLock` |
| Horizontal angle | RW | `siid=2`, `piid=7`, `30/60/90/120` | `xiaomiFanP69HorizontalAngleV2.horizontalAngle` |
| Vertical angle | RW | `siid=2`, `piid=9`, `30/60/90/100` | `xiaomiFanP69VerticalAngleV2.verticalAngle` |

Not exposed: fault, gear fan level, movement actions, delay timer, and dm-service shortcut actions because they are diagnostic, auxiliary, or duplicated by the exposed core controls.
