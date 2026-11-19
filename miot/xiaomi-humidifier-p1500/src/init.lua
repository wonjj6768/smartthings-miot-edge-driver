-- Exact model: xiaomi.humidifier.p1500
-- Protocol evidence: user-assumed (2026-11-20); not LAN confirmed.
local capabilities = require "st.capabilities"
local discovery = require "discovery"
local runtime = require "miot_driver"

local cap1 = capabilities["concertmirror08464.xiaomiHumP1500Mode"]
local cap2 = capabilities["concertmirror08464.xiaomiHumP1500TargetHum"]
local cap3 = capabilities["concertmirror08464.xiaomiHumP1500Fault"]
local cap4 = capabilities["concertmirror08464.xiaomiHumP1500WaterLevel"]
local cap5 = capabilities["concertmirror08464.xiaomiHumP1500AutoDry"]
local cap6 = capabilities["concertmirror08464.xiaomiHumP1500Overwet"]
local cap7 = capabilities["concertmirror08464.xiaomiHumP1500Display"]
local cap8 = capabilities["concertmirror08464.xiaomiHumP1500DisplayLevel"]
local cap9 = capabilities["concertmirror08464.xiaomiHumP1500AutoScreenOff"]
local cap10 = capabilities["concertmirror08464.xiaomiHumP1500Buzzer"]
local cap11 = capabilities["concertmirror08464.xiaomiHumP1500ChildLock"]

local MODEL = "xiaomi.humidifier.p1500"
local PROFILE_NAME = "xiaomi-humidifier-p1500"

local PROPERTIES = {
    {cap = capabilities.switch, attribute = "switch", siid = 2, piid = 1,
        raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = cap1, attribute = "mode", siid = 2, piid = 3,
        command = "setMode",
        raw_to_st = {[0] = "constantHumidity", [1] = "sleep", [2] = "strong", [3] = "airDry"},
        st_to_raw = {["constantHumidity"] = 0, ["sleep"] = 1, ["strong"] = 2, ["airDry"] = 3}},
    {cap = cap2, attribute = "targetHumidity", siid = 2, piid = 5,
        command = "setTargetHumidity", unit = "%", minimum = 40, maximum = 70, step = 1},
    {cap = cap3, attribute = "fault", siid = 2, piid = 2,
        raw_to_st = {
            [0] = "normal",
            [1] = "motorFault",
            [2] = "pumpFault",
            [3] = "humidificationError",
            [4] = "lackWater",
            [5] = "lowWater",
        }},
    {cap = cap4, attribute = "waterLevel", siid = 2, piid = 6,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = cap5, attribute = "autoDry", siid = 2, piid = 9,
        command = "setAutoDry",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap6, attribute = "overwetProtection", siid = 2, piid = 11,
        command = "setOverwetProtection",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = capabilities.relativeHumidityMeasurement, attribute = "humidity", siid = 3, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = capabilities.temperatureMeasurement, attribute = "temperature", siid = 3, piid = 2,
        unit = "C", minimum = -30, maximum = 100, step = 1},
    {cap = capabilities.filterState, attribute = "filterLifeRemaining", siid = 4, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = cap7, attribute = "display", siid = 6, piid = 1,
        command = "setDisplay",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap8, attribute = "displayLevel", siid = 6, piid = 2,
        command = "setDisplayLevel",
        raw_to_st = {[0] = "dim", [1] = "normal"},
        st_to_raw = {["dim"] = 0, ["normal"] = 1}},
    {cap = cap9, attribute = "autoScreenOff", siid = 6, piid = 3,
        command = "setAutoScreenOff",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap10, attribute = "buzzer", siid = 7, piid = 1,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap11, attribute = "childLock", siid = 8, piid = 1,
        command = "setChildLock",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
}

local ACTIONS = {
    {cap = capabilities.filterState, command = "resetFilter", siid = 4, aiid = 1, component = "main"},
}

runtime.run({
    model = MODEL, profile = PROFILE_NAME,
    name = "miot-xiaomi-humidifier-p1500", discovery = discovery,
    properties = PROPERTIES, actions = ACTIONS
})
