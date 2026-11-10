# Mijia Evaporative Humidifier 3 (600 mL/h)

SmartThings Edge LAN driver for the exact model `xiaomi.humidifier.600`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.600`
- specModel: `xiaomi-600`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-600:2:0000D061`
- Basis: the user explicitly authorized a MIoT assumption for this exact model on 2026-11-11. The exact v2 specification supplies the property/action mappings.
- Evidence: user-assumed; not LAN confirmed or hardware tested. Source: user-authorized-assumption+miot-spec.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.xiaomiHum600Buzzer`
- `concertmirror08464.xiaomiHum600ChildLock`
- `concertmirror08464.xiaomiHum600Fault`
- `concertmirror08464.xiaomiHum600Mode`
- `concertmirror08464.xiaomiHum600OverwetProtect`
- `concertmirror08464.xiaomiHum600Screen`
- `concertmirror08464.xiaomiHum600ScreenBrightness`
- `concertmirror08464.xiaomiHum600SelfClean`
- `concertmirror08464.xiaomiHum600TargetHumidity`
- `concertmirror08464.xiaomiHum600FilterLife`
- `refresh`

## MIoT Mapping

| Feature | Access | siid/piid or action | SmartThings |
| --- | --- | --- | --- |
| Power | RW | 2/1; bool | switch |
| Relative humidity | R | 3/1;0..100% | relativeHumidityMeasurement |
| Mode | RW | 2/3;0=constantHumidity,1=sleep,2=strong,3=airDry | xiaomiHum600Mode |
| Target humidity | RW | 2/5;40..70%, integer | xiaomiHum600TargetHumidity |
| Overwet protection | RW | 2/11; bool | xiaomiHum600OverwetProtect |
| Screen | RW | 6/1; bool | xiaomiHum600Screen |
| Screen brightness | RW | 6/2;0=dim,1=normal | xiaomiHum600ScreenBrightness |
| Buzzer | RW | 7/1; bool | xiaomiHum600Buzzer |
| Child lock | RW | 8/1; bool | xiaomiHum600ChildLock |
| Fault / low water | R | 2/2;0=noFaults,1=motorFault,2=pumpFault,3=pumpFail,4=lowWater | xiaomiHum600Fault |
| Self-clean | R/action | 10/1 state; actions10/1=start,10/2=stop | xiaomiHum600SelfClean |
| Filter life / reset | R/action | 4/1 life0..100%; action4/1 reset | xiaomiHum600FilterLife |

Successful commands schedule actual state polling. Filter resets and self-clean actions do not fabricate a new physical state.

Not exposed: no temperature or water-level property exists in the exact specification. Delay timers, remaining-time diagnostics, toggle, private filter-level and loop-mode internals are omitted.
