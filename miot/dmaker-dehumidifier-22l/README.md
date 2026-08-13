# Mijia Smart Dehumidifier 22L

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `dmaker.derh.22l`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.derh.22l`
- specModel: `dmaker-22l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:dmaker-22l:1`
- Basis: homebridge-miot includes an exact `dmaker.derh.22l` local MIoT device module with `requiresMiCloud=false` and explicit siid/piid mapping; the exact MIoT spec confirms the mapped properties below.
- Evidence: confirmed. Source: homebridge-miot-local+miot-spec+xiaomihumidifier-miot.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.dmakerDehum22lMode`, `concertmirror08464.dmakerDehum22lTargetHumidity`, `concertmirror08464.dmakerDehum22lChildLock`, `concertmirror08464.dmakerDehum22lIndicatorLight`, `concertmirror08464.dmakerDehum22lAlarm`, `concertmirror08464.dmakerDehum22lDryAfterOff`, `concertmirror08464.dmakerDehum22lResetFilter`
- `concertmirror08464.dmakerDehum22lTankStatus`, `concertmirror08464.dmakerDehum22lFilterStatus`, `concertmirror08464.dmakerDehum22lFault`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=waterFull`, `2=sensorFault1`, `3=sensorFault2`, `4=communicationFault1`, `5=filterClean`, `6=defrost`, `7=fanMotor`, `8=overload`, `9=lackOfRefrigerant` | `mijiaDehumidifier22lStatus.fault` |
| Water tank status | R | derived from `siid=2`, `piid=2`; `1=waterFull`, otherwise `normal` | `mijiaDehumidifier22lStatus.tankStatus` |
| Filter status | R | derived from `siid=2`, `piid=2`; `5=filterClean`, otherwise `normal` | `mijiaDehumidifier22lStatus.filterStatus` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `mijiaDehumidifier22lControls.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..70 %, step 1 | `mijiaDehumidifier22lControls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`, 0..100 % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`, C | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `mijiaDehumidifier22lControls.alarm` |
| Indicator light on | RW | `siid=5`, `piid=1`; false maps to `off` | `mijiaDehumidifier22lControls.indicatorLight` |
| Indicator light mode | RW | `siid=5`, `piid=2`; `0=off`, `1=half`, `2=full` | `mijiaDehumidifier22lControls.indicatorLight` |
| Child lock | RW | `siid=6`, `piid=1` | `mijiaDehumidifier22lControls.childLock` |
| Dry after off | RW | `siid=7`, `piid=2` | `mijiaDehumidifier22lControls.dryAfterOff` |
| Reset filter | Action | `siid=7`, `aiid=3` | `mijiaDehumidifier22lControls.resetFilter` |

Not exposed: off-delay time, dry-left time, warm-up state, loop-mode action, tank-full event payload, and diagnostics because they are auxiliary scheduling, internal, or event-only values rather than core SmartThings controls or sensors.
