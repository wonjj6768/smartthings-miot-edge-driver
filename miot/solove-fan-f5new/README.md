# Solove Fan F5 New

SmartThings Edge LAN driver for the Xiaomi MIoT fan model `solove.fan.f5new`.

## Protocol Decision

- Protocol: MIoT
- Model: `solove.fan.f5new`
- specModel: `solove-f5new`
- URN: `urn:miot-spec-v2:device:fan:0000A005:solove-f5new:1`
- Basis: current `hass-xiaomi-miot` lists exact model `solove.fan.f5new` in `MIOT_LOCAL_MODELS` with no classic converter, so its local path uses `get_properties` and `set_properties`; the exact MIoT spec supplies this mapping.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.soloveFanF5newFanLevel`
- `concertmirror08464.soloveFanF5newMode`
- `concertmirror08464.soloveFanF5newBuzzer`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=2`, `1/2/3` | `soloveFanF5newFanLevel.fanLevel` |
| Mode | RW | `siid=2`, `piid=7`, `0=Natural Wind`, `1=Straight Wind` | `soloveFanF5newMode.fanMode` |
| Buzzer | RW | `siid=5`, `piid=1` | `soloveFanF5newBuzzer.buzzer` |

Not exposed: unitless horizontal angle `0..3` and the ambiguous custom `electricity` property are not guessed; fault, countdown, charge, and secondary custom speed are auxiliary or lack a stable core mapping.
