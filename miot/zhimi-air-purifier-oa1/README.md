# Zhimi Air Purifier OA1

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `zhimi.airpurifier.oa1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airpurifier.oa1`
- specModel: `zhimi-oa1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-oa1:1`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirOa1FanLevel`
- `filterState`
- `concertmirror08464.zhimiAirOa1Buzzer`
- `concertmirror08464.zhimiAirOa1ChildLock`
- `concertmirror08464.zhimiAirOa1DisplayLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| fanLevel | RW | `siid=2`, `piid=5` | `concertmirror08464.zhimiAirOa1FanLevel` |
| Filter life | R | `siid=4`, `piid=2`; exact spec has no reset action | `filterState` |
| buzzer | RW | `siid=2`, `piid=7` | `concertmirror08464.zhimiAirOa1Buzzer` |
| childLock | RW | `siid=2`, `piid=9` | `concertmirror08464.zhimiAirOa1ChildLock` |
| displayLevel | RW | `siid=2`, `piid=6` | `concertmirror08464.zhimiAirOa1DisplayLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, and private metadata.
