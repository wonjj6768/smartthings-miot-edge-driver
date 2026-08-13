# Smartmi Standing Fan 3

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `zhimi.fan.za5`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.fan.za5`
- specModel: `zhimi-za5`
- URN: `urn:miot-spec-v2:device:fan:0000A005:zhimi-za5:4`
- Basis: python-miio `FanZA5` maps exact model `zhimi.fan.za5` with MIoT siid/piid properties; model docs identify it as Smartmi Standing Fan 3; exact MIoT spec confirms the mapped properties below.
- Evidence: confirmed. Source: python-miio+miot-spec+model-doc.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiFanZa5FanMode`
- `concertmirror08464.zhimiFanZa5DisplayBrightness`
- `concertmirror08464.zhimiFanZa5Anion`
- `concertmirror08464.zhimiFanZa5Buzzer`
- `concertmirror08464.zhimiFanZa5ChildLock`
- `concertmirror08464.zhimiFanZa5HorizontalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan speed percent | RW | `siid=6`, `piid=8`, `1..100` | `fanSpeedPercent` |
| Horizontal oscillation | RW | `siid=2`, `piid=3` | `fanOscillationMode` |
| Wind mode | RW | `siid=2`, `piid=7`, `0=nature`, `1=normal` | `zhimiFanZa5FanMode.fanMode` |
| Anion | RW | `siid=2`, `piid=11` | `zhimiFanZa5Anion.anion` |
| Display brightness | RW | `siid=4`, `piid=3`, `0..100 %` | `zhimiFanZa5DisplayBrightness.displayBrightness` |
| Buzzer | RW | `siid=5`, `piid=1` | `zhimiFanZa5Buzzer.buzzer` |
| Child lock | RW | `siid=3`, `piid=1` | `zhimiFanZa5ChildLock.childLock` |
| Humidity | R | `siid=7`, `piid=1`, `%` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=7`, `piid=7`, `C` | `temperatureMeasurement` |

Angle control: `zhimiFanZa5HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=5`, `30..120`.

Not exposed: fan level bucket, off-delay, button record, battery/power metadata, step movement, motor RPM, motor status, country code, and the private temperature-sensor switch because they are auxiliary, diagnostic, or not core SmartThings controls. The driver enables the private temperature-sensor switch before polling so `temperatureMeasurement` can update.
