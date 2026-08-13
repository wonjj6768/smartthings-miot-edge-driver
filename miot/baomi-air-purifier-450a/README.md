# Baomi Air Purifier 450A

SmartThings Edge LAN driver for the Baomi MIoT air purifier model `baomi.airpurifier.450a`.

## Protocol Decision

- Protocol: MIoT
- Model: `baomi.airpurifier.450a`
- specModel: `baomi-450a`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:baomi-450a:1`
- Basis: current `hass-xiaomi-miot` lists exact model `baomi.airpurifier.450a` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.baomiAir450aMode`
- `concertmirror08464.baomiAir450aFanLevel`
- `dustSensor`
- `filterState`
- `concertmirror08464.baomiAir450aFilterType`
- `concertmirror08464.baomiAir450aScreen`
- `concertmirror08464.baomiAir450aChildLock`
- `concertmirror08464.baomiAir450aBuzzer`
- `concertmirror08464.baomiAir450aSleep`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=silent`, `1=strong`, `2=smart` | `baomiAir450aMode.airPurifierMode` |
| Fan level | RW | `siid=2`, `piid=5`; `0..4` shown as level 1..5 | `baomiAir450aFanLevel.fanLevel` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor.fineDustLevel` |
| Filter life | R | `siid=4`, `piid=1`; percent | `filterState.filterLifeRemaining` |
| Filter type | RW | `siid=9`, `piid=1`; `0=anti-mite`, `1=formaldehyde`, `2=baby care` | `baomiAir450aFilterType.filterType` |
| Display | RW | `siid=7`, `piid=1` | `baomiAir450aScreen.screen` |
| Child lock | RW | `siid=8`, `piid=1` | `baomiAir450aChildLock.childLock` |
| Buzzer | RW | `siid=11`, `piid=1` | `baomiAir450aBuzzer.buzzer` |
| Sleep mode | RW | `siid=9`, `piid=2` | `baomiAir450aSleep.sleepMode` |

Not exposed: the fault property carries a single no-fault value, and the vendor `none` placeholder in the mode enum is not offered as a selectable mode.
