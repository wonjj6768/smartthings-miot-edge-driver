# Zhimi Humidifier V1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi humidifier v1 model `zhimi.humidifier.v1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.humidifier.v1`
- Basis: current `python-miio` lists exact model `zhimi.humidifier.v1` in the classic `AirHumidifier(Device)` implementation and uses `get_prop` plus `set_*` methods.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiHumV1TargetHumidity`
- `concertmirror08464.zhimiHumV1FanMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumV1Buzzer`
- `concertmirror08464.zhimiHumV1ChildLock`
- `concertmirror08464.zhimiHumV1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Hum V1 Target Humidity | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumV1TargetHumidity` |
| zhimi Hum V1 Fan Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumV1FanMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum V1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumV1Buzzer` |
| zhimi Hum V1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumV1ChildLock` |
| zhimi Hum V1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumV1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
