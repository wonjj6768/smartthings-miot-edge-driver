# Zhimi Humidifier CB2

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi humidifier cb2 model `zhimi.humidifier.cb2`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.humidifier.cb2`
- Basis: python-miio AirHumidifier lists one-property get_prop polling plus power, mode, humidity, temperature, target humidity, dry mode, depth-derived water level, LED brightness, buzzer, and child lock.
- Evidence: confirmed. Source: python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiHumCb2TargetHumidity`
- `concertmirror08464.zhimiHumCb2FanMode`
- `concertmirror08464.zhimiHumCb2DryMode`
- `concertmirror08464.zhimiHumCb2WaterLevel`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCb2Buzzer`
- `concertmirror08464.zhimiHumCb2ChildLock`
- `concertmirror08464.zhimiHumCb2LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Hum Cb2 Target Humidity | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2TargetHumidity` |
| zhimi Hum Cb2 Fan Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2FanMode` |
| zhimi Hum Cb2 Dry Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2DryMode` |
| zhimi Hum Cb2 Water Level | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2WaterLevel` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum Cb2 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2Buzzer` |
| zhimi Hum Cb2 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2ChildLock` |
| zhimi Hum Cb2 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
