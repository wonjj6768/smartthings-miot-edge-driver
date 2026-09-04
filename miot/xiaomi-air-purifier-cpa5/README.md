# Xiaomi Smart Pet Care Air Purifier

SmartThings Edge LAN driver for the Xiaomi MIoT air purifier model `xiaomi.airp.cpa5`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.cpa5`
- specModel: `xiaomi-cpa5`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-cpa5:1:0000D050`
- Basis: Homey's exact-model profile sends local `get_properties` and `set_properties` through its host/token connection with explicit `siid`/`piid` mappings.
- Evidence: confirmed. Source: [`shaarkys/com.xiaomi-miio` exact CPA5 implementation](https://github.com/shaarkys/com.xiaomi-miio/commit/8c68f8b52861d06278e9602c39a3f69867f8e25c).
- Contract sources: [exact MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn%3Amiot-spec-v2%3Adevice%3Aair-purifier%3A0000A007%3Axiaomi-cpa5%3A1%3A0000D050) and [Xiaomi product FAQ](https://www.mi.com/my/support/faq/details/KA-524990/).

## Exposed Capabilities

- `switch`
- `concertmirror08464.xiaomiAirCpa5Mode`
- `concertmirror08464.xiaomiAirCpa5FanLevel`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.xiaomiAirCpa5DisplayLevel`
- `concertmirror08464.xiaomiAirCpa5Buzzer`
- `concertmirror08464.xiaomiAirCpa5PetLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=3`; `0=auto`, `1=sleep`, `2=favorite/manual` | `concertmirror08464.xiaomiAirCpa5Mode` |
| Manual/favorite fan level | RW | `siid=9`, `piid=1`; values `0..14` | `concertmirror08464.xiaomiAirCpa5FanLevel` |
| PM2.5 | R | `siid=3`, `piid=4`; `0..600 μg/m³` | `fineDustSensor` |
| Filter life | R | `siid=4`, `piid=1`; `0..100%` | `filterState` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| Display brightness | RW | `siid=6`, `piid=2`; `0=off`, `1=bright`, `2=dim` | `concertmirror08464.xiaomiAirCpa5DisplayLevel` |
| Buzzer | RW | `siid=7`, `piid=1` | `concertmirror08464.xiaomiAirCpa5Buzzer` |
| Pet/physical lock | RW | `siid=8`, `piid=1` | `concertmirror08464.xiaomiAirCpa5PetLock` |

Not exposed: fault diagnostics, filter usage hours/days, motor RPM, country/region settings, debug writes,
mode-toggle internals, and AQI heartbeat. The exact model has no temperature, humidity, VOC, PM1, PM10,
or ionizer contract.
