# Zhimi Air Purifier MB3A

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier mb3a model `zhimi.airpurifier.mb3a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.mb3a`
- specModel: `zhimi-mb3a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb3a:1`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING; split by exact model id.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMb3aFanMode`
- `concertmirror08464.zhimiAirMb3aFanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMb3aBuzzer`
- `concertmirror08464.zhimiAirMb3aChildLock`
- `concertmirror08464.zhimiAirMb3aLedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Mb3a Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aFanMode` |
| zhimi Air Mb3a Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aFanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Mb3a Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aBuzzer` |
| zhimi Air Mb3a Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aChildLock` |
| zhimi Air Mb3a Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aLedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
