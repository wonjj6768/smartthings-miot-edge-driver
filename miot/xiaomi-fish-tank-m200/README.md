# Xiaomi Smart Fishbowl M200

SmartThings Edge LAN driver for the Xiaomi MIoT fish-tank model `xiaomi.fishbowl.m200`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fishbowl.m200`
- specModel: `xiaomi-m200`
- URN: `urn:miot-spec-v2:device:fish-tank:0000A0A2:xiaomi-m200:2`
- Basis: hass-xiaomi-miot local device support and issue logs identify exact model `xiaomi.fishbowl.m200` with local/LAN MIoT updater behavior; exact MIoT spec v2 supplies the feature contract below.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `filterState`
- `colorControl`
- `concertmirror08464.xiaomiTankM200WaterPump`, `concertmirror08464.xiaomiTankM200FeedProtection`, `concertmirror08464.xiaomiTankM200ChildLock`, `concertmirror08464.xiaomiTankM200NoDisturb`, `concertmirror08464.xiaomiTankM200Alarm`, `concertmirror08464.xiaomiTankM200IndicatorLight`, `concertmirror08464.xiaomiTankM200PumpFlux`, `concertmirror08464.xiaomiTankM200FeederStatus`, `concertmirror08464.xiaomiTankM200FeedProtect`, `concertmirror08464.xiaomiTankM200PumpStatus`, `concertmirror08464.xiaomiTankM200FeedNow`
- `concertmirror08464.xiaomiTankM200LightMode`, `concertmirror08464.xiaomiTankM200FlowSpeed`, `concertmirror08464.xiaomiTankM200LightLevel`, `concertmirror08464.xiaomiTankM200LightSwitch`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Main power | RW | `siid=2`, `piid=1` | `switch` |
| Water temperature | R | `siid=2`, `piid=6`, `0..99 C` | `temperatureMeasurement` |
| Water pump | RW | `siid=2`, `piid=2` | `xiaomiFishbowlM200Controls.waterPump` |
| Pump flux | RW | `siid=2`, `piid=3`, `0=level1`, `1=level2` | `xiaomiFishbowlM200Controls.pumpFlux` |
| Pump status | R | `siid=2`, `piid=4`, `0=notConnected`, `1=off`, `2=on`, `3=lowWater`, `4=blocked`, `5=fault` | `xiaomiFishbowlM200Controls.pumpStatus` |
| Feed now | Action | `siid=2`, `aiid=1`, input `piid=5`, `1..3` | `xiaomiFishbowlM200Controls.feedNow` |
| Aquarium light | RW | `siid=3`, `piid=1` | `xiaomiFishbowlM200Light.lightSwitch` |
| Light mode | RW | `siid=3`, `piid=2`, `0=day`, `1=flow`, `3=white`, `4=color2`, `5=color3`, `6=color4`, `7=nightLight`, `8=color5`, `9=color6` | `xiaomiFishbowlM200Light.lightMode` |
| Light brightness | RW | `siid=3`, `piid=3`, `1..100 %` | `xiaomiFishbowlM200Light.lightBrightness` |
| Flow speed | RW | `siid=3`, `piid=4`, `0=low`, `1=medium`, `2=high` | `xiaomiFishbowlM200Light.flowSpeed` |
| Light color | RW | `siid=4`, `piid=4`, RGB integer `1..16777215` | `colorControl` |
| Feeder status | R | `siid=5`, `piid=1`, `0=idle`, `1=busy` | `xiaomiFishbowlM200Controls.feederStatus` |
| Feed protection | RW | `siid=5`, `piid=8` | `xiaomiFishbowlM200Controls.feedProtect` |
| Feed protection status | R | `siid=5`, `piid=9`, `0=idle`, `1=busy` | `xiaomiFishbowlM200Controls.feedProtectStatus` |
| Filter life | R | `siid=6`, `piid=1`, `0..100 %` | `filterState.filterLifeRemaining` |
| Reset filter | Action | `siid=6`, `aiid=1` | `filterState.resetFilter` |
| Buzzer | RW | `siid=7`, `piid=1` | `xiaomiFishbowlM200Controls.alarm` |
| Indicator light | RW | `siid=8`, `piid=1` | `xiaomiFishbowlM200Controls.indicatorLight` |
| Child lock | RW | `siid=9`, `piid=1` | `xiaomiFishbowlM200Controls.childLock` |
| No disturb | RW | `siid=10`, `piid=1` | `xiaomiFishbowlM200Controls.noDisturb` |

Not exposed: no-disturb schedule, custom schedule payloads, filter-left-time, today feed count, feed result event details, pump current string, running duration, temperature warning settings, reminder masks, and internal bind timestamp because they are schedules, diagnostics, counters, or app-specific metadata rather than core SmartThings controls.
