-- Exact model: xiaomi.humidifier.ha2
-- Protocol evidence: user-assumed (2026-11-20); not LAN confirmed.
local capabilities = require "st.capabilities"
local discovery = require "discovery"
local runtime = require "miot_driver"

local cap1 = capabilities["concertmirror08464.xiaomiHumHa2Mode"]
local cap2 = capabilities["concertmirror08464.xiaomiHumHa2TargetHum"]
local cap3 = capabilities["concertmirror08464.xiaomiHumHa2HumFanLevel"]
local cap4 = capabilities["concertmirror08464.xiaomiHumHa2WaterLevel"]
local cap5 = capabilities["concertmirror08464.xiaomiHumHa2AutoDry"]
local cap6 = capabilities["concertmirror08464.xiaomiHumHa2Overwet"]
local cap7 = capabilities["concertmirror08464.xiaomiHumHa2CoarseDust"]
local cap8 = capabilities["concertmirror08464.xiaomiHumHa2AirQuality"]
local cap9 = capabilities["concertmirror08464.xiaomiHumHa2Display"]
local cap10 = capabilities["concertmirror08464.xiaomiHumHa2DisplayLevel"]
local cap11 = capabilities["concertmirror08464.xiaomiHumHa2Buzzer"]
local cap12 = capabilities["concertmirror08464.xiaomiHumHa2ChildLock"]
local cap13 = capabilities["concertmirror08464.xiaomiHumHa2PurifierMode"]
local cap14 = capabilities["concertmirror08464.xiaomiHumHa2PurifierFan"]
local cap15 = capabilities["concertmirror08464.xiaomiHumHa2FavoriteLevel"]
local cap16 = capabilities["concertmirror08464.xiaomiHumHa2HumFavorite"]
local cap17 = capabilities["concertmirror08464.xiaomiHumHa2Function"]
local cap18 = capabilities["concertmirror08464.xiaomiHumHa2TankStatus"]
local cap19 = capabilities["concertmirror08464.xiaomiHumHa2CleanTank"]

local MODEL = "xiaomi.humidifier.ha2"
local PROFILE_NAME = "xiaomi-humidifier-ha2"

local PROPERTIES = {
    {cap = capabilities.switch, attribute = "switch", siid = 2, piid = 1,
        raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = cap1, attribute = "mode", siid = 2, piid = 3,
        command = "setMode",
        raw_to_st = {[0] = "constantHumidity", [1] = "sleep", [2] = "favorite", [3] = "unspecified"},
        st_to_raw = {["constantHumidity"] = 0, ["sleep"] = 1, ["favorite"] = 2}},
    {cap = cap2, attribute = "targetHumidity", siid = 2, piid = 6,
        command = "setTargetHumidity", unit = "%", minimum = 40, maximum = 70, step = 1},
    {cap = cap3, attribute = "fanLevel", siid = 2, piid = 14,
        command = "setFanLevel",
        raw_to_st = {[0] = "levelOne", [1] = "levelTwo", [2] = "levelThree"},
        st_to_raw = {["levelOne"] = 0, ["levelTwo"] = 1, ["levelThree"] = 2}},
    {cap = cap4, attribute = "waterLevel", siid = 2, piid = 7,
        unit = "%", minimum = 0, maximum = 100, step = 5},
    {cap = cap5, attribute = "autoDry", siid = 2, piid = 11,
        command = "setAutoDry",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap6, attribute = "overwetProtection", siid = 2, piid = 10,
        command = "setOverwetProtection",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = capabilities.relativeHumidityMeasurement, attribute = "humidity", siid = 3, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = capabilities.temperatureMeasurement, attribute = "temperature", siid = 3, piid = 7,
        unit = "C", minimum = -30, maximum = 100, step = 0.1},
    {cap = capabilities.dustSensor, attribute = "fineDustLevel", siid = 3, piid = 4,
        unit = "μg/m^3", minimum = 0, maximum = 600, step = 1},
    {cap = cap7, attribute = "coarseDust", siid = 3, piid = 5,
        minimum = 0, maximum = 100, step = 1},
    {cap = capabilities.veryFineDustSensor, attribute = "veryFineDustLevel", siid = 3, piid = 6,
        unit = "μg/m^3", minimum = 0, maximum = 600, step = 1},
    {cap = cap8, attribute = "airQuality", siid = 3, piid = 3,
        raw_to_st = {
            [0] = "excellent",
            [1] = "good",
            [2] = "moderate",
            [3] = "poor",
            [4] = "heavyPollution",
            [5] = "hazardous",
        }},
    {cap = capabilities.filterState, attribute = "filterLifeRemaining", siid = 4, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = cap9, attribute = "display", siid = 5, piid = 1,
        command = "setDisplay",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap10, attribute = "displayLevel", siid = 5, piid = 2,
        command = "setDisplayLevel",
        raw_to_st = {[0] = "auto", [1] = "normal", [2] = "medium", [3] = "dim"},
        st_to_raw = {["auto"] = 0, ["normal"] = 1, ["medium"] = 2, ["dim"] = 3}},
    {cap = cap11, attribute = "buzzer", siid = 6, piid = 1,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap12, attribute = "childLock", siid = 7, piid = 1,
        command = "setChildLock",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap13, attribute = "purifierMode", siid = 11, piid = 4,
        command = "setPurifierMode",
        raw_to_st = {[0] = "auto", [1] = "sleep", [2] = "favorite", [3] = "unspecified"},
        st_to_raw = {["auto"] = 0, ["sleep"] = 1, ["favorite"] = 2}},
    {cap = cap14, attribute = "purifierFan", siid = 11, piid = 3,
        command = "setPurifierFan",
        raw_to_st = {[0] = "levelOne", [1] = "levelTwo", [2] = "levelThree"},
        st_to_raw = {["levelOne"] = 0, ["levelTwo"] = 1, ["levelThree"] = 2}},
    {cap = cap15, attribute = "favoriteLevel", siid = 10, piid = 1,
        command = "setFavoriteLevel", minimum = 0, maximum = 9, step = 1},
    {cap = cap16, attribute = "humFavorite", siid = 9, piid = 10,
        command = "setHumFavorite", minimum = 0, maximum = 9, step = 1},
    {cap = cap17, attribute = "function", siid = 9, piid = 5,
        command = "setFunction",
        raw_to_st = {[0] = "airPurifier", [1] = "humidifier"},
        st_to_raw = {["airPurifier"] = 0, ["humidifier"] = 1}},
    {cap = cap18, attribute = "tankStatus", siid = 9, piid = 11,
        raw_to_st = {[-2] = "missing", [-1] = "lackWater", [0] = "normal", [1] = "full"}},
    {cap = cap19, attribute = "cleanTank", siid = 9, piid = 12,
        raw_to_st = {[-1] = "low", [0] = "normal"}},
    {cap = capabilities.filterState, attribute = "filterLifeRemaining", siid = 15, piid = 1,
        component = "humidifierFilter",
        unit = "%", minimum = 0, maximum = 100, step = 1},
}

local ACTIONS = {
    {cap = capabilities.filterState, command = "resetFilter", siid = 4, aiid = 1, component = "main"},
    {cap = capabilities.filterState, command = "resetFilter", siid = 15, aiid = 1, component = "humidifierFilter"},
}

runtime.run({
    model = MODEL, profile = PROFILE_NAME,
    name = "miot-xiaomi-humidifier-ha2", discovery = discovery,
    properties = PROPERTIES, actions = ACTIONS
})
