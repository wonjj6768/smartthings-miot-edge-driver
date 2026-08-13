-- Kadeer Dehumidifier X1701 SmartThings Edge driver
-- Exact model: kadeer.derh.x1701
-- specModel: kadeer-x1701
-- URN: urn:miot-spec-v2:device:dehumidifier:0000A02D:kadeer-x1701:1
-- Protocol evidence: exact MIOT_LOCAL_MODELS membership without MIIO_TO_MIOT_SPECS;
-- circumstantial native MIoT get_properties/set_properties path, user-approved.
--
-- MIoT mapping
--   Power: siid=2, piid=1, RW
--   Relative humidity: siid=3, piid=7, R
--   Mode: siid=2, piid=3, RW [0=airy, 1=ordinary, 2=clothesDrying]
--   Target humidity: siid=2, piid=4, RW [30=h30, 35=h35, 40=h40, 45=h45, 50=h50, 55=h55, 60=h60, 65=h65, 70=h70, 75=h75, 80=h80]
--   Fan level: siid=3, piid=6, RW [0=low, 1=high]
--   Tank status: siid=3, piid=3, R [0=normal, 1=full]

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local PROFILE_NAME = "kadeer-dehumidifier-x1701"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local POWER_SIID = 2
local POWER_PIID = 1
local HUMIDITY_SIID = 3
local HUMIDITY_PIID = 7
local TEMPERATURE_SIID = nil
local TEMPERATURE_PIID = nil

local FEATURES = {
    { capability = capabilities["concertmirror08464.kadeerX1701Mode"], attribute = "mode", siid = 2, piid = 3, kind = "enum", initial = 1, command = "setMode", to_st = {[0] = "airy", [1] = "ordinary", [2] = "clothesDrying"}, to_wire = {["airy"] = 0, ["ordinary"] = 1, ["clothesDrying"] = 2} },
    { capability = capabilities["concertmirror08464.kadeerX1701TargetHumidity"], attribute = "targetHumidity", siid = 2, piid = 4, kind = "enum", initial = 40, command = "setTargetHumidity", to_st = {[30] = "h30", [35] = "h35", [40] = "h40", [45] = "h45", [50] = "h50", [55] = "h55", [60] = "h60", [65] = "h65", [70] = "h70", [75] = "h75", [80] = "h80"}, to_wire = {["h30"] = 30, ["h35"] = 35, ["h40"] = 40, ["h45"] = 45, ["h50"] = 50, ["h55"] = 55, ["h60"] = 60, ["h65"] = 65, ["h70"] = 70, ["h75"] = 75, ["h80"] = 80} },
    { capability = capabilities["concertmirror08464.kadeerX1701FanLevel"], attribute = "fanLevel", siid = 3, piid = 6, kind = "enum", initial = 0, command = "setFanLevel", to_st = {[0] = "low", [1] = "high"}, to_wire = {["low"] = 0, ["high"] = 1} },
    { capability = capabilities["concertmirror08464.kadeerX1701TankStatus"], attribute = "tankStatus", siid = 3, piid = 3, kind = "enumRead", initial = 0, to_st = {[0] = "normal", [1] = "full"} }
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function emit_feature(device, feature, wire_value)
    local value = wire_value
    if feature.kind == "bool" then
        value = wire_value and "on" or "off"
    elseif feature.kind == "tankFault" then
        value = feature.to_st[wire_value]
    elseif feature.kind == "boolRead" then
        value = wire_value and "full" or "normal"
    elseif feature.to_st then
        value = feature.to_st[wire_value]
    end
    if value == nil then return end

    if feature.unit then
        device:emit_event(feature.capability[feature.attribute]({value = value, unit = feature.unit}))
    else
        device:emit_event(feature.capability[feature.attribute]({value = value}))
    end
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local properties = {{siid = POWER_SIID, piid = POWER_PIID}}
    if HUMIDITY_SIID then table.insert(properties, {siid = HUMIDITY_SIID, piid = HUMIDITY_PIID}) end
    if TEMPERATURE_SIID then table.insert(properties, {siid = TEMPERATURE_SIID, piid = TEMPERATURE_PIID}) end
    for _, feature in ipairs(FEATURES) do
        table.insert(properties, {siid = feature.siid, piid = feature.piid})
    end

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            if result.siid == POWER_SIID and result.piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(result.value and "on" or "off"))
            elseif HUMIDITY_SIID and result.siid == HUMIDITY_SIID and result.piid == HUMIDITY_PIID then
                device:emit_event(capabilities.relativeHumidityMeasurement.humidity(result.value))
            elseif TEMPERATURE_SIID and result.siid == TEMPERATURE_SIID and result.piid == TEMPERATURE_PIID then
                device:emit_event(capabilities.temperatureMeasurement.temperature({value = result.value, unit = "C"}))
            end
            for _, feature in ipairs(FEATURES) do
                if result.siid == feature.siid and result.piid == feature.piid then
                    emit_feature(device, feature, result.value)
                end
            end
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

local function set_power(device, value)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok = pcall(miot.set, device, ip, token, POWER_SIID, POWER_PIID, value)
    if ok then
        device:emit_event(capabilities.switch.switch(value and "on" or "off"))
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function custom_handler(feature)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local requested = command.args[feature.attribute]
        local wire_value = requested
        if feature.kind == "bool" then
            wire_value = requested == "on"
        elseif feature.to_wire then
            wire_value = feature.to_wire[requested]
        elseif feature.kind == "integer" or feature.kind == "number" then
            wire_value = tonumber(requested)
            if wire_value then
                wire_value = math.max(feature.minimum, math.min(feature.maximum, wire_value))
                wire_value = feature.minimum + math.floor(((wire_value - feature.minimum) / feature.step) + 0.5) * feature.step
            end
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
    [capabilities.refresh.ID] = {
        [capabilities.refresh.commands.refresh.NAME] = function(_, device, _) pcall(poll_device_status, device) end
    }
}

for _, item in ipairs(FEATURES) do
    local feature = item
    if feature.command then
        capability_handlers[feature.capability.ID] = {
            [feature.capability.commands[feature.command].NAME] = custom_handler(feature)
        }
    end
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(FEATURES[1].capability.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    if HUMIDITY_SIID then device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0)) end
    if TEMPERATURE_SIID then device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"})) end
    for _, feature in ipairs(FEATURES) do emit_feature(device, feature, feature.initial) end
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
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

    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            pcall(poll_device_status, device)
        end
    end
end

local driver = Driver("miot-kadeer-dehumidifier-x1701", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = capability_handlers
})

driver:run()
