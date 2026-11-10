# Xiaomi Dehumidifier Lite

SmartThings Edge LAN driver for the Xiaomi MIoT dehumidifier model `xiaomi.derh.lite`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.derh.lite`
- specModel: `xiaomi-lite`
- URN: `urn:miot-spec-v2:device:dehumidifier:0000A02D:xiaomi-lite:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.derh.lite` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

`xiaomi.derh.13l` / specModel `xiaomi-13l` is a separate model/spec and is not included in this one-model driver.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.xiaomiDehumLiteMode`, `concertmirror08464.xiaomiDehumLiteTargetHum`, `concertmirror08464.xiaomiDehumLiteChildLock`, `concertmirror08464.xiaomiDehumLiteIndicator`, `concertmirror08464.xiaomiDehumLiteAlarm`, `concertmirror08464.xiaomiDehumLiteDryAfterOff`, `concertmirror08464.xiaomiDehumLiteResetFilter`
- `concertmirror08464.xiaomiDehumLiteTankStatus`, `concertmirror08464.xiaomiDehumLiteFilterStatus`, `concertmirror08464.xiaomiDehumLiteFault`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2`; `0=noFaults`, `1=waterFull`, `2=tempHumError`, `3=copperPipeTempError`, `4=communicationFailure`, `5=filterClean`, `6=defrost`, `7=motorStuck`, `8=overloadProtect`, `9=lackOfRefrigerant` | `xiaomiDehumLiteFault.fault` |
| Water tank status | R | derived from `siid=2`, `piid=2`; `1=waterFull`, otherwise `normal` | `xiaomiDehumLiteTankStatus.tankStatus` |
| Filter status | R | derived from `siid=2`, `piid=2`; `5=filterClean`, otherwise `normal` | `xiaomiDehumLiteFilterStatus.filterStatus` |
| Mode | RW | `siid=2`, `piid=3`; `0=smart`, `1=sleep`, `2=clothesDrying` | `xiaomiDehumLiteMode.mode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70 %, step 1 | `xiaomiDehumLiteTargetHum.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; celsius | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=4`, `piid=1` | `xiaomiDehumLiteAlarm.alarm` |
| Indicator light on | RW | `siid=5`, `piid=1` | `xiaomiDehumLiteIndicator.indicatorLight=off` |
| Indicator light mode | RW | `siid=5`, `piid=2`; `1=dim`, `2=bright` | `xiaomiDehumLiteIndicator.indicatorLight` |
| Child lock | RW | `siid=6`, `piid=1` | `xiaomiDehumLiteChildLock.childLock` |
| Dry after off | RW | `siid=7`, `piid=1` | `xiaomiDehumLiteDryAfterOff.dryAfterOff` |
| Reset filter | Action | `siid=7`, `aiid=3` | `xiaomiDehumLiteResetFilter.resetFilter` |

Not exposed: delay timer, dry-left-time, warming-up state, toggle action, loop-mode action, and internal diagnostic values because they are auxiliary/internal values rather than core controls or sensors for this port.

SmartThings routines can use the standard power/humidity capabilities and the dedicated mode and target-humidity condition/action cards. The exact device model must match; hardware compatibility for a retail region or SKU is not established by the specification alone.
