# Xiaomi Airer LYJ3XS

SmartThings Edge LAN driver for the Xiaomi MIoT clothes drying rack model `xiaomi.airer.lyj3xs`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airer.lyj3xs`
- specModel: `xiaomi-lyj3xs`
- URN: `urn:miot-spec-v2:device:airer:0000A00D:xiaomi-lyj3xs:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.airer.lyj3xs` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `windowShade`
- `windowShadeLevel`
- `concertmirror08464.xiaomiAirerLyj3Motor`
- `concertmirror08464.xiaomiAirerLyj3Status`
- `concertmirror08464.xiaomiAirerLyj3Fault`
- `switch`
- `switchLevel`
- `colorTemperature`
- `concertmirror08464.xiaomiAirerLyj3NightLight`
- `concertmirror08464.xiaomiAirerLyj3NightLevel`
- `concertmirror08464.xiaomiAirerLyj3Alarm`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Raise / lower / pause | W | `siid=2`, `piid=5`; `0=pause`, `1=up`, `2=down` | `windowShade` and `xiaomiAirerLyj3Motor.motorControl` |
| Current position | R | `siid=2`, `piid=11`; 0..100 % | `windowShadeLevel.shadeLevel` |
| Target position | W | `siid=2`, `piid=12`; 0..100 % | `windowShadeLevel.setShadeLevel` |
| Motion status | R | `siid=2`, `piid=2`; `0=stop`, `1=rising`, `2=down`, `3=upper limit`, `4=lower limit` | `xiaomiAirerLyj3Status.airerStatus` |
| Fault | R | `siid=2`, `piid=1`; `0=none`, `1=obstacle`, `2=overweight`, `4=motor` | `xiaomiAirerLyj3Fault.airerFault` |
| Light power | RW | `siid=3`, `piid=1` | `switch` |
| Light brightness | RW | `siid=3`, `piid=2`; 1..100 % | `switchLevel.level` |
| Color temperature | RW | `siid=3`, `piid=4`; 3000..6500 K, step 100 | `colorTemperature` |
| Night light | RW | `siid=3`, `piid=5` | `xiaomiAirerLyj3NightLight.nightLight` |
| Night light brightness | RW | `siid=3`, `piid=6`; 1..100 % | `xiaomiAirerLyj3NightLevel.nightBrightness` |
| Buzzer | RW | `siid=5`, `piid=1` | `xiaomiAirerLyj3Alarm.alarm` |

The rack uses the standard `windowShade` and `windowShadeLevel` capabilities so the app gets native raise, lower, pause, and position controls, and the light uses `switch`, `switchLevel`, and the standard `colorTemperature` because the device range matches that capability exactly. Setting the light level to 0 turns the light off instead, since the device rejects a 0 brightness.

Not exposed: motor-control values 3..5 repeat pause and the limit-setting variants, the motion start and end positions are travel calibration, `convergent` and `run-speed` are motion tuning, and the toggle plus set-night-light actions duplicate the property writes.
