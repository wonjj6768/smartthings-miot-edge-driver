# Shuii Humidifier JSQ002

SmartThings Edge LAN driver for exact model `shuii.humidifier.jsq002`.

## Protocol Decision

- Protocol: miIO
- Model: `shuii.humidifier.jsq002`
- specModel: `shuii-jsq002`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:shuii-jsq002:1`
- Basis: The exact hass-xiaomi-miot MIIO_TO_MIOT_SPECS entry defines get_props and the explicit classic setters used here; the MIoT spec is only the equivalent capability contract.
- Evidence: confirmed. Source: hass-xiaomi-miot-miio2miot+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.shuiiHumJsq002FanLevel`
- `concertmirror08464.shuiiHumJsq002Heater`
- `concertmirror08464.shuiiHumJsq002TargetHumidity`
- `concertmirror08464.shuiiHumJsq002WaterLevelCode`
- `concertmirror08464.shuiiHumJsq002TargetTemperature`
- `concertmirror08464.shuiiJsq002IndicatorBrightness`
- `concertmirror08464.shuiiHumJsq002Buzzer`
- `concertmirror08464.shuiiHumJsq002ChildLock`
- `refresh`

## miIO Mapping

All reads are returned by one classic `get_props` call in this exact order:
`power`, `gear`, `humidity`, `ledLevel`, `temperature`, `waterLevel`,
`heat`, `beaPower`, `childLock`, `targetTemp`, `targetHumidity`.

| Feature | Access | Classic miIO property / method | SmartThings |
|---|---:|---|---|
| Power | RW | `power`; `on_off [0\|1]` | `switch` |
| Relative humidity | R | `humidity` | `relativeHumidityMeasurement` |
| Temperature | R | `temperature` | `temperatureMeasurement` |
| Fan level | RW | `gear`; `set_gear [1..3]`; 1=level1, 2=level2, 3=level3 | `concertmirror08464.shuiiHumJsq002FanLevel` |
| Heater | RW | `heat`; `warm_on [0\|1]` | `concertmirror08464.shuiiHumJsq002Heater` |
| Target humidity | RW | `targetHumidity`; `set_humidity [30..90]` | `concertmirror08464.shuiiHumJsq002TargetHumidity` |
| Water level code | R | `waterLevel`; raw 1..5 | `concertmirror08464.shuiiHumJsq002WaterLevelCode` |
| Target temperature | RW | `targetTemp`; `set_temp [30..60]` | `concertmirror08464.shuiiHumJsq002TargetTemperature` |
| Indicator brightness | RW | `ledLevel`; `set_led [1..3]` | `concertmirror08464.shuiiJsq002IndicatorBrightness` |
| Buzzer | RW | `beaPower`; `buzzer_on [0\|1]` | `concertmirror08464.shuiiHumJsq002Buzzer` |
| Child lock | RW | `childLock`; `set_lock [0\|1]` | `concertmirror08464.shuiiHumJsq002ChildLock` |

Not exposed: water level is exposed only as the raw 1..5 code because the percentage scale is not defined.
