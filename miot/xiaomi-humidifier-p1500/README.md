# Mijia Mist-Free Humidifier 3 1500mL/h

SmartThings Edge LAN driver for exact model `xiaomi.humidifier.p1500`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.p1500`
- specModel: `xiaomi-p1500`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-p1500:1:0000D061`
- Basis: explicit user authorization on 2026-11-20 to assume MIoT for recent models whose
  LAN protocol is unconfirmed. No exact model entry was found in the reviewed
  [miio2miot converter](https://github.com/al-one/hass-xiaomi-miot/blob/8ac4df7005aefb6a92ae5f66f53fa56e2e548c16/custom_components/xiaomi_miot/core/miio2miot_specs.py)
  or its MIOT_LOCAL_MODELS list. The official MIoT spec defines the feature contract.
- Evidence: **user-assumed; not LAN confirmed; no physical device/hub verification**.
- Contract: [exact official MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-p1500:1:0000D061).

Register the device with Xiaomi Home / Mi Home in its supported server region first.
Then enter the local IP and 32-character token. Reads/writes use local MIoT only.

## Exposed Capabilities and MIoT Mapping

| Feature | Access | Key | Value / unit | Capability.attribute (component) |
| --- | --- | --- | --- | --- |
| on | RW | `2/1` | false=off; true=on | `switch.switch` (main) |
| Mode | RW | `2/3` | 0=constantHumidity; 1=sleep; 2=strong; 3=airDry | `concertmirror08464.xiaomiHumP1500Mode.mode` (main) |
| Target humidity | RW | `2/5` | 40..70, step 1 % | `concertmirror08464.xiaomiHumP1500TargetHum.targetHumidity` (main) |
| Fault / water status | R | `2/2` | 0=normal; 1=motorFault; 2=pumpFault; 3=humidificationError; 4=lackWater; 5=lowWater | `concertmirror08464.xiaomiHumP1500Fault.fault` (main) |
| Water level | R | `2/6` | 0..100, step 1 % | `concertmirror08464.xiaomiHumP1500WaterLevel.waterLevel` (main) |
| Automatic air drying | RW | `2/9` | false=off; true=on | `concertmirror08464.xiaomiHumP1500AutoDry.autoDry` (main) |
| Overwet protection | RW | `2/11` | false=off; true=on | `concertmirror08464.xiaomiHumP1500Overwet.overwetProtection` (main) |
| relative-humidity | R | `3/1` | 0..100, step 1 % | `relativeHumidityMeasurement.humidity` (main) |
| temperature | R | `3/2` | -30..100, step 1 C | `temperatureMeasurement.temperature` (main) |
| filter-life-level | R | `4/1` | 0..100, step 1 % | `filterState.filterLifeRemaining` (main) |
| Display | RW | `6/1` | false=off; true=on | `concertmirror08464.xiaomiHumP1500Display.display` (main) |
| Display brightness | RW | `6/2` | 0=dim; 1=normal | `concertmirror08464.xiaomiHumP1500DisplayLevel.displayLevel` (main) |
| Auto screen off | RW | `6/3` | false=off; true=on | `concertmirror08464.xiaomiHumP1500AutoScreenOff.autoScreenOff` (main) |
| Buzzer | RW | `7/1` | false=off; true=on | `concertmirror08464.xiaomiHumP1500Buzzer.buzzer` (main) |
| Child lock | RW | `8/1` | false=off; true=on | `concertmirror08464.xiaomiHumP1500ChildLock.childLock` (main) |
| Reset filter | Action | `4/aiid=1` | Empty input array | `filterState.resetFilter` (main) |

Polling reads one property per request and continues after a rejected property.
Commands refresh actual state after a successful reply; failed or missing reads preserve
the previous state. Unspecified `None` modes are displayed but are not writable choices.
Fan-level commands write the fan-level property only; they do not invent a mode transition.

Not exposed: auxiliary timers/counters, maintenance/self-check/debug/private fields,
and redundant toggle/loop actions. Exact omitted properties: 2/10 air-dry-remain-time; 9/1 delay; 9/2 delay-time; 9/3 delay-remain-time; 10/2 clean-left-time; 10/1 descale; 11/1 set-filter-level; 11/2 filter-clean; 11/3 lack-water-drying; 11/4 auto-screen-start; 11/5 auto-screen-over.
Self-clean/descale and private actions are not executed by this driver.
