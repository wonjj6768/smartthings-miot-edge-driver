# Mijia Smart Evaporative Humidifier Pro

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `xiaomi.humidifier.600ek`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.600ek`
- specModel: `xiaomi-600ek`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-600ek:2:0000D061`
- Basis: The exact Homey implementation sends local `get_properties` and `set_properties` calls for `xiaomi.humidifier.600ek`; the exact v2 MIoT spec supplies its siid/piid/action contract.
- Evidence: confirmed. Source: homey-miot-local+miot-spec+xiaomi-product.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `concertmirror08464.xiaomiHum600ekMode`
- `concertmirror08464.xiaomiHum600ekTargetHumidity`
- `concertmirror08464.xiaomiHum600ekScreen`
- `concertmirror08464.xiaomiHum600ekScreenBrightness`
- `concertmirror08464.xiaomiHum600ekBuzzer`
- `concertmirror08464.xiaomiHum600ekChildLock`
- `concertmirror08464.xiaomiHum600ekOverwetProtect`
- `concertmirror08464.xiaomiHum600ekFault`
- `concertmirror08464.xiaomiHum600ekSelfClean`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Relative humidity | R | `siid=3`, `piid=1`; 0..100 % | `relativeHumidityMeasurement` |
| Mode | RW | `siid=2`, `piid=3`; 0=constantHumidity, 1=sleep, 2=strong, 3=airDry | `concertmirror08464.xiaomiHum600ekMode` |
| Target humidity | RW | `siid=2`, `piid=5`; 40..70 %, step 1 | `concertmirror08464.xiaomiHum600ekTargetHumidity` |
| Screen | RW | `siid=6`, `piid=1`; false=off, true=on | `concertmirror08464.xiaomiHum600ekScreen` |
| Screen brightness | RW | `siid=6`, `piid=2`; 0=dim, 1=normal | `concertmirror08464.xiaomiHum600ekScreenBrightness` |
| Buzzer | RW | `siid=7`, `piid=1`; false=off, true=on | `concertmirror08464.xiaomiHum600ekBuzzer` |
| Child lock | RW | `siid=8`, `piid=1`; false=off, true=on | `concertmirror08464.xiaomiHum600ekChildLock` |
| Over-humidification protection | RW | `siid=2`, `piid=11`; false=off, true=on | `concertmirror08464.xiaomiHum600ekOverwetProtect` |
| Fault / low water | R | `siid=2`, `piid=2`; 0=noFaults, 1=motorFault, 2=pumpFault, 3=pumpFail, 4=lowWater | `concertmirror08464.xiaomiHum600ekFault` |
| Self-cleaning | R/action | status `siid=10`, `piid=1`; start `siid=10`, `aiid=1`; stop `siid=10`, `aiid=2` | `concertmirror08464.xiaomiHum600ekSelfClean` |

Not exposed: temperature and water-level properties are absent from the exact contract. Delay timers, remaining-time diagnostics, toggle, and private filter-level/filter-clean/loop-mode internals are omitted; the model exposes no exact filter-life or reset-filter action.
