# Zhimi Humidifier CB1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi humidifier cb1 model `zhimi.humidifier.cb1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.humidifier.cb1`
- Basis: python-miio AirHumidifier lists one-property get_prop polling plus power, mode, humidity, temperature, target humidity, dry mode, depth-derived water level, LED brightness, buzzer, and child lock.
- Evidence: confirmed. Source: python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiHumCb1TargetHumidity`
- `concertmirror08464.zhimiHumCb1FanMode`
- `concertmirror08464.zhimiHumCb1DryMode`
- `concertmirror08464.zhimiHumCb1WaterLevel`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCb1Buzzer`
- `concertmirror08464.zhimiHumCb1ChildLock`
- `concertmirror08464.zhimiHumCb1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Hum Cb1 Target Humidity | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1TargetHumidity` |
| zhimi Hum Cb1 Fan Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1FanMode` |
| zhimi Hum Cb1 Dry Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1DryMode` |
| zhimi Hum Cb1 Water Level | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1WaterLevel` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum Cb1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1Buzzer` |
| zhimi Hum Cb1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1ChildLock` |
| zhimi Hum Cb1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCb1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
