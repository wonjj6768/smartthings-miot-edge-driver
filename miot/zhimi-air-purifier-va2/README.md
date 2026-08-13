# Zhimi Air Purifier VA2

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier va2 model `zhimi.airp.va2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.va2`
- specModel: `zhimi-va2`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-va2:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING_VA2; use the air-purifier URN, not the air-fresh URN.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirVa2FanMode`
- `concertmirror08464.zhimiAirVa2FanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirVa2Buzzer`
- `concertmirror08464.zhimiAirVa2ChildLock`
- `concertmirror08464.zhimiAirVa2LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Va2 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa2FanMode` |
| zhimi Air Va2 Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa2FanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Va2 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa2Buzzer` |
| zhimi Air Va2 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa2ChildLock` |
| zhimi Air Va2 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa2LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
