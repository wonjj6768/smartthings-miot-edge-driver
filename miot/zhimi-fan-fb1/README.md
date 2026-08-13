# Zhimi Fan FB1

SmartThings Edge LAN driver for the Smartmi MIoT fan model `zhimi.fan.fb1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.fan.fb1`
- specModel: `zhimi-fb1`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-fb1:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.fan.fb1` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `concertmirror08464.zhimiFanFb1FanLevel`
- `concertmirror08464.zhimiFanFb1FanMode`
- `fanOscillationMode`
- `concertmirror08464.zhimiFanFb1HorizontalAngleV2`
- `concertmirror08464.zhimiFanFb1VerticalAngleV2`
- `concertmirror08464.zhimiFanFb1Indicator`
- `concertmirror08464.zhimiFanFb1Buzzer`
- `concertmirror08464.zhimiFanFb1ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed | RW | `siid=5`, `piid=10`; 1..100 stepless | `fanSpeedPercent.percent` |
| Fan level | RW | `siid=2`, `piid=2`; numeric 1..5 | `zhimiFanFb1FanLevel.fanLevel` |
| Wind mode | RW | `siid=2`, `piid=7`; `0=natural`, `1=straight` | `zhimiFanFb1FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=3` | `fanOscillationMode` |
| Horizontal angle | RW | `siid=2`, `piid=5`; 0..120 degrees | `zhimiFanFb1HorizontalAngleV2.horizontalAngle` |
| Vertical angle | RW | `siid=2`, `piid=6`; 0..90 degrees | `zhimiFanFb1VerticalAngleV2.verticalAngle` |
| Indicator light | RW | `siid=2`, `piid=10`; `0=off`, `1=on` | `zhimiFanFb1Indicator.indicatorLight` |
| Buzzer | RW | `siid=2`, `piid=11` | `zhimiFanFb1Buzzer.buzzer` |
| Child lock | RW | `siid=6`, `piid=1` | `zhimiFanFb1ChildLock.childLock` |

The swing angles travel as strings through `*AngleV2` capabilities so the iOS app renders the input field correctly; the driver converts them back to numbers before writing. Unlike zhimi.fan.fa1, this model declares the fan level as a numeric 1..5 range rather than an enum, so it uses a slider capability.

Not exposed: the status and fault properties report idle/busy plus a stuck code, the vertical swing toggle shares the same vane the vertical angle already sets, the country code is a regional setting, and the custom-service timing value, swing-back flags, step-move strings, one-key macros, and toggle actions are schedule, remote-button, and duplicate-write helpers.
