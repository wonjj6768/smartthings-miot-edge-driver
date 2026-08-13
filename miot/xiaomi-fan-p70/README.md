# Xiaomi BPLDS10DM Smart Desktop Air Circulation Fan

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p70`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p70`
- specModel: `xiaomi-p70`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p70:1:0000D062`
- Basis: current `syssi/xiaomi_fan` implements exact model `xiaomi.fan.p70` as `FanP70(MiotDevice)`, with explicit `siid`/`piid` mapping, `get_properties` polling, and `set_property` writes. The exact MIoT spec confirms the mapped fan contract.
- Evidence: confirmed. Source: python-miio-miot+syssi-xiaomi-fan-exact+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP70FanMode`
- `concertmirror08464.xiaomiFanP70IndicatorLight`
- `concertmirror08464.xiaomiFanP70Buzzer`
- `concertmirror08464.xiaomiFanP70ChildLock`
- `concertmirror08464.xiaomiFanP70HorizontalAngleV2`
- `concertmirror08464.xiaomiFanP70VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed percent | RW | `siid=2`, `piid=5`, `1..100` | `fanSpeedPercent` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `xiaomiFanP70FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=6` | `fanOscillationMode`: `horizontal` / `all` |
| Vertical swing | RW | `siid=2`, `piid=8` | `fanOscillationMode`: `vertical` / `all` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiFanP70IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFanP70Buzzer.buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiFanP70ChildLock.childLock` |

Angle controls: `xiaomiFanP70HorizontalAngleV2.horizontalAngle` maps `siid=2`, `piid=7`, `30/60/90/120`; `xiaomiFanP70VerticalAngleV2.verticalAngle` maps `siid=2`, `piid=9`, `30/60/90/100`.

Not exposed: fault, gear fan level, movement actions, delay timer, and dm-service shortcut actions because they are diagnostic, auxiliary, or duplicated by the exposed core controls.
