# Zhimi Air Purifier AIRP MB3A

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier airp mb3a model `zhimi.airp.mb3a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mb3a`
- specModel: `zhimi-mb3a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb3a:1`
- Basis: python-miio lists this alternate model id as AirPurifierMiot _MAPPING; separate driver from zhimi.airpurifier.mb3a.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirAirpMb3aFanMode`
- `concertmirror08464.zhimiAirAirpMb3aFanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirAirpMb3aBuzzer`
- `concertmirror08464.zhimiAirAirpMb3aChildLock`
- `concertmirror08464.zhimiAirMb3aLedLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Airp Mb3a Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirAirpMb3aFanMode` |
| zhimi Air Airp Mb3a Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirAirpMb3aFanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| Filter state | R | Model-specific siid/piid constants in `src/init.lua`; exact spec has no reset action | `filterState` |
| zhimi Air Airp Mb3a Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirAirpMb3aBuzzer` |
| zhimi Air Airp Mb3a Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirAirpMb3aChildLock` |
| zhimi Air Airp Mb3a Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb3aLedLevel` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
