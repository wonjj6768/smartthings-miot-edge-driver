# Zhimi Humidifier CA4

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi humidifier ca4 model `zhimi.humidifier.ca4`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.humidifier.ca4`
- specModel: `zhimi-ca4`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:zhimi-ca4:2`
- Basis: python-miio lists this as AirHumidifierMiot _MAPPINGS_CA4; core controls are power, mode, target humidity, dry mode, LED/display, buzzer, and child lock.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCa4TargetHumidity`
- `concertmirror08464.zhimiHumCa4FanMode`
- `concertmirror08464.zhimiHumCa4DryMode`
- `concertmirror08464.zhimiHumCa4WaterLevel`
- `concertmirror08464.zhimiHumCa4Buzzer`
- `concertmirror08464.zhimiHumCa4ChildLock`
- `concertmirror08464.zhimiHumCa4LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum Ca4 Target Humidity | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4TargetHumidity` |
| zhimi Hum Ca4 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4FanMode` |
| zhimi Hum Ca4 Dry Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4DryMode` |
| zhimi Hum Ca4 Water Level | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4WaterLevel` |
| zhimi Hum Ca4 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4Buzzer` |
| zhimi Hum Ca4 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4ChildLock` |
| zhimi Hum Ca4 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa4LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
