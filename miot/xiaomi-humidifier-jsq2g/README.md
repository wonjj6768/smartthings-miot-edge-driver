# Mijia Smart Anti-bacterial Humidifier 2

SmartThings Edge LAN driver for exact model `xiaomi.humidifier.jsq2g`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.jsq2g`
- specModel: `xiaomi-jsq2g`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-jsq2g:1:0000D061`
- Basis: explicit user authorization on 2026-11-20 to assume MIoT for recent models whose
  LAN protocol is unconfirmed. No exact model entry was found in the reviewed
  [miio2miot converter](https://github.com/al-one/hass-xiaomi-miot/blob/8ac4df7005aefb6a92ae5f66f53fa56e2e548c16/custom_components/xiaomi_miot/core/miio2miot_specs.py)
  or its MIOT_LOCAL_MODELS list. The official MIoT spec defines the feature contract.
- Evidence: **user-assumed; not LAN confirmed; no physical device/hub verification**.
- Contract: [exact official MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-jsq2g:1:0000D061).

Register the device with Xiaomi Home / Mi Home in its supported server region first.
Then enter the local IP and 32-character token. Reads/writes use local MIoT only.

## Exposed Capabilities and MIoT Mapping

| Feature | Access | Key | Value / unit | Capability.attribute (component) |
| --- | --- | --- | --- | --- |
| on | RW | `2/1` | false=off; true=on | `switch.switch` (main) |
| Mode | RW | `2/8` | 0=constantHumidity; 3=level | `concertmirror08464.xiaomiHumJsq2gMode.mode` (main) |
| Target humidity | RW | `2/6` | 40..70, step 1 % | `concertmirror08464.xiaomiHumJsq2gTargetHum.targetHumidity` (main) |
| Mist level | RW | `2/5` | 0=levelOne; 1=levelTwo; 2=levelThree; 4=constantHumidity | `concertmirror08464.xiaomiHumJsq2gFanLevel.fanLevel` (main) |
| Water / tank status | R | `2/2` | 0=normal; 1=lowWater; 2=tankRemoved | `concertmirror08464.xiaomiHumJsq2gWaterStatus.waterStatus` (main) |
| relative-humidity | R | `3/1` | 0..100, step 1 % | `relativeHumidityMeasurement.humidity` (main) |
| temperature | R | `3/7` | -30..100, step 1 C | `temperatureMeasurement.temperature` (main) |
| Indicator light | RW | `5/1` | false=off; true=on | `concertmirror08464.xiaomiHumJsq2gDisplay.display` (main) |
| Buzzer | RW | `6/1` | false=off; true=on | `concertmirror08464.xiaomiHumJsq2gBuzzer.buzzer` (main) |
| Overwet protection | RW | `7/6` | false=off; true=on | `concertmirror08464.xiaomiHumJsq2gOverwet.overwetProtection` (main) |
| Constant humidity protection | RW | `7/8` | false=off; true=on | `concertmirror08464.xiaomiHumJsq2gConstantProtect.constantProtection` (main) |

Polling reads one property per request and continues after a rejected property.
Commands refresh actual state after a successful reply; failed or missing reads preserve
the previous state. Unspecified `None` modes are displayed but are not writable choices.
Fan-level commands write the fan-level property only; they do not invent a mode transition.

Not exposed: auxiliary timers/counters, maintenance/self-check/debug/private fields,
and redundant toggle/loop actions. Exact omitted properties: 2/7 status; 7/1 the-tank-filed; 7/2 water-shortage-fault; 7/3 humi-sensor-falut; 7/4 temp-sensor-fault; 7/5 overwet-protect; 7/7 constant-protect.
Self-clean/descale and private actions are not executed by this driver.
