# SmartThings Edge Drivers for Xiaomi Devices

Installation channel (`wonjj_miot`): [open SmartThings channel](https://bestow-regional.api.smartthings.com/invite/r3MyzkOpOz2p)

SmartThings Edge LAN drivers for Xiaomi ecosystem devices using the MIoT and miIO protocols.

Each driver targets one exact Xiaomi model id. Do not choose by retail product name alone because Xiaomi often reuses the same product name for different hardware models.

## Choosing a Driver

1. Check the Xiaomi model id from Mi Home, Xiaomi Cloud Tokens Extractor, or the device information page.
2. Find the exact same value in the `Device model` column below.
3. Install the matching `SmartThings driver name` from the `wonjj_miot` channel.
4. If several rows have the same `Product name`, use `Device model` as the deciding value.

The `SmartThings driver name` column is the name shown in the SmartThings Edge channel. The `Driver folder` column is included for source review and issue reports.

## Requirements

These LAN drivers need the Xiaomi device token and local IP address. Use [Xiaomi Cloud Tokens Extractor](https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor), select the same Xiaomi server region used in Mi Home, then copy the device `token` and `ip` into the SmartThings device preferences.

## Installation

1. Open the installation channel above and enroll the SmartThings location.
2. Install the SmartThings driver whose `Device model` exactly matches the Xiaomi model id.
3. Add a device in the SmartThings app.
4. Enter `ipAddress`, `token`, and `pollingInterval` in device preferences.
5. Toggle `createDev` when using the LAN manual creation pattern.

## Drivers

Supported drivers are grouped by protocol and device type.

### MIoT Air Purifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miot/zhimi-air-purifier-airp-mb5` | `zhimi.airp.mb5` | Xiaomi Smart Air Purifier 4 | `Xiaomi Smart Air Purifier 4` |
| `miot/zhimi-air-purifier-mb5a` | `zhimi.airp.mb5a` | Xiaomi Smart Air Purifier 4 | `Zhimi Air Purifier MB5A` |
| `miot/zhimi-air-purifier-va2` | `zhimi.airp.va2` | Xiaomi Air Purifier Pro H | `Zhimi Air Purifier VA2` |
| `miot/zhimi-air-purifier-vb4` | `zhimi.airp.vb4` | Xiaomi Air Purifier Pro 4 | `Zhimi Air Purifier VB4` |
| `miot/zhimi-air-purifier-rmb1` | `zhimi.airp.rmb1` | Xiaomi Smart Air Purifier 4 Lite | `Zhimi Air Purifier RMB1` |
| `miot/zhimi-air-purifier-rma1` | `zhimi.airpurifier.rma1` | Xiaomi Smart Air Purifier 4 Lite | `Zhimi Air Purifier RMA1` |
| `miot/zhimi-air-purifier-rma2` | `zhimi.airpurifier.rma2` | Xiaomi Smart Air Purifier 4 Lite | `Zhimi Air Purifier RMA2` |
| `miot/zhimi-air-purifier-za1` | `zhimi.airpurifier.za1` | Smartmi Air Purifier | `Zhimi Air Purifier ZA1` |
| `miot/zhimi-air-purifier-meb1` | `zhimi.airp.meb1` | Xiaomi Smart Air Purifier Elite | `Xiaomi Smart Air Purifier Elite` |
| `miot/zhimi-air-purifier-cpa4` | `zhimi.airp.cpa4` | Xiaomi Smart Air Purifier 4 Compact | `Xiaomi Smart Air Purifier 4 Compact` |
| `miot/zhimi-air-purifier-mb4` | `zhimi.airpurifier.mb4` | Xiaomi Mi Air Purifier 3C | `Zhimi Air Purifier MB4` |
| `miot/zhimi-air-purifier-mb4a` | `zhimi.airp.mb4a` | Xiaomi Mi Air Purifier 3C v2 | `Zhimi Air Purifier MB4A` |
| `miot/zhimi-air-purifier-ma4` | `zhimi.airpurifier.ma4` | Xiaomi Mi Air Purifier 3 | `Zhimi Air Purifier MA4` |
| `miot/zhimi-air-purifier-mb3` | `zhimi.airpurifier.mb3` | Xiaomi Mi Air Purifier 3H | `Zhimi Air Purifier MB3` |
| `miot/zhimi-air-purifier-mb3a` | `zhimi.airpurifier.mb3a` | Xiaomi Mi Air Purifier 3H v2 | `Zhimi Air Purifier MB3A` |
| `miot/zhimi-air-purifier-airp-mb3a` | `zhimi.airp.mb3a` | Xiaomi Mi Air Purifier 3H v2 | `Zhimi Air Purifier AIRP MB3A` |
| `miot/zhimi-air-purifier-va1` | `zhimi.airpurifier.va1` | Xiaomi Mi Air Purifier Pro H CN | `Zhimi Air Purifier VA1` |
| `miot/zhimi-air-purifier-vb2` | `zhimi.airpurifier.vb2` | Xiaomi Mi Air Purifier Pro H | `Zhimi Air Purifier VB2` |
| `miot/xiaomi-air-purifier-cpa4` | `xiaomi.airp.cpa4` | Xiaomi Air Purifier CPA4 | `Xiaomi Air Purifier CPA4` |
| `miot/xiaomi-air-purifier-cpa5` | `xiaomi.airp.cpa5` | Xiaomi Smart Pet Care Air Purifier | `Xiaomi Pet Air CPA5` |
| `miot/xiaomi-air-purifier-mb5` | `xiaomi.airp.mb5` | Mijia Smart Air Purifier 6 | `Mijia Smart Air Purifier 6` |
| `miot/xiaomi-air-purifier-mb6` | `xiaomi.airp.mb6` | Mijia Smart Air Purifier Max | `Mijia Air Purifier Max` |
| `miot/xiaomi-air-purifier-mp4` | `xiaomi.airp.mp4` | Xiaomi Air Purifier MP4 | `Xiaomi Air Purifier MP4` |
| `miot/xiaomi-air-purifier-mp5` | `xiaomi.airp.mp5` | Xiaomi Air Purifier MP5 | `Xiaomi Air Purifier MP5` |
| `miot/xiaomi-air-purifier-pa1` | `xiaomi.airp.pa1` | Xiaomi Air Purifier PA1 | `Xiaomi Air Purifier PA1` |
| `miot/xiaomi-air-purifier-rmb3` | `xiaomi.airp.rmb3` | Xiaomi Air Purifier RMB3 | `Xiaomi Air Purifier RMB3` |
| `miot/xiaomi-air-purifier-ua3` | `xiaomi.airp.ua3` | Xiaomi Air Purifier UA3 | `Xiaomi Air Purifier UA3` |
| `miot/xiaomi-air-purifier-va2b` | `xiaomi.airp.va2b` | Xiaomi Air Purifier VA2B | `Xiaomi Air Purifier VA2B` |
| `miot/xiaomi-air-purifier-va3` | `xiaomi.airp.va3` | Xiaomi Air Purifier VA3 | `Xiaomi Air Purifier VA3` |
| `miot/xiaomi-air-purifier-va4` | `xiaomi.airp.va4` | Xiaomi Air Purifier VA4 | `Xiaomi Air Purifier VA4` |
| `miot/zhimi-air-purifier-mea1` | `zhimi.airp.mea1` | Zhimi Air Purifier MEA1 | `Zhimi Air Purifier MEA1` |
| `miot/airdog-air-purifier-mn` | `airdog.airpurifier.mn` | Airdog Air Purifier MN | `Airdog Air Purifier MN` |
| `miot/baomi-air-purifier-450a` | `baomi.airpurifier.450a` | Baomi Air Purifier 450A | `Baomi Air Purifier 450A` |
| `miot/bj352-air-purifier-y106cm` | `bj352.airp.y106cm` | BJ352 Air Purifier Y106CM | `BJ352 Air Purifier Y106CM` |
| `miot/dmaker-air-purifier-f20` | `dmaker.airpurifier.f20` | Dmaker Air Purifier F20 | `Dmaker Air Purifier F20` |
| `miot/dmaker-air-purifier-swift` | `dmaker.airp.swift` | Dmaker Air Purifier Swift | `Dmaker Air Purifier Swift` |
| `miot/dmaker-air-purifier-swift2` | `dmaker.airp.swift2` | Dmaker Air Purifier Swift 2 | `Dmaker Air Purifier Swift 2` |
| `miot/hanyi-air-purifier-kj550` | `hanyi.airpurifier.kj550` | Hanyi Air Purifier KJ550 | `Hanyi Air Purifier KJ550` |
| `miot/viomi-air-purifier-v3` | `viomi.airp.v3` | Viomi Air Purifier V3 | `Viomi Air Purifier V3` |
| `miot/zhimi-air-purifier-mp4` | `zhimi.airp.mp4` | Zhimi Air Purifier MP4 | `Zhimi Air Purifier MP4` |
| `miot/zhimi-air-purifier-mp4a` | `zhimi.airp.mp4a` | Zhimi Air Purifier MP4A | `Zhimi Air Purifier MP4A` |
| `miot/zhimi-air-purifier-airp-rma2` | `zhimi.airp.rma2` | Zhimi Air Purifier AirP RMA2 | `Zhimi Air Purifier AirP RMA2` |
| `miot/zhimi-air-purifier-rma3` | `zhimi.airp.rma3` | Zhimi Air Purifier RMA3 | `Zhimi Air Purifier RMA3` |
| `miot/zhimi-air-purifier-sa4` | `zhimi.airp.sa4` | Zhimi Air Purifier SA4 | `Zhimi Air Purifier SA4` |
| `miot/zhimi-air-purifier-ua1` | `zhimi.airp.ua1` | Zhimi Air Purifier UA1 | `Zhimi Air Purifier UA1` |
| `miot/zhimi-air-purifier-ua1a` | `zhimi.airp.ua1a` | Zhimi Air Purifier UA1A | `Zhimi Air Purifier UA1A` |
| `miot/zhimi-air-purifier-ua2` | `zhimi.airp.ua2` | Zhimi Air Purifier UA2 | `Zhimi Air Purifier UA2` |
| `miot/zhimi-air-purifier-va2a` | `zhimi.airp.va2a` | Zhimi Air Purifier VA2A | `Zhimi Air Purifier VA2A` |
| `miot/zhimi-air-purifier-vb2a` | `zhimi.airp.vb2a` | Zhimi Air Purifier VB2A | `Zhimi Air Purifier VB2A` |
| `miot/zhimi-air-purifier-oa1` | `zhimi.airpurifier.oa1` | Zhimi Air Purifier OA1 | `Zhimi Air Purifier OA1` |
| `miot/zhimi-air-purifier-xa1` | `zhimi.airpurifier.xa1` | Zhimi Air Purifier XA1 | `Zhimi Air Purifier XA1` |

### MIoT Humidifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miot/zhimi-humidifier-ca4` | `zhimi.humidifier.ca4` | Smartmi Evaporative Humidifier 2 | `Zhimi Humidifier CA4` |
| `miot/zhimi-humidifier-ca6` | `zhimi.humidifier.ca6` | Smartmi Evaporative Humidifier CA6 | `Zhimi Humidifier CA6` |
| `miot/zhimi-humidifier-ca7` | `zhimi.humidifier.ca7` | Zhimi Humidifier CA7 | `Zhimi Humidifier CA7` |
| `miot/deerma-humidifier-jsq5` | `deerma.humidifier.jsq5` | Xiaomi Mi Smart Antibacterial Humidifier S | `Deerma Humidifier JSQ5` |
| `miot/deerma-humidifier-jsq2w` | `deerma.humidifier.jsq2w` | Xiaomi Smart Humidifier 2 | `Deerma Humidifier JSQ2W` |
| `miot/deerma-humidifier-990dw` | `deerma.humidifier.990dw` | Deerma Humidifier 990DW | `Deerma Humidifier 990DW` |
| `miot/pinlo-humidifier-sh01` | `pinlo.humidifier.sh01` | Pinlo Humidifier SH01 | `Pinlo Humidifier SH01` |
| `miot/xiaomi-humidifier-airmx` | `xiaomi.humidifier.airmx` | Mijia Mist-Free Humidifier 3 Pro | `Mijia Mist-Free Humidifier 3 Pro` |
| `miot/xiaomi-humidifier-600ek` | `xiaomi.humidifier.600ek` | Mijia Smart Evaporative Humidifier Pro | `Mijia Smart Evaporative Humidifier Pro` |
| `miot/xiaomi-humidifier-p800` | `xiaomi.humidifier.p800` | Mijia Mist-Free Humidifier 3 (800) | `Xiaomi Humidifier P800` |
| `miot/xiaomi-humidifier-p1200` | `xiaomi.humidifier.p1200` | Mijia No-Fog Humidifier 3 1200 | `Xiaomi Humidifier P1200` |
| `miot/dmaker-humidifier-p2` | `dmaker.humidifier.p2` | Dmaker Humidifier P2 | `Dmaker Humidifier P2` |
| `miot/xiaomi-humidifier-3lite` | `xiaomi.humidifier.3lite` | Xiaomi Smart Humidifier 3 Lite | `Xiaomi Humidifier 3lite` |
| `miot/xiaomi-humidifier-4lite` | `xiaomi.humidifier.4lite` | Xiaomi Humidifier 4 Lite | `Xiaomi Humidifier 4lite` |
| `miot/deerma-humidifier-ct500` | `deerma.humidifier.ct500` | Deerma Humidifier CT500 | `Deerma Humidifier CT500` |
| `miot/deerma-humidifier-jsq2g` | `deerma.humidifier.jsq2g` | Deerma Humidifier JSQ2G | `Deerma Humidifier JSQ2G` |
| `miot/deerma-humidifier-rz300` | `deerma.humidifier.rz300` | Deerma Humidifier RZ300 | `Deerma Humidifier RZ300` |
| `miot/leshow-humidifier-jsq2` | `leshow.humidifier.jsq2` | Leshow Humidifier JSQ2 | `Leshow Humidifier JSQ2` |
| `miot/leshow-humidifier-jsq3` | `leshow.humidifier.jsq3` | Leshow Humidifier JSQ3 | `Leshow Humidifier JSQ3` |
| `miot/mate-humidifier-cs01` | `mate.humidifier.cs01` | Mate Humidifier CS01 | `Mate Humidifier CS01` |
| `miot/xiaomi-humidifier-p3` | `xiaomi.humidifier.p3` | Xiaomi Humidifier P3 | `Xiaomi Humidifier P3` |
| `miot/zhimi-humidifier-cb1a` | `zhimi.humidifier.cb1a` | Zhimi Humidifier CB1A | `Zhimi Humidifier CB1A` |

### MIoT Dehumidifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miot/xiaomi-dehumidifier-lite` | `xiaomi.derh.lite` | Xiaomi Smart Dehumidifier Lite | `Xiaomi Dehumidifier Lite` |
| `miot/xiaomi-dehumidifier-13l` | `xiaomi.derh.13l` | Xiaomi Smart Dehumidifier 13L | `Xiaomi Dehumidifier 13L` |
| `miot/dmaker-dehumidifier-22l` | `dmaker.derh.22l` | Mijia Smart Dehumidifier 22L | `Mijia Dehumidifier 22L` |
| `miot/nwt-dehumidifier-312en` | `nwt.derh.312en` | NWT Dehumidifier 312EN | `NWT Dehumidifier 312EN` |
| `miot/nwt-dehumidifier-16l` | `nwt.fan.16l` | NWT Dehumidifier 16L | `NWT Dehumidifier 16L` |
| `miot/nwt-dehumidifier-60l` | `nwt.derh.60l` | NWT Dehumidifier 60L | `NWT Dehumidifier 60L` |
| `miot/nwt-dehumidifier-24wu1` | `nwt.derh.24wu1` | NWT Dehumidifier 24WU1 | `NWT Dehumidifier 24WU1` |
| `miot/aden-dehumidifier-derh16` | `aden.derh.derh16` | Aden D16 Dehumidifier | `Aden D16 Dehumidifier` |
| `miot/aden-dehumidifier-fight` | `aden.derh.fight` | Aden Fight Dehumidifier | `Aden Fight Dehumidifier` |
| `miot/deye-dehumidifier-u20a3` | `deye.derh.u20a3` | Deye U20 Dehumidifier | `Deye U20 Dehumidifier` |
| `miot/deye-dehumidifier-z12a3` | `deye.derh.z12a3` | Deye Z12 Dehumidifier | `Deye Z12 Dehumidifier` |
| `miot/dmaker-dehumidifier-22ht` | `dmaker.derh.22ht` | Dmaker 22ht Dehumidifier | `Dmaker 22ht Dehumidifier` |
| `miot/dmaker-dehumidifier-50l` | `dmaker.derh.50l` | Dmaker 50l Dehumidifier | `Dmaker 50l Dehumidifier` |
| `miot/kadeer-dehumidifier-x1701` | `kadeer.derh.x1701` | Kadeer X1701 Dehumidifier | `Kadeer X1701 Dehumidifier` |
| `miot/nwt-dehumidifier-330ef` | `nwt.derh.330ef` | NWT 330ef Dehumidifier | `NWT 330ef Dehumidifier` |
| `miot/nwt-dehumidifier-nwt10l` | `nwt.derh.nwt10l` | NWT 10l Dehumidifier | `NWT 10l Dehumidifier` |

### MIoT Fans

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miot/dmaker-fan-1c` | `dmaker.fan.1c` | Mi Smart Standing Fan 1C | `Xiaomi Fan 1C` |
| `miot/dmaker-fan-1e` | `dmaker.fan.1e` | Mijia DC Inverter Standing Fan E | `Mijia Fan 1E` |
| `miot/dmaker-fan-p10` | `dmaker.fan.p10` | Mi Smart Standing Fan 2 | `Xiaomi Fan P10` |
| `miot/dmaker-fan-p11` | `dmaker.fan.p11` | Xiaomi Smart Fan V2 | `Xiaomi Smart Fan V2` |
| `miot/dmaker-fan-p15` | `dmaker.fan.p15` | Xiaomi Mi Smart Standing Fan Pro 4th Gen (ZLBPSP01XY) | `Mi Smart Standing Fan Pro` |
| `miot/dmaker-fan-p9` | `dmaker.fan.p9` | Mi Smart Tower Fan | `Mi Smart Tower Fan` |
| `miot/dmaker-fan-p39` | `dmaker.fan.p39` | Xiaomi Smart Tower Fan | `Xiaomi Smart Tower Fan` |
| `miot/dmaker-fan-p42` | `dmaker.fan.p42` | Xiaomi Smart Standing Fan 2 | `Xiaomi Fan P42` |
| `miot/dmaker-fan-p44` | `dmaker.fan.p44` | Mijia Smart Evaporative Cooling Fan | `Mijia Fan P44` |
| `miot/dmaker-fan-p8` | `dmaker.fan.p8` | Mijia Standing Fan P8 | `Mijia Fan P8` |
| `miot/dmaker-fan-p33` | `dmaker.fan.p33` | Xiaomi Smart Standing Fan 2 Pro | `Xiaomi Smart Standing Fan 2 Pro` |
| `miot/dmaker-fan-p18` | `dmaker.fan.p18` | Mi Smart Fan 2 | `Xiaomi Smart Standing Fan 2` |
| `miot/dmaker-fan-p220` | `dmaker.fan.p220` | Mijia Smart DC Inverter Circulating Standing Fan | `Mijia Fan P220` |
| `miot/dmaker-fan-p221` | `dmaker.fan.p221` | Mijia Smart DC Inverter Circulating Standing Fan Battery Edition | `Mijia Fan P221` |
| `miot/dmaker-fan-p28` | `dmaker.fan.p28` | Mijia Smart DC Inverter Circulating Fan Floor Type | `Mijia Fan P28` |
| `miot/dmaker-fan-p30` | `dmaker.fan.p30` | Xiaomi Smart Standing Fan 2 P30 | `Dmaker Fan P30` |
| `miot/dmaker-fan-p5c` | `dmaker.fan.p5c` | Mijia Smart DC Standing Fan 1X | `Mijia Fan P5C` |
| `miot/xiaomi-fan-2lite` | `xiaomi.fan.2lite` | Mi Smart Standing Fan 2 Lite | `Xiaomi Fan 2 Lite` |
| `miot/xiaomi-fan-p30` | `xiaomi.fan.p30` | Mi Smart Standing Fan 2 | `Xiaomi Fan P30` |
| `miot/xiaomi-fan-p45` | `xiaomi.fan.p45` | Xiaomi Smart Tower Fan 2 | `Xiaomi Smart Tower Fan 2` |
| `miot/xiaomi-fan-p51` | `xiaomi.fan.p51` | Mijia Circulation Fan | `Mijia Circulation Fan` |
| `miot/xiaomi-fan-p69` | `xiaomi.fan.p69` | Mijia Smart Desktop Air Circulation Fan | `Mijia Desktop Circulation Fan` |
| `miot/xiaomi-fan-p70` | `xiaomi.fan.p70` | Xiaomi BPLDS10DM Smart Desktop Air Circulation Fan | `Xiaomi Fan P70` |
| `miot/xiaomi-fan-p76` | `xiaomi.fan.p76` | Xiaomi Smart Standing Air Circulation Fan | `Xiaomi Fan P76` |
| `miot/xiaomi-fan-p90` | `xiaomi.fan.p90` | Mijia Smart DC Inverter Circulation Fan Pro | `Xiaomi Fan P90` |
| `miot/xiaomi-fan-p85` | `xiaomi.fan.p85` | Mijia Smart Standing Fan Pro Slim | `Mijia Fan P85` |
| `miot/dmaker-fan-p45` | `dmaker.fan.p45` | Mijia DC Inverter Tower Fan 2 | `Mijia DC Inverter Tower Fan 2` |
| `miot/xiaomi-fan-p43` | `xiaomi.fan.p43` | Xiaomi Fan P43 | `Xiaomi Fan P43` |
| `miot/zhimi-fan-za5` | `zhimi.fan.za5` | Smartmi Standing Fan 3 | `Smartmi Standing Fan 3` |
| `miot/zhimi-fan-fa1` | `zhimi.fan.fa1` | Zhimi Fan FA1 | `Zhimi Fan FA1` |
| `miot/zhimi-fan-fa2` | `zhimi.fan.fa2` | Zhimi Fan FA2 | `Zhimi Fan FA2` |
| `miot/zhimi-fan-fb1` | `zhimi.fan.fb1` | Zhimi Fan FB1 | `Zhimi Fan FB1` |
| `miot/dmaker-fan-p23` | `dmaker.fan.p23` | Mijia Fan P23 | `Mijia Fan P23` |
| `miot/dreame-fan-l2146` | `dreame.fan.l2146` | Dreame Fan L2146 | `Dreame Fan L2146` |
| `miot/dreame-fan-p2018` | `dreame.fan.p2018` | Dreame Fan P2018 | `Dreame Fan P2018` |
| `miot/kadeer-fan-l22xh2` | `kadeer.fan.l22xh2` | Kadeer Fan L22XH2 | `Kadeer Fan L22XH2` |
| `miot/solove-fan-f5new` | `solove.fan.f5new` | Solove Fan F5 New | `Solove Fan F5 New` |
| `miot/viomi-fan-v13` | `viomi.fan.v13` | Viomi Fan V13 | `Viomi Fan V13` |

### MIoT Other Devices

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miot/xiaomi-fish-tank-m100` | `hfjh.fishbowl.m100` | Xiaomi Smart Fish Tank MYG100 | `Xiaomi Smart Fish Tank MYG100` |
| `miot/xiaomi-fish-tank-m200` | `xiaomi.fishbowl.m200` | Xiaomi Smart Fishbowl M200 | `Xiaomi Smart Fishbowl M200` |
| `miot/zhimi-heater-mc2` | `zhimi.heater.mc2` | Mi Smart Space Heater S | `Mi Smart Space Heater S` |
| `miot/zhimi-heater-mc2a` | `zhimi.heater.mc2a` | Mi Smart Space Heater S MC2A | `Mi Smart Space Heater S MC2A` |
| `miot/kadeer-heater-l250sr` | `kadeer.heater.l250sr` | Kadeer L250 Heater | `Kadeer L250 Heater` |
| `miot/leshow-heater-bs2` | `leshow.heater.bs2` | Leshow BS2 Heater | `Leshow BS2 Heater` |
| `miot/leshow-heater-nfj2lx` | `leshow.heater.nfj2lx` | Leshow NFJ2 Heater | `Leshow NFJ2 Heater` |
| `miot/leshow-heater-nfj3lx` | `leshow.heater.nfj3lx` | Leshow NFJ3 Heater | `Leshow NFJ3 Heater` |
| `miot/viomi-heater-v10` | `viomi.heater.v10` | Viomi V10 Heater | `Viomi V10 Heater` |
| `miot/viomi-heater-v5` | `viomi.heater.v5` | Viomi V5 Heater | `Viomi V5 Heater` |
| `miot/viomi-heater-v6` | `viomi.heater.v6` | Viomi Heater V6 | `Viomi Heater V6` |
| `miot/viomi-heater-v8` | `viomi.heater.v8` | Viomi Heater V8 | `Viomi Heater V8` |
| `miot/viomi-heater-v9` | `viomi.heater.v9` | Viomi Heater V9 | `Viomi Heater V9` |
| `miot/xiaomi-heater-ma4` | `xiaomi.heater.ma4` | Xiaomi Heater MA4 | `Xiaomi Heater MA4` |
| `miot/xiaomi-heater-ma7` | `xiaomi.heater.ma7` | Xiaomi Heater MA7 | `Xiaomi Heater MA7` |
| `miot/xiaomi-heater-ma8` | `xiaomi.heater.ma8` | Xiaomi Heater MA8 | `Xiaomi Heater MA8` |
| `miot/zhimi-heater-ma2` | `zhimi.heater.ma2` | Smartmi Heater MA2 | `Smartmi Heater MA2` |
| `miot/zhimi-heater-ma5` | `zhimi.heater.ma5` | Smartmi Heater MA5 | `Smartmi Heater MA5` |
| `miot/zhimi-heater-ma6` | `zhimi.heater.ma6` | Smartmi Heater MA6 | `Smartmi Heater MA6` |
| `miot/zhimi-heater-za3` | `zhimi.heater.za3` | Smartmi Heater ZA3 | `Smartmi Heater ZA3` |
| `miot/zhimi-heater-zb1a` | `zhimi.heater.zb1a` | Smartmi Heater ZB1A | `Smartmi Heater ZB1A` |
| `miot/qingping-air-monitor-lite` | `cgllc.airm.cgd1st` | Qingping Air Monitor Lite | `Qingping Air Monitor Lite2` |
| `miot/xiaomi-pet-waterer-iv02` | `xiaomi.pet_waterer.iv02` | Xiaomi Pet Waterer IV02 | `Xiaomi Pet Waterer IV02` |
| `miot/xiaomi-pet-waterer-70m2` | `xiaomi.pet_waterer.70m2` | Xiaomi Pet Waterer 70M2 | `Xiaomi Pet Waterer 70M2` |
| `miot/xiaomi-pet-feeder-iv2001` | `xiaomi.feeder.iv2001` | Xiaomi Pet Feeder IV2001 | `Xiaomi Pet Feeder IV2001` |
| `miot/xiaomi-pet-feeder-pi2001` | `xiaomi.feeder.pi2001` | Xiaomi Pet Feeder PI2001 | `Xiaomi Pet Feeder PI2001` |
| `miot/tmwl-electronic-valve-iotb2` | `tmwl.valve.iotb2` | TMWL Electronic Valve IOTB2 | `TMWL Electronic Valve IOTB2` |
| `miot/brains-occupancy-sensor-r4` | `brains.sensor_occupy.r4` | Brains Occupancy Sensor R4 | `Brains Occupancy Sensor R4` |
| `miot/xiaomi-curtain-acn009` | `xiaomi.curtain.acn009` | Xiaomi Curtain ACN009 | `Xiaomi Curtain ACN009` |
| `miot/xiaomi-airer-pro3` | `xiaomi.airer.pro3` | Xiaomi Airer Pro 3 | `Xiaomi Airer Pro 3` |
| `miot/xiaomi-water-heater-ym03` | `xiaomi.waterheater.ym03` | Xiaomi Water Heater YM03 | `Xiaomi Water Heater YM03` |
| `miot/xiaomi-water-dispenser-a1en` | `xiaomi.ysj.a1en` | Xiaomi Water Dispenser A1EN | `Xiaomi Water Dispenser A1EN` |
| `miot/xiaomi-electric-blanket-mj1` | `xiaomi.blanket.mj1` | Xiaomi Electric Blanket MJ1 | `Xiaomi Electric Blanket MJ1` |
| `miot/xiaomi-hood-ymv5` | `xiaomi.hood.ymv5` | Xiaomi Hood YMV5 | `Xiaomi Hood YMV5` |
| `miot/xiaomi-water-purifier-lx20` | `xiaomi.waterpuri.lx20` | Xiaomi Water Purifier LX20 | `Xiaomi Water Purifier LX20` |
| `miot/xiaomi-airer-lyj3xs` | `xiaomi.airer.lyj3xs` | Xiaomi Airer LYJ3XS | `Xiaomi Airer LYJ3XS` |
| `miot/xiaomi-hood-jyjss2` | `xiaomi.hood.jyjss2` | Xiaomi Hood JYJSS2 | `Xiaomi Hood JYJSS2` |
| `miot/xiaomi-kettle-v20` | `xiaomi.kettle.v20` | Xiaomi Kettle V20 | `Xiaomi Kettle V20` |
| `miot/xiaomi-water-heater-ym02` | `xiaomi.waterheater.ym02` | Xiaomi Water Heater YM02 | `Xiaomi Water Heater YM02` |
| `miot/xiaomi-water-purifier-lx32` | `xiaomi.waterpuri.lx32` | Xiaomi Water Purifier LX32 | `Xiaomi Water Purifier LX32` |
| `miot/xiaomi-air-conditioner-ra1r00` | `xiaomi.airc.ra1r00` | Xiaomi Air Conditioner RA1 | `Xiaomi Air Conditioner RA1` |
| `miot/xiaomi-air-conditioner-c38` | `xiaomi.aircondition.c38` | Xiaomi Air Conditioner C38 | `Xiaomi Air Conditioner C38` |
| `miot/xiaomi-air-conditioner-r09h00` | `xiaomi.airc.r09h00` | Xiaomi Air Conditioner R09 | `Xiaomi Air Conditioner R09` |

### miIO Air Purifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/zhimi-air-purifier-mc1` | `zhimi.airpurifier.mc1` | Xiaomi Air Purifier 2S Global Version | `Zhimi Air Purifier MC1` |
| `miIo/zhimi-air-purifier-mc2` | `zhimi.airpurifier.mc2` | Xiaomi Air Purifier 2H | `Zhimi Air Purifier MC2` |
| `miIo/zhimi-air-purifier-v1` | `zhimi.airpurifier.v1` | Xiaomi Mi Air Purifier | `Zhimi Air Purifier V1` |
| `miIo/zhimi-air-purifier-v2` | `zhimi.airpurifier.v2` | Xiaomi Mi Air Purifier | `Zhimi Air Purifier V2` |
| `miIo/zhimi-air-purifier-v3` | `zhimi.airpurifier.v3` | Xiaomi Mi Air Purifier | `Zhimi Air Purifier V3` |
| `miIo/zhimi-air-purifier-v5` | `zhimi.airpurifier.v5` | Xiaomi Mi Air Purifier Pro | `Zhimi Air Purifier V5` |
| `miIo/zhimi-air-purifier-v6` | `zhimi.airpurifier.v6` | Xiaomi Mi Air Purifier Pro (AC-M3-CA) | `Zhimi Air Purifier V6` |
| `miIo/zhimi-air-purifier-v7` | `zhimi.airpurifier.v7` | Xiaomi Mi Air Purifier Pro V7 | `Zhimi Air Purifier V7` |
| `miIo/zhimi-air-purifier-m1` | `zhimi.airpurifier.m1` | Xiaomi Mi Air Purifier 2 Mini | `Zhimi Air Purifier M1` |
| `miIo/zhimi-air-purifier-m2` | `zhimi.airpurifier.m2` | Xiaomi Air Purifier 2 | `Zhimi Air Purifier M2` |
| `miIo/zhimi-air-purifier-ma1` | `zhimi.airpurifier.ma1` | Xiaomi Air Purifier 2S | `Zhimi Air Purifier MA1` |
| `miIo/zhimi-air-purifier-ma2` | `zhimi.airpurifier.ma2` | Xiaomi Air Purifier 2S | `Zhimi Air Purifier MA2` |
| `miIo/zhimi-air-purifier-sa1` | `zhimi.airpurifier.sa1` | Xiaomi Air Purifier S | `Zhimi Air Purifier SA1` |
| `miIo/zhimi-air-purifier-sa2` | `zhimi.airpurifier.sa2` | Xiaomi Air Purifier S2 | `Zhimi Air Purifier SA2` |
| `miIo/airdog-air-purifier-x3` | `airdog.airpurifier.x3` | Airdog Air Purifier X3 | `Airdog Air Purifier X3` |
| `miIo/airdog-air-purifier-x5` | `airdog.airpurifier.x5` | Airdog Air Purifier X5 | `Airdog Air Purifier X5` |
| `miIo/airdog-air-purifier-x7sm` | `airdog.airpurifier.x7sm` | Airdog Air Purifier X7sm | `Airdog Air Purifier X7sm` |

### miIO Humidifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/zhimi-humidifier-v1` | `zhimi.humidifier.v1` | Smartmi Evaporative Humidifier | `Zhimi Humidifier V1` |
| `miIo/zhimi-humidifier-ca1` | `zhimi.humidifier.ca1` | Smartmi Evaporative Humidifier 2 | `Zhimi Humidifier CA1` |
| `miIo/zhimi-humidifier-cb1` | `zhimi.humidifier.cb1` | Smartmi Air Humidifier 2 | `Zhimi Humidifier CB1` |
| `miIo/zhimi-humidifier-cb2` | `zhimi.humidifier.cb2` | Smartmi Air Humidifier 2 | `Zhimi Humidifier CB2` |
| `miIo/deerma-humidifier-mjjsq` | `deerma.humidifier.mjjsq` | Mi Smart Antibacterial Humidifier | `Deerma Humidifier MJJSQ` |
| `miIo/deerma-humidifier-jsq` | `deerma.humidifier.jsq` | Mi Smart Antibacterial Humidifier | `Deerma Humidifier JSQ` |
| `miIo/deerma-humidifier-jsq1` | `deerma.humidifier.jsq1` | Mi Smart Antibacterial Humidifier | `Deerma Humidifier JSQ1` |
| `miIo/shuii-humidifier-jsq002` | `shuii.humidifier.jsq002` | Shuii Humidifier JSQ002 | `Shuii Humidifier JSQ002` |

### miIO Dehumidifiers

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/nwt-dehumidifier-wdh318efw1` | `nwt.derh.wdh318efw1` | Xiaomi Widetech Dehumidifier | `Nwt Dehumidifier WDH318EFW1` |

### miIO Fans

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/zhimi-fan-sa1` | `zhimi.fan.sa1` | Zhimi Fan SA1 | `Zhimi Fan SA1` |
| `miIo/zhimi-fan-za1` | `zhimi.fan.za1` | Smartmi Inverter Pedestal Fan | `Zhimi Fan ZA1` |
| `miIo/zhimi-fan-za3` | `zhimi.fan.za3` | Smartmi Pedestal Fan ZA3 | `Zhimi Fan ZA3` |
| `miIo/zhimi-fan-za4` | `zhimi.fan.za4` | Smartmi Standing Fan 2S | `Smartmi Standing Fan 2S` |
| `miIo/zhimi-fan-v3` | `zhimi.fan.v3` | Smartmi Smart Wireless Fan 1st Gen (ZLBPLDS01ZM) | `Zhimi Fan V3` |
| `miIo/zhimi-fan-v2` | `zhimi.fan.v2` | Smartmi DC Pedestal Fan | `Zhimi Fan V2` |
| `miIo/dmaker-fan-p5` | `dmaker.fan.p5` | Mi Smart Standing Fan 1X | `Mi Smart Standing Fan 1X` |
| `miIo/air-fan-ca23ad9` | `air.fan.ca23ad9` | Airmate Fan CA23AD9 | `Airmate Fan CA23AD9` |

### miIO Air Conditioners

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/xiaomi-aircondition-ma4` | `xiaomi.aircondition.ma4` | Mijia Air Conditioner MA4 | `Mijia Air Conditioner MA4` |

### miIO Plugs and Lights

| Driver folder | Device model | Product name | SmartThings driver name |
|---------------|--------------|--------------|-------------------------|
| `miIo/chuangmi-plug-m1` | `chuangmi.plug.m1` | Xiaomi Smart WiFi Socket | `Chuangmi Plug M1` |
| `miIo/chuangmi-plug-m3` | `chuangmi.plug.m3` | Xiaomi Smart WiFi Socket | `Chuangmi Plug M3` |
| `miIo/chuangmi-plug-v2` | `chuangmi.plug.v2` | Xiaomi Smart WiFi Socket | `Chuangmi Plug V2` |
| `miIo/philips-sread1` | `philips.light.sread1` | Philips Smart Desk Lamp | `Philips Smart Desk Lamp` |
| `miIo/philips-sread2` | `philips.light.sread2` | Philips Smart Desk Lamp 2 | `Philips Smart Desk Lamp 2` |
| `miIo/yeelink-light-bslamp2` | `yeelink.light.bslamp2` | Mi Bedside Lamp 2 | `Mi Bedside Lamp 2` |
| `miIo/yeelink-light-color2` | `yeelink.light.color2` | Yeelight Color Bulb V2 | `Yeelight Color Bulb V2` |
| `miIo/yeelink-light-lamp1` | `yeelink.light.lamp1` | Xiaomi Mi Desk Lamp | `Xiaomi Mi Desk Lamp` |
| `miIo/yeelink-light-mono1` | `yeelink.light.mono1` | Yeelight Mono Bulb | `Yeelight Mono Bulb` |

Yeelight Color Bulb V2 supports the `statelessSwitchLevelStep` automation action for relative brightness changes. See its [mapping and profile update behavior](miIo/yeelink-light-color2/README.md).

## Libraries

| Library | Description |
|---------|-------------|
| `libs/miot.lua` | MIoT protocol implementation (get_properties / set_properties / action) |
| `libs/miio.lua` | miIO protocol implementation (get_prop / set_prop) |
| `libs/md5.lua` | MD5 implementation used for AES key derivation - extracted from [pure_lua_SHA](https://github.com/Egor-Skriptunoff/pure_lua_SHA) (MIT) |

## Related

[smartthings-tuya-edge-driver](https://github.com/wonjj6768/smartthings-tuya-edge-driver) - SmartThings Edge Drivers for Zigbee, LAN (Tuya/Xiaomi), and Matter devices.
