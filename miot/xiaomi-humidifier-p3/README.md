# Xiaomi Humidifier P3

SmartThings Edge LAN driver for exact model `xiaomi.humidifier.p3`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.p3`
- specModel: `xiaomi-p3`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-p3:2`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.xiaomiHumP3Mode`
- `concertmirror08464.xiaomiHumP3TargetHumidity`
- `concertmirror08464.xiaomiHumP3Buzzer`
- `concertmirror08464.xiaomiHumP3ChildLock`
- `concertmirror08464.xiaomiHumP3Screen`
- `concertmirror08464.xiaomiHumP3ScreenBrightness`
- `concertmirror08464.xiaomiHumP3WaterStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1` | `relativeHumidityMeasurement` |
| Filter life | R/action | `siid=8`, `piid=1`; reset `siid=8`, `aiid=1` | `filterState` |
| Mode | RW | `siid=2`, `piid=3`; 0=constantHumidity, 1=sleep, 2=strong | `concertmirror08464.xiaomiHumP3Mode` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..70 % | `concertmirror08464.xiaomiHumP3TargetHumidity` |
| Buzzer | RW | `siid=4`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHumP3Buzzer` |
| Child lock | RW | `siid=5`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHumP3ChildLock` |
| Screen | RW | `siid=7`, `piid=1`; False=off, True=on | `concertmirror08464.xiaomiHumP3Screen` |
| Screen brightness | RW | `siid=7`, `piid=2`; 0=dim, 1=normal | `concertmirror08464.xiaomiHumP3ScreenBrightness` |
| Water status | R | `siid=6`, `piid=2`; 0=normal, 1=lowWater | `concertmirror08464.xiaomiHumP3WaterStatus` |

Not exposed: off-delay, cleaning internals, and private protection counters are omitted. Filter reset uses the exact filter action. Generic device fault/fault-code and operating-status diagnostics are not exposed.
