# Leshow Humidifier JSQ2

SmartThings Edge LAN driver for exact model `leshow.humidifier.jsq2`.

## Protocol Decision

- Protocol: MIoT
- Model: `leshow.humidifier.jsq2`
- specModel: `leshow-jsq2`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:leshow-jsq2:2`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `filterState`
- `concertmirror08464.leshowHumJsq2Mode`
- `concertmirror08464.leshowHumJsq2TargetHumidity`
- `concertmirror08464.leshowHumJsq2WaterStatus`
- `concertmirror08464.leshowHumJsq2FanLevel`
- `concertmirror08464.leshowHumJsq2Buzzer`
- `concertmirror08464.leshowHumJsq2IndicatorLight`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=7`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=7`, `piid=7` | `temperatureMeasurement` |
| Filter life | R/action | `siid=13`, `piid=1`; reset `siid=13`, `aiid=1` | `filterState` |
| Mode | RW | `siid=2`, `piid=3`; 0=constantHumidity, 1=level1, 2=level2, 3=level3, 4=dry | `concertmirror08464.leshowHumJsq2Mode` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..70 % | `concertmirror08464.leshowHumJsq2TargetHumidity` |
| Water status | R | `siid=2`, `piid=7`; 0=lack, 1=normal | `concertmirror08464.leshowHumJsq2WaterStatus` |
| Fan level | RW | `siid=2`, `piid=8`; 0=auto, 1=level1, 2=level2, 3=level3, 4=dry | `concertmirror08464.leshowHumJsq2FanLevel` |
| Buzzer | RW | `siid=10`, `piid=1`; False=off, True=on | `concertmirror08464.leshowHumJsq2Buzzer` |
| Indicator light | RW | `siid=11`, `piid=1`; False=off, True=on | `concertmirror08464.leshowHumJsq2IndicatorLight` |

Not exposed: countdown and private over-wet/auto-dry diagnostics are omitted. Filter reset uses the exact filter action. Generic device fault/fault-code and operating-status diagnostics are not exposed.
