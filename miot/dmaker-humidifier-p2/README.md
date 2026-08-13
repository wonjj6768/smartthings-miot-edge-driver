# Dmaker Humidifier P2

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `dmaker.humidifier.p2`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.humidifier.p2`
- specModel: `dmaker-p2`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:dmaker-p2:2`
- Basis: hass-xiaomi-miot local device support and issue logs identify exact model `dmaker.humidifier.p2` with local/LAN MIoT updater behavior; exact MIoT spec v2 supplies the feature contract below.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.dmakerHumP2Mode`, `concertmirror08464.dmakerHumP2TargetHumidity`, `concertmirror08464.dmakerHumP2ChildLock`, `concertmirror08464.dmakerHumP2Alarm`, `concertmirror08464.dmakerHumP2ScreenBrightness`, `concertmirror08464.dmakerHumP2Screen`, `concertmirror08464.dmakerHumP2OverwetProtect`
- `concertmirror08464.dmakerHumP2Fault`, `concertmirror08464.dmakerHumP2WaterLevel`, `concertmirror08464.dmakerHumP2WaterStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=motorFault`, `2=pumpFault`, `3=lowWater`, `4=sensorFault`, `5=fullWater` | `dmakerHumidifierP2Stats.fault` |
| Mode | RW | `siid=2`, `piid=3`; `0=constantHumidity`, `1=sleep`, `2=strong` | `dmakerHumidifierP2Controls.mode` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..70 %, step 1 | `dmakerHumidifierP2Controls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7`; C | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `dmakerHumidifierP2Controls.alarm` |
| Child lock | RW | `siid=6`, `piid=1` | `dmakerHumidifierP2Controls.childLock` |
| Water status | R | `siid=7`, `piid=2`; `0=normal`, `1=lowWater`, `2=full` | `dmakerHumidifierP2Stats.waterStatus` |
| Water level | R | `siid=7`, `piid=3`; 0..16 | `dmakerHumidifierP2Stats.waterLevel` |
| Over-wet protection | RW | `siid=7`, `piid=4` | `dmakerHumidifierP2Controls.overwetProtect` |
| Screen on | RW | `siid=8`, `piid=1` | `dmakerHumidifierP2Controls.screen` |
| Screen brightness | RW | `siid=8`, `piid=2`; `0=dim`, `1=normal` | `dmakerHumidifierP2Controls.screenBrightness` |
| Filter life | R | `siid=9`, `piid=1`; 0..100 % | `filterState.filterLifeRemaining` |
| Reset filter life | Action | `siid=9`, `aiid=1` | `filterState.resetFilter` |

Not exposed: off-delay, fan-dry-time, write-only filter level override, loop-mode action, serial data, and internal metadata because they are timers, maintenance internals, or app-specific values rather than core SmartThings controls.
