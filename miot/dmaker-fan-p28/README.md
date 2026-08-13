# Mijia Smart DC Inverter Circulating Fan Floor Type

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p28`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p28`
- specModel: `dmaker-p28`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p28:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.fan.p28` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.dmakerFanP28FanMode`
- `concertmirror08464.dmakerFanP28IndicatorLight`
- `concertmirror08464.dmakerFanP28Buzzer`
- `concertmirror08464.dmakerFanP28ChildLock`
- `concertmirror08464.dmakerFanP28HorizontalAngleV2`
- `concertmirror08464.dmakerFanP28VerticalAngleV2`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature`, `2=smart`, `3=sleep` | `dmakerFanP28FanMode.fanMode` |
| Stepless speed | RW | `siid=8`, `piid=1`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Vertical swing | RW | `siid=2`, `piid=7` | `fanOscillationMode` |
| Indicator light | RW | `siid=4`, `piid=1` | `dmakerFanP28IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=5`, `piid=1` | `dmakerFanP28Buzzer.buzzer` |
| Child lock | RW | `siid=7`, `piid=1` | `dmakerFanP28ChildLock.childLock` |
| Temperature | R | `siid=9`, `piid=1`, C | `temperatureMeasurement` |
| Humidity | R | `siid=9`, `piid=2`, % | `relativeHumidityMeasurement` |

Angle controls: `dmakerFanP28HorizontalAngleV2.horizontalAngle` maps `siid=2`, `piid=5`, `30/60/90/120/150`; `dmakerFanP28VerticalAngleV2.verticalAngle` maps `siid=2`, `piid=8`, `30/60/90`.

Not exposed: gear bucket, countdown timer, manual movement commands, swing-all shortcut, centering helpers, and loop/toggle actions are secondary controls or automation shortcuts.
