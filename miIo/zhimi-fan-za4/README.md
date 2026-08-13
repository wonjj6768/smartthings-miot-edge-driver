# Smartmi Standing Fan 2S

SmartThings Edge LAN driver for the classic Xiaomi miIO fan model `zhimi.fan.za4`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.fan.za4`
- specModel: `zhimi-za4`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-za4:3`
- Basis: current `python-miio` lists exact model `zhimi.fan.za4` in the classic `Fan(Device)` implementation, polls with one-property `get_prop` requests, and writes with `set_*` methods. The MIoT spec is equivalent capability-contract evidence only.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.zhimiFanZa4FanMode`
- `concertmirror08464.zhimiFanZa4DisplayBrightness`
- `concertmirror08464.zhimiFanZa4Buzzer`
- `concertmirror08464.zhimiFanZa4ChildLock`
- `concertmirror08464.zhimiFanZa4HorizontalAngleV2`
- `refresh`

## miIO Mapping

| Feature | Access | miIO property / method | SmartThings |
|---|---:|---|---|
| Power | RW | `power` / `set_power` | `switch` |
| Fan speed percent | RW | `speed_level`, `natural_level` / matching setters | `fanSpeedPercent` |
| Horizontal oscillation | RW | `angle_enable` / `set_angle_enable` | `fanOscillationMode` |
| Wind mode | RW | `speed_level`, `natural_level` | `zhimiFanZa4FanMode.fanMode` |
| Display brightness | RW | `led_b` / `set_led_b`; `0=normal`, `1=dim`, `2=off` | `zhimiFanZa4DisplayBrightness.displayBrightness` |
| Buzzer | RW | `buzzer` / `set_buzzer`; `0=off`, `2=on` | `zhimiFanZa4Buzzer.buzzer` |
| Child lock | RW | `child_lock` / `set_child_lock` | `zhimiFanZa4ChildLock.childLock` |

Angle state/control: `zhimiFanZa4HorizontalAngleV2.horizontalAngle` maps `angle` / `set_angle`, `0..120`.

Not exposed: motor speed, AC power, usage time, and countdown because they are auxiliary or diagnostic values rather than core SmartThings controls for this port.
