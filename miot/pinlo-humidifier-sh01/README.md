# Pinlo Humidifier SH01

SmartThings Edge LAN driver for the Xiaomi MIoT humidifier model `pinlo.humidifier.sh01`.

## Protocol Decision

- Protocol: MIoT
- Model: `pinlo.humidifier.sh01`
- specModel: `pinlo-sh01`
- URN: `urn:miot-spec-v2:device:humidifier:0000A00E:pinlo-sh01:1`
- Basis: current `hass-xiaomi-miot` lists exact model `pinlo.humidifier.sh01` in `MIOT_LOCAL_MODELS` with no `MIIO_TO_MIOT_SPECS` conversion, so its local host/token path sends `get_properties` and `set_properties` with `siid`/`piid`. The exact MIoT spec is the equivalent capability contract.
- Evidence: circumstantial. The only source is exact-model membership in the hass-xiaomi-miot MIOT_LOCAL_MODELS list; this model is not in python-miio and no real device response is recorded.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.pinloHumSh01Mode`
- `concertmirror08464.pinloHumSh01FanLevel`
- `concertmirror08464.pinloHumSh01TargetHumidity`
- `concertmirror08464.pinloHumSh01Heater`
- `concertmirror08464.pinloHumSh01WaterShortage`
- `refresh`

## MIoT Mapping

| Feature | Access | MIoT Key | SmartThings |
|---|---:|---|---|
| Power | RW | `siid=2`, `piid=1` | `switch` |
| Water shortage | R | `siid=2`, `piid=2`; `0=noFaults`, `1=lowWater` | `pinloHumSh01WaterShortage.waterShortage` |
| Mode | RW | `siid=2`, `piid=3`; `1=constantHumidity`, `2=manual`, `3=auto` | `pinloHumSh01Mode.mode` |
| Fan level | RW | `siid=2`, `piid=5`; `1..3` levels | `pinloHumSh01FanLevel.fanLevel` |
| Target humidity | RW | `siid=2`, `piid=6`; 45..95 %, step 5 | `pinloHumSh01TargetHumidity.targetHumidity` |
| Heater | RW | `siid=2`, `piid=8`; `0=off`, `1=on` | `pinloHumSh01Heater.heater` |
| Relative humidity | R | `siid=3`, `piid=1`; % | `relativeHumidityMeasurement` |
| Temperature | R | `siid=3`, `piid=2`; celsius | `temperatureMeasurement` |

Not exposed: the `siid=4` multifunction service only carries timer counters and undocumented internal values in the exact spec. This model has no buzzer, indicator light, or child lock property.
