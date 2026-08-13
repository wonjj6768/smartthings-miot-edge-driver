# Yeelight Mono Bulb

SmartThings Edge LAN driver for the Xiaomi/miIO light model `yeelink.light.mono1`.

## Protocol Decision

- Protocol: miIO
- Model: `yeelink.light.mono1`
- Basis: `python-miio` lists `yeelink.light.mono1` in the Yeelight miIO integration and implements `get_prop`, `set_power`, and `set_bright`; the MIoT spec records the equivalent mono light contract for power and brightness.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `switchLevel`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Brightness | RW | `bright`, `set_bright`; 1..100 % | `switchLevel` |

Not exposed: brightness delta, developer mode, default-state setting, name setting, and internal Yeelight app settings because they are auxiliary controls rather than core SmartThings light controls.
