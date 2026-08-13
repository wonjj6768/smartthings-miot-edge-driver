-- Airmate Fan CA23AD9 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miio = require "miio"

local fanLevelCap = capabilities["concertmirror08464.airFanCa23ad9FanLevel"]
local fanModeCap = capabilities["concertmirror08464.airFanCa23ad9Mode"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "air-fan-ca23ad9"

-- miIO model: air.fan.ca23ad9
-- Source: exact hass-xiaomi-miot MIIO_TO_MIOT_SPECS converter.
-- Read: get_prop(["on"]) returns power, mode, speed, lrWind, udWind,
--       onTime, offTime in that order.
-- Write: SetSwitch([0|1]), SetLevel([1..32]), SetH_Swing([0|1]),
--        SetV_Swing([0|1]), SetMode([1|2]).
local PROPERTIES = {"power", "mode", "speed", "lrWind", "udWind", "onTime", "offTime"}
local MODE_TO_ST = {[1] = "basic", [2] = "babyCare"}
local ST_TO_MODE = {basic = 1, babyCare = 2}
local SUPPORTED_OSCILLATION_MODES = {"off", "horizontal", "vertical", "all"}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(fanLevelCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function on_off_to_bool(value)
    return value == true or value == 1 or value == "1" or value == "on"
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local response = miio.cmd(device, ip, token, "get_prop", {"on"})
    if not response or not response.result then return end

    local values = {}
    for index, property in ipairs(PROPERTIES) do
        values[property] = response.result[index]
    end

    local horizontal_swing = nil
    local vertical_swing = nil

    if values.power ~= nil then
        device:emit_event(capabilities.switch.switch(on_off_to_bool(values.power) and "on" or "off"))
    end
    if type(values.speed) == "number" then
        device:emit_event(fanLevelCap.fanLevel({value = values.speed}))
    end
    if values.lrWind ~= nil then horizontal_swing = on_off_to_bool(values.lrWind) end
    if values.udWind ~= nil then vertical_swing = on_off_to_bool(values.udWind) end
    if horizontal_swing ~= nil or vertical_swing ~= nil then
        local swing = "off"
        if horizontal_swing and vertical_swing then
            swing = "all"
        elseif horizontal_swing then
            swing = "horizontal"
        elseif vertical_swing then
            swing = "vertical"
        end
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(swing))
    end
    if type(values.mode) == "number" and MODE_TO_ST[values.mode] then
        device:emit_event(fanModeCap.fanMode({value = MODE_TO_ST[values.mode]}))
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

local function set_miio(device, method, params, event)
    local ip, token = get_device_config(device)
    if ip and miio.set_prop(device, ip, token, method, params) then
        device:emit_event(event)
        return true
    end
    return false
end

local function switch_on_handler(_, device, _)
    if set_miio(device, "SetSwitch", {1}, capabilities.switch.switch.on()) then
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function switch_off_handler(_, device, _)
    set_miio(device, "SetSwitch", {0}, capabilities.switch.switch.off())
end

local function set_fan_level_handler(_, device, command)
    local level = math.floor(tonumber(command.args.fanLevel) or 1)
    level = math.max(1, math.min(32, level))
    set_miio(device, "SetLevel", {level}, fanLevelCap.fanLevel({value = level}))
end

local function set_oscillation_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    local mode = command.args.fanOscillationMode
    if mode ~= "off" and mode ~= "horizontal" and mode ~= "vertical" and mode ~= "all" then return end
    local horizontal = mode == "horizontal" or mode == "all"
    local vertical = mode == "vertical" or mode == "all"
    local ok_horizontal = miio.set_prop(device, ip, token, "SetH_Swing", {horizontal and 1 or 0})
    local ok_vertical = miio.set_prop(device, ip, token, "SetV_Swing", {vertical and 1 or 0})
    if ok_horizontal and ok_vertical then
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(mode))
    end
end

local function set_fan_mode_handler(_, device, command)
    local mode = command.args.fanMode
    local value = ST_TO_MODE[mode]
    if not value then return end
    set_miio(device, "SetMode", {value}, fanModeCap.fanMode({value = mode}))
end

local function refresh_handler(_, device, _)
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanLevelCap.fanLevel({value = 1}))
    device:emit_event(capabilities.fanOscillationMode.supportedFanOscillationModes({value = SUPPORTED_OSCILLATION_MODES}))
    device:emit_event(capabilities.fanOscillationMode.fanOscillationMode("off"))
    device:emit_event(fanModeCap.fanMode({value = "basic"}))
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

local driver = Driver("miio-air-fan-ca23ad9", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = switch_on_handler,
            [capabilities.switch.commands.off.NAME] = switch_off_handler
        },
        [fanLevelCap.ID] = {[fanLevelCap.commands.setFanLevel.NAME] = set_fan_level_handler},
        [capabilities.fanOscillationMode.ID] = {
            [capabilities.fanOscillationMode.commands.setFanOscillationMode.NAME] = set_oscillation_handler
        },
        [fanModeCap.ID] = {[fanModeCap.commands.setFanMode.NAME] = set_fan_mode_handler},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

driver:run()
