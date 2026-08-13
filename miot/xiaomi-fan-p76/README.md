# Xiaomi Smart Standing Air Circulation Fan

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p76`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p76`
- specModel: `xiaomi-p76`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p76:1:0000D062`
- Basis: `syssi/xiaomi_fan` commit `b994a09` implements the exact `xiaomi.fan.p76` model as `FanP76(MiotDevice)` using local host/token access, `get_properties`, `set_property`, and the same siid/piid mapping used by this driver. The exact MIoT spec is the equivalent capability contract, and the Xiaomi 131001-0418 manual confirms the product model and user-facing functions.
- Evidence: confirmed. Source: python-miio-miot+syssi-xiaomi-fan-exact+miot-spec+xiaomi-manual.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP76FanMode`
- `concertmirror08464.xiaomiFanP76IndicatorLight`
- `concertmirror08464.xiaomiFanP76Buzzer`
- `concertmirror08464.xiaomiFanP76ChildLock`
- `concertmirror08464.xiaomiFanP76HorizontalAngleV2`
- `concertmirror08464.xiaomiFanP76VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed percent | RW | `siid=2`, `piid=5`, `1..100` | `fanSpeedPercent` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `xiaomiFanP76FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=6` | `fanOscillationMode`: `horizontal` / `all` |
| Vertical swing | RW | `siid=2`, `piid=8` | `fanOscillationMode`: `vertical` / `all` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiFanP76IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFanP76Buzzer.buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiFanP76ChildLock.childLock` |

Angle controls: `xiaomiFanP76HorizontalAngleV2.horizontalAngle` maps `siid=2`, `piid=7`, `30/60/90/120`; `xiaomiFanP76VerticalAngleV2.verticalAngle` maps `siid=2`, `piid=9`, `30/60/90/100`.

Not exposed: fault, gear fan level, movement actions, delay timer, and dm-service shortcut actions because they are diagnostic, auxiliary, or duplicated by the exposed core controls.
