# SmartThings Edge Drivers for Xiaomi Devices

SmartThings Edge Drivers for Xiaomi devices using the MIoT and miIO protocols.



## Drivers

| Driver | Protocol | Device |
|--------|----------|--------|
| `miot/zhimi-air-purifier-mb5` | MIoT | `zhimi.airpurifier.mb5` |
| `miot/zhimi-humidifier-ca6` | MIoT | `zhimi.humidifier.ca6` |
| `miot/xiaomi-humidifier-p800` | MIoT | `deerma.humidifier.jsq5` |
| `miot/qingping-air-monitor-lite` | MIoT | `cgllc.airm.cgd1st` |
| `miIo/philips-sread1` | miIO | `philips.light.sread1` |



## Libraries

| Library | Description |
|---------|-------------|
| `libs/miot.lua` | MIoT protocol implementation (get_properties / set_properties / action) |
| `libs/miio.lua` | miIO protocol implementation (get_prop / set_prop) |
| `libs/md5.lua` | MD5 implementation used for AES key derivation — extracted from [pure_lua_SHA](https://github.com/Egor-Skriptunoff/pure_lua_SHA) (MIT) |



## Related

[smartthings-tuya-edge-driver](https://github.com/wonjj6768/smartthings-tuya-edge-driver) — SmartThings Edge Drivers for Zigbee, LAN (Tuya/Xiaomi), and Matter devices.

Installation channel: https://bestow-regional.api.smartthings.com/invite/OzMgVZvVpDj9
