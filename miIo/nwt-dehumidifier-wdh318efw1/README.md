# Xiaomi Widetech Dehumidifier

SmartThings Edge LAN driver for the Xiaomi/miIO dehumidifier model `nwt.derh.wdh318efw1`.

## Protocol Decision

- Protocol: miIO
- Model: `nwt.derh.wdh318efw1`
- Basis: python-miio `miio.integrations.nwt.dehumidifier.airdehumidifier` lists exact model `nwt.derh.wdh318efw1` in `class AirDehumidifier(Device)`. Its `status()` reads with `get_properties(properties, max_properties=1)`, so every property is a separate classic `get_prop` request, and it writes with `set_power`, `set_mode`, `set_fan_level`, `set_led`, `set_buzzer`, `set_child_lock`, and `set_auto`. The docstring records a real device response payload. Rejected native MIoT: no `MiotDevice` mapping and no MIoT spec URN for this model.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.nwtDerhWdh318Mode`
- `concertmirror08464.nwtDerhWdh318FanLevel`
- `concertmirror08464.nwtDerhWdh318TargetHumidity`
- `concertmirror08464.nwtDerhWdh318TankFull`
- `concertmirror08464.nwtDerhWdh318IndicatorLight`
- `concertmirror08464.nwtDerhWdh318Buzzer`
- `concertmirror08464.nwtDerhWdh318ChildLock`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `on_off`, `set_power` with `on` / `off` | `switch` |
| Mode | RW | `mode`, `set_mode` with `on` / `auto` / `dry_cloth` | `nwtDerhWdh318Mode`, `on` / `auto` / `dryCloth` |
| Fan level | RW | `fan_speed`, `set_fan_level`, `0=sleep`, `1=low`, `2=medium`, `3=high`, `4=strong` | `nwtDerhWdh318FanLevel` |
| Target humidity | RW | `auto`, `set_auto`, `40` / `50` / `60` percent | `nwtDerhWdh318TargetHumidity` |
| Humidity | R | `humidity`, percent | `relativeHumidityMeasurement` |
| Temperature | R | `temp`, Celsius | `temperatureMeasurement` |
| Water tank | R | `tank_full`, `on` means full | `nwtDerhWdh318TankFull`, `normal` / `full` |
| Indicator light | RW | `led`, `set_led` with `on` / `off` | `nwtDerhWdh318IndicatorLight` |
| Buzzer | RW | `buzzer`, `set_buzzer` with `on` / `off` | `nwtDerhWdh318Buzzer` |
| Child lock | RW | `child_lock`, `set_child_lock` with `on` / `off` | `nwtDerhWdh318ChildLock` |
| Refresh | Action | Re-read each property with its own `get_prop` request | `refresh` |

Reads are issued one property per request because python-miio caps this model at `max_properties=1`; batching several names into one `get_prop` is not what the exact model implementation does.

Not exposed: `compressor_status`, `defrost_status`, `fan_st`, and `alarm` are internal or diagnostic values and are intentionally omitted.
