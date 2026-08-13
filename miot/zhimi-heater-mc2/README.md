# Mi Smart Space Heater S

SmartThings Edge LAN driver for the Xiaomi MIoT heater model `zhimi.heater.mc2`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.heater.mc2`
- specModel: `zhimi-mc2`
- URN: `urn:miot-spec-v2:device:heater:0000A01A:zhimi-mc2:1`
- Basis: the exact MIoT spec, `python-miio` HeaterMiot mapping, and openHAB Xiaomi Mi IO model/channel listing all confirm the same core local MIoT properties for this model.
- Evidence: confirmed. Source: miot-spec+python-miio+openhab.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.zhimiHeaterMc2CountdownHours`, `concertmirror08464.zhimiHeaterMc2FaultCode`, `concertmirror08464.zhimiHeaterMc2Buzzer`, `concertmirror08464.zhimiHeaterMc2ChildLock`, `concertmirror08464.zhimiHeaterMc2IndicatorLight`, `concertmirror08464.zhimiHeaterMc2Fault`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, nonzero `fault` | `zhimiHeaterMc2Controls.fault`, `faultCode` |
| Target temperature | RW | `siid=2`, `piid=5`; 18..28 C, step 1 | `thermostatHeatingSetpoint.heatingSetpoint` |
| Countdown timer | RW | `siid=3`, `piid=1`; 0..12 h, step 1 | `zhimiHeaterMc2Controls.countdownHours` |
| Current temperature | R | `siid=4`, `piid=7`; C | `temperatureMeasurement` |
| Child lock | RW | `siid=5`, `piid=1` | `zhimiHeaterMc2Controls.childLock` |
| Buzzer | RW | `siid=6`, `piid=1` | `zhimiHeaterMc2Controls.buzzer` |
| Indicator light | RW | `siid=7`, `piid=3`; `0=bright`, `1=off` | `zhimiHeaterMc2Controls.indicatorLight` |

Not exposed: private service values such as hardware-enable, use-time, country-code, button events, and vendor diagnostic events because they are auxiliary/internal rather than core SmartThings controls or sensors for this port.
