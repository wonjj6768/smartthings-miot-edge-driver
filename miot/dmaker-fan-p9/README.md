# Mi Smart Tower Fan

SmartThings Edge LAN driver for one MIoT model: `dmaker.fan.p9`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p9`
- Spec model: `dmaker-p9`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p9:2`
- Basis: python-miio lists `dmaker.fan.p9` in `FanMiot` with MIoT siid/piid mapping; openHAB documents it as Mi Smart Tower Fan / Xiaomi Mijia Smart Tower Fan; MIoT spec v2 confirms the core siid/piid layout.
- Evidence: confirmed. Source: python-miio+miot-spec+openhab-model-doc.

## Exposed Capabilities

- `switch`: power
- `fanSpeedPercent`: stepless fan speed percent, 1-100%
- `fanOscillationMode`: horizontal oscillation, `off` / `horizontal`
- `concertmirror08464.dmakerFanP9FanMode`
- `concertmirror08464.dmakerFanP9IndicatorLight`
- `concertmirror08464.dmakerFanP9Buzzer`
- `concertmirror08464.dmakerFanP9ChildLock`
- `concertmirror08464.dmakerFanP9HorizontalAngleV2`
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

Alarm service `siid=4`:

- `piid=1` alarm, read/write, not used because python-miio maps buzzer to fan service `siid=2/piid=7`

Indicator light service `siid=5`:

- `piid=1` indicator light, read/write, not used because python-miio maps light to fan service `siid=2/piid=9`

Angle control: `dmakerFanP9HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=6`, `30/60/90/120/150`.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
