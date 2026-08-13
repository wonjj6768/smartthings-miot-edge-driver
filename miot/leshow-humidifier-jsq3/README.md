# Leshow Humidifier JSQ3

SmartThings Edge LAN driver for exact model `leshow.humidifier.jsq3`.

## Protocol Decision

- Protocol: MIoT
- Model: `leshow.humidifier.jsq3`
- specModel: `leshow-jsq3`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:leshow-jsq3:2`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.leshowHumJsq3Mode`
- `concertmirror08464.leshowHumJsq3TargetHumidity`
- `concertmirror08464.leshowHumJsq3WaterLevel`
- `concertmirror08464.leshowHumJsq3Buzzer`
- `concertmirror08464.leshowHumJsq3Screen`
- `concertmirror08464.leshowHumJsq3ScreenBrightness`
- `concertmirror08464.leshowHumJsq3Heater`
- `concertmirror08464.leshowHumJsq3WaterOver`
- `concertmirror08464.leshowHumJsq3WaterShortage`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Filter life | R/action | `siid=11`, `piid=3`; reset `siid=11`, `aiid=1` | `filterState` |
| Mode | RW | `siid=2`, `piid=3`; 0=constantHumidity, 1=strong, 2=sleep, 3=dry, 4=wash | `concertmirror08464.leshowHumJsq3Mode` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..70 % | `concertmirror08464.leshowHumJsq3TargetHumidity` |
| Water level | R | `siid=2`, `piid=7`; 0..100 % | `concertmirror08464.leshowHumJsq3WaterLevel` |
| Buzzer | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.leshowHumJsq3Buzzer` |
| Screen | RW | `siid=10`, `piid=1`; False=off, True=on | `concertmirror08464.leshowHumJsq3Screen` |
| Screen brightness | RW | `siid=10`, `piid=2`; 0..1 | `concertmirror08464.leshowHumJsq3ScreenBrightness` |
| Heater | RW | `siid=8`, `piid=4`; False=off, True=on | `concertmirror08464.leshowHumJsq3Heater` |
| Water over | R | `siid=12`, `piid=5`; False=normal, True=detected | `concertmirror08464.leshowHumJsq3WaterOver` |
| Water shortage | R | `siid=12`, `piid=6`; False=normal, True=shortage | `concertmirror08464.leshowHumJsq3WaterShortage` |

Not exposed: private flow/sensor counters, countdowns, wash diagnostics, and protection internals are omitted. Filter reset uses the exact filter action. Generic device fault/fault-code and operating-status diagnostics are not exposed.
