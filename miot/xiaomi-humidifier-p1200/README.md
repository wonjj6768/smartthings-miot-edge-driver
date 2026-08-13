# Xiaomi Humidifier P1200

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `xiaomi.humidifier.p1200`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.p1200`
- specModel: `xiaomi-p1200`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-p1200:3`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.humidifier.p1200` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `filterState`
- `concertmirror08464.xiaomiHumP1200Mode`, `concertmirror08464.xiaomiHumP1200TargetHumidity`, `concertmirror08464.xiaomiHumP1200ChildLock`, `concertmirror08464.xiaomiHumP1200Alarm`, `concertmirror08464.xiaomiHumP1200ScreenLevel`, `concertmirror08464.xiaomiHumP1200OverwetProtect`, `concertmirror08464.xiaomiHumP1200DrySwitch`
- `concertmirror08464.xiaomiHumP1200FilterClean`, `concertmirror08464.xiaomiHumP1200Fault`, `concertmirror08464.xiaomiHumP1200WaterLevel`, `concertmirror08464.xiaomiHumP1200WaterStatus`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=motorFault`, `2=pumpFault`, `3=pumpFail`, `4=sensorFault`, `5=lowWater` | `xiaomiHumidifierP1200Stats.fault` |
| Mode | RW | `siid=2`, `piid=3`; `0=constantHumidity`, `1=sleep`, `2=strong` | `xiaomiHumidifierP1200Controls.mode` |
| Target humidity | RW | `siid=2`, `piid=4`; 40..70 %, step 1 | `xiaomiHumidifierP1200Controls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; C | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `xiaomiHumidifierP1200Controls.alarm` |
| Child lock | RW | `siid=5`, `piid=1` | `xiaomiHumidifierP1200Controls.childLock` |
| Water status | R | `siid=6`, `piid=2`; `0=normal`, `1=lowWater` | `xiaomiHumidifierP1200Stats.waterStatus` |
| Over-wet protection | RW | `siid=6`, `piid=3` | `xiaomiHumidifierP1200Controls.overwetProtect` |
| Water level | R | `siid=6`, `piid=7`; 0..100 % | `xiaomiHumidifierP1200Stats.waterLevel` |
| Dry switch | RW | `siid=6`, `piid=8` | `xiaomiHumidifierP1200Controls.drySwitch` |
| Filter clean status | R | `siid=6`, `piid=9`; `0=none`, `1=clean` | `xiaomiHumidifierP1200Stats.filterClean` |
| Screen on | RW | `siid=7`, `piid=1` | `xiaomiHumidifierP1200Controls.screenBrightness=off` |
| Screen brightness | RW | `siid=7`, `piid=2`; `0=dim`, `1=normal` | `xiaomiHumidifierP1200Controls.screenBrightness` |
| Filter life | R | `siid=8`, `piid=1`; 0..100 % | `filterState.filterLifeRemaining` |
| Reset filter life | Action | `siid=8`, `aiid=1` | `filterState.resetFilter` |


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
