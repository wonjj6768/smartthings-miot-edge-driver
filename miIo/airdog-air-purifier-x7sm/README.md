# Airdog Air Purifier X7sm

SmartThings Edge LAN driver for the Xiaomi/miIO air purifier model `airdog.airpurifier.x7sm`.

## Protocol Decision

- Protocol: miIO
- Model: `airdog.airpurifier.x7sm`
- Basis: python-miio `miio.integrations.airdog.airpurifier.airpurifier_airdog` lists exact model `airdog.airpurifier.x7sm` in `class AirDogX3(Device)`, whose `AVAILABLE_PROPERTIES` entry for this model is the shared list plus `hcho`. It reads `power`, `mode`, `speed`, `lock`, `clean`, `pm`, `hcho` over classic `get_prop` and writes with `send("set_power", [0|1])`, `send("set_wind", [modeIndex, speed])`, `send("set_lock", [0|1])`, and `send("set_clean")`. Rejected native MIoT: no `MiotDevice` mapping for this model.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `fineDustSensor`
- `concertmirror08464.airdogAirX7smHcho`
- `concertmirror08464.airdogAirX7smMode`
- `concertmirror08464.airdogAirX7smFanLevel`
- `concertmirror08464.airdogAirX7smCleanFilter`
- `concertmirror08464.airdogAirX7smChildLock`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `1` / `0` | `switch` |
| Mode | RW | `mode`, `set_wind` first argument, `0=auto`, `1=manual`, `2=sleep` | `airdogAirX7smMode` |
| Fan level | RW | `speed`, `set_wind` second argument, `1..5` | `airdogAirX7smFanLevel` |
| PM2.5 | R | `pm`, μg/m³ | `fineDustSensor` |
| Formaldehyde | R | `hcho` | `airdogAirX7smHcho` |
| Filter status | R | `clean`, `y` means the display shows `-C-` | `airdogAirX7smCleanFilter`, `normal` / `needsCleaning` |
| Child lock | RW | `lock`, `set_lock` with `1` / `0` | `airdogAirX7smChildLock` |
| Refresh | Action | Re-read the `get_prop` property list | `refresh` |

Mode and fan level share one `set_wind` write. Auto and sleep always send speed `1`, matching the exact model implementation, and setting a fan level switches the device to manual.

Not exposed: `set_clean` is a maintenance reset rather than a core control, so the filter state is read-only here.
