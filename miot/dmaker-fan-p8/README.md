# Mijia Fan P8

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p8`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p8`
- specModel: `dmaker-p8`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p8:2`
- Basis: `hass-xiaomi-miot` commit `0e8644f` lists exact model `dmaker.fan.p8` for local MIoT, while `homebridge-xiaomi-fan` commit `1725e5b` classifies it as MIoT and implements local `siid` / `piid` access.
- Evidence: confirmed. Source: hass-xiaomi-miot-local+homebridge-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.dmakerFanP8FanLevel`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP8FanMode`
- `concertmirror08464.dmakerFanP8IndicatorLight`
- `concertmirror08464.dmakerFanP8Buzzer`
- `concertmirror08464.dmakerFanP8ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=2`, `1..3` | `dmakerFanP8FanLevel.fanLevel` |
| Horizontal swing | RW | `siid=2`, `piid=3` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=7`, `0=normal`, `1=sleep` | `dmakerFanP8FanMode.fanMode` |
| Buzzer | RW | `siid=2`, `piid=11` | `dmakerFanP8Buzzer.buzzer` |
| Indicator light | RW | `siid=2`, `piid=12` | `dmakerFanP8IndicatorLight.indicatorLight` |
| Child lock | RW | `siid=3`, `piid=1` | `dmakerFanP8ChildLock.childLock` |

Not exposed: off-delay timer and toggle action because they are auxiliary and duplicate core controls.
