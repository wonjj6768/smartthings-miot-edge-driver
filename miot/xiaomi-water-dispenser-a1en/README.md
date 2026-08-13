# Xiaomi Water Dispenser A1EN

SmartThings Edge LAN driver for the Xiaomi MIoT water dispenser model `xiaomi.ysj.a1en`.

## Protocol Decision

- Protocol: MIoT
- Model: `xiaomi.ysj.a1en`
- specModel: `xiaomi-a1en`
- URN: `urn:miot-spec-v2:device:water-dispenser:0000A0A1:xiaomi-a1en:1`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.ysj.a1en` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `temperatureMeasurement`
- `thermostatHeatingSetpoint`
- `concertmirror08464.xiaomiYsjA1enStatus`
- `concertmirror08464.xiaomiYsjA1enWaterMode`
- `concertmirror08464.xiaomiYsjA1enCup`
- `concertmirror08464.xiaomiYsjA1enFault`
- `concertmirror08464.xiaomiYsjA1enTdsIn`
- `concertmirror08464.xiaomiYsjA1enTdsOut`
- `concertmirror08464.xiaomiYsjA1enFilterOne`
- `concertmirror08464.xiaomiYsjA1enFilterTwo`
- `concertmirror08464.xiaomiYsjA1enLock`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Device fault | R | `siid=2`, `piid=1`; `0=noFaults` .. `9=purifiedWaterError` | `xiaomiYsjA1enFault.deviceFault` |
| Operating status | R | `siid=2`, `piid=3`; `0=idle`, `1=waterComingOut`, `2=cleaning`, `3=error`, `4=purifier` | `xiaomiYsjA1enStatus.operatingStatus` |
| Water temperature | R | `siid=2`, `piid=5`; celsius | `temperatureMeasurement` |
| Target temperature | RW | `siid=2`, `piid=6`; 40..95 C | `thermostatHeatingSetpoint` |
| Cup size | RW | `siid=2`, `piid=14`; `0=small`, `1=middle`, `2=bigger` | `xiaomiYsjA1enCup.cupSetting` |
| Water mode | RW | `siid=2`, `piid=15`; `0=roomTemperature`, `1=milk`, `2=coffee`, `3=boilWater` | `xiaomiYsjA1enWaterMode.waterMode` |
| Inlet TDS | R | `siid=3`, `piid=1`; ppm | `xiaomiYsjA1enTdsIn.tdsIn` |
| Outlet TDS | R | `siid=3`, `piid=2`; ppm | `xiaomiYsjA1enTdsOut.tdsOut` |
| Child lock | RW | `siid=4`, `piid=1`; `0=selectOpen`, `1=open`, `2=close` | `xiaomiYsjA1enLock.childLock` |
| Filter 1 life | R | `siid=5`, `piid=1`; % | `xiaomiYsjA1enFilterOne.filterLifeLevel` |
| Filter 2 life | R | `siid=6`, `piid=1`; % | `xiaomiYsjA1enFilterTwo.filterLifeLevel` |

This exact spec has no whole-device power property, so `switch` is intentionally absent.

Not exposed: tap default mode, local mode config, winter mode, the raw 32-bit mode value, and interval reminders are configuration values; clean progress, clean status, and reset status track maintenance runs; the recipe and clean actions plus the filter reset actions are maintenance-only; and the screen auto-off time and no-disturb period are scheduling preferences.
