# Deerma Humidifier 990DW

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `deerma.humidifier.990dw`.

## Protocol Decision

- Protocol: MIoT
- Model: `deerma.humidifier.990dw`
- specModel: `deerma-990dw`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:deerma-990dw:1`
- Basis: current `hass-xiaomi-miot` lists exact model `deerma.humidifier.990dw` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHum990dwFanLevel`
- `concertmirror08464.deermaHum990dwTargetHumidity`
- `concertmirror08464.deermaHum990dwStatus`
- `concertmirror08464.deermaHum990dwIndicatorLight`
- `concertmirror08464.deermaHum990dwAlarm`
- `concertmirror08464.deermaHum990dwTankFilled`
- `concertmirror08464.deermaHum990dwWaterShortage`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=3`; `1..5` levels, `6=constantHumidity`, `7=sleep` | `deermaHum990dwFanLevel.fanLevel` |
| Operating status | R | `siid=2`, `piid=4`; `1=idle`, `2=busy` | `deermaHum990dwStatus.operatingStatus` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70 %, step 1 | `deermaHum990dwTargetHumidity.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; celsius | `temperatureMeasurement` |
| Indicator light | RW | `siid=4`, `piid=1` | `deermaHum990dwIndicatorLight.indicatorLight` |
| Water tank installed | R | `siid=5`, `piid=1`; `true=filled`, `false=notFilled` | `deermaHum990dwTankFilled.tankFilled` |
| Water shortage | R | `siid=5`, `piid=2`; `true=shortage`, `false=normal` | `deermaHum990dwWaterShortage.waterShortage` |
| Buzzer | RW | `siid=6`, `piid=1` | `deermaHum990dwAlarm.alarm` |

Not exposed: device fault only reports `0=noFaults`, the humidity and temperature sensor fault flags at `siid=5`, `piid=3` and `piid=4` are internal diagnostics, and the `siid=2` toggle action duplicates the `switch` capability.
