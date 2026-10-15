-- Mijia Smart Air Purifier Max: exact model xiaomi.airp.mb6.
-- Protocol basis: openHAB PR #21935 exact-model local get_properties /
-- set_properties mapping. Upstream marks it experimental, without hardware confirmation.
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mb6:1:0000D050

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.xiaomiAirMb6Mode"]
local fanLevelCap = capabilities["concertmirror08464.xiaomiAirMb6FanLevel"]
local favoriteCap = capabilities["concertmirror08464.xiaomiAirMb6FavoriteFanLevel"]
local uvCap = capabilities["concertmirror08464.xiaomiAirMb6Uv"]
local airQualityCap = capabilities["concertmirror08464.xiaomiAirMb6AirQuality"]
local displayCap = capabilities["concertmirror08464.xiaomiAirMb6Display"]
local displayLevelCap = capabilities["concertmirror08464.xiaomiAirMb6DisplayLevel"]
local buzzerCap = capabilities["concertmirror08464.xiaomiAirMb6Buzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiAirMb6ChildLock"]

local MODEL = "xiaomi.airp.mb6"
local PROFILE_NAME = "xiaomi-air-purifier-mb6"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local FILTER_SIID = 4
local RESET_FILTER_AIID = 1

-- Exact MIoT mapping (siid/piid):
-- 2/1 power bool RW; 2/3 mode RW (0 auto, 3 sleep, 5 favorite, 6 level);
-- 2/4 fan level RW (0..2); 2/6 UV bool RW.
-- 3/1 humidity R (0..100 %); 3/2 temperature R (-30..100 C, step 0.1);
-- 3/3 air quality R (0..5); 3/4 PM2.5 R (0..600 ug/m^3, step 1);
-- 3/5 PM10 R (0..100 ug/m^3, step 1); 3/6 HCHO R (0..1 mg/m^3, step 0.001);
-- 3/9 PM1 R (0..1000 ug/m^3, step 1); 4/1 filter life R (0..100 %).
-- 6/1 display bool RW; 6/2 brightness RW (0 dim, 1 normal, 2 medium);
-- 7/1 buzzer bool RW; 8/1 child lock bool RW; 9/1 favorite fan level RW (0..10, step 1).
-- Action: siid=4, aiid=1 reset-filter-life, no inputs or outputs.

local MODE_TO_ST = {[0] = "auto", [3] = "sleep", [5] = "favorite", [6] = "level"}
local ST_TO_MODE = {auto = 0, sleep = 3, favorite = 5, level = 6}
local FAN_LEVEL_TO_ST = {[0] = "level1", [1] = "level2", [2] = "level3"}
local ST_TO_FAN_LEVEL = {level1 = 0, level2 = 1, level3 = 2}
local DISPLAY_LEVEL_TO_ST = {[0] = "dim", [1] = "normal", [2] = "medium"}
local ST_TO_DISPLAY_LEVEL = {dim = 0, normal = 1, medium = 2}
local BOOL_TO_ST = {[false] = "off", [true] = "on"}
local ST_TO_BOOL = {off = false, on = true}
local AIR_QUALITY_TO_ST = {
    [0] = "excellent", [1] = "good", [2] = "moderate",
    [3] = "poor", [4] = "heavyPollution", [5] = "hazardous"
}

local FEATURES = {
    {cap = modeCap, attribute = "mode", command = "setMode", siid = 2, piid = 3,
        raw_to_st = MODE_TO_ST, st_to_raw = ST_TO_MODE},
    {cap = fanLevelCap, attribute = "fanLevel", command = "setFanLevel", siid = 2, piid = 4,
        raw_to_st = FAN_LEVEL_TO_ST, st_to_raw = ST_TO_FAN_LEVEL},
    {cap = favoriteCap, attribute = "favoriteFanLevel", command = "setFavoriteFanLevel", siid = 9, piid = 1,
        minimum = 0, maximum = 10},
    {cap = uvCap, attribute = "uv", command = "setUv", siid = 2, piid = 6,
        raw_to_st = BOOL_TO_ST, st_to_raw = ST_TO_BOOL},
    {cap = airQualityCap, attribute = "airQuality", siid = 3, piid = 3, raw_to_st = AIR_QUALITY_TO_ST},
    {cap = displayCap, attribute = "display", command = "setDisplay", siid = 6, piid = 1,
        raw_to_st = BOOL_TO_ST, st_to_raw = ST_TO_BOOL},
    {cap = displayLevelCap, attribute = "displayLevel", command = "setDisplayLevel", siid = 6, piid = 2,
        raw_to_st = DISPLAY_LEVEL_TO_ST, st_to_raw = ST_TO_DISPLAY_LEVEL},
    {cap = buzzerCap, attribute = "buzzer", command = "setBuzzer", siid = 7, piid = 1,
        raw_to_st = BOOL_TO_ST, st_to_raw = ST_TO_BOOL},
    {cap = childLockCap, attribute = "childLock", command = "setChildLock", siid = 8, piid = 1,
        raw_to_st = BOOL_TO_ST, st_to_raw = ST_TO_BOOL}
}

local PROPERTIES = {
    {cap = capabilities.switch, attribute = "switch", siid = 2, piid = 1, raw_to_st = BOOL_TO_ST},
    {cap = capabilities.relativeHumidityMeasurement, attribute = "humidity", siid = 3, piid = 1, unit = "%"},
    {cap = capabilities.temperatureMeasurement, attribute = "temperature", siid = 3, piid = 2, unit = "C"},
    {cap = capabilities.dustSensor, attribute = "fineDustLevel", siid = 3, piid = 4, unit = "μg/m^3"},
    {cap = capabilities.dustSensor, attribute = "dustLevel", siid = 3, piid = 5, unit = "μg/m^3"},
    {cap = capabilities.formaldehydeMeasurement, attribute = "formaldehydeLevel",
        siid = 3, piid = 6, unit = "mg/m^3"},
    {cap = capabilities.veryFineDustSensor, attribute = "veryFineDustLevel", siid = 3, piid = 9, unit = "μg/m^3"},
    {cap = capabilities.filterState, attribute = "filterLifeRemaining", siid = 4, piid = 1, unit = "%"}
}
for _, feature in ipairs(FEATURES) do
    table.insert(PROPERTIES, feature)
end

local EXPECTED_CAPABILITY_IDS = {
    capabilities.switch.ID, capabilities.relativeHumidityMeasurement.ID, capabilities.temperatureMeasurement.ID,
    capabilities.dustSensor.ID, capabilities.formaldehydeMeasurement.ID, capabilities.veryFineDustSensor.ID,
    capabilities.filterState.ID, capabilities.refresh.ID
}
for _, feature in ipairs(FEATURES) do
    table.insert(EXPECTED_CAPABILITY_IDS, feature.cap.ID)
end

local function get_device_config(device)
    local ip, token = device.preferences.ipAddress, device.preferences.token
    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function emit_supported_filter_commands(device)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    -- The exact openHAB mapping sets maxProperties=1. Keep each local read to one property.
    for _, property in ipairs(PROPERTIES) do
        local context = string.format("%s get_properties siid=%d piid=%d", MODEL, property.siid, property.piid)
        local ok, response = pcall(miot.get, device, ip, token, property.siid, property.piid)
        if not ok then
            device.log.error(context .. " failed: " .. tostring(response))
            return
        end
        if not response or type(response.result) ~= "table" then
            local err = response and response.error
            local reason = err and (tostring(err.code) .. ": " .. tostring(err.message)) or "missing result"
            device.log.error(context .. " failed: " .. reason)
            return
        end

        local result = response.result[1]
        if not result or result.code ~= 0 or result.value == nil then
            device.log.error(context .. " failed: code=" .. tostring(result and result.code))
        else
            local value = result.value
            if property.raw_to_st then
                value = property.raw_to_st[value]
            elseif type(value) ~= "number" then
                value = nil
            end
            if value == nil then
                device.log.error(context .. " returned unsupported value: " .. tostring(result.value))
            else
                device:emit_event(property.cap[property.attribute]({value = value, unit = property.unit}))
            end
        end
    end
end

local function schedule_status_refresh(device)
    device.thread:call_with_delay(1, function()
        if device:supports_capability_by_id(capabilities.filterState.ID, "main") then
            emit_supported_filter_commands(device)
        end
        poll_device_status(device)
    end)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    device:set_field(POLLING_TIMER, device.thread:call_on_schedule(interval, function()
        poll_device_status(device)
    end, "Polling"))
end

local function set_property(device, siid, piid, value)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok, err = pcall(miot.set, device, ip, token, siid, piid, value)
    if not ok then
        device.log.error(string.format("%s set_properties siid=%d piid=%d failed: %s", MODEL, siid, piid, err))
        return
    end
    schedule_status_refresh(device)
end

local function switch_on_handler(_, device)
    set_property(device, 2, 1, true)
end

local function switch_off_handler(_, device)
    set_property(device, 2, 1, false)
end

local function make_feature_handler(feature)
    return function(_, device, command)
        local value = command.args[feature.attribute]
        if feature.st_to_raw then
            value = feature.st_to_raw[value]
        elseif type(value) ~= "number" or value % 1 ~= 0 or value < feature.minimum or value > feature.maximum then
            value = nil
        end
        if value == nil then
            device.log.error(MODEL .. " " .. feature.command .. " received an unsupported value")
            return
        end
        set_property(device, feature.siid, feature.piid, value)
    end
end

local function reset_filter_handler(_, device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok, err = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_AIID, {})
    if not ok then
        device.log.error(string.format("%s action siid=%d aiid=%d failed: %s", MODEL, FILTER_SIID,
            RESET_FILTER_AIID, err))
        return
    end
    schedule_status_refresh(device)
end

local function ensure_profile(device)
    for _, capability_id in ipairs(EXPECTED_CAPABILITY_IDS) do
        if not device:supports_capability_by_id(capability_id, "main") then
            device:try_update_metadata({profile = PROFILE_NAME})
            return true
        end
    end
    return false
end

local function refresh_handler(_, device)
    if ensure_profile(device) then
        schedule_status_refresh(device)
        return
    end
    emit_supported_filter_commands(device)
    poll_device_status(device)
end

local function device_added(driver, device)
    refresh_handler(driver, device)
end

local function device_init(_, device)
    local profile_updated = ensure_profile(device)
    device:online()
    stop_polling_timer(device)
    if not profile_updated then emit_supported_filter_commands(device) end
    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        if profile_updated then
            schedule_status_refresh(device)
        else
            poll_device_status(device)
        end
    end
end

local function device_removed(_, device)
    stop_polling_timer(device)
end

local function device_info_changed(driver, device, _, args)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old, new = args.old_st_store.preferences, device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            refresh_handler(driver, device)
        end
    end
end

local capability_handlers = {
    [capabilities.switch.ID] = {
        [capabilities.switch.commands.on.NAME] = switch_on_handler,
        [capabilities.switch.commands.off.NAME] = switch_off_handler
    },
    [capabilities.filterState.ID] = {
        [capabilities.filterState.commands.resetFilter.NAME] = reset_filter_handler
    },
    [capabilities.refresh.ID] = {
        [capabilities.refresh.commands.refresh.NAME] = refresh_handler
    }
}
for _, feature in ipairs(FEATURES) do
    if feature.command then
        capability_handlers[feature.cap.ID] = {
            [feature.cap.commands[feature.command].NAME] = make_feature_handler(feature)
        }
    end
end

local driver = Driver("miot-xiaomi-airp-mb6", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added, init = device_init, driverSwitched = device_init,
        removed = device_removed, infoChanged = device_info_changed
    },
    capability_handlers = capability_handlers
})
driver:run()
