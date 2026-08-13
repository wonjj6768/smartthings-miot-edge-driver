# Mijia Smart Standing Fan Pro Slim

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `xiaomi.fan.p85`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p85`
- specModel: `xiaomi-p85`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p85:1:0000D062`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.fan.p85` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.xiaomiFanP85FanMode`
- `concertmirror08464.xiaomiFanP85IndicatorLight`
- `concertmirror08464.xiaomiFanP85Buzzer`
- `concertmirror08464.xiaomiFanP85ChildLock`
- `concertmirror08464.xiaomiFanP85HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=11`, `piid=6`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=6` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `xiaomiFanP85FanMode.fanMode` |
| Indicator light | RW | `siid=5`, `piid=1` | `xiaomiFanP85IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFanP85Buzzer.buzzer` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiFanP85ChildLock.childLock` |

Angle control: `xiaomiFanP85HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=7`, `30/60/90`.

Not exposed: fan level bucket, fault, delay off, turn-left/right actions, and custom natural wind curves because they are secondary controls or diagnostic/private values.
