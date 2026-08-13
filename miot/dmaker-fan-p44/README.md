# Mijia Smart Evaporative Cooling Fan

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dmaker.fan.p44`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p44`
- specModel: `dmaker-p44`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p44:1`
- Basis: `hass-xiaomi-miot` commit `0e8644f` lists exact model `dmaker.fan.p44` in `MIOT_LOCAL_MODELS`, disables cloud in auto mode, and uses local `get_properties` / `set_properties`; the exact MIoT spec supplies the `siid` / `piid` mapping.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP44FanLevel`
- `concertmirror08464.dmakerFanP44FanMode`
- `concertmirror08464.dmakerFanP44AirCooler`
- `concertmirror08464.dmakerFanP44WaterStatus`
- `concertmirror08464.dmakerFanP44IndicatorLight`
- `concertmirror08464.dmakerFanP44Buzzer`
- `concertmirror08464.dmakerFanP44ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=2`, `1..4` | `dmakerFanP44FanLevel.fanLevel` |
| Wind mode | RW | `siid=2`, `piid=3`, `0=normal`, `1=nature`, `2=sleep`, `3=coldAir` | `dmakerFanP44FanMode.fanMode` |
| Horizontal swing | RW | `siid=2`, `piid=4` | `fanOscillationMode` |
| Air cooler | RW | `siid=2`, `piid=6` | `dmakerFanP44AirCooler.airCooler` |
| Water status | R | `siid=2`, `piid=7`, `0=normal`, `1=lackWater`, `2=disconnected` | `dmakerFanP44WaterStatus.waterStatus` |
| Indicator light | RW | `siid=4`, `piid=1` | `dmakerFanP44IndicatorLight.indicatorLight` |
| Buzzer | RW | `siid=5`, `piid=1` | `dmakerFanP44Buzzer.buzzer` |
| Child lock | RW | `siid=7`, `piid=1` | `dmakerFanP44ChildLock.childLock` |

Not exposed: dry-after-off, dry-left-time, motor fault details, and action helpers because they are auxiliary values rather than core SmartThings fan controls.
