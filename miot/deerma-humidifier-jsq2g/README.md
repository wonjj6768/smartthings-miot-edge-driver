# Deerma Humidifier JSQ2G

SmartThings Edge LAN driver for exact model `deerma.humidifier.jsq2g`.

## Protocol Decision

- Protocol: MIoT
- Model: `deerma.humidifier.jsq2g`
- specModel: `deerma-jsq2g`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:deerma-jsq2g:2`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHumJsq2gFanLevel`
- `concertmirror08464.deermaHumJsq2gTargetHumidity`
- `concertmirror08464.deermaHumJsq2gMode`
- `concertmirror08464.deermaHumJsq2gBuzzer`
- `concertmirror08464.deermaHumJsq2gIndicatorLight`
- `concertmirror08464.deermaHumJsq2gWaterShortage`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Fan level | RW | `siid=2`, `piid=5`; 1=level1, 2=level2, 3=level3, 4=level4 | `concertmirror08464.deermaHumJsq2gFanLevel` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..70 % | `concertmirror08464.deermaHumJsq2gTargetHumidity` |
| Mode | RW | `siid=2`, `piid=8`; 0=none, 1=constantHumidity | `concertmirror08464.deermaHumJsq2gMode` |
| Buzzer | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.deermaHumJsq2gBuzzer` |
| Indicator light | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.deermaHumJsq2gIndicatorLight` |
| Water shortage | R | `siid=7`, `piid=2`; False=normal, True=shortage | `concertmirror08464.deermaHumJsq2gWaterShortage` |

Not exposed: the ambiguously named tank field and auxiliary sensor/protection diagnostics are not exposed. The clear water-shortage property remains exposed separately. Generic device fault/fault-code and operating-status diagnostics are not exposed.
