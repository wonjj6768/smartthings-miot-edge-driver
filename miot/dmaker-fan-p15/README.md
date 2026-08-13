# Xiaomi Mi Smart Standing Fan Pro 4th Gen (ZLBPSP01XY)

SmartThings Edge LAN driver for the Xiaomi Mi Smart Standing Fan Pro product code `ZLBPSP01XY`, model `dmaker.fan.p15`.

## Protocol Decision

- Protocol: MIoT
- Model: `dmaker.fan.p15`
- Spec model: `dmaker-p15`
- URN: `urn:miot-spec-v2:device:fan:0000A005:dmaker-p15:1`
- Basis: python-miio `FanMiot` supports exact model `dmaker.fan.p15` with the P11 MIoT layout; openHAB documents it as Mi Smart Standing Fan Pro; MIoT spec v1 confirms the core siid/piid layout.
- Evidence: confirmed. Source: python-miio+miot-spec+openhab-model-doc.

## Exposed Capabilities

- `switch`: power
- `fanSpeedPercent`: fan speed percent, mapped to the writable 4-level MIoT fan level
- `fanOscillationMode`: horizontal oscillation, `off` / `horizontal`
- `concertmirror08464.dmakerFanP15FanMode`
- `concertmirror08464.dmakerFanP15IndicatorLight`
- `concertmirror08464.dmakerFanP15Buzzer`
- `concertmirror08464.dmakerFanP15ChildLock`
- `concertmirror08464.dmakerFanP15HorizontalAngleV2`
- `refresh`

## MIoT Mapping

Fan service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fan level bucket `1..4`, read/write, mapped from `fanSpeedPercent`
- `piid=3` mode, read/write, `0=normal`, `1=nature`
- `piid=4` horizontal swing, read/write
- `piid=5` `30/60/90/120/140`, read/write
- `piid=6` status/speed `1..100`, read/notify only in the exact MIoT spec.

Off delay time service `siid=3`:

- `piid=1` power-off countdown `0..480` minutes, read/write

Indicator light service `siid=4`:

- `piid=1` indicator light, read/write

Alarm service `siid=5`:

- `piid=1` buzzer/alarm, read/write

Motor controller service `siid=6`:

- `piid=1` motor control `0=none`, `1=left`, `2=right`, write only
- `piid=2` fault, read only diagnostic value

Physical controls locked service `siid=7`:

- `piid=1` child lock, read/write

Angle control: `dmakerFanP15HorizontalAngleV2.horizontalAngle` maps MIoT `siid=2`, `piid=5`, `30/60/90/120/140`.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
