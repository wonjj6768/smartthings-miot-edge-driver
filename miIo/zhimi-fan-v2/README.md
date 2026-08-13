# Smartmi DC Pedestal Fan

SmartThings Edge LAN driver for the Xiaomi/miIO fan model `zhimi.fan.v2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.fan.v2`
- specModel: `zhimi-v2`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-v2:1`
- Basis: python-miio `miio.integrations.zhimi.fan.fan` lists exact model `zhimi.fan.v2` in `class Fan(Device)`, reads its properties with `send("get_prop")`, and writes with `set_power`, `set_speed_level`, `set_natural_level`, `set_angle_enable`, `set_angle`, `set_led`, `set_led_b`, `set_buzzer`, and `set_child_lock`. The `zhimi-v2` MIoT spec is used only as the equivalent capability contract for the angle range and battery reporting. Rejected native MIoT: no `MiotDevice` mapping and no `MIOT_LOCAL_MODELS` entry for this model.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `battery`
- `concertmirror08464.zhimiFanV2FanMode`
- `concertmirror08464.zhimiFanV2IndicatorLight`
- `concertmirror08464.zhimiFanV2LedBrightness`
- `concertmirror08464.zhimiFanV2Buzzer`
- `concertmirror08464.zhimiFanV2ChildLock`
- `concertmirror08464.zhimiFanV2HorizontalAngleV2`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Direct speed | RW | `speed_level`, `set_speed_level`, `0..100` | `fanSpeedPercent` in normal mode |
| Natural speed | RW | `natural_level`, `set_natural_level`, `0..100` | `fanSpeedPercent` in nature mode, `fanMode` |
| Oscillation | RW | `angle_enable`, `set_angle_enable` with `on` / `off` | `fanOscillationMode`, `off` / `horizontal` |
| Oscillation angle | RW | `angle`, `set_angle`, `30..120` | `zhimiFanV2HorizontalAngleV2` |
| Temperature | R | `temp_dec`, deci-Celsius | `temperatureMeasurement` |
| Humidity | R | `humidity`, percent | `relativeHumidityMeasurement` |
| Battery | R | `battery`, percent | `battery` |
| Indicator light | RW | `led`, `set_led` with `on` / `off` | `zhimiFanV2IndicatorLight` |
| LED brightness | RW | `led_b`, `set_led_b`, `0=bright`, `1=dim`, `2=off` | `zhimiFanV2LedBrightness` |
| Buzzer | RW | `buzzer`, `set_buzzer` with `on` / `off` | `zhimiFanV2Buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` with `on` / `off` | `zhimiFanV2ChildLock` |
| Refresh | Action | Re-read the `get_prop` property list | `refresh` |

Fan mode: `normal` writes `set_natural_level` `0` so the direct speed applies, `nature` writes the current percent to `set_natural_level`. `led` and `led_b` are separate device properties on this model, so the indicator light toggle and the three-step brightness are separate capabilities.

Not exposed: `ac_power`, `bat_charge`, `bat_state`, `button_pressed`, `speed` motor RPM, `use_time`, and `poweroff_time` are diagnostic or accumulated values and are intentionally omitted.
