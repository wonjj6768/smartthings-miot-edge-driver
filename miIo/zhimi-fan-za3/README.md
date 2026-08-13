# Smartmi Pedestal Fan ZA3

SmartThings Edge LAN driver for the Xiaomi/miIO fan model `zhimi.fan.za3`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.fan.za3`
- Basis: python-miio lists exact model `zhimi.fan.za3` in the classic Zhimi Fan miIO integration, based on `Device` / `get_prop`, and documents `set_power`, `set_direct_speed`, `set_natural_speed`, `set_oscillate`, `set_angle`, `set_led_brightness`, `set_buzzer`, and `set_child_lock`.
- Evidence: confirmed. Source: python-miio-classic+home-assistant-xiaomi-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.zhimiFanZa3FanMode`
- `concertmirror08464.zhimiFanZa3LedBrightness`
- `concertmirror08464.zhimiFanZa3Buzzer`
- `concertmirror08464.zhimiFanZa3ChildLock`
- `concertmirror08464.zhimiFanZa3HorizontalAngleV2`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Fan speed percent | RW | `speed_level`, `set_speed_level`, `1..100` | `fanSpeedPercent` in normal mode |
| Natural speed percent | RW | `natural_level`, `set_natural_level`, `1..100`; `0` disables natural mode | `fanSpeedPercent` in nature mode and `zhimiFanZa3FanMode.fanMode` |
| Horizontal oscillation | RW | `angle_enable`, `set_angle_enable` with `on` / `off` | `fanOscillationMode` |
| LED brightness | RW | `led_b`, `set_led_b`; `0=bright`, `1=dim`, `2=off` | `zhimiFanZa3LedBrightness.ledBrightness` |
| Buzzer | RW | `buzzer`, `set_buzzer`; `2=on`, `0=off` | `zhimiFanZa3Buzzer.buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` with `on` / `off` | `zhimiFanZa3ChildLock.childLock` |

Angle control: `zhimiFanZa3HorizontalAngleV2.horizontalAngle` maps miIO `angle` / `set_angle`, `0..120`.

Not exposed: rotate-left/right, AC power, use time, countdown, and raw RPM because they are auxiliary controls or diagnostic values rather than core SmartThings controls for this port.
