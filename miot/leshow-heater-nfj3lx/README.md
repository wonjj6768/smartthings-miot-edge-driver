# Leshow NFJ3 Heater

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `leshow.heater.nfj3lx`.

## Protocol Decision

- Protocol: MIoT
- Model: `leshow.heater.nfj3lx`
- specModel: `leshow-nfj3lx`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:leshow-nfj3lx:1`
- Driver path: `miot/leshow-heater-nfj3lx`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.leshowNfj3Mode`
- `concertmirror08464.leshowNfj3ChildLock`
- `concertmirror08464.leshowNfj3Buzzer`
- `concertmirror08464.leshowNfj3IndicatorLight`
- `concertmirror08464.leshowNfj3Swing`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Target temperature | RW | `siid=2`, `piid=3`; 22..28 C, step 1 | `thermostatHeatingSetpoint` |
| Measured temperature | R | `siid=4`, `piid=7` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=5`; `0=constantTemperature`, `1=heat`, `2=warm`, `3=naturalWind` | `concertmirror08464.leshowNfj3Mode` |
| Child lock | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.leshowNfj3ChildLock` |
| Buzzer | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.leshowNfj3Buzzer` |
| Indicator light | RW | `siid=7`, `piid=1`; boolean | `concertmirror08464.leshowNfj3IndicatorLight` |
| Swing | RW | `siid=8`, `piid=1`; boolean | `concertmirror08464.leshowNfj3Swing` |

Temperature selection: The environment service temperature at siid=4, piid=7 is used; the duplicate heater-service temperature is not exposed.

Not exposed: countdown scheduling, the duplicate heater-service temperature, fault, PCB temperature, auto-light, and toggle actions are not exposed because they are auxiliary or duplicate values.
