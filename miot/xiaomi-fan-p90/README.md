# Mijia Smart DC Inverter Circulation Fan Pro

## Device Identity

- Protocol: native MIoT LAN (`get_properties` / `set_properties`)
- Model: `xiaomi.fan.p90`
- Spec model: `xiaomi-p90`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p90:1:0000D062`

## Basis

The exact-model implementation added by `flynnpark` records authenticated LAN `get_properties` responses with `code = 0` for `xiaomi.fan.p90`, and the user reports that implementation working on a real device. The exact MIoT specification is used as the equivalent capability contract. No exact-model classic miIO `get_prop` / `set_*` implementation was found.

## Exposed Features

- Power
- Fan speed, 1-100%
- Normal and natural wind modes
- Horizontal and vertical oscillation
- Display on/off
- Buzzer on/off
- Child lock on/off
- Independent left, right, up, and down oscillation boundaries
- Refresh

## MIoT Mapping

| Feature | Service / property | Access | SmartThings capability |
| --- | --- | --- | --- |
| Power | `2/1` | read/write | `switch` |
| Wind mode | `2/3` | read/write | `concertmirror08464.xiaomiFanP90FanMode` |
| Fan speed | `2/4` | read/write | `fanSpeedPercent` |
| Horizontal oscillation | `2/6` | read/write | `fanOscillationMode` |
| Vertical oscillation | `2/8` | read/write | `fanOscillationMode` |
| Display | `6/1` | read/write | `concertmirror08464.xiaomiFanP90IndicatorLight` |
| Buzzer | `7/1` | read/write | `concertmirror08464.xiaomiFanP90Buzzer` |
| Child lock | `8/1` | read/write | `concertmirror08464.xiaomiFanP90ChildLock` |
| Left boundary | `11/2` | read/write, 10-120°, step 10° | `concertmirror08464.xiaomiFanP90LeftAngleV2` |
| Right boundary | `11/3` | read/write, 0-110°, step 10° | `concertmirror08464.xiaomiFanP90RightAngleV2` |
| Up boundary | `11/5` | read/write, 10-100°, step 10° | `concertmirror08464.xiaomiFanP90UpAngleV2` |
| Down boundary | `11/6` | read/write, 0-90°, step 10° | `concertmirror08464.xiaomiFanP90DownAngleV2` |

Fault, off-to-center, delay timer properties, symmetrical-swing helper flags, duplicate speed, and shortcut actions are not exposed because they are diagnostic, auxiliary, or duplicate controls.

## Evidence

- Exact-model working implementation: `flynnpark/smartthings-miot-edge-driver` commit `c6117c494b7015351d02174c3dd30a97b9af0ae6`
- Exact capability contract: Xiaomi MIoT specification `xiaomi.fan.p90` v1
