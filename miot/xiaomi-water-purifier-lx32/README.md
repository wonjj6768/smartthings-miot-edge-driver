# Xiaomi Water Purifier LX32

SmartThings Edge LAN driver for the Xiaomi MIoT water purifier model `xiaomi.waterpuri.lx32`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.waterpuri.lx32`
- specModel: `xiaomi-lx32`
- URN: `urn:miot-spec-v2:device:water-purifier:0000A013:xiaomi-lx32:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.waterpuri.lx32` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `concertmirror08464.xiaomiPuriLx32Status`
- `temperatureMeasurement`
- `concertmirror08464.xiaomiPuriLx32TdsOut`
- `concertmirror08464.xiaomiPuriLx32FilterOne`
- `concertmirror08464.xiaomiPuriLx32FilterTwo`
- `concertmirror08464.xiaomiPuriLx32SaveMode`
- `concertmirror08464.xiaomiPuriLx32Cup`
- `concertmirror08464.xiaomiPuriLx32Volume`
- `concertmirror08464.xiaomiPuriLx32Pipeline`
- `concertmirror08464.xiaomiPuriLx32Holiday`
- `concertmirror08464.xiaomiPuriLx32NoDisturb`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Status | R | `siid=2`, `piid=2`; `1=idle`, `2=dispensing` | `xiaomiPuriLx32Status.purifierStatus` |
| Water temperature | R | `siid=2`, `piid=3`; celsius | `temperatureMeasurement` |
| Purified water TDS | R | `siid=4`, `piid=2`; ppm | `xiaomiPuriLx32TdsOut.tdsOut` |
| Filter 1 life | R | `siid=3`, `piid=1`; percent | `xiaomiPuriLx32FilterOne.filterLife` |
| Filter 2 life | R | `siid=5`, `piid=1`; percent | `xiaomiPuriLx32FilterTwo.filterLife` |
| Water mode | RW | `siid=2`, `piid=4`; `0=default`, `1=quality`, `2=save` | `xiaomiPuriLx32SaveMode.waterMode` |
| Cup preset | RW | `siid=7`, `piid=2`; `0=last used`, `1..6=cup 1..6` | `xiaomiPuriLx32Cup.outWaterCup` |
| Dispense volume | RW | `siid=7`, `piid=3`; mL | `xiaomiPuriLx32Volume.outWaterVolume` |
| Pipeline connection | RW | `siid=2`, `piid=5` | `xiaomiPuriLx32Pipeline.pipelineConnection` |
| Holiday mode | RW | `siid=2`, `piid=7` | `xiaomiPuriLx32Holiday.holidayMode` |
| Do not disturb | RW | `siid=6`, `piid=1` | `xiaomiPuriLx32NoDisturb.noDisturb` |

The device declares no power property, so this driver exposes no `switch` capability. The TDS reading and dispense volume are clamped to the 1000 ppm and 2000 mL the vendor app displays even though the raw properties allow larger values.

Not exposed: the fault property reports a raw 32-bit code, the stop-production action has no matching state, the filter time and flow counters are cumulative stats, `cup-setting` carries an opaque preset blob, and the water-use-details production time, cumulative output, and statistical TDS average are counters.
