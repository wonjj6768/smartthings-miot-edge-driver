# Xiaomi Smart Fish Tank MYG100

SmartThings Edge LAN driver for the Xiaomi MIoT fish-tank model `hfjh.fishbowl.m100`.

## Protocol Decision

- Protocol: MIoT
- Model: `hfjh.fishbowl.m100`
- specModel: `hfjh-m100`
- URN: `urn:miot-spec-v2:device:fish-tank:0000A0A2:hfjh-m100:3`
- Basis: current `hass-xiaomi-miot` lists exact model `hfjh.fishbowl.m100` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fish-tank contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `filterState`
- `colorControl`
- `concertmirror08464.xiaomiTankM100IndicatorLevel`, `concertmirror08464.xiaomiTankM100WaterPump`, `concertmirror08464.xiaomiTankM100ChildLock`, `concertmirror08464.xiaomiTankM100Alarm`, `concertmirror08464.xiaomiTankM100IndicatorLight`, `concertmirror08464.xiaomiTankM100PumpFlux`, `concertmirror08464.xiaomiTankM100FeederStatus`, `concertmirror08464.xiaomiTankM100PumpStatus`, `concertmirror08464.xiaomiTankM100FeedNow`
- `concertmirror08464.xiaomiTankM100LightMode`, `concertmirror08464.xiaomiTankM100FlowSpeed`, `concertmirror08464.xiaomiTankM100LightLevel`, `concertmirror08464.xiaomiTankM100LightSwitch`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Main power | RW | `siid=2`, `piid=1` | `switch` |
| Water temperature | R | `siid=2`, `piid=4`, `0..99 C` | `temperatureMeasurement` |
| Water pump | RW | `siid=2`, `piid=2` | `xiaomiFishTankM100Controls.waterPump` |
| Pump flux | RW | `siid=2`, `piid=3`, `0=level1`, `1=level2`, `2=level3` | `xiaomiFishTankM100Controls.pumpFlux` |
| Pump status | R | `siid=2`, `piid=6`, `0=notInserted`, `1=closed`, `2=opened`, `3=low`, `4=blocked`, `5=fault` | `xiaomiFishTankM100Controls.pumpStatus` |
| Feed now | Action | `siid=2`, `aiid=1`, input `piid=5`, `1..3` | `xiaomiFishTankM100Controls.feedNow` |
| Feeder status | R | `siid=6`, `piid=1`, `0=idle`, `1=busy` | `xiaomiFishTankM100Controls.feederStatus` |
| Filter life | R | `siid=10`, `piid=1`, `0..100 %` | `filterState.filterLifeRemaining` |
| Reset filter | Action | `siid=10`, `aiid=1` | `filterState.resetFilter` |
| Buzzer | RW | `siid=13`, `piid=1` | `xiaomiFishTankM100Controls.alarm` |
| Indicator light | RW | `siid=14`, `piid=1` | `xiaomiFishTankM100Controls.indicatorLight` |
| Indicator brightness | RW | `siid=14`, `piid=2`, `0=low`, `1=middle`, `2=high` | `xiaomiFishTankM100Controls.indicatorBrightness` |
| Aquarium light | RW | `siid=15`, `piid=1` | `xiaomiFishTankM100Light.lightSwitch` |
| Light mode | RW | `siid=15`, `piid=2`, `0=day`, `1=flow`, `2=waterGrass`, `3..6=color1..4`, `7=nightLight`, `8=color5` | `xiaomiFishTankM100Light.lightMode` |
| Light brightness | RW | `siid=15`, `piid=3`, `1..100 %` | `xiaomiFishTankM100Light.lightBrightness` |
| Flow speed | RW | `siid=15`, `piid=5`, `0=low`, `1=medium`, `2=high` | `xiaomiFishTankM100Light.flowSpeed` |
| Light color | RW | `siid=4`, `piid=5`, RGB integer `1..16777215` | `colorControl` |
| Child lock | RW | `siid=16`, `piid=1` | `xiaomiFishTankM100Controls.childLock` |

Not exposed: no-disturb schedule, custom schedule payloads, filter-left-time, today feed count, feed result event details, pump current string, running duration, temperature warning settings, reminder masks, and internal bind timestamp because they are schedules, diagnostics, counters, or app-specific metadata rather than core SmartThings controls.
