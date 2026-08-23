# Xiaomi Smart Air Purifier Elite

SmartThings Edge LAN driver for one MIoT model: `zhimi.airp.meb1`.

## Protocol Decision

- Protocol: MIoT
- Model: `zhimi.airp.meb1`
- Spec model: `zhimi-meb1`
- URN: `urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-meb1:1`
- Basis: current `hass-xiaomi-miot` lists exact model `zhimi.airp.meb1` in `MIOT_LOCAL_MODELS`; its local path sends `get_properties` and `set_properties` with `siid`/`piid` mappings. The exact MIoT spec confirms the mapped property contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`: power
- `concertmirror08464.zhimiAirMeb1Uv`, `concertmirror08464.zhimiAirMeb1AirPurifierMode`, `concertmirror08464.zhimiAirMeb1Buzzer`, `concertmirror08464.zhimiAirMeb1ChildLock`, `concertmirror08464.zhimiAirMeb1FanLevel`, `concertmirror08464.zhimiAirMeb1DisplayLevel`, `concertmirror08464.zhimiAirMeb1Plasma`
  - `airPurifierMode`: `auto` / `sleep` / `favorite` / `manual`
  - `fanLevel`: `level1` / `level2` / `level3`
  - `displayBrightness`: `off` / `bright` / `brightest`
  - `plasma`: `off` / `on`
  - `uv`: `off` / `on`
  - `buzzer`: `off` / `on`
  - `childLock`: `off` / `on`
- `dustSensor`: PM2.5 and PM10 density
- `temperatureMeasurement`: temperature
- `relativeHumidityMeasurement`: humidity
- `filterState`: filter life remaining and reset
- `refresh`

## MIoT Mapping

Air purifier service `siid=2`:

- `piid=1` power, read/write
- `piid=2` fault, read only diagnostic value, not exposed
- `piid=4` mode, read/write, `0=auto`, `1=sleep`, `2=favorite`, `3=manual`
- `piid=5` fan level, read/write, `1=level1`, `2=level2`, `3=level3`
- `piid=6` plasma, read/write
- `piid=7` UV, read/write
- `aiid=1` toggle, not exposed

Environment service `siid=3`:

- `piid=1` humidity `0..100%`, read only
- `piid=4` PM2.5 `0..1000 ug/m3`, read only
- `piid=7` temperature `-30..100 C`, read only
- `piid=8` PM10 `0..100 ug/m3`, read only
- `piid=9` air quality enum, read only, not exposed

Filter service `siid=4`:

- `piid=1` filter life `0..100%`, read only
- `piid=3` filter used time, read only, not exposed
- `aiid=1` reset filter life action -> `filterState.resetFilter`

Alarm service `siid=6`:

- `piid=1` buzzer/alarm, read/write

Physical controls locked service `siid=8`:

- `piid=1` child lock, read/write

Screen service `siid=13`:

- `piid=2` display brightness, read/write, `0=off`, `1=bright`, `2=brightest`

Favorite, display unit, custom diagnostics, filter-time, AQI heartbeat, and RFID services are not exposed as core SmartThings controls or sensors.


Not exposed: auxiliary diagnostics, accumulated usage, hardware metadata, and non-core private values are intentionally omitted.
