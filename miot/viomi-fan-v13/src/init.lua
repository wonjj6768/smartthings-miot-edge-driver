-- Viomi Fan V13 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanLevelCap = capabilities["concertmirror08464.viomiFanV13FanLevel"]
local modeCap = capabilities["concertmirror08464.viomiFanV13Mode"]
local screenCap = capabilities["concertmirror08464.viomiFanV13Screen"]
local buzzerCap = capabilities["concertmirror08464.viomiFanV13Buzzer"]
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "viomi-fan-v13"
local FAN_SIID = 2
local POWER_PIID = 1
local FAN_LEVEL_PIID = 2
local HORIZONTAL_SWING_PIID = 3
local MODE_PIID = 4
local VERTICAL_SWING_PIID = 6
local SCREEN_SIID = 5
local SCREEN_PIID = 1
local BUZZER_SIID = 6
local BUZZER_PIID = 1

-- Exact MIoT contract: viomi.fan.v13, viomi-v13:1.
-- Fan 2/1 on RW; 2/2 level 1..99 RW; 2/3 horizontal swing RW;
-- 2/4 mode 0=Basic, 1=Natural Wind, 2=Baby Care, 4=Sleep RW;
-- 2/6 vertical swing RW; screen 5/1 RW; alarm 6/1 RW. Anion 2/7 is not exposed.
local MODE_TO_ST = {[0] = "basic", [1] = "naturalWind", [2] = "babyCare", [4] = "sleep"}
local ST_TO_MODE = {basic = 0, naturalWind = 1, babyCare = 2, sleep = 4}
local SUPPORTED_OSCILLATION_MODES = {"off", "horizontal", "vertical", "all"}

local function get_device_config(device)
    local ip, token = device.preferences.ipAddress, device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end
local function ensure_profile(device)
    if not device:supports_capability_by_id(fanLevelCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end
local function emit_bool(device, attribute, value)
    device:emit_event(attribute({value = value and "on" or "off"}))
end
local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local properties = {
        {siid = FAN_SIID, piid = POWER_PIID}, {siid = FAN_SIID, piid = FAN_LEVEL_PIID},
        {siid = FAN_SIID, piid = HORIZONTAL_SWING_PIID}, {siid = FAN_SIID, piid = MODE_PIID},
        {siid = FAN_SIID, piid = VERTICAL_SWING_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_PIID}, {siid = BUZZER_SIID, piid = BUZZER_PIID}
    }
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end
    local horizontal_swing = nil
    local vertical_swing = nil
    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid, piid, value = result.siid, result.piid, result.value
            if siid == FAN_SIID and piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(value and "on" or "off"))
            elseif siid == FAN_SIID and piid == FAN_LEVEL_PIID and type(value) == "number" then
                device:emit_event(fanLevelCap.fanLevel({value = value}))
            elseif siid == FAN_SIID and piid == HORIZONTAL_SWING_PIID then
                horizontal_swing = value
            elseif siid == FAN_SIID and piid == MODE_PIID and MODE_TO_ST[value] then
                device:emit_event(modeCap.fanMode({value = MODE_TO_ST[value]}))
            elseif siid == FAN_SIID and piid == VERTICAL_SWING_PIID then
                vertical_swing = value
            elseif siid == SCREEN_SIID and piid == SCREEN_PIID then
                emit_bool(device, screenCap.screen, value)
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then
                emit_bool(device, buzzerCap.buzzer, value)
            end
        end
    end
    if horizontal_swing ~= nil or vertical_swing ~= nil then
        local mode = "off"
        if horizontal_swing and vertical_swing then
            mode = "all"
        elseif horizontal_swing then
            mode = "horizontal"
        elseif vertical_swing then
            mode = "vertical"
        end
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(mode))
    end
end
local function start_polling_timer(device)
    local timer = device.thread:call_on_schedule(device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL,
        function() pcall(poll_device_status, device) end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end
local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then device.thread:cancel_timer(timer); device:set_field(POLLING_TIMER, nil) end
end
local function set_property(device, siid, piid, value, event)
    local ip, token = get_device_config(device)
    if not ip then return false end
    local ok = pcall(miot.set, device, ip, token, siid, piid, value)
    if ok then device:emit_event(event); return true end
    return false
end
local function switch_on_handler(_, device, _)
    if set_property(device, FAN_SIID, POWER_PIID, true, capabilities.switch.switch.on()) then
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end
local function switch_off_handler(_, device, _) set_property(device, FAN_SIID, POWER_PIID, false, capabilities.switch.switch.off()) end
local function set_level_handler(_, device, command)
    local value = math.max(1, math.min(99, math.floor(tonumber(command.args.fanLevel) or 1)))
    set_property(device, FAN_SIID, FAN_LEVEL_PIID, value, fanLevelCap.fanLevel({value = value}))
end
local function set_horizontal_swing_handler(_, device, command)
    local value = command.args.fanOscillationMode
    if value ~= "off" and value ~= "horizontal" and value ~= "vertical" and value ~= "all" then return end
    local ip, token = get_device_config(device)
    if not ip then return end
    local horizontal = value == "horizontal" or value == "all"
    local vertical = value == "vertical" or value == "all"
    local ok_horizontal = pcall(miot.set, device, ip, token, FAN_SIID, HORIZONTAL_SWING_PIID, horizontal)
    local ok_vertical = pcall(miot.set, device, ip, token, FAN_SIID, VERTICAL_SWING_PIID, vertical)
    if ok_horizontal and ok_vertical then
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(value))
    end
end
local function set_mode_handler(_, device, command)
    local value = ST_TO_MODE[command.args.fanMode]
    if value ~= nil then set_property(device, FAN_SIID, MODE_PIID, value, modeCap.fanMode({value = command.args.fanMode})) end
end
local function set_bool_handler(capability, attribute, siid, piid, argument)
    return function(_, device, command)
        local value = command.args[argument]
        if value ~= "off" and value ~= "on" then return end
        set_property(device, siid, piid, value == "on", capability[attribute]({value = value}))
    end
end
local function refresh_handler(_, device, _) pcall(poll_device_status, device) end
local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanLevelCap.fanLevel({value = 1}))
    device:emit_event(capabilities.fanOscillationMode.supportedFanOscillationModes({value = SUPPORTED_OSCILLATION_MODES}))
    device:emit_event(capabilities.fanOscillationMode.fanOscillationMode("off"))
    device:emit_event(modeCap.fanMode({value = "basic"}))
    emit_bool(device, screenCap.screen, false)
    emit_bool(device, buzzerCap.buzzer, false)
end
local function device_init(_, device)
    ensure_profile(device); device:online()
    local ip = get_device_config(device)
    if ip then start_polling_timer(device); pcall(poll_device_status, device) end
end
local function device_removed(_, device) stop_polling_timer(device) end
local function device_info_changed(driver, device, _, args)
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old, new = args.old_st_store.preferences, device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then start_polling_timer(device); pcall(poll_device_status, device) end
    end
end

local driver = Driver("miot-viomi-fan-v13", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_added, init = device_init, removed = device_removed, infoChanged = device_info_changed},
    capability_handlers = {
        [capabilities.switch.ID] = {[capabilities.switch.commands.on.NAME] = switch_on_handler, [capabilities.switch.commands.off.NAME] = switch_off_handler},
        [fanLevelCap.ID] = {[fanLevelCap.commands.setFanLevel.NAME] = set_level_handler},
        [capabilities.fanOscillationMode.ID] = {[capabilities.fanOscillationMode.commands.setFanOscillationMode.NAME] = set_horizontal_swing_handler},
        [modeCap.ID] = {[modeCap.commands.setFanMode.NAME] = set_mode_handler},
        [screenCap.ID] = {[screenCap.commands.setScreen.NAME] = set_bool_handler(screenCap, "screen", SCREEN_SIID, SCREEN_PIID, "screen")},
        [buzzerCap.ID] = {[buzzerCap.commands.setBuzzer.NAME] = set_bool_handler(buzzerCap, "buzzer", BUZZER_SIID, BUZZER_PIID, "buzzer")},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

driver:run()
