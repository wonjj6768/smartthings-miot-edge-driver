# Smartmi Smart Wireless Fan 1st Gen (ZLBPLDS01ZM)

SmartThings Edge LAN driver for the Smartmi Smart Wireless Fan 1st Gen product code `ZLBPLDS01ZM`, model `zhimi.fan.v3`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.fan.v3`
- Product code: `ZLBPLDS01ZM`
- Mi Home app name: Zhimi Standing Fan
- specModel: `zhimi-v3`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-v3:3`
- Basis: python-miio lists `zhimi.fan.v3` in the classic `Fan` miIO integration and defines the local `get_prop` and `set_*` methods used here.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `battery`
- `concertmirror08464.zhimiFanV3FanMode`
- `concertmirror08464.zhimiFanV3LedBrightness`
- `concertmirror08464.zhimiFanV3Buzzer`
- `concertmirror08464.zhimiFanV3ChildLock`
- `concertmirror08464.zhimiFanV3HorizontalAngleV2`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Direct speed | RW | `speed_level`, `set_speed_level`, `0..100` | `fanSpeedPercent` in normal mode |
| Natural speed | RW | `natural_level`, `set_natural_level`, `0..100` | `fanSpeedPercent` in nature mode, `fanMode` |
| Oscillation | RW | `angle_enable`, `set_angle_enable` with `on` / `off` | `fanOscillationMode` |
| Temperature | R | `temp_dec`, deci-Celsius | `temperatureMeasurement` |
| Humidity | R | `humidity`, percent | `relativeHumidityMeasurement` |
| Battery | R | `battery`, percent | `battery` |
| Display brightness | RW | `led_b`, `set_led_b`, `0=bright`, `1=dim`, `2=off` | `zhimiFanV3LedBrightness.ledBrightness` |
| Buzzer | RW | `buzzer`, `set_buzzer` with `on` / `off` | `zhimiFanV3Buzzer.buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` with `on` / `off` | `zhimiFanV3ChildLock.childLock` |

Angle control: `zhimiFanV3HorizontalAngleV2.horizontalAngle` maps miIO `angle` / `set_angle`, `30..120`.

Not exposed: motor RPM, AC power state, button record, delay countdown, use time, battery charging state, and manual left/right movement are auxiliary metadata or secondary controls.
