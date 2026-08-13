# Mijia Fan P23

SmartThings Edge LAN driver for the Dmaker MIoT fan and heater model `dmaker.fan.p23`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p23`
- specModel: `dmaker-p23`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p23:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.fan.p23` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `concertmirror08464.dmakerFanP23FanLevel`
- `concertmirror08464.dmakerFanP23FanMode`
- `fanOscillationMode`
- `concertmirror08464.dmakerFanP23Symmetric`
- `concertmirror08464.dmakerFanP23LeftAngleV2`
- `concertmirror08464.dmakerFanP23RightAngleV2`
- `concertmirror08464.dmakerFanP23HeaterOn`
- `concertmirror08464.dmakerFanP23TargetTemp`
- `concertmirror08464.dmakerFanP23Heating`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.dmakerFanP23OffDelay`
- `concertmirror08464.dmakerFanP23Indicator`
- `concertmirror08464.dmakerFanP23Buzzer`
- `concertmirror08464.dmakerFanP23ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Fan power | RW | `siid=5`, `piid=1` | `switch` |
| Fan speed | RW | `siid=8`, `piid=1`; 1..100 | `fanSpeedPercent.percent` |
| Fan level | RW | `siid=5`, `piid=2`; numeric 1..10 | `dmakerFanP23FanLevel.fanLevel` |
| Wind mode | RW | `siid=5`, `piid=4`; `0=constant temperature`, `1=straight`, `2=natural`, `3=sleep` | `dmakerFanP23FanMode.fanMode` |
| Horizontal swing | RW | `siid=5`, `piid=3` | `fanOscillationMode` |
| Symmetric swing | RW | `siid=8`, `piid=2` | `dmakerFanP23Symmetric.symmetricSwing` |
| Left angle | RW | `siid=8`, `piid=3`; 30..150 degrees, step 5 | `dmakerFanP23LeftAngleV2.leftAngle` |
| Right angle | RW | `siid=8`, `piid=4`; 0..120 degrees, step 5 | `dmakerFanP23RightAngleV2.rightAngle` |
| Heater power | RW | `siid=2`, `piid=1` | `dmakerFanP23HeaterOn.heaterOn` |
| Heater target temperature | RW | `siid=2`, `piid=5`; 18..28 C | `dmakerFanP23TargetTemp.targetTemperature` |
| Heating | RW | `siid=2`, `piid=6` | `dmakerFanP23Heating.heating` |
| Room temperature | R | `siid=4`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=4`, `piid=1`; percent | `relativeHumidityMeasurement` |
| Off delay | RW | `siid=8`, `piid=5`; 0..720 minutes | `dmakerFanP23OffDelay.offDelayTime` |
| Indicator light | RW | `siid=9`, `piid=1` | `dmakerFanP23Indicator.indicatorLight` |
| Buzzer | RW | `siid=7`, `piid=1` | `dmakerFanP23Buzzer.buzzer` |
| Child lock | RW | `siid=3`, `piid=1` | `dmakerFanP23ChildLock.childLock` |

This model is a fan and heater combo. The SmartThings `switch` controls the fan service, and the heater keeps its own power switch, target temperature, and heating flag so the two halves stay independent. The left and right angles travel as strings through `*AngleV2` capabilities for iOS compatibility, and the driver snaps values to the 5 degree step before writing.

Not exposed: the heater fault property reports a raw code, the heater mode has a single constant-temperature value, and `siid=8` `piid=6` is a write-only left/right nudge command.
