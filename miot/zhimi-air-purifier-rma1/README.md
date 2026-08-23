# Zhimi Air Purifier RMA1

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier rma1 model `zhimi.airpurifier.rma1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.rma1`
- specModel: `zhimi-rma1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-rma1:1`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_RMA1; uses a three-mode custom capability.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirRma1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirRma1Buzzer`
- `concertmirror08464.zhimiAirRma1ChildLock`
- `concertmirror08464.zhimiAirRma1LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Rma1 Air Purifier Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRma1AirPurifierMode` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| zhimi Air Rma1 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRma1Buzzer` |
| zhimi Air Rma1 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRma1ChildLock` |
| zhimi Air Rma1 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirRma1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
