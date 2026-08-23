# Xiaomi Smart Air Purifier 4

SmartThings Edge LAN driver for one MIoT model: `zhimi.airp.mb5`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.mb5`
- Spec model: `zhimi-mb5`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-mb5:1`
- Basis: python-miio lists `zhimi.airp.mb5` in `AirPurifierMiot` with the VA2 MIoT mapping; python-miio issue #1406 and openHAB document it as Xiaomi Smart Air Purifier 4; MIoT spec v1 confirms the core siid/piid layout.
- Evidence: confirmed. Source: python-miio+miot-spec+model-doc.

## Exposed Capabilities

- `switch`: power
- `concertmirror08464.zhimiAirAirpMb5FanMode`: `auto` / `sleep` / `favorite` / `manual`
- `concertmirror08464.zhimiAirAirpMb5FanSpeed`: fan level `1..3`
- `fineDustSensor`: PM2.5 density
- `temperatureMeasurement`: temperature
- `relativeHumidityMeasurement`: humidity
- `filterState`: filter life remaining and reset
- `concertmirror08464.zhimiAirAirpMb5Buzzer`, `concertmirror08464.zhimiAirAirpMb5ChildLock`, `concertmirror08464.zhimiAirMb5LedLevel`
  - `ledBrightness`: display brightness, `off` / `dim` / `bright`
  - `buzzer`: 부저음, `off` / `on`
  - `childLock`: 차일드락, `off` / `on`
- `refresh`

## MIoT Mapping

Air purifier service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fault, read only diagnostic value, not exposed
- `piid=4` mode, read/write, `0=auto`, `1=sleep`, `2=favorite`, `3=manual`
- `piid=5` fan level `1..3`, read/write
- `piid=6` anion, read/write, not exposed
- `aiid=1` toggle, not exposed

Environment service `siid=3`:

- `piid=1` humidity `0..100%`, read only
- `piid=4` PM2.5 `0..1000 ug/m3`, read only
- `piid=7` temperature `-30..100 C`, read only

Filter service `siid=4`:

- `piid=1` filter life `0..100%`, read only
- `aiid=1` reset filter life action -> `filterState.resetFilter`
- `piid=3` filter used time, read only, not exposed
- `piid=4` filter left time, read only, not exposed

Alarm service `siid=6`:

- `piid=1` buzzer/alarm, read/write

Physical controls locked service `siid=8`:

- `piid=1` child lock, read/write

Screen service `siid=13`:

- `piid=2` brightness, read/write, `0=off`, `1=dim`, `2=bright`

Device display unit service `siid=14`:

- `piid=1` temperature display unit, read/write, not exposed

Custom service `siid=9`, filter-time `siid=10`, aqi `siid=11`, and rfid `siid=12` contain motor diagnostics, favorite tuning, accumulated AQI, and RFID values. They are not exposed as core SmartThings controls or sensors.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
