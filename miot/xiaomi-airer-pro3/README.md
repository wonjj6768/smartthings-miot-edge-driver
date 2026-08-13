# Xiaomi Airer Pro 3

SmartThings Edge LAN driver for the Xiaomi MIoT airer model `xiaomi.airer.pro3`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airer.pro3`
- specModel: `xiaomi-pro3`
- URN: `urn:miot-spec-v2:device:airer:0000A00D:xiaomi-pro3:2:0000D067`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.airer.pro3` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `switchLevel`
- `concertmirror08464.xiaomiAirerPro3Motor`
- `concertmirror08464.xiaomiAirerPro3Position`
- `concertmirror08464.xiaomiAirerPro3Status`
- `concertmirror08464.xiaomiAirerPro3Fault`
- `concertmirror08464.xiaomiAirerPro3NightLight`
- `concertmirror08464.xiaomiAirerPro3NightLevel`
- `concertmirror08464.xiaomiAirerPro3Alarm`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Device fault | R | `siid=2`, `piid=1`; `0=noFaults`, `1=obstacle`, `2=overweight`, `3=motorFault` | `xiaomiAirerPro3Fault.deviceFault` |
| Motor status | R | `siid=2`, `piid=2`; `0=stopUpperLimit`, `1=rising`, `2=down`, `3=stop`, `4=stopLowerLimit` | `xiaomiAirerPro3Status.motorStatus` |
| Motor control | W | `siid=2`, `piid=5`; `0=pause`, `1=up`, `2=down` | `xiaomiAirerPro3Motor.motorControl` |
| Target position | RW | `siid=2`, `piid=12`; 0..100 % | `xiaomiAirerPro3Position.targetPosition` |
| Light power | RW | `siid=3`, `piid=1` | `switch` |
| Light brightness | RW | `siid=3`, `piid=2`; 1..100 % | `switchLevel` |
| Night light | RW | `siid=3`, `piid=4` | `xiaomiAirerPro3NightLight.nightLight` |
| Night brightness | RW | `siid=3`, `piid=5`; 1..100 % | `xiaomiAirerPro3NightLevel.nightBrightness` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiAirerPro3Alarm.alarm` |

Not exposed: motion start and end positions plus the upper and lower limit actions are calibration-only, the light toggle action duplicates `switch`, and the `siid=6` service carries night-light schedule times, motor speed, and mirrored position and progress values.
