# Zhimi Air Purifier RMB1

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier rmb1 model `zhimi.airp.rmb1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.rmb1`
- specModel: `zhimi-rmb1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-rmb1:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_RMB1; uses a three-mode custom capability.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirRmb1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirRmb1Buzzer`
- `concertmirror08464.zhimiAirRmb1ChildLock`
- `concertmirror08464.zhimiAirRmb1LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Rmb1 Air Purifier Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRmb1AirPurifierMode` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| zhimi Air Rmb1 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRmb1Buzzer` |
| zhimi Air Rmb1 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRmb1ChildLock` |
| zhimi Air Rmb1 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRmb1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
