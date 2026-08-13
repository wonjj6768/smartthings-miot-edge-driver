# Zhimi Air Purifier MB4

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier mb4 model `zhimi.airpurifier.mb4`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.mb4`
- specModel: `zhimi-mb4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb4:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_MB4; core controls are power and auto/sleep/favorite mode, core sensors are PM2.5 and filter life.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMb4AirPurifierMode`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMb4Buzzer`
- `concertmirror08464.zhimiAirMb4ChildLock`
- `concertmirror08464.zhimiAirMb4LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Mb4 Air Purifier Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4AirPurifierMode` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Mb4 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4Buzzer` |
| zhimi Air Mb4 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4ChildLock` |
| zhimi Air Mb4 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
