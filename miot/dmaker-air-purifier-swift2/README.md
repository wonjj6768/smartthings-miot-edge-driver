# Dmaker Air Purifier Swift 2

SmartThings Edge LAN driver for the Dmaker MIoT air purifier model `dmaker.airp.swift2`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.airp.swift2`
- specModel: `dmaker-swift2`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:dmaker-swift2:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dmaker.airp.swift2` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `concertmirror08464.dmakerAirSwift2Mode`
- `concertmirror08464.dmakerAirSwift2FanLevel`
- `dustSensor`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `tvocMeasurement`
- `filterState`
- `concertmirror08464.dmakerAirSwift2FanOn`
- `concertmirror08464.dmakerAirSwift2FanSpeed`
- `concertmirror08464.dmakerAirSwift2Swing`
- `concertmirror08464.dmakerAirSwift2SwingAngle`
- `concertmirror08464.dmakerAirSwift2Anion`
- `concertmirror08464.dmakerAirSwift2Screen`
- `concertmirror08464.dmakerAirSwift2Buzzer`
- `concertmirror08464.dmakerAirSwift2Volume`
- `concertmirror08464.dmakerAirSwift2ChildLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Mode | RW | `siid=2`, `piid=4`; `0=smart`, `1=sleep`, `2=purification`, `3=fan` | `dmakerAirSwift2Mode.airPurifierMode` |
| Purifier stage | RW | `siid=2`, `piid=7`; `1..3` | `dmakerAirSwift2FanLevel.fanLevel` |
| PM2.5 | R | `siid=3`, `piid=4` | `dustSensor.fineDustLevel` |
| Room temperature | R | `siid=3`, `piid=7`; celsius | `temperatureMeasurement` |
| Room humidity | R | `siid=3`, `piid=1`; percent | `relativeHumidityMeasurement` |
| VOC | R | `siid=3`, `piid=8`; ppb | `tvocMeasurement.tvocLevel` |
| Filter life | R | `siid=4`, `piid=1`; percent | `filterState.filterLifeRemaining` |
| Fan output | RW | `siid=10`, `piid=1` | `dmakerAirSwift2FanOn.fanOn` |
| Fan speed | RW | `siid=10`, `piid=2`; 1..100 | `dmakerAirSwift2FanSpeed.fanSpeed` |
| Horizontal swing | RW | `siid=10`, `piid=3` | `dmakerAirSwift2Swing.horizontalSwing` |
| Swing angle | RW | `siid=10`, `piid=5`; 30, 60, or 90 degrees | `dmakerAirSwift2SwingAngle.swingAngle` |
| Anion | RW | `siid=2`, `piid=8` | `dmakerAirSwift2Anion.anion` |
| Display brightness | RW | `siid=7`, `piid=2`; `0=off`, `1=auto`, `2=half`, `3=full` | `dmakerAirSwift2Screen.screenBrightness` |
| Buzzer | RW | `siid=6`, `piid=1` | `dmakerAirSwift2Buzzer.buzzer` |
| Buzzer volume | RW | `siid=6`, `piid=2`; 0..3 | `dmakerAirSwift2Volume.buzzerVolume` |
| Child lock | RW | `siid=8`, `piid=1` | `dmakerAirSwift2ChildLock.childLock` |

This model combines a purifier and a circulating fan, so the fan service is exposed with its own output switch, 1..100 speed, swing, and swing angle alongside the purifier stage.

Not exposed: the fault property reports a vendor code, `filter-left-time` is a countdown duplicate of the filter life level, and the `dm-sevice` fan-mode purify overrides, per-mode rise angles, anion state machine, and filter rate setter are vendor tuning fields.
