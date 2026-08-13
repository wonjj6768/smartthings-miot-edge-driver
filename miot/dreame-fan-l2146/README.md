# Dreame Fan L2146

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `dreame.fan.l2146`.

## Protocol Decision

- Protocol: MIoT
- Model: `dreame.fan.l2146`
- specModel: `dreame-l2146`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dreame-l2146:1`
- Basis: current `hass-xiaomi-miot` lists exact model `dreame.fan.l2146` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec. See "Evidence Grades" in the root README.md.

## Exposed Capabilities

- `switch`
- `fanSpeedPercent`
- `fanOscillationMode`
- `concertmirror08464.dreameFanL2146Mode`
- `concertmirror08464.dreameFanL2146HorizontalAngleV2`
- `concertmirror08464.dreameFanL2146SwingAngleV2`
- `concertmirror08464.dreameFanL2146WindReverse`
- `concertmirror08464.dreameFanL2146Screen`
- `concertmirror08464.dreameFanL2146Buzzer`
- `concertmirror08464.dreameFanL2146ChildLock`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Speed | RW | `siid=2`, `piid=2`, `1..100` | `fanSpeedPercent` |
| Horizontal swing | RW | `siid=2`, `piid=19` | `fanOscillationMode` |
| Absolute horizontal angle | RW | `siid=2`, `piid=5`, `-75..75` | `dreameFanL2146HorizontalAngleV2.horizontalAngle` |
| Swing included angle | RW | `siid=2`, `piid=20`, `30/60/90/120/150` | `dreameFanL2146SwingAngleV2.swingAngle` |
| Mode | RW | `siid=2`, `piid=18`, `1..5` exact spec enum | `dreameFanL2146Mode.fanMode` |
| Wind reverse | RW | `siid=2`, `piid=17` | `dreameFanL2146WindReverse.windReverse` |
| Child lock | RW | `siid=9`, `piid=1` | `dreameFanL2146ChildLock.childLock` |
| Buzzer | RW | `siid=12`, `piid=1` | `dreameFanL2146Buzzer.buzzer` |
| Screen | RW | `siid=13`, `piid=1` | `dreameFanL2146Screen.screen` |
| Temperature | R | `siid=14`, `piid=1`, Celsius | `temperatureMeasurement` |
| Relative humidity | R | `siid=14`, `piid=2`, percent | `relativeHumidityMeasurement` |

Not exposed: fault codes, countdown, PM2.5/PM10 values without a spec unit, filter life, real-angle telemetry, debug, reset, and private write-only helpers are diagnostic, ambiguous, or auxiliary contracts.
