# Xiaomi Smart Standing Fan 2 P30

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p30`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p30`
- specModel: `dmaker-p30`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p30:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.fan.p30` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP30FanMode`
- `concertmirror08464.dmakerFanP30IndicatorLight`
- `concertmirror08464.dmakerFanP30Buzzer`
- `concertmirror08464.dmakerFanP30ChildLock`
- `concertmirror08464.dmakerFanP30HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=2`, `piid=10`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `dmakerFanP30FanMode.fanMode` |
| Indicator light | RW | `siid=2`, `piid=7` | `dmakerFanP30IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=2`, `piid=8` | `dmakerFanP30Buzzer.buzzer` |
| Child lock | RW | `siid=3`, `piid=1` | `dmakerFanP30ChildLock.childLock` |

Angle control: `dmakerFanP30HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=5`, `30/60/90/120/140`.

Not exposed: level bucket, swing angle, power-off delay, motor movement command, and toggle/loop actions are secondary controls or physical shortcut helpers.
