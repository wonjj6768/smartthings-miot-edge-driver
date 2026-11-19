# Mijia Smart Air Purifier 6C

SmartThings Edge LAN driver for exact model `xiaomi.airp.rma6`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.airp.rma6`
- specModel: `xiaomi-rma6`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-rma6:1:0000D050`
- Basis: explicit user authorization on 2026-11-20 to assume MIoT for recent models whose
  LAN protocol is unconfirmed. No exact model entry was found in the reviewed
  [miio2miot converter](https://github.com/al-one/hass-xiaomi-miot/blob/8ac4df7005aefb6a92ae5f66f53fa56e2e548c16/custom_components/xiaomi_miot/core/miio2miot_specs.py)
  or its MIOT_LOCAL_MODELS list. The official MIoT spec defines the feature contract.
- Evidence: **user-assumed; not LAN confirmed; no physical device/hub verification**.
- Contract: [exact official MIoT spec](https://miot-spec.org/miot-spec-v2/instance?type=urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-rma6:1:0000D050).

Register the device with Xiaomi Home / Mi Home in its supported server region first.
Then enter the local IP and 32-character token. Reads/writes use local MIoT only.

## Exposed Capabilities and MIoT Mapping

| Feature | Access | Key | Value / unit | Capability.attribute (component) |
| --- | --- | --- | --- | --- |
| on | RW | `2/1` | false=off; true=on | `switch.switch` (main) |
| Mode | RW | `2/3` | 0=auto; 3=sleep; 5=favorite; 6=unspecified | `concertmirror08464.xiaomiAirRma6Mode.mode` (main) |
| Fan level | RW | `2/4` | 0=levelOne; 1=levelTwo; 2=levelThree | `concertmirror08464.xiaomiAirRma6FanLevel.fanLevel` (main) |
| Favorite fan level | RW | `9/1` | 0..9, step 1 | `concertmirror08464.xiaomiAirRma6FavoriteLevel.favoriteLevel` (main) |
| UV sterilization | RW | `2/6` | false=off; true=on | `concertmirror08464.xiaomiAirRma6Uv.uv` (main) |
| relative-humidity | R | `3/1` | 0..100, step 1 % | `relativeHumidityMeasurement.humidity` (main) |
| temperature | R | `3/2` | -30..100, step 0.1 C | `temperatureMeasurement.temperature` (main) |
| pm2.5-density | R | `3/4` | 0..600, step 1 μg/m^3 | `dustSensor.fineDustLevel` (main) |
| hcho-density | R | `3/6` | 0..1, step 0.001 mg/m^3 | `formaldehydeMeasurement.formaldehydeLevel` (main) |
| Air quality | R | `3/3` | 0=excellent; 1=good; 2=moderate; 3=hazardous; 4=hazardous; 5=hazardous | `concertmirror08464.xiaomiAirRma6AirQuality.airQuality` (main) |
| filter-life-level | R | `4/1` | 0..100, step 1 % | `filterState.filterLifeRemaining` (main) |
| Display | RW | `6/1` | false=off; true=on | `concertmirror08464.xiaomiAirRma6Display.display` (main) |
| Display brightness | RW | `6/2` | 0=dim; 1=normal; 2=medium | `concertmirror08464.xiaomiAirRma6DisplayLevel.displayLevel` (main) |
| Buzzer | RW | `7/1` | false=off; true=on | `concertmirror08464.xiaomiAirRma6Buzzer.buzzer` (main) |
| Child lock | RW | `8/1` | false=off; true=on | `concertmirror08464.xiaomiAirRma6ChildLock.childLock` (main) |
| Reset filter | Action | `4/aiid=1` | Empty input array | `filterState.resetFilter` (main) |

Polling reads one property per request and continues after a rejected property.
Commands refresh actual state after a successful reply; failed or missing reads preserve
the previous state. Unspecified `None` modes are displayed but are not writable choices.
Fan-level commands write the fan-level property only; they do not invent a mode transition.

Not exposed: auxiliary timers/counters, maintenance/self-check/debug/private fields,
and redundant toggle/loop actions. Exact omitted properties: 2/2 fault; 4/2 filter-left-time; 4/3 filter-used-time; 14/1 self-check-items; 14/2 self-check-results; 14/3 manual-check-results; 10/1 filter-used-time; 10/2 filter-used-life; 12/1 update-heartbeat; 13/1 favorite-square; 13/2 reboot-cause; 13/4 motor-rpm-feedback; 13/5 hcho-tag; 13/6 iic-error-cnt; 13/7 hcho-original; 13/8 common-property; 13/10 particle-abnormal-on.
Self-clean/descale and private actions are not executed by this driver.
