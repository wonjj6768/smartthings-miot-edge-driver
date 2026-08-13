# Xiaomi Smart Air Purifier 4 Compact

SmartThings Edge LAN driver for `zhimi.airp.cpa4`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.cpa4`
- Spec model: `zhimi-cpa4`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-cpa4:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.airp.cpa4` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.zhimiAirCpa4AirPurifierMode`
- `fineDustSensor`
- `filterState`
- `concertmirror08464.zhimiAirCpa4Buzzer`
- `concertmirror08464.zhimiAirCpa4ChildLock`
- `concertmirror08464.zhimiAirCpa4ScreenBrightness`
- `refresh`

## MIoT Mapping

| Feature | MIoT key | Access | SmartThings capability |
| --- | --- | --- | --- |
| Power | `siid=2`, `piid=1` | read/write | `switch` |
| Mode | `siid=2`, `piid=4`, `0=Auto`, `1=Sleep`, `2=Favorite` | read/write | `concertmirror08464.zhimiAirCpa4AirPurifierMode` |
| PM2.5 | `siid=3`, `piid=4`, `0..600 ug/m3` | read | `fineDustSensor` |
| Filter life | `siid=4`, `piid=1`, `0..100 %` | read | `filterState.filterLifeRemaining` |
| Buzzer | `siid=6`, `piid=1` | read/write | `concertmirror08464.zhimiAirCpa4Buzzer` |
| Child lock | `siid=8`, `piid=1` | read/write | `concertmirror08464.zhimiAirCpa4ChildLock` |
| Screen brightness | `siid=13`, `piid=2`, `0=Close`, `1=Bright`, `2=Brightest` | read/write | `concertmirror08464.zhimiAirCpa4ScreenBrightness` |

The custom service favorite level (`siid=9`, `piid=11`) is intentionally not exposed as a direct control here because the primary mode contract is auto/sleep/favorite and existing user reports note mixed behavior around fan-level style commands on this compact model.

Not exposed: favorite-level tuning, diagnostics, accumulated usage, and private service values are intentionally omitted.
