# Deerma Humidifier JSQ5

SmartThings Edge LAN driver for the Xiaomi/Deerma MIoT humidifier model `deerma.humidifier.jsq5`.

## Protocol Decision

- Protocol: MIoT
- Model: `deerma.humidifier.jsq5`
- specModel: `deerma-jsq5`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:deerma-jsq5:1`
- Basis: python-miio `AirHumidifierJsqs` supports this model as a MIoT device; the exact MIoT spec confirms the mapped properties below.
- Evidence: confirmed. Source: python-miio+miot-spec.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `relativeHumidityMeasurement`
- `concertmirror08464.deermaHumJsq5TargetHumidity`, `concertmirror08464.deermaHumJsq5Alarm`, `concertmirror08464.deermaHumJsq5IndicatorLight`, `concertmirror08464.deermaHumJsq5FanLevel`
- `concertmirror08464.deermaHumJsq5TankFilled`, `concertmirror08464.deermaHumJsq5Fault`, `concertmirror08464.deermaHumJsq5LowWater`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Fault | R | `siid=2`, `piid=2` | `deermaHumidifierJsq5Stats.fault` |
| Fan level | RW | `siid=2`, `piid=5`; `1=level1`, `2=level2`, `3=level3`, `4=humidity` | `deermaHumidifierJsq5Controls.fanLevel` |
| Target humidity | RW | `siid=2`, `piid=6`; 40..80 %, step 1 | `deermaHumidifierJsq5Controls.targetHumidity` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=7`; C | `temperatureMeasurement` |
| Alarm / buzzer | RW | `siid=5`, `piid=1` | `deermaHumidifierJsq5Controls.alarm` |
| Indicator light | RW | `siid=6`, `piid=1` | `deermaHumidifierJsq5Controls.indicatorLight` |
| Water shortage | R | `siid=7`, `piid=1` | `deermaHumJsq5LowWater.lowWater` |
| Tank detected | R | `siid=7`, `piid=2` | `deermaHumidifierJsq5Stats.tankFilled` |


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
