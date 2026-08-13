# Zhimi Humidifier CA7

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `zhimi.humidifier.ca7`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.humidifier.ca7`
- specModel: `zhimi-ca7`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:zhimi-ca7:1:0000D061`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.humidifier.ca7` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.zhimiHumCa7Mode`
- `concertmirror08464.zhimiHumCa7TargetHumidity`
- `concertmirror08464.zhimiHumCa7Status`
- `concertmirror08464.zhimiHumCa7WaterLevel`
- `concertmirror08464.zhimiHumCa7ScreenBrightness`
- `concertmirror08464.zhimiHumCa7Alarm`
- `concertmirror08464.zhimiHumCa7ChildLock`
- `concertmirror08464.zhimiHumCa7AirDry`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `2=sleep`, `3=auto`, `4=favorite` | `zhimiHumCa7Mode.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..60 %, step 1 | `zhimiHumCa7TargetHumidity.targetHumidity` |
| Water level | R | `siid=2`, `piid=6`; `0=empty`, `1=low`, `2=normal` | `zhimiHumCa7WaterLevel.waterLevel` |
| Automatic air drying | RW | `siid=2`, `piid=9` | `zhimiHumCa7AirDry.airDry` |
| Operating status | R | `siid=2`, `piid=11`; `1=close`, `2=work`, `3=dry`, `4=clean` | `zhimiHumCa7Status.operatingStatus` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; celsius | `temperatureMeasurement` |
| Screen brightness | RW | `siid=6`, `piid=2`; `0=close`, `1=dim`, `2=normal` | `zhimiHumCa7ScreenBrightness.screenBrightness` |
| Buzzer | RW | `siid=7`, `piid=1` | `zhimiHumCa7Alarm.alarm` |
| Child lock | RW | `siid=8`, `piid=1` | `zhimiHumCa7ChildLock.childLock` |

Not exposed: device fault reports a raw 0..15 code, the `siid=10` service exposes country code, motor, and debug values, and the `siid=2` toggle action duplicates the `switch` capability.
