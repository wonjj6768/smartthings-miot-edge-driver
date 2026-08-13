# Xiaomi Humidifier 4lite

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `xiaomi.humidifier.4lite`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.4lite`
- specModel: `xiaomi-4lite`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-4lite:2:0000D061`
- Basis: the exact MIoT spec confirms the local MIoT service/property contract. The Xiaomi Home / ha_xiaomi_home MIoT stack is spec-driven for Wi-Fi MIoT devices, and this driver maps only the core LAN MIoT properties from the exact spec.
- Evidence: confirmed. Source: miot-spec+ha-xiaomi-home-miot-local+xiaomi-home-product-family.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.xiaomiHum4liteMode`, `concertmirror08464.xiaomiHum4liteTargetHumidity`, `concertmirror08464.xiaomiHum4liteChildLock`, `concertmirror08464.xiaomiHum4liteScreenLevel`, `concertmirror08464.xiaomiHum4liteAlarm`, `concertmirror08464.xiaomiHum4liteOverwetProtect`
- `concertmirror08464.xiaomiHum4liteFault`, `concertmirror08464.xiaomiHum4liteWaterStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=motorFault`, `2=pumpFault`, `3=pumpFail`, `4=lowWater` | `xiaomiHumidifier4liteStats.fault` |
| Water tank status | R | derived from `siid=2`, `piid=2`; `4=lowWater`, otherwise `normal` | `xiaomiHumidifier4liteStats.waterStatus` |
| Mode | RW | `siid=2`, `piid=3`; `0=constantHumidity`, `1=sleep`, `2=strong`, `3=airDry` | `xiaomiHumidifier4liteControls.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70 %, step 1 | `xiaomiHumidifier4liteControls.targetHumidity` |
| Over-wet protection | RW | `siid=2`, `piid=11` | `xiaomiHumidifier4liteControls.overwetProtect` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Filter life | R | `siid=4`, `piid=1`; 0..100 % | `filterState.filterLifeRemaining` |
| Reset filter life | Action | `siid=4`, `aiid=1` | `filterState.resetFilter` |
| Screen on | RW | `siid=6`, `piid=1` | `xiaomiHumidifier4liteControls.screenBrightness=off` |
| Screen brightness | RW | `siid=6`, `piid=2`; `0=dim`, `1=normal` | `xiaomiHumidifier4liteControls.screenBrightness` |
| Alarm / buzzer | RW | `siid=7`, `piid=1` | `xiaomiHumidifier4liteControls.alarm` |
| Child lock | RW | `siid=8`, `piid=1` | `xiaomiHumidifier4liteControls.childLock` |

Not exposed: delay timer, air-dry remaining time, clean-time, write-only filter level, filter-clean status, and loop/self-clean actions because they are auxiliary/internal values rather than core SmartThings controls or sensors for this port.
