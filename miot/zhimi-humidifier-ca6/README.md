# Zhimi Humidifier CA6

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi humidifier ca6 model `zhimi.humidifier.ca6`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.humidifier.ca6`
- specModel: `zhimi-ca6`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:zhimi-ca6:1`
- Basis: current `python-miio` implements exact model `zhimi.humidifier.ca6` as `AirHumidifierMiotCA6(MiotDevice)`, with `_MAPPINGS_CA6` and `get_properties`/`set_properties`. The exact MIoT spec confirms the mapped property contract.
- Evidence: confirmed. Source: python-miio-miot+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.zhimiHumCa6FanMode`
- `concertmirror08464.zhimiHumCa6TargetHumidity`
- `concertmirror08464.zhimiHumCa6WaterLevel`
- `concertmirror08464.zhimiHumCa6DryMode`
- `concertmirror08464.zhimiHumCa6Buzzer`
- `concertmirror08464.zhimiHumCa6ChildLock`
- `concertmirror08464.zhimiHumCa6LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| zhimi Hum Ca6 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6FanMode` |
| zhimi Hum Ca6 Target Humidity | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6TargetHumidity` |
| zhimi Hum Ca6 Water Level | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6WaterLevel` |
| zhimi Hum Ca6 Dry Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6DryMode` |
| zhimi Hum Ca6 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6Buzzer` |
| zhimi Hum Ca6 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6ChildLock` |
| zhimi Hum Ca6 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiHumCa6LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
