# Mijia Air Conditioner MA4

SmartThings Edge LAN driver for the Xiaomi classic miIO air conditioner model `xiaomi.aircondition.ma4`.

## Protocol Decision

- Protocol: classic miIO
- Model: `xiaomi.aircondition.ma4`
- specModel: `xiaomi-ma4`
- URN: `urn:miot-spec-v2:device:air-conditioner:0000A004:xiaomi-ma4:2`
- Basis: current `hass-xiaomi-miot` lists exact model `xiaomi.aircondition.ma4` in `MIIO_TO_MIOT_SPECS` with `extend_model` pointing at `xiaomi.aircondition.ma1`, so `Miio2MiotHelper` reads every value with `get_prop` and writes with `set_power`, `set_mode`, `set_temp`, `set_energysave`, `set_auxheat`, `set_sleep`, `set_dry`, `set_wind_level`, `set_swing`, `set_swingh`, `set_beep`, and `set_light`. The exact model also appears in `MIOT_LOCAL_MODELS`, but the runtime resolves the `miio2miot` converter first, so the classic classification applies. The exact MIoT spec v2 is the equivalent capability contract.
- Evidence: confirmed. Source: hass-xiaomi-miot-miio2miot+miot-spec.

## Exposed Capabilities

- `switch`
- `airConditionerMode`
- `thermostatCoolingSetpoint`
- `temperatureMeasurement`
- `airConditionerFanMode`
- `concertmirror08464.xiaomiAcMa4HSwing`
- `concertmirror08464.xiaomiAcMa4VSwing`
- `concertmirror08464.xiaomiAcMa4Eco`
- `concertmirror08464.xiaomiAcMa4Heater`
- `concertmirror08464.xiaomiAcMa4Sleep`
- `concertmirror08464.xiaomiAcMa4Dryer`
- `concertmirror08464.xiaomiAcMa4Alarm`
- `concertmirror08464.xiaomiAcMa4Indicator`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Property | Write Method | SmartThings |
|---|---:|---|---|---|
| Power | RW | `power` | `set_power` | `switch` |
| Mode | RW | `mode`; `2=cool`, `3=dry`, `4=fanOnly`, `5=heat` | `set_mode` | `airConditionerMode` |
| Target temperature | RW | `settemp`; 16..31 C, step 0.5 | `set_temp` | `thermostatCoolingSetpoint` |
| ECO | RW | `energysave` | `set_energysave` | `xiaomiAcMa4Eco.eco` |
| Auxiliary heater | RW | `auxheat` | `set_auxheat` | `xiaomiAcMa4Heater.auxHeater` |
| Sleep mode | RW | `sleep` | `set_sleep` | `xiaomiAcMa4Sleep.sleepMode` |
| Auto dry | RW | `dry` | `set_dry` | `xiaomiAcMa4Dryer.dryer` |
| Fan level | RW | `wind_level`; `0=auto`, `1..7` levels | `set_wind_level` | `airConditionerFanMode` |
| Vertical swing | RW | `swing` | `set_swing` | `xiaomiAcMa4VSwing.verticalSwing` |
| Horizontal swing | RW | `swingh` | `set_swingh` | `xiaomiAcMa4HSwing.horizontalSwing` |
| Room temperature | R | `temperature`; celsius | | `temperatureMeasurement` |
| Buzzer | RW | `beep` | `set_beep` | `xiaomiAcMa4Alarm.alarm` |
| Indicator light | RW | `light` | `set_light` | `xiaomiAcMa4Indicator.indicatorLight` |

Boolean properties are read with a non-zero test and written as an integer `0` or `1`, matching the converter templates for this model. The `miio2miot` spec sets `chunk_properties` to 1 for this family, so each property is polled with its own `get_prop` request.

Not exposed: the maintenance `examine`/`error` strings are vendor diagnostics, and the enhance `timer` carries a schedule blob rather than a device control.
