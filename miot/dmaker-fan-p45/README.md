# Mijia DC Inverter Tower Fan 2

SmartThings Edge LAN driver for one MIoT model: `dmaker.fan.p45`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p45`
- Spec model: `dmaker-p45`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p45:1`
- Basis: python-miio `FanMiot` lists the exact model with MIoT siid/piid mapping. MIoT spec v1 confirms power, fan level, mode, horizontal swing, angle, off delay, indicator light, buzzer, child lock, and stepless fan speed. Model docs identify `dmaker.fan.p45` as Mijia DC Inverter Tower Fan 2.
- Evidence: confirmed. Source: python-miio+miot-spec+model-doc+kr-user-report.

## Exposed Capabilities

- `switch`: power
- `fanSpeedPercent`: stepless fan speed percent, 1-100%
- `fanOscillationMode`: horizontal oscillation, `off` / `horizontal`
- `concertmirror08464.dmakerFanP45FanMode`
- `concertmirror08464.dmakerFanP45IndicatorLight`
- `concertmirror08464.dmakerFanP45Buzzer`
- `concertmirror08464.dmakerFanP45ChildLock`
- `concertmirror08464.dmakerFanP45HorizontalAngleV2`
- `refresh`

## MIoT Mapping

Fan service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fan level `1..4`, read/write, not exposed separately
- `piid=3` mode, read/write, `0=normal`, `1=nature`, `2=sleep`
- `piid=4` horizontal swing, read/write
- `piid=5` `30/60/90/120/150`, read/write
- `aiid=1` toggle
- `aiid=2` turn left
- `aiid=3` turn right

Off delay service `siid=3`:

- `piid=1` off delay time `0..480` minutes, read/write

Indicator light service `siid=4`:

- `piid=1` indicator light, read/write

Alarm service `siid=5`:

- `piid=1` buzzer/alarm, read/write

Physical controls locked service `siid=7`:

- `piid=1` child lock, read/write

Dmaker service `siid=8`:

- `piid=1` stepless fan level `1..100`, read/write
- `piid=3` start left, write only
- `piid=4` start right, write only
- `piid=5..9` natural wind customization strings, read/write

Angle control: `dmakerFanP45HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=5`, `30/60/90/120/150`.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
