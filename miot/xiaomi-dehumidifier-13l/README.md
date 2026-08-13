# Xiaomi Dehumidifier 13L

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `xiaomi.derh.13l`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.derh.13l`
- specModel: `xiaomi-13l`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:xiaomi-13l:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.derh.13l` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

`xiaomi.derh.lite` / specModel `xiaomi-lite` is a separate model/spec and is not included in this one-model driver.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.xiaomiDehum13lMode`, `concertmirror08464.xiaomiDehum13lTargetHumidity`, `concertmirror08464.xiaomiDehum13lChildLock`, `concertmirror08464.xiaomiDehum13lIndicatorLight`, `concertmirror08464.xiaomiDehum13lAlarm`, `concertmirror08464.xiaomiDehum13lDryAfterOff`, `concertmirror08464.xiaomiDehum13lResetFilter`
- `concertmirror08464.xiaomiDehum13lTankStatus`, `concertmirror08464.xiaomiDehum13lFilterStatus`, `concertmirror08464.xiaomiDehum13lFault`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=waterFull`, `2=sensorFault1`, `3=sensorFault2`, `4=communicationFault1`, `5=filterClean`, `6=defrost`, `7=fanMotor`, `8=overload`, `9=lackOfRefrigerant` | `xiaomiDehumidifier13lStatus.fault` |
| Water tank status | R | derived from `siid=2`, `piid=2`; `1=waterFull`, otherwise `normal` | `xiaomiDehumidifier13lStatus.tankStatus` |
| Filter status | R | derived from `siid=2`, `piid=2`; `5=filterClean`, otherwise `normal` | `xiaomiDehumidifier13lStatus.filterStatus` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `xiaomiDehumidifier13lControls.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 30..70 %, step 1 | `xiaomiDehumidifier13lControls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; celsius | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `xiaomiDehumidifier13lControls.alarm` |
| Indicator light on | RW | `siid=5`, `piid=1` | `xiaomiDehumidifier13lControls.indicatorLight=off` |
| Indicator light mode | RW | `siid=5`, `piid=2`; `1=half`, `2=full` | `xiaomiDehumidifier13lControls.indicatorLight` |
| Child lock | RW | `siid=6`, `piid=1` | `xiaomiDehumidifier13lControls.childLock` |
| Dry after off | RW | `siid=7`, `piid=1` | `xiaomiDehumidifier13lControls.dryAfterOff` |
| Reset filter | Action | `siid=7`, `aiid=3` | `xiaomiDehumidifier13lControls.resetFilter` |

Not exposed: delay timer, dry-left-time, warming-up state, toggle action, loop-mode action, and internal diagnostic values because they are auxiliary/internal values rather than core controls or sensors for this port.
