# Zhimi Air Purifier VA1

SmartThings Edge LAN driver for the Xiaomi/MIoT zhimi air purifier va1 model `zhimi.airpurifier.va1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.va1`
- specModel: `zhimi-va1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-va1:2`
- Basis: python-miio lists this as AirPurifierMiot _MAPPING; core controls are power, mode, and fan level.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirVa1FanMode`
- `concertmirror08464.zhimiAirVa1FanSpeed`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirVa1Buzzer`
- `concertmirror08464.zhimiAirVa1ChildLock`
- `concertmirror08464.zhimiAirVa1LedBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific siid/piid constants in `src/init.lua` | `switch` |
| zhimi Air Va1 Fan Mode | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa1FanMode` |
| zhimi Air Va1 Fan Speed | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa1FanSpeed` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific siid/piid constants in `src/init.lua` | `filterState` |
| zhimi Air Va1 Buzzer | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa1Buzzer` |
| zhimi Air Va1 Child Lock | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa1ChildLock` |
| zhimi Air Va1 Led Brightness | RW | Model-specific siid/piid constants in `src/init.lua` | `concertmirror08464.zhimiAirVa1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
