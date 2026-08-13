# Airdog Air Purifier X5

SmartThings Edge LAN driver for the Xiaomi/miIO air purifier model `airdog.airpurifier.x5`.

## Protocol Decision

- Protocol: miIO
- Model: `airdog.airpurifier.x5`
- Basis: python-miio `miio.integrations.airdog.airpurifier.airpurifier_airdog` lists exact model `airdog.airpurifier.x5` in `class AirDogX3(Device)`, whose `AVAILABLE_PROPERTIES` entry for this model is the same shared list as x3. It reads `power`, `mode`, `speed`, `lock`, `clean`, `pm` over classic `get_prop` and writes with `send("set_power", [0|1])`, `send("set_wind", [modeIndex, speed])`, `send("set_lock", [0|1])`, and `send("set_clean")`. The docstring records a real device response payload. Rejected native MIoT: no `MiotDevice` mapping for this model.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `fineDustSensor`
- `concertmirror08464.airdogAirX5Mode`
- `concertmirror08464.airdogAirX5FanLevel`
- `concertmirror08464.airdogAirX5CleanFilter`
- `concertmirror08464.airdogAirX5ChildLock`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `1` / `0` | `switch` |
| Mode | RW | `mode`, `set_wind` first argument, `0=auto`, `1=manual`, `2=sleep` | `airdogAirX5Mode` |
| Fan level | RW | `speed`, `set_wind` second argument, `1..5` | `airdogAirX5FanLevel` |
| PM2.5 | R | `pm`, μg/m³ | `fineDustSensor` |
| Filter status | R | `clean`, `y` means the display shows `-C-` | `airdogAirX5CleanFilter`, `normal` / `needsCleaning` |
| Child lock | RW | `lock`, `set_lock` with `1` / `0` | `airdogAirX5ChildLock` |
| Refresh | Action | Re-read the `get_prop` property list | `refresh` |

Mode and fan level share one `set_wind` write. Auto and sleep always send speed `1`, matching the exact model implementation, and setting a fan level switches the device to manual.

Not exposed: `set_clean` is a maintenance reset rather than a core control, so the filter state is read-only here.
