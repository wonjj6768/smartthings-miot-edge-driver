# Xiaomi Smart WiFi Socket

SmartThings Edge LAN driver for the Xiaomi/Chuangmi miIO plug model `chuangmi.plug.m1`.

## Setup

This LAN driver needs the device Xiaomi token and local IP address. Use [Xiaomi Cloud Tokens Extractor](https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor) with the same Mi Home server region, then enter the device `token` and `ip` in SmartThings preferences.

## Protocol Decision

- Protocol: miIO
- Model: `chuangmi.plug.m1`
- Basis: python-miio `ChuangmiPlug` lists this exact model with `power`, `temperature`, and `set_power`; syssi/xiaomiplug identifies it as Xiaomi Smart WiFi Socket with power and temperature support.
- Evidence: confirmed. Source: python-miio+homeassistant-integration.

## Exposed Capabilities

- `switch`
- `temperatureMeasurement`
- `refresh`

## miIO Mapping

| Feature | Access | miIO Key | SmartThings |
|---|---:|---|---|
| Power | RW | `power`, `set_power` with `on` / `off` | `switch` |
| Internal temperature | R | `temperature`; C | `temperatureMeasurement` |

Not exposed: scheduling, usage history, and other cloud/app-only plug functions because python-miio does not confirm them as local miIO core properties for this exact model.
