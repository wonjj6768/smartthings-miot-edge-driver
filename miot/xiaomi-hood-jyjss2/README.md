# Xiaomi Hood JYJSS2

SmartThings Edge LAN driver for the Xiaomi MIoT range hood model `xiaomi.hood.jyjss2`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.hood.jyjss2`
- specModel: `xiaomi-jyjss2`
- URN: `urn:miot-spec-v2:device:hood:0000A01B:xiaomi-jyjss2:3`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.hood.jyjss2` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiHoodJyj2FanLevel`
- `concertmirror08464.xiaomiHoodJyj2Light`
- `dustSensor`
- `concertmirror08464.xiaomiHoodJyj2OffDelay`
- `concertmirror08464.xiaomiHoodJyj2DelayTime`
- `concertmirror08464.xiaomiHoodJyj2Countdown`
- `concertmirror08464.xiaomiHoodJyj2CleanRemind`
- `concertmirror08464.xiaomiHoodJyj2CleanTime`
- `concertmirror08464.xiaomiHoodJyj2Gestures`
- `concertmirror08464.xiaomiHoodJyj2AutoVent`
- `concertmirror08464.xiaomiHoodJyj2StoveLink`
- `concertmirror08464.xiaomiHoodJyj2Battery`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=3`, `piid=1`; `1=low`, `2=high`, `3=turbo` | `xiaomiHoodJyj2FanLevel.fanLevel` |
| Hood light | RW | `siid=6`, `piid=1` | `xiaomiHoodJyj2Light.hoodLight` |
| PM2.5 | R | `siid=12`, `piid=1` | `dustSensor.fineDustLevel` |
| Power off delay | RW | `siid=2`, `piid=5` | `xiaomiHoodJyj2OffDelay.offDelay` |
| Off delay minutes | RW | `siid=2`, `piid=6`; 0..7 | `xiaomiHoodJyj2DelayTime.offDelayTime` |
| Countdown | RW | `siid=2`, `piid=7`; 0..420 minutes | `xiaomiHoodJyj2Countdown.countdownTime` |
| Clean reminder | RW | `siid=2`, `piid=11` | `xiaomiHoodJyj2CleanRemind.cleanRemind` |
| Clean reminder hours | RW | `siid=2`, `piid=12`; 20..50, step 10 | `xiaomiHoodJyj2CleanTime.cleanRemindTime` |
| Gesture control | RW | `siid=2`, `piid=18` | `xiaomiHoodJyj2Gestures.gestures` |
| Auto ventilation | RW | `siid=2`, `piid=20` | `xiaomiHoodJyj2AutoVent.autoVentilation` |
| Stove link status | R | `siid=2`, `piid=8`; `0=unbound`, `1=unlinked`, `2=linked` | `xiaomiHoodJyj2StoveLink.stoveLink` |
| Remote battery | R | `siid=11`, `piid=1`; `0=low`, `1=normal` | `xiaomiHoodJyj2Battery.batteryState` |

Not exposed: the fault property reports a raw 32-bit code, the power-on and power-off light linkage flags plus `working-remind-time` are app preferences, the PM trigger thresholds tune auto ventilation rather than expose device state, `siid=12` `piid=2..4` record which input last triggered the hood, and the kitchen-stove and dry-wash services need the paired stove appliance.
