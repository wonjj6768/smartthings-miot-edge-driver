# Smartmi Inverter Pedestal Fan

SmartThings Edge LAN driver for the Xiaomi/miIO fan model `zhimi.fan.za1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.fan.za1`
- Basis: python-miio lists exact model `zhimi.fan.za1` in the classic Zhimi Fan miIO integration, uses `Device` / `get_prop` with one-property polling for ZA1, and implements `set_power`, `set_speed_level`, `set_natural_level`, `set_angle_enable`, `set_led_b`, `set_buzzer`, and `set_child_lock`; Home Assistant Xiaomi Miio also lists this model under the classic Standing Fan platform.
- Evidence: confirmed. Source: python-miio-classic+home-assistant-xiaomi-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.zhimiFanZa1FanMode`
- `concertmirror08464.zhimiFanZa1LedBrightness`
- `concertmirror08464.zhimiFanZa1Buzzer`
- `concertmirror08464.zhimiFanZa1ChildLock`
- `concertmirror08464.zhimiFanZa1HorizontalAngleV2`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Fan speed percent | RW | `speed_level`, `set_speed_level`, `1..100` | `fanSpeedPercent` in normal mode |
| Natural speed percent | RW | `natural_level`, `set_natural_level`, `1..100`; `0` disables natural mode | `fanSpeedPercent` in nature mode and `zhimiFanZa1FanMode.fanMode` |
| Horizontal oscillation | RW | `angle_enable`, `set_angle_enable` with `on` / `off` | `fanOscillationMode` |
| LED brightness | RW | `led_b`, `set_led_b`; `0=bright`, `1=dim`, `2=off` | `zhimiFanZa1LedBrightness.ledBrightness` |
| Buzzer | RW | `buzzer`, `set_buzzer`; `2=on`, `0=off` | `zhimiFanZa1Buzzer.buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` with `on` / `off` | `zhimiFanZa1ChildLock.childLock` |

Angle control: `zhimiFanZa1HorizontalAngleV2.horizontalAngle` maps miIO `angle` / `set_angle`, `0..120`.

Not exposed: rotate-left/right, AC power, use time, countdown, and raw RPM because they are auxiliary controls or diagnostic values rather than core SmartThings controls for this port.
