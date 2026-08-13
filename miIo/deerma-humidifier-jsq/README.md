# Mi Smart Antibacterial Humidifier

SmartThings Edge LAN driver for the Xiaomi/miIO humidifier model `deerma.humidifier.jsq`.

## Protocol Decision

- Protocol: miIO
- Model: `deerma.humidifier.jsq`
- Basis: python-miio `miio.integrations.deerma.humidifier.airhumidifier_mjjsq` lists exact model `deerma.humidifier.jsq` in `class AirHumidifierMjjsq(Device)`. Its `status()` reads with `get_properties(properties, max_properties=1)`, so every property is a separate classic `get_prop` request, and it writes with `Set_OnOff`, `Set_HumidifierGears`, `SetLedState`, `SetTipSound_Status`, and `Set_HumiValue`. Its AVAILABLE_PROPERTIES entry is the same shared list as mjjsq. Rejected native MIoT: no `MiotDevice` mapping for this model.
- Evidence: confirmed. Source: python-miio-classic.

## Exposed Capabilities

- `switch`
- `relativeHumidityMeasurement`
- `temperatureMeasurement`
- `concertmirror08464.deermaHumJsqMode`
- `concertmirror08464.deermaHumJsqTargetHumidity`
- `concertmirror08464.deermaHumJsqWaterShortage`
- `concertmirror08464.deermaHumJsqTankAttached`
- `concertmirror08464.deermaHumJsqIndicatorLight`
- `concertmirror08464.deermaHumJsqBuzzer`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `OnOff_State`, `Set_OnOff` with `1` / `0` | `switch` |
| Mode | RW | `Humidifier_Gear`, `Set_HumidifierGears`, `1=low`, `2=medium`, `3=high`, `4=humidity` | `deermaHumJsqMode` |
| Target humidity | RW | `HumiSet_Value`, `Set_HumiValue`, 0..99 percent | `deermaHumJsqTargetHumidity` |
| Humidity | R | `Humidity_Value`, percent | `relativeHumidityMeasurement` |
| Temperature | R | `TemperatureValue`, Celsius | `temperatureMeasurement` |
| Water shortage | R | `waterstatus`, `0` means empty | `deermaHumJsqWaterShortage`, `normal` / `shortage` |
| Water tank | R | `watertankstatus`, `0` means detached | `deermaHumJsqTankAttached`, `attached` / `detached` |
| Indicator light | RW | `Led_State`, `SetLedState` with `1` / `0` | `deermaHumJsqIndicatorLight` |
| Buzzer | RW | `TipSound_State`, `SetTipSound_Status` with `1` / `0` | `deermaHumJsqBuzzer` |
| Refresh | Action | Re-read each property with its own `get_prop` request | `refresh` |

Reads are issued one property per request because python-miio caps this model at `max_properties=1`.

Not exposed: `use_time` returns nothing on this device, and no other diagnostic values are available.
