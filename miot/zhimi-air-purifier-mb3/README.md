# Zhimi Air Purifier MB3

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier mb3 model `zhimi.airpurifier.mb3`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.mb3`
- specModel: `zhimi-mb3`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb3:3`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING; core controls are power, mode, and fan level.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMb3FanMode`
- `concertmirror08464.zhimiAirMb3FanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMb3Buzzer`
- `concertmirror08464.zhimiAirMb3ChildLock`
- `concertmirror08464.zhimiAirMb3LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Mb3 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3FanMode` |
| zhimi Air Mb3 Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3FanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Mb3 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3Buzzer` |
| zhimi Air Mb3 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3ChildLock` |
| zhimi Air Mb3 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
