# Brains Occupancy Sensor R4

SmartThings Edge LAN driver for the Xiaomi MIoT occupancy sensor model `brains.sensor_occupy.r4`.

## Protocol Decision

- Protocol: MIoT
- Model: `brains.sensor_occupy.r4`
- specModel: `brains-r4`
- URN: `urn:miot-spec-v2:device:occupancy-sensor:0000A0BF:brains-r4:2`
- Basis: current `hass-xiaomi-miot` lists exact model `brains.sensor_occupy.r4` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `presenceSensor`
- `illuminanceMeasurement`
- `concertmirror08464.brainsOccupyR4Status`
- `concertmirror08464.brainsOccupyR4Distance`
- `concertmirror08464.brainsOccupyR4NoOneTime`
- `concertmirror08464.brainsOccupyR4IndicatorLight`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Occupancy status | R | `siid=2`, `piid=1`; `0=noOne`, `1=moveless`, `2=inMovement`, `3=enter` | `brainsOccupyR4Status.occupancyStatus` and `presenceSensor` |
| No one determine time | RW | `siid=2`, `piid=2`; 0..3600 s | `brainsOccupyR4NoOneTime.noOneDetermineTime` |
| Illumination | R | `siid=2`, `piid=5`; lux | `illuminanceMeasurement` |
| Indicator light | RW | `siid=3`, `piid=1` | `brainsOccupyR4IndicatorLight.indicatorLight` |
| Target distance | R | `siid=6`, `piid=16`; 0..4.5 m | `brainsOccupyR4Distance.targetDistance` |

`presenceSensor` reports `present` for any detected state other than `noOne`, so standard presence automations work alongside the detailed occupancy state.

Not exposed: the `siid=5` service holds vendor BLE debug values, and the remaining `siid=6` properties are radar tuning, LDR linkage thresholds, breaker linkage, engineering mode, and bottom-noise diagnostics rather than core SmartThings controls. The `detection-sensitiviy` property is an undocumented string in the exact spec, so it is omitted.
