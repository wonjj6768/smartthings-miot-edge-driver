# Deerma Humidifier CT500

SmartThings Edge LAN driver for exact model `deerma.humidifier.ct500`.

## Protocol Decision

- Protocol: MIoT
- Model: `deerma.humidifier.ct500`
- specModel: `deerma-ct500`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:deerma-ct500:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHumCt500FanLevelV3`
- `concertmirror08464.deermaHumCt500WaterLevel`
- `concertmirror08464.deermaHumCt500WaterShortage`
- `concertmirror08464.deermaHumCt500SpilledWater`
- `concertmirror08464.deermaHumCt500IndicatorLight`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Fan level | RW | `siid=2`, `piid=5`; 1=level1, 2=level2, 3=level3, 4=auto, 5=humidity, 6=low, 7=turbo | `concertmirror08464.deermaHumCt500FanLevelV3` |
| Water level | R | `siid=2`, `piid=6`; 0=percent0, 1=percent25, 2=percent50, 3=percent75, 4=percent100, 5=percent110 | `concertmirror08464.deermaHumCt500WaterLevel` |
| Water shortage | R | `siid=7`, `piid=2`; False=normal, True=shortage | `concertmirror08464.deermaHumCt500WaterShortage` |
| Spilled water | R | `siid=7`, `piid=3`; False=normal, True=detected | `concertmirror08464.deermaHumCt500SpilledWater` |
| Indicator light | RW | `siid=8`, `piid=1`; False=off, True=on | `concertmirror08464.deermaHumCt500IndicatorLight` |

Not exposed: the timer and the no-fault-only fault property are omitted. Water level is exposed with the exact enumerated percentages, including the model's 110% value.
