# Dmaker 50l Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `dmaker.derh.50l`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.derh.50l`
- specModel: `dmaker-50l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:dmaker-50l:1`
- Driver path: `miot/dmaker-dehumidifier-50l`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.dmk50lMode`
- `concertmirror08464.dmk50lTargetHumidity`
- `concertmirror08464.dmk50lBuzzer`
- `concertmirror08464.dmk50lIndicatorLight`
- `concertmirror08464.dmk50lIndicatorBrightness`
- `concertmirror08464.dmk50lChildLock`
- `concertmirror08464.dmk50lTankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `concertmirror08464.dmk50lMode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..70, step 1 % | `concertmirror08464.dmk50lTargetHumidity` |
| Buzzer | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.dmk50lBuzzer` |
| Indicator light | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.dmk50lIndicatorLight` |
| Indicator brightness | RW | `siid=5`, `piid=2`; `0=off`, `1=half`, `2=full` | `concertmirror08464.dmk50lIndicatorBrightness` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.dmk50lChildLock` |
| Tank status | R | `siid=2`, `piid=2`; `0=normal`, `1=full` | `concertmirror08464.dmk50lTankStatus` |

Not exposed: fault codes other than water-full, off-delay/dry-after-off state, anion, UV, pump-after-off, tube state, filter reset, and toggle/loop actions are auxiliary or diagnostic values.
