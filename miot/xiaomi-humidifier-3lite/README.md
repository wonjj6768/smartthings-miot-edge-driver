# Xiaomi Humidifier 3lite

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `xiaomi.humidifier.3lite`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.3lite`
- specModel: `xiaomi-3lite`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-3lite:1:0000D061`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.humidifier.3lite` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.xiaomiHum3liteMode`, `concertmirror08464.xiaomiHum3liteTargetHumidity`, `concertmirror08464.xiaomiHum3liteAutoAirDrying`, `concertmirror08464.xiaomiHum3liteChildLock`, `concertmirror08464.xiaomiHum3liteAlarm`, `concertmirror08464.xiaomiHum3liteScreenLevel`, `concertmirror08464.xiaomiHum3liteOverwetProtect`
- `concertmirror08464.xiaomiHum3liteFault`, `concertmirror08464.xiaomiHum3liteWaterStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=motorFault`, `2=pumpFault`, `3=pumpFail`, `4=pause`, `5=lowWater` | `xiaomiHumidifier3liteStats.fault` |
| Water tank status | R | derived from `siid=2`, `piid=2`; `5=lowWater`, otherwise `normal` | `xiaomiHumidifier3liteStats.waterStatus` |
| Mode | RW | `siid=2`, `piid=3`; `0=constantHumidity`, `1=sleep`, `2=strong` | `xiaomiHumidifier3liteControls.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70 %, step 1 | `xiaomiHumidifier3liteControls.targetHumidity` |
| Automatic air drying | RW | `siid=2`, `piid=11` | `xiaomiHumidifier3liteControls.automaticAirDrying` |
| Over-wet protection | RW | `siid=2`, `piid=13` | `xiaomiHumidifier3liteControls.overwetProtect` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Filter life | R | `siid=4`, `piid=1`; 0..100 % | `filterState.filterLifeRemaining` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| Screen on | RW | `siid=6`, `piid=1` | `xiaomiHumidifier3liteControls.screenBrightness=off` |
| Screen brightness | RW | `siid=6`, `piid=2`; `0=dim`, `1=normal` | `xiaomiHumidifier3liteControls.screenBrightness` |
| Alarm / buzzer | RW | `siid=7`, `piid=1` | `xiaomiHumidifier3liteControls.alarm` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiHumidifier3liteControls.childLock` |

Not exposed: delay timer, air-dry remaining time, clean-time, write-only filter level, and loop-mode action because they are auxiliary/internal values rather than core controls or sensors for this port.
