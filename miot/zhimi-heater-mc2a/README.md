# Mi Smart Space Heater S MC2A

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.mc2a`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.mc2a`
- specModel: `zhimi-mc2a`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-mc2a:1`
- Basis: python-miio `miio.integrations.zhimi.heater.heater_miot` has an exact `zhimi.heater.mc2a` entry in `_MAPPINGS` on `class HeaterMiot(MiotDevice)`, spelling out siid/piid for power, target temperature, countdown, temperature, child lock, and buzzer. That is a native MIoT `get_properties` / `set_properties` implementation. The exact MIoT spec is the equivalent capability contract for ranges. Rejected classic miIO: there is no `MIIO_TO_MIOT_SPECS` entry and no `get_prop` implementation for this model.
- Evidence: confirmed. Source: python-miio-miot+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterMc2aCountdownHours`
- `concertmirror08464.zhimiHeaterMc2aIndicatorLight`
- `concertmirror08464.zhimiHeaterMc2aBuzzer`
- `concertmirror08464.zhimiHeaterMc2aChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1`, bool | `switch` |
| Target temperature | RW | `siid=2`, `piid=5`, 18..28 C, step 1 | `thermostatHeatingSetpoint.heatingSetpoint` |
| Countdown timer | RW | `siid=3`, `piid=1`, 0..12 h, step 1 | `zhimiHeaterMc2aCountdownHours` |
| Current temperature | R | `siid=4`, `piid=7`, C | `temperatureMeasurement` |
| Child lock | RW | `siid=5`, `piid=1`, bool | `zhimiHeaterMc2aChildLock` |
| Buzzer | RW | `siid=6`, `piid=1`, bool | `zhimiHeaterMc2aBuzzer` |
| Indicator light | RW | `siid=7`, `piid=1`, bool | `zhimiHeaterMc2aIndicatorLight` |
| Refresh | Action | Re-read the properties above with `get_properties` | `refresh` |

Indicator light follows the exact `zhimi-mc2a:1` spec, which defines `siid=7`, `piid=1` as a bool on/off. The python-miio entry for this model reuses `mc2`'s `piid=3` brightness, which this spec does not define, so the spec wins for that one property.

Not exposed: `siid=2`, `piid=2` fault carries only `No Faults` in this spec, and the private service values (button-pressed, hw-enable, use-time, country-code) are diagnostic or internal.
