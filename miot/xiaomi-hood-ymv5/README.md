# Xiaomi Hood YMV5

SmartThings Edge LAN driver for the Xiaomi MIoT range hood model `xiaomi.hood.ymv5`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.hood.ymv5`
- specModel: `xiaomi-ymv5`
- URN: `urn:miot-spec-v2:device:hood:0000A01B:xiaomi-ymv5:3`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.hood.ymv5` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiHoodYmv5FanLevel`
- `concertmirror08464.xiaomiHoodYmv5Light`
- `concertmirror08464.xiaomiHoodYmv5OffDelay`
- `concertmirror08464.xiaomiHoodYmv5Countdown`
- `concertmirror08464.xiaomiHoodYmv5CleanRemind`
- `concertmirror08464.xiaomiHoodYmv5StoveLink`
- `concertmirror08464.xiaomiHoodYmv5DryStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Power off delay | RW | `siid=2`, `piid=3` | `xiaomiHoodYmv5OffDelay.powerOffDelay` |
| Countdown time | RW | `siid=2`, `piid=5`; 0..420 s | `xiaomiHoodYmv5Countdown.countdownTime` |
| Stove link status | R | `siid=2`, `piid=6`; `0=unbound`, `1=unlinked`, `2=linked` | `xiaomiHoodYmv5StoveLink.stoveLinkStatus` |
| Clean reminder | RW | `siid=2`, `piid=13` | `xiaomiHoodYmv5CleanRemind.cleanRemind` |
| Hood light | RW | `siid=4`, `piid=1` | `xiaomiHoodYmv5Light.light` |
| Fan level | RW | `siid=5`, `piid=1`; `0=low`, `1=high`, `2=stirFry` | `xiaomiHoodYmv5FanLevel.fanLevel` |
| Dry cleaning status | R | `siid=7`, `piid=2`; `0=notStarted`, `1=preDry`, `2=dryCleaning`, `3=dryCompleted` | `xiaomiHoodYmv5DryStatus.dryCleaningStatus` |

Not exposed: the fault property reports a raw 32-bit code, holiday mode and its ventilation schedule are scheduling values, power-on and power-off light linkage plus cruise and gesture switches are installation preferences, the kitchen stove service exposes burner status and bind actions for a paired cooktop rather than this device, remote battery level is a two-state accessory flag, and the dry-cleaning timer, guide, remaining time, and start/stop actions are maintenance-only.
