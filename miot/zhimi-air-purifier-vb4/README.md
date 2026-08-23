# Zhimi Air Purifier VB4

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier vb4 model `zhimi.airp.vb4`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.vb4`
- specModel: `zhimi-vb4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-vb4:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_VB4; use the latest MIoT air-purifier URN.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirVb4FanMode`
- `concertmirror08464.zhimiAirVb4FanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirVb4Buzzer`
- `concertmirror08464.zhimiAirVb4ChildLock`
- `concertmirror08464.zhimiAirVb4LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Vb4 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb4FanMode` |
| zhimi Air Vb4 Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb4FanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| zhimi Air Vb4 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb4Buzzer` |
| zhimi Air Vb4 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb4ChildLock` |
| zhimi Air Vb4 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVb4LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
