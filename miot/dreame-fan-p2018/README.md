# Dreame Fan P2018

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dreame.fan.p2018`.

## Protocol Decision

- Protocol: MIoT
- Model: `dreame.fan.p2018`
- specModel: `dreame-p2018`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dreame-p2018:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dreame.fan.p2018` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.dreameFanP2018Mode`
- `concertmirror08464.dreameFanP2018HorizontalAngleV2`
- `concertmirror08464.dreameFanP2018SwingAngleV2`
- `concertmirror08464.dreameFanP2018WindReverse`
- `concertmirror08464.dreameFanP2018Screen`
- `concertmirror08464.dreameFanP2018Buzzer`
- `concertmirror08464.dreameFanP2018ChildLock`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Speed | RW | `siid=2`, `piid=2`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=19` | `fanOscillationMode` |
| Absolute horizontal angle | RW | `siid=2`, `piid=5`, `-75..75` | `dreameFanP2018HorizontalAngleV2.horizontalAngle` |
| Swing included angle | RW | `siid=2`, `piid=20`, `30/60/90/120/150` | `dreameFanP2018SwingAngleV2.swingAngle` |
| Mode | RW | `siid=2`, `piid=18`, `1..5` exact spec enum | `dreameFanP2018Mode.fanMode` |
| Wind reverse | RW | `siid=2`, `piid=17` | `dreameFanP2018WindReverse.windReverse` |
| Child lock | RW | `siid=9`, `piid=1` | `dreameFanP2018ChildLock.childLock` |
| Buzzer | RW | `siid=12`, `piid=1` | `dreameFanP2018Buzzer.buzzer` |
| Screen | RW | `siid=13`, `piid=1` | `dreameFanP2018Screen.screen` |
| Temperature | R | `siid=14`, `piid=1`, Celsius | `temperatureMeasurement` |
| Relative humidity | R | `siid=14`, `piid=2`, percent | `relativeHumidityMeasurement` |

Not exposed: fault codes, countdown, PM2.5/PM10 values without a spec unit, filter life, real-angle telemetry, debug, reset, and private write-only helpers are diagnostic, ambiguous, or auxiliary contracts.
