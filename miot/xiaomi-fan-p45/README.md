# Xiaomi Smart Tower Fan 2

SmartThings Edge LAN driver for one MIoT model: `xiaomi.fan.p45`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.fan.p45`
- Spec model: `xiaomi-p45`
- URN: `urn:miot-spec-v2:device:fan:0000A005:xiaomi-p45:1:0000D062`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.fan.p45` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped fan contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`: power
- `fanSpeedPercent`: stepless fan speed percent, 1-100%
- `fanOscillationMode`: horizontal oscillation, `off` / `horizontal`
- `concertmirror08464.xiaomiFanP45FanMode`
- `concertmirror08464.xiaomiFanP45IndicatorLight`
- `concertmirror08464.xiaomiFanP45Buzzer`
- `concertmirror08464.xiaomiFanP45ChildLock`
- `concertmirror08464.xiaomiFanP45HorizontalAngleV2`
- `refresh`

## MIoT Mapping

Fan service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fault, read only diagnostic value
- `piid=3` mode, read/write, `0=normal`, `1=nature`, `2=sleep`
- `piid=4` gear fan level `1..4`, read/write, not exposed separately
- `piid=5` stepless fan level `1..100`, read/write
- `piid=6` horizontal swing, read/write
- `piid=7` `30/60/90/120/150`, read/write
- `aiid=3` toggle
- `aiid=4` turn left
- `aiid=5` turn right

Indicator light service `siid=5`:

- `piid=1` indicator light, read/write

Alarm service `siid=7`:

- `piid=1` buzzer/alarm, read/write

Physical controls locked service `siid=11`:

- `piid=1` child lock, read/write

Delay service `siid=12`:

- `piid=1` delay on/off, read/write
- `piid=2` delay time `0..480` minutes, read/write
- `piid=3` delay remain time `0..480` minutes, read only

Xiaomi dm-service `siid=13`:

- `piid=1` start left, write only
- `piid=2` start right, write only
- `piid=3..7` natural wind customization strings, read/write

Angle control: `xiaomiFanP45HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=7`, `30/60/90/120/150`.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
