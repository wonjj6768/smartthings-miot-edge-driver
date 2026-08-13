# Aden Fight Dehumidifier

SmartThings Edge LAN driver for exact Xiaomi ecosystem model `aden.derh.fight`.

## Protocol Decision

- Protocol: MIoT
- Model: `aden.derh.fight`
- specModel: `aden-fight`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:aden-fight:1`
- Driver path: `miot/aden-dehumidifier-fight`
- Basis: current `hass-xiaomi-miot` `MIOT_LOCAL_MODELS` contains the exact model and no `MIIO_TO_MIOT_SPECS` converter; its local host/token path therefore uses native `get_properties` and `set_properties` with siid/piid. The exact MIoT spec is the feature contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.adenFightMode`
- `concertmirror08464.adenFightTargetHumidity`
- `concertmirror08464.adenFightBuzzer`
- `concertmirror08464.adenFightIndicatorLight`
- `concertmirror08464.adenFightIndicatorBrightness`
- `concertmirror08464.adenFightChildLock`
- `concertmirror08464.adenFightTankStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key / contract | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2` | `temperatureMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `concertmirror08464.adenFightMode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..80, step 1 % | `concertmirror08464.adenFightTargetHumidity` |
| Buzzer | RW | `siid=4`, `piid=1`; boolean | `concertmirror08464.adenFightBuzzer` |
| Indicator light | RW | `siid=5`, `piid=1`; boolean | `concertmirror08464.adenFightIndicatorLight` |
| Indicator brightness | RW | `siid=5`, `piid=2`; `0=half`, `1=full` | `concertmirror08464.adenFightIndicatorBrightness` |
| Child lock | RW | `siid=6`, `piid=1`; boolean | `concertmirror08464.adenFightChildLock` |
| Tank status | R | `siid=2`, `piid=2`; `0=normal`, `1=full` | `concertmirror08464.adenFightTankStatus` |

Not exposed: fault codes other than water-full, off-delay time, dry-after-off, dry-left-time, warming-up, anion, filter reset, and toggle/loop actions are auxiliary or lack a stable SmartThings core contract.
