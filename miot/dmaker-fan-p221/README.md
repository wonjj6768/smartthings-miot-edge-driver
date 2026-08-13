# Mijia Smart DC Inverter Circulating Standing Fan Battery Edition

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p221`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p221`
- specModel: `dmaker-p221`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p221:2`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.fan.p221` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.dmakerFanP221FanMode`
- `concertmirror08464.dmakerFanP221IndicatorLight`
- `concertmirror08464.dmakerFanP221Buzzer`
- `concertmirror08464.dmakerFanP221ChildLock`
- `concertmirror08464.dmakerFanP221HorizontalAngleV2`
- `concertmirror08464.dmakerFanP221VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature`, `2=smart`, `3=sleep` | `dmakerFanP221FanMode.fanMode` |
| Stepless speed | RW | `siid=8`, `piid=1`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Vertical swing | RW | `siid=2`, `piid=7` | `fanOscillationMode` |
| Indicator light | RW | `siid=4`, `piid=1` | `dmakerFanP221IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=5`, `piid=1` | `dmakerFanP221Buzzer.buzzer` |
| Child lock | RW | `siid=7`, `piid=1` | `dmakerFanP221ChildLock.childLock` |
| Temperature | R | `siid=9`, `piid=1`, C | `temperatureMeasurement` |
| Humidity | R | `siid=9`, `piid=2`, % | `relativeHumidityMeasurement` |

Angle controls: `dmakerFanP221HorizontalAngleV2.horizontalAngle` maps `siid=2`, `piid=5`, `30/60/90/120/140`; `dmakerFanP221VerticalAngleV2.verticalAngle` maps `siid=2`, `piid=8`, `35/65/95`.

Not exposed: gear bucket, countdown timer, manual movement commands, automatic on/off temperature settings, and loop/toggle actions are secondary controls or automation shortcuts.
