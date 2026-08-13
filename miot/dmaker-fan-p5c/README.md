# Mijia Smart DC Standing Fan 1X

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p5c`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p5c`
- specModel: `dmaker-p5c`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p5c:2`
- Basis: Exact MIoT spec defines local fan properties for `dmaker.fan.p5c`, and openHAB logs for the exact model show local `get_properties` mapping.
- Evidence: confirmed. Source: miot-spec+openhab-local.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP5cFanMode`
- `concertmirror08464.dmakerFanP5cIndicatorLight`
- `concertmirror08464.dmakerFanP5cBuzzer`
- `concertmirror08464.dmakerFanP5cChildLock`
- `concertmirror08464.dmakerFanP5cHorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Stepless speed | RW | `siid=8`, `piid=1`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature` | `dmakerFanP5cFanMode.fanMode` |
| Indicator light | RW | `siid=4`, `piid=1` | `dmakerFanP5cIndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=5`, `piid=1` | `dmakerFanP5cBuzzer.buzzer` |
| Child lock | RW | `siid=7`, `piid=1` | `dmakerFanP5cChildLock.childLock` |

Angle control: `dmakerFanP5cHorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=5`, `30/60/90/120/140`.

Not exposed: fan level bucket, supply status, delay off, turn-left/right actions, and custom natural wind curves because they are secondary controls or diagnostic/private values.
