# Zhimi Humidifier CA1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi humidifier ca1 model `zhimi.humidifier.ca1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.humidifier.ca1`
- Basis: python-miio AirHumidifier lists one-property get_prop polling plus power, mode, humidity, temp_dec, target humidity, dry mode, depth-derived water level, LED brightness, buzzer, and child lock.
- Evidence: confirmed. Source: python-miio.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiHumCa1TargetHumidity`
- `concertmirror08464.zhimiHumCa1FanMode`
- `concertmirror08464.zhimiHumCa1DryMode`
- `concertmirror08464.zhimiHumCa1WaterLevel`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCa1Buzzer`
- `concertmirror08464.zhimiHumCa1ChildLock`
- `concertmirror08464.zhimiHumCa1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Hum Ca1 Target Humidity | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1TargetHumidity` |
| zhimi Hum Ca1 Fan Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1FanMode` |
| zhimi Hum Ca1 Dry Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1DryMode` |
| zhimi Hum Ca1 Water Level | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1WaterLevel` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum Ca1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1Buzzer` |
| zhimi Hum Ca1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1ChildLock` |
| zhimi Hum Ca1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiHumCa1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
