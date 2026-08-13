# Leshow BS2 Heater

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `leshow.heater.bs2`.

## Protocol Decision

- Protocol: MIoT
- Model: `leshow.heater.bs2`
- specModel: `leshow-bs2`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:leshow-bs2:1`
- Driver path: `miot/leshow-heater-bs2`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.leshowBs2Mode`
- `concertmirror08464.leshowBs2ChildLock`
- `concertmirror08464.leshowBs2Buzzer`
- `concertmirror08464.leshowBs2IndicatorBrightness`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=3`; 18..28 C, step 1 | `thermostatHeatingSetpoint` |
| Measured temperature | R | `siid=4`, `piid=7` | `temperatureMeasurement` |
| Relative humidity | R | `siid=4`, `piid=8` | `relativeHumidityMeasurement` |
| Mode | RW | `siid=2`, `piid=5`; `0=auto`, `1=low` | `concertmirror08464.leshowBs2Mode` |
| Child lock | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.leshowBs2ChildLock` |
| Buzzer | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.leshowBs2Buzzer` |
| Indicator brightness | RW | `siid=10`, `piid=1`; `0=off`, `1=half`, `2=full` | `concertmirror08464.leshowBs2IndicatorBrightness` |

Temperature selection: The environment service temperature at siid=4, piid=7 is used; duplicate heater-service and relational temperature properties are not exposed.

Not exposed: countdown scheduling, heater-service duplicate temperature, relational temperature/humidity copies, PCB/plug temperature, push/on-off status, fault, and toggle actions are not exposed because they are auxiliary or duplicate values.
