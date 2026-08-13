# Dmaker 22ht Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `dmaker.derh.22ht`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.derh.22ht`
- specModel: `dmaker-22ht`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:dmaker-22ht:1`
- Driver path: `miot/dmaker-dehumidifier-22ht`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.dmk22htMode`
- `concertmirror08464.dmk22htTargetHumidity`
- `concertmirror08464.dmk22htBuzzer`
- `concertmirror08464.dmk22htIndicatorLight`
- `concertmirror08464.dmk22htIndicatorBrightness`
- `concertmirror08464.dmk22htChildLock`
- `concertmirror08464.dmk22htTankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `concertmirror08464.dmk22htMode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70, step 1 % | `concertmirror08464.dmk22htTargetHumidity` |
| Buzzer | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.dmk22htBuzzer` |
| Indicator light | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.dmk22htIndicatorLight` |
| Indicator brightness | RW | `siid=5`, `piid=2`; `0=off`, `1=half`, `2=full` | `concertmirror08464.dmk22htIndicatorBrightness` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.dmk22htChildLock` |
| Tank status | R | `siid=2`, `piid=2`; `0=normal`, `1=full` | `concertmirror08464.dmk22htTankStatus` |

Not exposed: fault codes other than water-full, off-delay time, dry-after-off, dry-left-time, warming-up, filter reset, and toggle/loop actions are auxiliary or diagnostic values.
