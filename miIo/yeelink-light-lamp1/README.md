# Xiaomi Mi Desk Lamp

SmartThings Edge LAN driver for the Xiaomi/miIO light model `yeelink.light.lamp1`.

## Protocol Decision

- Protocol: miIO
- Model: `yeelink.light.lamp1`
- Basis: `python-miio` lists `yeelink.light.lamp1` in the Yeelight miIO integration and implements `get_prop`, `set_power`, `set_bright`, and `set_ct_abx`; the MIoT spec records the equivalent power, brightness, and color temperature contract.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `switchLevel`
- `colorTemperature`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Brightness | RW | `bright`, `set_bright`; 1..100 % | `switchLevel` |
| Color temperature | RW | `ct`, `set_ct_abx`; 2700..6500 K | `colorTemperature` |

Not exposed: lamp scenes, brightness delta, color temperature delta, developer mode, default-state setting, name setting, and internal Yeelight app settings because they are auxiliary controls rather than core SmartThings light controls.
