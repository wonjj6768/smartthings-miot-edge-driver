-- Leshow Humidifier JSQ3 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.leshowHumJsq3Mode"]
local targetHumidityCap = capabilities["concertmirror08464.leshowHumJsq3TargetHumidity"]
local waterLevelCap = capabilities["concertmirror08464.leshowHumJsq3WaterLevel"]
local buzzerCap = capabilities["concertmirror08464.leshowHumJsq3Buzzer"]
local screenCap = capabilities["concertmirror08464.leshowHumJsq3Screen"]
local screenBrightnessCap = capabilities["concertmirror08464.leshowHumJsq3ScreenBrightness"]
local heaterCap = capabilities["concertmirror08464.leshowHumJsq3Heater"]
local waterOverCap = capabilities["concertmirror08464.leshowHumJsq3WaterOver"]
local waterShortageCap = capabilities["concertmirror08464.leshowHumJsq3WaterShortage"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "leshow-humidifier-jsq3"
local EXPECTED_CAPABILITY_ID = "concertmirror08464.leshowHumJsq3Mode"

-- Exact model: leshow.humidifier.jsq3
-- specModel: leshow-jsq3
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:leshow-jsq3:2
-- Native MIoT local contract: get_properties / set_properties with the
-- exact siid/piid entries below. Read-only and writable flags follow the spec.

local FEATURES = {
    {
        name = "mode",
        cap = modeCap,
        attribute = "mode",
        siid = 2,
        piid = 3,
        writable = true,
        command = "setMode",
        raw_to_st = {[0] = "constantHumidity", [1] = "strong", [2] = "sleep", [3] = "dry", [4] = "wash"},
    },
    {
        name = "targetHumidity",
        cap = targetHumidityCap,
        attribute = "targetHumidity",
        siid = 2,
        piid = 6,
        writable = true,
        command = "setTargetHumidity",
        minimum = 40,
        maximum = 70,
        integer = true,
        unit = "%",
    },
    {
        name = "waterLevel",
        cap = waterLevelCap,
        attribute = "waterLevel",
        siid = 2,
        piid = 7,
        writable = false,
        minimum = 0,
        maximum = 100,
        integer = true,
        unit = "%",
    },
    {
        name = "buzzer",
        cap = buzzerCap,
        attribute = "buzzer",
        siid = 5,
        piid = 1,
        writable = true,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        name = "screen",
        cap = screenCap,
        attribute = "screen",
        siid = 10,
        piid = 1,
        writable = true,
        command = "setScreen",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        name = "screenBrightness",
        cap = screenBrightnessCap,
        attribute = "screenBrightness",
        siid = 10,
        piid = 2,
        writable = true,
        command = "setScreenBrightness",
        minimum = 0,
        maximum = 1,
        integer = true,
    },
    {
        name = "heater",
        cap = heaterCap,
        attribute = "heater",
        siid = 8,
        piid = 4,
        writable = true,
        command = "setHeater",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        name = "waterOver",
        cap = waterOverCap,
        attribute = "waterOver",
        siid = 12,
        piid = 5,
        writable = false,
        raw_to_st = {[false] = "normal", [true] = "detected"},
    },
    {
        name = "waterShortage",
        cap = waterShortageCap,
        attribute = "waterShortage",
        siid = 12,
        piid = 6,
        writable = false,
        raw_to_st = {[false] = "normal", [true] = "shortage"},
    },
}

for _, item in ipairs(FEATURES) do
    if item.raw_to_st then
        item.st_to_raw = {}
        for raw, mapped in pairs(item.raw_to_st) do
            item.st_to_raw[mapped] = raw
        end
    end
end

local PROPERTIES = {
    {kind = "switch", siid = 2, piid = 1},
    {kind = "humidity", siid = 3, piid = 1},
    {kind = "filter", siid = 11, piid = 3},
    {kind = "custom", siid = 2, piid = 3, feature = FEATURES[1]},
    {kind = "custom", siid = 2, piid = 6, feature = FEATURES[2]},
    {kind = "custom", siid = 2, piid = 7, feature = FEATURES[3]},
    {kind = "custom", siid = 5, piid = 1, feature = FEATURES[4]},
    {kind = "custom", siid = 10, piid = 1, feature = FEATURES[5]},
    {kind = "custom", siid = 10, piid = 2, feature = FEATURES[6]},
    {kind = "custom", siid = 8, piid = 4, feature = FEATURES[7]},
    {kind = "custom", siid = 12, piid = 5, feature = FEATURES[8]},
    {kind = "custom", siid = 12, piid = 6, feature = FEATURES[9]},
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function find_property(siid, piid)
    for _, property in ipairs(PROPERTIES) do
        if property.siid == siid and property.piid == piid then
            return property
        end
    end
    return nil
end

local function emit_custom(device, item, raw)
    local mapped = raw
    if item.raw_to_st then
        mapped = item.raw_to_st[raw]
        if mapped == nil then return end
    end
    if item.unit then
        device:emit_event(item.cap[item.attribute]({value = mapped, unit = item.unit}))
    else
        device:emit_event(item.cap[item.attribute]({value = mapped}))
    end
end

local function emit_property(device, property, value)
    if property.kind == "switch" then
        device:emit_event(capabilities.switch.switch(value and "on" or "off"))
    elseif property.kind == "temperature" then
        device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
    elseif property.kind == "humidity" then
        device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
    elseif property.kind == "setpoint" then
        device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value = value, unit = "C"}))
    elseif property.kind == "filter" then
        device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
    elseif property.kind == "oscillation" then
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(value and "horizontal" or "off"))
    elseif property.kind == "custom" then
        emit_custom(device, property.feature, value)
    end
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local request = {}
    for _, property in ipairs(PROPERTIES) do
        table.insert(request, {siid = property.siid, piid = property.piid})
    end
    local ok, response = pcall(miot.gets, device, ip, token, request)
    if not ok or not response or not response.result then return end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local property = find_property(result.siid, result.piid)
            if property then emit_property(device, property, result.value) end
        end
    end
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function()
        pcall(poll_device_status, device)
    end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

local function set_miot_property(device, property, value)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok = pcall(miot.set, device, ip, token, property.siid, property.piid, value)
    if ok then
        emit_property(device, property, value)
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function switch_on_handler(_, device, _)
    set_miot_property(device, find_property(2, 1), true)
end

local function switch_off_handler(_, device, _)
    set_miot_property(device, find_property(2, 1), false)
end

local function set_custom_handler(device, item, command)
    local requested = command.args[item.attribute]
    local raw = requested
    if item.st_to_raw then
        raw = item.st_to_raw[requested]
        if raw == nil then return end
    else
        raw = tonumber(requested)
        if raw == nil then return end
        if item.integer then raw = math.floor(raw + 0.5) end
        raw = clamp(raw, item.minimum, item.maximum)
    end
    set_miot_property(device, find_property(item.siid, item.piid), raw)
end


local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok = pcall(miot.action, device, ip, token, 11, 1, {})
    if ok then
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(EXPECTED_CAPABILITY_ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    pcall(poll_device_status, device)
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    stop_polling_timer(device)
    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        pcall(poll_device_status, device)
    end
end

local function device_removed(_, device)
    stop_polling_timer(device)
end

local function device_info_changed(driver, device, _, args)
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old = args.old_st_store.preferences
    local new = device.preferences
    if old.createDev == false and new.createDev == true then
        discovery.create_device(driver)
    end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            pcall(poll_device_status, device)
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

for _, item in ipairs(FEATURES) do
    if item.writable then
        local feature_item = item
        capability_handlers[item.cap.ID] = {
            [item.cap.commands[item.command].NAME] = function(_, device, command)
                set_custom_handler(device, feature_item, command)
            end
        }
    end
end

local edge_driver = Driver("miot-leshow-humidifier-jsq3", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = capability_handlers
})

edge_driver:run()
