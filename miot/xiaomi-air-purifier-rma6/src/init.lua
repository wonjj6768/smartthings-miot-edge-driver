-- Exact model: xiaomi.airp.rma6
-- Protocol evidence: user-assumed (2026-11-20); not LAN confirmed.
local capabilities = require "st.capabilities"
local discovery = require "discovery"
local runtime = require "miot_driver"

local cap1 = capabilities["concertmirror08464.xiaomiAirRma6Mode"]
local cap2 = capabilities["concertmirror08464.xiaomiAirRma6FanLevel"]
local cap3 = capabilities["concertmirror08464.xiaomiAirRma6FavoriteLevel"]
local cap4 = capabilities["concertmirror08464.xiaomiAirRma6Uv"]
local cap5 = capabilities["concertmirror08464.xiaomiAirRma6AirQuality"]
local cap6 = capabilities["concertmirror08464.xiaomiAirRma6Display"]
local cap7 = capabilities["concertmirror08464.xiaomiAirRma6DisplayLevel"]
local cap8 = capabilities["concertmirror08464.xiaomiAirRma6Buzzer"]
local cap9 = capabilities["concertmirror08464.xiaomiAirRma6ChildLock"]

local MODEL = "xiaomi.airp.rma6"
local PROFILE_NAME = "xiaomi-air-purifier-rma6"

local PROPERTIES = {
    {cap = capabilities.switch, attribute = "switch", siid = 2, piid = 1,
        raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = cap1, attribute = "mode", siid = 2, piid = 3,
        command = "setMode",
        raw_to_st = {[0] = "auto", [3] = "sleep", [5] = "favorite", [6] = "unspecified"},
        st_to_raw = {["auto"] = 0, ["sleep"] = 3, ["favorite"] = 5}},
    {cap = cap2, attribute = "fanLevel", siid = 2, piid = 4,
        command = "setFanLevel",
        raw_to_st = {[0] = "levelOne", [1] = "levelTwo", [2] = "levelThree"},
        st_to_raw = {["levelOne"] = 0, ["levelTwo"] = 1, ["levelThree"] = 2}},
    {cap = cap3, attribute = "favoriteLevel", siid = 9, piid = 1,
        command = "setFavoriteLevel", minimum = 0, maximum = 9, step = 1},
    {cap = cap4, attribute = "uv", siid = 2, piid = 6,
        command = "setUv",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = capabilities.relativeHumidityMeasurement, attribute = "humidity", siid = 3, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = capabilities.temperatureMeasurement, attribute = "temperature", siid = 3, piid = 2,
        unit = "C", minimum = -30, maximum = 100, step = 0.1},
    {cap = capabilities.dustSensor, attribute = "fineDustLevel", siid = 3, piid = 4,
        unit = "μg/m^3", minimum = 0, maximum = 600, step = 1},
    {cap = capabilities.formaldehydeMeasurement, attribute = "formaldehydeLevel", siid = 3, piid = 6,
        unit = "mg/m^3", minimum = 0, maximum = 1, step = 0.001},
    {cap = cap5, attribute = "airQuality", siid = 3, piid = 3,
        raw_to_st = {
            [0] = "excellent",
            [1] = "good",
            [2] = "moderate",
            [3] = "hazardous",
            [4] = "hazardous",
            [5] = "hazardous",
        }},
    {cap = capabilities.filterState, attribute = "filterLifeRemaining", siid = 4, piid = 1,
        unit = "%", minimum = 0, maximum = 100, step = 1},
    {cap = cap6, attribute = "display", siid = 6, piid = 1,
        command = "setDisplay",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap7, attribute = "displayLevel", siid = 6, piid = 2,
        command = "setDisplayLevel",
        raw_to_st = {[0] = "dim", [1] = "normal", [2] = "medium"},
        st_to_raw = {["dim"] = 0, ["normal"] = 1, ["medium"] = 2}},
    {cap = cap8, attribute = "buzzer", siid = 7, piid = 1,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
    {cap = cap9, attribute = "childLock", siid = 8, piid = 1,
        command = "setChildLock",
        raw_to_st = {[false] = "off", [true] = "on"},
        st_to_raw = {["off"] = false, ["on"] = true}},
}

local ACTIONS = {
    {cap = capabilities.filterState, command = "resetFilter", siid = 4, aiid = 1, component = "main"},
}

runtime.run({
    model = MODEL, profile = PROFILE_NAME,
    name = "miot-xiaomi-airp-rma6", discovery = discovery,
    properties = PROPERTIES, actions = ACTIONS
})
