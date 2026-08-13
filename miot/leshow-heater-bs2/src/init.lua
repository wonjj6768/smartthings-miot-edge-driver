-- Leshow Heater BS2 SmartThings Edge driver
-- Exact model: leshow.heater.bs2
-- specModel: leshow-bs2
-- URN: urn:miot-spec-v2:device:heater:0000A01A:leshow-bs2:1
-- Protocol evidence: exact MIOT_LOCAL_MODELS membership without MIIO_TO_MIOT_SPECS;
-- circumstantial native MIoT get_properties/set_properties path, user-approved.
--
-- MIoT mapping
--   Power: siid=2, piid=1, RW
--   Target temperature: siid=2, piid=3, RW, 18..28 C, step 1
--   Measured temperature: siid=4, piid=7, R
--   Relative humidity: siid=4, piid=8, R
--   Mode: siid=2, piid=5, RW [0=auto, 1=low]
--   Child lock: siid=5, piid=1, RW [boolean]
--   Buzzer: siid=6, piid=1, RW [boolean]
--   Indicator brightness: siid=10, piid=1, RW [0=off, 1=half, 2=full]

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local PROFILE_NAME = "leshow-heater-bs2"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local POWER_SIID = 2
local POWER_PIID = 1
local SETPOINT_SIID = 2
local SETPOINT_PIID = 3
local SETPOINT_MIN = 18
local SETPOINT_MAX = 28
local SETPOINT_STEP = 1
local TEMPERATURE_SIID = 4
local TEMPERATURE_PIID = 7
local HUMIDITY_SIID = 4
local HUMIDITY_PIID = 8

local FEATURES = {
    { capability = capabilities["concertmirror08464.leshowBs2Mode"], attribute = "mode", command = "setMode", siid = 2, piid = 5, kind = "enum", initial = 0, to_st = {[0] = "auto", [1] = "low"}, to_wire = {["auto"] = 0, ["low"] = 1} },
    { capability = capabilities["concertmirror08464.leshowBs2ChildLock"], attribute = "childLock", command = "setChildLock", siid = 5, piid = 1, kind = "bool", initial = false },
    { capability = capabilities["concertmirror08464.leshowBs2Buzzer"], attribute = "buzzer", command = "setBuzzer", siid = 6, piid = 1, kind = "bool", initial = false },
    { capability = capabilities["concertmirror08464.leshowBs2IndicatorBrightness"], attribute = "indicatorBrightness", command = "setIndicatorBrightness", siid = 10, piid = 1, kind = "enum", initial = 1, to_st = {[0] = "off", [1] = "half", [2] = "full"}, to_wire = {["off"] = 0, ["half"] = 1, ["full"] = 2} }
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end

local function clamp_step(value, minimum, maximum, step)
    value = math.max(minimum, math.min(maximum, value))
    return minimum + math.floor(((value - minimum) / step) + 0.5) * step
end

local function emit_feature(device, feature, wire_value)
    local value = wire_value
    if feature.kind == "bool" then value = wire_value and "on" or "off"
    elseif feature.to_st then value = feature.to_st[wire_value] end
    if value == nil then return end
    if feature.unit then
        device:emit_event(feature.capability[feature.attribute]({value = value, unit = feature.unit}))
    else
        device:emit_event(feature.capability[feature.attribute]({value = value}))
    end
end

local function emit_setpoint_range(device)
    device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
        value = {minimum = SETPOINT_MIN, maximum = SETPOINT_MAX, step = SETPOINT_STEP},
        unit = "C"
    }))
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local properties = {
        {siid = POWER_SIID, piid = POWER_PIID},
        {siid = SETPOINT_SIID, piid = SETPOINT_PIID}
    }
    if TEMPERATURE_SIID then table.insert(properties, {siid = TEMPERATURE_SIID, piid = TEMPERATURE_PIID}) end
    if HUMIDITY_SIID then table.insert(properties, {siid = HUMIDITY_SIID, piid = HUMIDITY_PIID}) end
    for _, feature in ipairs(FEATURES) do table.insert(properties, {siid = feature.siid, piid = feature.piid}) end

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            if result.siid == POWER_SIID and result.piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(result.value and "on" or "off"))
            elseif result.siid == SETPOINT_SIID and result.piid == SETPOINT_PIID then
                device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value = result.value, unit = "C"}))
            elseif TEMPERATURE_SIID and result.siid == TEMPERATURE_SIID and result.piid == TEMPERATURE_PIID then
                device:emit_event(capabilities.temperatureMeasurement.temperature({value = result.value, unit = "C"}))
            elseif HUMIDITY_SIID and result.siid == HUMIDITY_SIID and result.piid == HUMIDITY_PIID then
                device:emit_event(capabilities.relativeHumidityMeasurement.humidity(result.value))
            end
            for _, feature in ipairs(FEATURES) do
                if result.siid == feature.siid and result.piid == feature.piid then emit_feature(device, feature, result.value) end
            end
        end
    end
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function() pcall(poll_device_status, device) end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then device.thread:cancel_timer(timer); device:set_field(POLLING_TIMER, nil) end
end

local function set_power(device, value)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok = pcall(miot.set, device, ip, token, POWER_SIID, POWER_PIID, value)
    if ok then
        device:emit_event(capabilities.switch.switch(value and "on" or "off"))
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function set_setpoint(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    local value = clamp_step(tonumber(command.args.setpoint), SETPOINT_MIN, SETPOINT_MAX, SETPOINT_STEP)
    local ok = pcall(miot.set, device, ip, token, SETPOINT_SIID, SETPOINT_PIID, value)
    if ok then device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value = value, unit = "C"})) end
end

local function custom_handler(feature)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end
        local requested = command.args[feature.attribute]
        local wire_value = requested
        if feature.kind == "bool" then wire_value = requested == "on"
        elseif feature.to_wire then wire_value = feature.to_wire[requested]
        else
            wire_value = tonumber(requested)
            if wire_value then wire_value = clamp_step(wire_value, feature.minimum, feature.maximum, feature.step) end
        end
        if wire_value == nil then return end

        local ok = pcall(miot.set, device, ip, token, feature.siid, feature.piid, wire_value)
        if ok then
            emit_feature(device, feature, wire_value)
            device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
        end
    end
end

local capability_handlers = {
    [capabilities.switch.ID] = {
        [capabilities.switch.commands.on.NAME] = function(_, device, _) set_power(device, true) end,
        [capabilities.switch.commands.off.NAME] = function(_, device, _) set_power(device, false) end
    },
    [capabilities.thermostatHeatingSetpoint.ID] = {
        [capabilities.thermostatHeatingSetpoint.commands.setHeatingSetpoint.NAME] = set_setpoint
    },
    [capabilities.refresh.ID] = {
        [capabilities.refresh.commands.refresh.NAME] = function(_, device, _) emit_setpoint_range(device); pcall(poll_device_status, device) end
    }
}

for _, item in ipairs(FEATURES) do
    local feature = item
    capability_handlers[feature.capability.ID] = {
        [feature.capability.commands[feature.command].NAME] = custom_handler(feature)
    }
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(FEATURES[1].capability.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value = SETPOINT_MIN, unit = "C"}))
    emit_setpoint_range(device)
    if TEMPERATURE_SIID then device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"})) end
    if HUMIDITY_SIID then device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0)) end
    for _, feature in ipairs(FEATURES) do emit_feature(device, feature, feature.initial) end
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    emit_setpoint_range(device)
    local ip = get_device_config(device)
    if ip then start_polling_timer(device); pcall(poll_device_status, device) end
end

local function device_removed(_, device) stop_polling_timer(device) end

local function device_info_changed(driver, device, _, args)
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old = args.old_st_store.preferences
    local new = device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then start_polling_timer(device); pcall(poll_device_status, device) end
    end
end

local driver = Driver("miot-leshow-heater-bs2", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_added, init = device_init, removed = device_removed, infoChanged = device_info_changed},
    capability_handlers = capability_handlers
})

driver:run()
