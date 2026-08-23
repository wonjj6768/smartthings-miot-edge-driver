# TMWL Electronic Valve IOTB2

SmartThings Edge LAN driver for the Xiaomi MIoT electronic valve model `tmwl.valve.iotb2`.

## Protocol Decision

- Protocol: MIoT
- Model: `tmwl.valve.iotb2`
- specModel: `tmwl-iotb2`
- URN: `urn:miot-spec-v2:device:electronic-valve:0000A0A7:tmwl-iotb2:1`
- Basis: current `hass-xiaomi-miot` lists exact model `tmwl.valve.iotb2` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `valve`
- `powerMeter`
- `concertmirror08464.tmwlValveEnergyUsage`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Valve switch | RW | `siid=2`, `piid=1`; `true=open`, `false=closed` | `valve` |
| Electric power | R | `siid=3`, `piid=6`; watt | `powerMeter` |
| Power consumption | R | `siid=3`, `piid=1`; kWh | `concertmirror08464.tmwlValveEnergyUsage` |

Not exposed: target water level and the raw 0..100 fault code carry no documented enum in the exact spec, and the `siid=4`, `siid=6`, `siid=7`, and `siid=8` services hold terminal temperatures, leakage and overload thresholds, and device-lock internals rather than core SmartThings controls.
