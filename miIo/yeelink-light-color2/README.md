# Yeelight Color Bulb V2

SmartThings Edge LAN driver for the Xiaomi/miIO light model `yeelink.light.color2`.

## Protocol Decision

- Protocol: miIO
- Model: `yeelink.light.color2`
- Basis: current `python-miio` Yeelight specs list exact model `yeelink.light.color2`; its classic `Device` implementation uses `get_prop`, `set_power`, `set_bright`, `set_ct_abx`, and `set_rgb`. The MIoT spec is equivalent capability-contract evidence only.
- Evidence: confirmed. Source: python-miio-classic+miot-spec.

## Exposed Capabilities

- `switch`
- `switchLevel`
- `statelessSwitchLevelStep` (automation action)
- `colorTemperature`
- `colorControl`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Brightness | RW | `bright`, `set_bright`; 1..100 % | `switchLevel` |
| Brightness step | Command | Read `power` / `bright` with `get_prop`, then `set_power` / `set_bright`; signed -100..100 percentage points | `statelessSwitchLevelStep.stepLevel(stepSize)` |
| Color temperature | RW | `ct`, `set_ct_abx`; 1700..6500 K | `colorTemperature` |
| Color | RW | `rgb`, `set_rgb` | `colorControl` |

Brightness steps use a fresh device reading, clamp the target to 0..100 %, and turn the light off at 0 %. An off light starts from 0 %; a zero step does nothing. After a successful step, the driver polls the actual device state. The standard capability provides an automation action and has no dashboard state or detail-view control. Existing devices receive the updated profile from `added`, `init`, `driverSwitched`, or `refresh` when the step capability is missing.

Not exposed: scenes, color temperature delta, developer mode, default-state setting, name setting, and internal Yeelight app settings because they are auxiliary controls rather than core SmartThings light controls.
