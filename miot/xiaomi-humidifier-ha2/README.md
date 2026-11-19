# Mijia Purifying Evaporative Humidifier 3 Pro

SmartThings Edge LAN driver for exact model `xiaomi.humidifier.ha2`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.humidifier.ha2`
- specModel: `xiaomi-ha2`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-ha2:1:0000D061`
- Basis: explicit user authorization on 2026-11-20 to assume MIoT for recent models whose
  LAN protocol is unconfirmed. No exact model entry was found in the reviewed
  [miio2miot converter](https://github.com/al-one/hass-xiaomi-miot/blob/8ac4df7005aefb6a92ae5f66f53fa56e2e548c16/custom_components/xiaomi_miot/core/miio2miot_specs.py)
  or its MIOT_LOCAL_MODELS list. The official MIoT spec defines the feature contract.
- Evidence: **user-assumed; not LAN confirmed; no physical device/hub verification**.
- Contract: [exact official MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-ha2:1:0000D061).

Register the device with Xiaomi Home / Mi Home in its supported server region first.
Then enter the local IP and 32-character token. Reads/writes use local MIoT only.

## Exposed Capabilities and MIoT Mapping

| Feature | Access | Key | Value / unit | Capability.attribute (component) |
| --- | --- | --- | --- | --- |
| on | RW | `2/1` | false=off; true=on | `switch.switch` (main) |
| Humidifier mode | RW | `2/3` | 0=constantHumidity; 1=sleep; 2=favorite; 3=unspecified | `concertmirror08464.xiaomiHumHa2Mode.mode` (main) |
| Target humidity | RW | `2/6` | 40..70, step 1 % | `concertmirror08464.xiaomiHumHa2TargetHum.targetHumidity` (main) |
| Humidifier fan level | RW | `2/14` | 0=levelOne; 1=levelTwo; 2=levelThree | `concertmirror08464.xiaomiHumHa2HumFanLevel.fanLevel` (main) |
| Water level | R | `2/7` | 0..100, step 5 % | `concertmirror08464.xiaomiHumHa2WaterLevel.waterLevel` (main) |
| Automatic air drying | RW | `2/11` | false=off; true=on | `concertmirror08464.xiaomiHumHa2AutoDry.autoDry` (main) |
| Overwet protection | RW | `2/10` | false=off; true=on | `concertmirror08464.xiaomiHumHa2Overwet.overwetProtection` (main) |
| relative-humidity | R | `3/1` | 0..100, step 1 % | `relativeHumidityMeasurement.humidity` (main) |
| temperature | R | `3/7` | -30..100, step 0.1 C | `temperatureMeasurement.temperature` (main) |
| pm2.5-density | R | `3/4` | 0..600, step 1 μg/m^3 | `dustSensor.fineDustLevel` (main) |
| PM10 raw value (no unit in spec) | R | `3/5` | 0..100, step 1 | `concertmirror08464.xiaomiHumHa2CoarseDust.coarseDust` (main) |
| pm1 | R | `3/6` | 0..600, step 1 μg/m^3 | `veryFineDustSensor.veryFineDustLevel` (main) |
| Air quality | R | `3/3` | 0=excellent; 1=good; 2=moderate; 3=poor; 4=heavyPollution; 5=hazardous | `concertmirror08464.xiaomiHumHa2AirQuality.airQuality` (main) |
| filter-life-level | R | `4/1` | 0..100, step 1 % | `filterState.filterLifeRemaining` (main) |
| Display | RW | `5/1` | false=off; true=on | `concertmirror08464.xiaomiHumHa2Display.display` (main) |
| Display brightness | RW | `5/2` | 0=auto; 1=normal; 2=medium; 3=dim | `concertmirror08464.xiaomiHumHa2DisplayLevel.displayLevel` (main) |
| Buzzer | RW | `6/1` | false=off; true=on | `concertmirror08464.xiaomiHumHa2Buzzer.buzzer` (main) |
| Child lock | RW | `7/1` | false=off; true=on | `concertmirror08464.xiaomiHumHa2ChildLock.childLock` (main) |
| Purifier mode | RW | `11/4` | 0=auto; 1=sleep; 2=favorite; 3=unspecified | `concertmirror08464.xiaomiHumHa2PurifierMode.purifierMode` (main) |
| Purifier fan level | RW | `11/3` | 0=levelOne; 1=levelTwo; 2=levelThree | `concertmirror08464.xiaomiHumHa2PurifierFan.purifierFan` (main) |
| Purifier favorite fan level | RW | `10/1` | 0..9, step 1 | `concertmirror08464.xiaomiHumHa2FavoriteLevel.favoriteLevel` (main) |
| Humidifier favorite fan level | RW | `9/10` | 0..9, step 1 | `concertmirror08464.xiaomiHumHa2HumFavorite.humFavorite` (main) |
| Function | RW | `9/5` | 0=airPurifier; 1=humidifier | `concertmirror08464.xiaomiHumHa2Function.function` (main) |
| Humidifier water tank | R | `9/11` | -2=missing; -1=lackWater; 0=normal; 1=full | `concertmirror08464.xiaomiHumHa2TankStatus.tankStatus` (main) |
| Cleaning water tank | R | `9/12` | -1=low; 0=normal | `concertmirror08464.xiaomiHumHa2CleanTank.cleanTank` (main) |
| filter-life-level | R | `15/1` | 0..100, step 1 % | `filterState.filterLifeRemaining` (humidifierFilter) |
| Reset filter | Action | `4/aiid=1` | Empty input array | `filterState.resetFilter` (main) |
| Reset filter | Action | `15/aiid=1` | Empty input array | `filterState.resetFilter` (humidifierFilter) |

Polling reads one property per request and continues after a rejected property.
Commands refresh actual state after a successful reply; failed or missing reads preserve
the previous state. Unspecified `None` modes are displayed but are not writable choices.
Fan-level commands write the fan-level property only; they do not invent a mode transition.

The device has one power property. `function` selects air purification or humidification;
purifier and humidifier mode/fan settings are independent. The two `filterState` components
use their own reset action (4/1 and 15/1). The spec provides no unit for 3/5, so that
PM10 value is exposed without a concentration unit.

Not exposed: auxiliary timers/counters, maintenance/self-check/debug/private fields,
and redundant toggle/loop actions. Exact omitted properties: 2/2 fault; 2/12 air-dry-remain-time; 2/13 status; 4/2 filter-left-time; 5/4 on; 11/5 smoke-abnormal-alarm-switch; 12/3 clean-left-time; 13/1 delay; 13/2 delay-time; 13/3 delay-remain-time; 14/1 self-check-items; 14/2 self-check-results; 14/3 manual-check-results; 15/2 filter-left-time; 9/1 origin-string; 9/2 aqi-heartbeat; 9/3 filter-used-debug; 9/4 filter-used-debug; 9/6 silent; 9/7 silent-start; 9/8 silent-stop; 9/9 dry-need-flag; 9/14 p-favo-square; 9/15 water-pour-flag; 9/17 h-water-low-run-on; 9/19 h-disp-curve-on; 9/20 p-disp-curve-on; 9/21 p-disp-index.
Self-clean/descale and private actions are not executed by this driver.
