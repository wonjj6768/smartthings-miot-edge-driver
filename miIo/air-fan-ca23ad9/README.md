# Airmate Fan CA23AD9

SmartThings Edge LAN driver for the Xiaomi/miIO fan model `air.fan.ca23ad9`.

## Protocol Decision

- Protocol: miIO
- Model: `air.fan.ca23ad9`
- specModel: `air-ca23ad9`
- URN: `urn:miot-spec-v2:device:fan:0000A005:air-ca23ad9:1`
- Basis: the exact `hass-xiaomi-miot` `MIIO_TO_MIOT_SPECS` converter reads this model with `get_prop` and writes `SetSwitch`, `SetLevel`, `SetH_Swing`, `SetV_Swing`, and `SetMode`; the MIoT spec is only the equivalent feature contract.
- Evidence: confirmed. Source: hass-xiaomi-miot-miio2miot+miot-spec.

## Exposed Capabilities

- `switch`
- `concertmirror08464.airFanCa23ad9FanLevel`
- `fanOscillationMode`
- `concertmirror08464.airFanCa23ad9Mode`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `SetSwitch`, `0/1` | `switch` |
| Fan level | RW | `speed`, `SetLevel`, `1..32` | `airFanCa23ad9FanLevel.fanLevel` |
| Two-axis swing | RW | `lrWind`/`udWind`, `SetH_Swing`/`SetV_Swing`, `0/1` | `fanOscillationMode`, `off/horizontal/vertical/all` |
| Mode | RW | `mode`, `SetMode`, `1=Basic`, `2=Baby Care` | `airFanCa23ad9Mode.fanMode` |
| Refresh | Action | `get_prop(["on"])` positional result | `refresh` |

Not exposed: `onTime` and `offTime` are returned by the exact query but have no confirmed setter or stable SmartThings control contract.
