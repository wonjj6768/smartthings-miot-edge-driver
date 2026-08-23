# Xiaomi Air Purifier CPA4

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.cpa4`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.cpa4`
- specModel: `xiaomi-cpa4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-cpa4:2`
- Basis: `hass-xiaomi-miot` lists this exact model for local MIoT host/token access using
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.
  `get_properties` and `set_properties`; the exact MIoT spec supplies the property contract.

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirCpa4Mode`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirCpa4Buzzer`
- `concertmirror08464.xiaomiAirCpa4ChildLock`
- `concertmirror08464.xiaomiAirCpa4DisplayLevel`
- `concertmirror08464.xiaomiAirCpa4FanLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| airPurifierMode | RW | `siid=2`, `piid=4` | `concertmirror08464.xiaomiAirCpa4Mode` |
| PM2.5 | R | `siid=3`, `piid=4` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| buzzer | RW | `siid=6`, `piid=1` | `concertmirror08464.xiaomiAirCpa4Buzzer` |
| childLock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirCpa4ChildLock` |
| displayLevel | RW | `siid=13`, `piid=2` | `concertmirror08464.xiaomiAirCpa4DisplayLevel` |
| favorite fan level (0-14) | RW | `siid=9`, `piid=11` | `concertmirror08464.xiaomiAirCpa4FanLevel` |

Not exposed: faults, RFID data, motor RPM, accumulated usage, self-test, debug, country/region settings,
and AQI polling internals.
