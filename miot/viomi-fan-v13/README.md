# Viomi Fan V13

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `viomi.fan.v13`.

## Protocol Decision

- Protocol: MIoT
- Model: `viomi.fan.v13`
- specModel: `viomi-v13`
- URN: `urn:miot-spec-v2:device:fan:0000A005:viomi-v13:1`
- Basis: current `hass-xiaomi-miot` lists exact model `viomi.fan.v13` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.viomiFanV13FanLevel`
- `fanOscillationMode`
- `concertmirror08464.viomiFanV13Mode`
- `concertmirror08464.viomiFanV13Screen`
- `concertmirror08464.viomiFanV13Buzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=2`, `1..99` | `viomiFanV13FanLevel.fanLevel` |
| Two-axis swing | RW | `siid=2`, `piid=3/6` | `fanOscillationMode`, `off/horizontal/vertical/all` |
| Mode | RW | `siid=2`, `piid=4`, `0/1/2/4` exact spec enum | `viomiFanV13Mode.fanMode` |
| Screen | RW | `siid=5`, `piid=1` | `viomiFanV13Screen.screen` |
| Buzzer | RW | `siid=6`, `piid=1` | `viomiFanV13Buzzer.buzzer` |

Not exposed: anion, status, countdown, and the empty private function service are auxiliary values rather than core controls.
