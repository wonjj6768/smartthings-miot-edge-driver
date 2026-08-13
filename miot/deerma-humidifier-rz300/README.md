# Deerma Humidifier RZ300

SmartThings Edge LAN driver for exact model `deerma.humidifier.rz300`.

## Protocol Decision

- Protocol: MIoT
- Model: `deerma.humidifier.rz300`
- specModel: `deerma-rz300`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:deerma-rz300:2`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHumRz300FanLevel`
- `concertmirror08464.deermaHumRz300IndicatorLight`
- `concertmirror08464.deermaHumRz300WaterShortage`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Fan level | RW | `siid=2`, `piid=5`; 1=level1, 2=level2, 3=level3, 4=humidity, 5=quiet, 6=turbo | `concertmirror08464.deermaHumRz300FanLevel` |
| Indicator light | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.deermaHumRz300IndicatorLight` |
| Water shortage | R | `siid=7`, `piid=3`; False=normal, True=shortage | `concertmirror08464.deermaHumRz300WaterShortage` |

Not exposed: the timer, write-only water type selector, maintenance reminder, and diagnostic fault flags are omitted.
