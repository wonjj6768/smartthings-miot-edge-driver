# Zhimi Fan FA2

SmartThings Edge LAN driver for the Smartmi MIoT fan model `zhimi.fan.fa2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.fan.fa2`
- specModel: `zhimi-fa2`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-fa2:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.fan.fa2` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `concertmirror08464.zhimiFanFa2FanLevel`
- `concertmirror08464.zhimiFanFa2FanMode`
- `fanOscillationMode`
- `concertmirror08464.zhimiFanFa2HorizontalAngleV2`
- `concertmirror08464.zhimiFanFa2VerticalAngleV2`
- `concertmirror08464.zhimiFanFa2MotorSpeed`
- `concertmirror08464.zhimiFanFa2Indicator`
- `concertmirror08464.zhimiFanFa2Buzzer`
- `concertmirror08464.zhimiFanFa2ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed | RW | `siid=5`, `piid=10`; 1..100 stepless | `fanSpeedPercent.percent` |
| Fan level | RW | `siid=2`, `piid=2`; `1..4` | `zhimiFanFa2FanLevel.fanLevel` |
| Wind mode | RW | `siid=2`, `piid=7`; `0=natural`, `1=straight`, `2=temp wind` | `zhimiFanFa2FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=3` | `fanOscillationMode` |
| Horizontal angle | RW | `siid=2`, `piid=12`; 0..120 degrees | `zhimiFanFa2HorizontalAngleV2.horizontalAngle` |
| Vertical angle | RW | `siid=2`, `piid=14`; 0..100 degrees | `zhimiFanFa2VerticalAngleV2.verticalAngle` |
| Motor speed | R | `siid=7`, `piid=2`; rpm | `zhimiFanFa2MotorSpeed.motorSpeed` |
| Indicator light | RW | `siid=2`, `piid=10`; `0=off`, `1=on` | `zhimiFanFa2Indicator.indicatorLight` |
| Buzzer | RW | `siid=2`, `piid=11` | `zhimiFanFa2Buzzer.buzzer` |
| Child lock | RW | `siid=6`, `piid=1` | `zhimiFanFa2ChildLock.childLock` |

The swing angles travel as strings through `*AngleV2` capabilities so the iOS app renders the input field correctly; the driver converts them back to numbers before writing. This model adds a temp wind mode that zhimi.fan.fa1 does not have.

Not exposed: `siid=2` `piid=13` and `piid=15` repeat the same angle contracts for a second stored preset, the vertical swing toggle shares the same vane the vertical angle already sets, `siid=7` `piid=1` reports a raw temperature value the vendor app rescales, and the custom-service timing value, swing-back flags, step-move strings, one-key macros, and toggle actions are schedule, remote-button, and duplicate-write helpers.
