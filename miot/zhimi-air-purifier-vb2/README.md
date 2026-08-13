# Zhimi Air Purifier VB2

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier vb2 model `zhimi.airpurifier.vb2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.vb2`
- specModel: `zhimi-vb2`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-vb2:1`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING; core controls are power, mode, and fan level.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirVb2FanMode`
- `concertmirror08464.zhimiAirVb2FanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirVb2Buzzer`
- `concertmirror08464.zhimiAirVb2ChildLock`
- `concertmirror08464.zhimiAirVb2LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Vb2 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb2FanMode` |
| zhimi Air Vb2 Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb2FanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Vb2 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb2Buzzer` |
| zhimi Air Vb2 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb2ChildLock` |
| zhimi Air Vb2 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
