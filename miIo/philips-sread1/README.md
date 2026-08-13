# Philips Smart Desk Lamp

SmartThings Edge LAN driver for the Xiaomi/miIO philips sread1 model `philips.light.sread1`.

## Protocol Decision

- Protocol: miIO
- Model: `philips.light.sread1`
- Basis: MIoT spec exists, but repository implementation uses miIO get_prop/set_* methods.
- Evidence: confirmed. Source: existing-driver+python-miio.

## Exposed Capabilities

- `main`
- `switch`
- `switchLevel`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| main | RW | Model-specific property/method constants in `src/init.lua` | `main` |
| switch | RW | Model-specific property/method constants in `src/init.lua` | `switch` |
| switch Level | RW | Model-specific property/method constants in `src/init.lua` | `switchLevel` |
| Refresh | Action | Re-read the model-specific status properties | `refresh` |

Not exposed: diagnostic faults, accumulated usage, hardware metadata, private services, and other non-core values are intentionally omitted.
