# Mate Humidifier CS01

SmartThings Edge LAN driver for exact model `mate.humidifier.cs01`.

## Protocol Decision

- Protocol: MIoT
- Model: `mate.humidifier.cs01`
- specModel: `mate-cs01`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:mate-cs01:1`
- Basis: The exact model is present in hass-xiaomi-miot MIOT_LOCAL_MODELS, whose host/token local path uses native get_properties/set_properties; the exact MIoT spec supplies this capability contract.
- Evidence: circumstantial. Source: hass-xiaomi-miot-local+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.mateHumCs01FanLevel`
- `refresh`

## MIoT Mapping

| Feature | Access | Local key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fan level | RW | `siid=2`, `piid=5`; 1=level1, 2=level2, 3=level3, 4=level4, 5=level5 | `concertmirror08464.mateHumCs01FanLevel` |

Not exposed: the exact spec exposes no humidity, temperature, tank, display, buzzer, or child-lock property. Generic device fault/fault-code and operating-status diagnostics are not exposed.
