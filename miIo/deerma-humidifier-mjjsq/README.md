# Mi Smart Antibacterial Humidifier

SmartThings Edge LAN driver for the Xiaomi/miIO humidifier model `deerma.humidifier.mjjsq`.

## Protocol Decision

- Protocol: miIO
- Model: `deerma.humidifier.mjjsq`
- Basis: python-miio `miio.integrations.deerma.humidifier.airhumidifier_mjjsq` lists exact model `deerma.humidifier.mjjsq` in `class AirHumidifierMjjsq(Device)`. Its `status()` reads with `get_properties(properties, max_properties=1)`, so every property is a separate classic `get_prop` request, and it writes with `Set_OnOff`, `Set_HumidifierGears`, `SetLedState`, `SetTipSound_Status`, and `Set_HumiValue`. The docstring records a real device response payload. Rejected native MIoT: no `MiotDevice` mapping for this model.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHumMjjsqMode`
- `concertmirror08464.deermaHumMjjsqTargetHumidity`
- `concertmirror08464.deermaHumMjjsqWaterShortage`
- `concertmirror08464.deermaHumMjjsqTankAttached`
- `concertmirror08464.deermaHumMjjsqIndicatorLight`
- `concertmirror08464.deermaHumMjjsqBuzzer`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `OnOff_State`, `Set_OnOff` with `1` / `0` | `switch` |
| Mode | RW | `Humidifier_Gear`, `Set_HumidifierGears`, `1=low`, `2=medium`, `3=high`, `4=humidity` | `deermaHumMjjsqMode` |
| Target humidity | RW | `HumiSet_Value`, `Set_HumiValue`, 0..99 percent | `deermaHumMjjsqTargetHumidity` |
| Humidity | R | `Humidity_Value`, percent | `relativeHumidityMeasurement` |
| Temperature | R | `TemperatureValue`, Celsius | `temperatureMeasurement` |
| Water shortage | R | `waterstatus`, `0` means empty | `deermaHumMjjsqWaterShortage`, `normal` / `shortage` |
| Water tank | R | `watertankstatus`, `0` means detached | `deermaHumMjjsqTankAttached`, `attached` / `detached` |
| Indicator light | RW | `Led_State`, `SetLedState` with `1` / `0` | `deermaHumMjjsqIndicatorLight` |
| Buzzer | RW | `TipSound_State`, `SetTipSound_Status` with `1` / `0` | `deermaHumMjjsqBuzzer` |
| Refresh | Action | Re-read each property with its own `get_prop` request | `refresh` |

Reads are issued one property per request because python-miio caps this model at `max_properties=1`.

Not exposed: `use_time` returns nothing on this device, and no other diagnostic values are available.
