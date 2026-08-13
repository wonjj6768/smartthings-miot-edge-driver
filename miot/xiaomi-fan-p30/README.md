# Mi Smart Standing Fan 2

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p30`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p30`
- specModel: `xiaomi-p30`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p30:1:0000D062`
- Basis: current `syssi/xiaomi_fan` implements exact model `xiaomi.fan.p30` as `FanXiaomiP30(MiotDevice)`, with explicit `siid`/`piid` mapping, `get_properties` polling, and `set_property` writes. The exact MIoT spec confirms the mapped fan contract.
- Evidence: confirmed. Source: python-miio-miot+syssi-xiaomi-fan-exact+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP30FanMode`
- `concertmirror08464.xiaomiFanP30IndicatorLight`
- `concertmirror08464.xiaomiFanP30Buzzer`
- `concertmirror08464.xiaomiFanP30ChildLock`
- `concertmirror08464.xiaomiFanP30HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=2`, `piid=5`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=6` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `xiaomiFanP30FanMode.fanMode` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiFanP30IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFanP30Buzzer.buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiFanP30ChildLock.childLock` |

Angle control: `xiaomiFanP30HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=7`, `30/60/90/120/140`.

Not exposed: fan level bucket, fault, delay off, turn-left/right actions, and custom natural wind curves because they are secondary controls or diagnostic/private values.
