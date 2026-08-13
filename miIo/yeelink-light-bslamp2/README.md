# Mi Bedside Lamp 2

SmartThings Edge LAN driver for the Xiaomi/miIO light model `yeelink.light.bslamp2`.

## Protocol Decision

- Protocol: miIO
- Model: `yeelink.light.bslamp2`
- Basis: current `python-miio` Yeelight specs list exact model `yeelink.light.bslamp2`; its classic `Device` implementation uses `get_prop`, `set_power`, `set_bright`, `set_ct_abx`, and `set_rgb`. The MIoT spec is equivalent capability-contract evidence only.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `switch`
- `switchLevel`
- `colorTemperature`
- `colorControl`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Brightness | RW | `bright`, `set_bright`; 1..100 % | `switchLevel` |
| Color temperature | RW | `ct`, `set_ct_abx`; 1700..6500 K | `colorTemperature` |
| Color | RW | `rgb`, `set_rgb` | `colorControl` |

Not exposed: scenes, brightness delta, color temperature delta, developer mode, default-state setting, name setting, and internal Yeelight app settings because they are auxiliary controls rather than core SmartThings light controls.
