# Qingping Air Monitor Lite2

SmartThings Edge LAN driver for the Xiaomi/MIoT qingping air monitor lite model `cgllc.airm.cgd1st`.

## Protocol Decision

- Protocol: MIoT
- Model: `cgllc.airm.cgd1st`
- specModel: `cgllc-cgd1st`
- URN: `urn:miot-spec-v2:device:air-monitor:0000A008:cgllc-cgd1st:2`
- Basis: current `hass-xiaomi-miot` lists exact model `cgllc.airm.cgd1st` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the environment and battery property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `main`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `dustSensor`
- `carbonDioxideMeasurement`
- `battery`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| main | RW | Model-specific siid/piid constants in `src/init.lua` | `main` |
| temperature Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `temperatureMeasurement` |
| relative Humidity Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `relativeHumidityMeasurement` |
| dust Sensor | R | Model-specific siid/piid constants in `src/init.lua` | `dustSensor` |
| carbon Dioxide Measurement | R | Model-specific siid/piid constants in `src/init.lua` | `carbonDioxideMeasurement` |
| battery | RW | Model-specific siid/piid constants in `src/init.lua` | `battery` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
