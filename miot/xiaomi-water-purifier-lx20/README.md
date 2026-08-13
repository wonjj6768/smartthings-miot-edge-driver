# Xiaomi Water Purifier LX20

SmartThings Edge LAN driver for the Xiaomi MIoT water purifier model `xiaomi.waterpuri.lx20`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.waterpuri.lx20`
- specModel: `xiaomi-lx20`
- URN: `urn:miot-spec-v2:device:water-purifier:0000A013:xiaomi-lx20:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.waterpuri.lx20` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `temperatureMeasurement`
- `concertmirror08464.xiaomiPuriLx20Status`
- `concertmirror08464.xiaomiPuriLx20SaveMode`
- `concertmirror08464.xiaomiPuriLx20TdsIn`
- `concertmirror08464.xiaomiPuriLx20TdsOut`
- `concertmirror08464.xiaomiPuriLx20FilterRo`
- `concertmirror08464.xiaomiPuriLx20FilterRoTwo`
- `concertmirror08464.xiaomiPuriLx20FilterPpc`
- `concertmirror08464.xiaomiPuriLx20Output`
- `concertmirror08464.xiaomiPuriLx20NoDisturb`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Operating status | R | `siid=2`, `piid=2`; `1=idle`, `2=busy` | `xiaomiPuriLx20Status.operatingStatus` |
| Water temperature | R | `siid=2`, `piid=3`; celsius | `temperatureMeasurement` |
| Water mode | RW | `siid=2`, `piid=4`; `0=default`, `1=quality`, `2=save` | `xiaomiPuriLx20SaveMode.waterMode` |
| RO 400 filter life | R | `siid=3`, `piid=1`; % | `xiaomiPuriLx20FilterRo.filterLifeLevel` |
| Inlet TDS | R | `siid=4`, `piid=1`; ppm | `xiaomiPuriLx20TdsIn.tdsIn` |
| Outlet TDS | R | `siid=4`, `piid=2`; ppm | `xiaomiPuriLx20TdsOut.tdsOut` |
| RO 800 filter life | R | `siid=5`, `piid=1`; % | `xiaomiPuriLx20FilterRoTwo.filterLifeLevel` |
| Do not disturb | RW | `siid=6`, `piid=1` | `xiaomiPuriLx20NoDisturb.noDisturb` |
| Pure water output | R | `siid=8`, `piid=2`; mL | `xiaomiPuriLx20Output.pureWaterOutput` |
| PPC filter life | R | `siid=9`, `piid=1`; % | `xiaomiPuriLx20FilterPpc.filterLifeLevel` |

This exact spec has no whole-device power property, so `switch` is intentionally absent.

Not exposed: the fault property reports a raw 32-bit code, pipeline connection and holiday mode are installation and away settings, the stop-production action and the three filter reset actions are maintenance-only, filter used time, used flow, left flow, left time, and anti-fake flags are consumable counters, and water production time is a cumulative statistic.
