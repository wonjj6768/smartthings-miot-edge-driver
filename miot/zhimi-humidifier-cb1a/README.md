# Zhimi Humidifier CB1A

SmartThings Edge LAN driver for exact model `zhimi.humidifier.cb1a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.humidifier.cb1a`
- specModel: `zhimi-cb1a`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:zhimi-cb1a:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCb1aFanLevel`
- `concertmirror08464.zhimiHumCb1aTargetHumidity`
- `concertmirror08464.zhimiHumCb1aDry`
- `concertmirror08464.zhimiHumCb1aBuzzer`
- `concertmirror08464.zhimiHumCb1aScreenBrightness`
- `concertmirror08464.zhimiHumCb1aChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Temperature | R | `siid=3`, `piid=7` | `temperatureMeasurement` |
| Relative humidity | R | `siid=3`, `piid=9` | `relativeHumidityMeasurement` |
| Fan level | RW | `siid=2`, `piid=5`; 0=auto, 1=level1, 2=level2, 3=level3 | `concertmirror08464.zhimiHumCb1aFanLevel` |
| Target humidity | RW | `siid=2`, `piid=6`; 30..80 % | `concertmirror08464.zhimiHumCb1aTargetHumidity` |
| Dry mode | RW | `siid=2`, `piid=8`; False=off, True=on | `concertmirror08464.zhimiHumCb1aDry` |
| Buzzer | RW | `siid=4`, `piid=1`; False=off, True=on | `concertmirror08464.zhimiHumCb1aBuzzer` |
| Screen brightness | RW | `siid=5`, `piid=2`; 0=dark, 1=glimmer, 2=brightest | `concertmirror08464.zhimiHumCb1aScreenBrightness` |
| Child lock | RW | `siid=6`, `piid=1`; False=off, True=on | `concertmirror08464.zhimiHumCb1aChildLock` |

Not exposed: raw water level 0..128 has no unit or polarity in the exact spec and is not exposed. Raw fault, button, use-time, RPM, and maintenance internals are also omitted.
