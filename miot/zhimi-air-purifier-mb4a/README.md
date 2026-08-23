# Zhimi Air Purifier MB4A

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier mb4a model `zhimi.airp.mb4a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mb4a`
- specModel: `zhimi-mb4a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb4a:1`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_MB4; split from zhimi.airpurifier.mb4 as a separate one-model driver.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMb4aAirPurifierMode`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMb4aBuzzer`
- `concertmirror08464.zhimiAirMb4aChildLock`
- `concertmirror08464.zhimiAirMb4aLedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Mb4a Air Purifier Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4aAirPurifierMode` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| zhimi Air Mb4a Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4aBuzzer` |
| zhimi Air Mb4a Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4aChildLock` |
| zhimi Air Mb4a Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirMb4aLedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
