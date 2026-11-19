-- Exact model: xiaomi.humidifier.jsq2g
-- Protocol evidence: user-assumed (2026-11-20); not LAN confirmed.
local capabilities = require "st.capabilities"
local discovery = require "discovery"
local runtime = require "miot_driver"

local cap1 = capabilities["concertmirror08464.xiaomiHumJsq2gMode"]
local cap2 = capabilities["concertmirror08464.xiaomiHumJsq2gTargetHum"]
local cap3 = capabilities["concertmirror08464.xiaomiHumJsq2gFanLevel"]
local cap4 = capabilities["concertmirror08464.xiaomiHumJsq2gWaterStatus"]
local cap5 = capabilities["concertmirror08464.xiaomiHumJsq2gDisplay"]
local cap6 = capabilities["concertmirror08464.xiaomiHumJsq2gBuzzer"]
local cap7 = capabilities["concertmirror08464.xiaomiHumJsq2gOverwet"]
local cap8 = capabilities["concertmirror08464.xiaomiHumJsq2gConstantProtect"]

local MODEL = "xiaomi.humidifier.jsq2g"
local PROFILE_NAME = "xiaomi-humidifier-jsq2g"

local PROPERTIES = {
    {cap = capabilities.switch, attribute = "switch", siid = 2, piid = 1,
        raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = cap1, attribute = "mode", siid = 2, piid = 8,
        command = "setMode",
        raw_to_st = {[0] = "constantHumidity", [3] = "level"},
        st_to_raw = {["constantHumidity"] = 0, ["level"] = 3}},
    {cap = cap2, attribute = "targetHumidity", siid = 2, piid = 6,
        command = "setTargetHumidity", unit = "%", minimum = 40, maximum = 70, step = 1},
    {cap = cap3, attribute = "fanLevel", siid = 2, piid = 5,
        command = "setFanLevel",
        raw_to_st = {[0] = "levelOne", [1] = "levelTwo", [2] = "levelThree", [4] = "constantHumidity"},
        st_to_raw = {["levelOne"] = 0, ["levelTwo"] = 1, ["levelThree"] = 2, ["constantHumidity"] = 4}},
    {cap = cap4, attribute = "waterStatus", siid = 2, piid = 2,
        raw_to_st = {[0] = "normal", [1] = "lowWater", [2] = "tankRemoved"}},
    {cap = capabilities.relativeHumidityMeasurement, attribute = "humidity", siid = 3, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = capabilities.temperatureMeasurement, attribute = "temperature", siid = 3, piid = 7,
        unit = "C", minimum = -30, maximum = 100, step = 1},
    {cap = cap5, attribute = "display", siid = 5, piid = 1,
        command = "setDisplay",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap6, attribute = "buzzer", siid = 6, piid = 1,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap7, attribute = "overwetProtection", siid = 7, piid = 6,
        command = "setOverwetProtection",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap8, attribute = "constantProtection", siid = 7, piid = 8,
        command = "setConstantProtection",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
}

local ACTIONS = {
}

runtime.run({
    model = MODEL, profile = PROFILE_NAME,
    name = "miot-xiaomi-humidifier-jsq2g", discovery = discovery,
    properties = PROPERTIES, actions = ACTIONS
})
