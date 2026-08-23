# Zhimi Air Purifier MB5A

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier mb5a model `zhimi.airp.mb5a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mb5a`
- specModel: `zhimi-mb5a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb5a:1`
- Basis: python-miio lists this as AirPurifierMiot; MIoT spec uses the same core siid/piid mapping as zhimi-mb5.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMb5aFanMode`
- `concertmirror08464.zhimiAirMb5aFanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMb5aBuzzer`
- `concertmirror08464.zhimiAirMb5aChildLock`
- `concertmirror08464.zhimiAirMb5aLedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Mb5a Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb5aFanMode` |
| zhimi Air Mb5a Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb5aFanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| zhimi Air Mb5a Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb5aBuzzer` |
| zhimi Air Mb5a Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb5aChildLock` |
| zhimi Air Mb5a Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb5aLedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
