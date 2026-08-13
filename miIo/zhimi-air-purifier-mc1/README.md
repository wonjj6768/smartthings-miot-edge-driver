# Zhimi Air Purifier MC1

SmartThings Edge LAN driver for the Xiaomi/miIO zhimi air purifier mc1 model `zhimi.airpurifier.mc1`.

## Protocol Decision

- Protocol: miIO
- Model: `zhimi.airpurifier.mc1`
- Basis: current `python-miio` lists exact model `zhimi.airpurifier.mc1` in the classic `AirPurifier(Device)` implementation and uses `get_prop` plus `set_*` methods. The MIoT spec is equivalent capability-contract evidence only.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirMc1AirPurifierMode`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirMc1Buzzer`
- `concertmirror08464.zhimiAirMc1ChildLock`
- `concertmirror08464.zhimiAirMc1LedBrightness`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| zhimi Air Mc1 Air Purifier Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc1AirPurifierMode` |
| temperature Measurement | R | Model-specific property/method constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific property/method constants in `src/init.lua` | `relativeHumidityMeasurement` |
| fine Dust Sensor | R | Model-specific property/method constants in `src/init.lua` | `fineDustSensor` |
| filter State | R | Model-specific property/method constants in `src/init.lua` | `filterState` |
| zhimi Air Mc1 Buzzer | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc1Buzzer` |
| zhimi Air Mc1 Child Lock | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc1ChildLock` |
| zhimi Air Mc1 Led Brightness | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.zhimiAirMc1LedBrightness` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
