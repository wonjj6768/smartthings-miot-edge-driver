# Xiaomi Smart Standing Fan 2

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p42`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p42`
- specModel: `dmaker-p42`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p42:1`
- Basis: `hass-xiaomi-miot` commit `0e8644f` lists exact model `dmaker.fan.p42` in `MIOT_LOCAL_MODELS`, disables cloud in auto mode, and uses local `get_properties` / `set_properties`; the exact MIoT spec supplies the `siid` / `piid` mapping.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP42FanMode`
- `concertmirror08464.dmakerFanP42IndicatorLight`
- `concertmirror08464.dmakerFanP42Buzzer`
- `concertmirror08464.dmakerFanP42ChildLock`
- `concertmirror08464.dmakerFanP42HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=2`, `piid=10`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Horizontal angle | RW | `siid=2`, `piid=5`, `30/60/90/120/140` | `dmakerFanP42HorizontalAngleV2.horizontalAngle` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `dmakerFanP42FanMode.fanMode` |
| Indicator light | RW | `siid=2`, `piid=7` | `dmakerFanP42IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=2`, `piid=8` | `dmakerFanP42Buzzer.buzzer` |
| Child lock | RW | `siid=3`, `piid=1` | `dmakerFanP42ChildLock.childLock` |

Not exposed: fan level bucket, off-delay time, motor-control left/right action, and toggle action because they are auxiliary values or physical shortcut helpers rather than core SmartThings fan controls.
