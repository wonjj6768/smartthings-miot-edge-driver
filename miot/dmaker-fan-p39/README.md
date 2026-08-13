# Xiaomi Smart Tower Fan

SmartThings Edge LAN driver for one MIoT model: `dmaker.fan.p39`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p39`
- Spec model: `dmaker-p39`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p39:1`
- Basis: python-miio lists exact model `dmaker.fan.p39` in `FanMiot` with MIoT siid/piid mapping; model docs identify it as Xiaomi Smart Tower Fan BPTS01DM; MIoT spec v1 confirms the core siid/piid layout.
- Evidence: confirmed. Source: python-miio+miot-spec+model-doc.

## Exposed Capabilities

- `switch`: power
- `fanSpeedPercent`: stepless fan speed percent, 1-100%
- `fanOscillationMode`: horizontal oscillation, `off` / `horizontal`
- `concertmirror08464.dmakerFanP39FanMode`
- `concertmirror08464.dmakerFanP39IndicatorLight`
- `concertmirror08464.dmakerFanP39Buzzer`
- `concertmirror08464.dmakerFanP39ChildLock`
- `concertmirror08464.dmakerFanP39HorizontalAngleV2`
- `refresh`

## MIoT Mapping

Fan service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fan level `1..4`, read/write, not exposed separately
- `piid=4` mode, read/write, `0=normal`, `1=nature`, `2=sleep`
- `piid=5` horizontal swing, read/write
- `piid=6` `30/60/90/120/150`, read/write
- `piid=7` alarm/buzzer, read/write
- `piid=8` off-delay time `0..480` minutes, read/write
- `piid=9` display/indicator brightness, read/write
- `piid=10` motor control `0/1/2`, write only
- `piid=11` stepless fan level `1..100`, read/write
- `aiid=1` toggle

Physical controls locked service `siid=3`:

- `piid=1` child lock, read/write

Dmaker service `siid=4`:

- `aiid=1` loop gear
- `aiid=2` loop mode

Angle control: `dmakerFanP39HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=6`, `30/60/90/120/150`.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
