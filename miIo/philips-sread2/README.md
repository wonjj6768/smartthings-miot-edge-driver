# Philips Smart Desk Lamp 2

SmartThings Edge LAN driver for the Xiaomi/miIO philips sread2 model `philips.light.sread2`.

## Protocol Decision

- Protocol: miIO
- Model: `philips.light.sread2`
- Basis: current `python-miio` lists exact model `philips.light.sread2` in `PhilipsEyecare(Device)` and implements classic `get_prop`, `set_power`, `set_brightness`, and `set_scene` methods. The MIoT spec is equivalent capability-contract evidence only.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `main`
- `switch`
- `switchLevel`
- `concertmirror08464.philipsLightMode`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| main | RW | Model-specific property/method constants in `src/init.lua` | `main` |
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| switch Level | RW | Model-specific property/method constants in `src/init.lua` | `switchLevel` |
| philips Light Mode | RW | Model-specific property/method constants in `src/init.lua` | `concertmirror08464.philipsLightMode` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
