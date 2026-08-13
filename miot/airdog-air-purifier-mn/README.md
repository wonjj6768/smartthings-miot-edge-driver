# Airdog Air Purifier MN

SmartThings Edge LAN driver for the Airdog MIoT air purifier model `airdog.airpurifier.mn`.

## Protocol Decision

- Protocol: MIoT
- Model: `airdog.airpurifier.mn`
- specModel: `airdog-mn`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:airdog-mn:1`
- Basis: current `hass-xiaomi-miot` lists exact model `airdog.airpurifier.mn` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.airdogAirMnMode`
- `concertmirror08464.airdogAirMnFanLevel`
- `dustSensor`
- `concertmirror08464.airdogAirMnChildLock`
- `concertmirror08464.airdogAirMnSleep`
- `concertmirror08464.airdogAirMnSmartLight`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=auto`, `1=manual`, `2=sleep` | `airdogAirMnMode.airPurifierMode` |
| Fan level | RW | `siid=2`, `piid=5`; `1..4` | `airdogAirMnFanLevel.fanLevel` |
| PM2.5 | R | `siid=3`, `piid=4`; 0..1000 | `dustSensor.fineDustLevel` |
| Child lock | RW | `siid=5`, `piid=1` | `airdogAirMnChildLock.childLock` |
| Sleep switch | RW | `siid=5`, `piid=2` | `airdogAirMnSleep.sleepMode` |
| Smart lighting | RW | `siid=5`, `piid=3` | `airdogAirMnSmartLight.smartLight` |

Not exposed: the fault property carries a single no-fault value, and the filter service only offers a reset action.
