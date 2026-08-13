-- Solove Fan F5 New Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanLevelCap = capabilities["concertmirror08464.soloveFanF5newFanLevel"]
local modeCap = capabilities["concertmirror08464.soloveFanF5newMode"]
local buzzerCap = capabilities["concertmirror08464.soloveFanF5newBuzzer"]
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "solove-fan-f5new"
local FAN_SIID = 2
local POWER_PIID = 1
local FAN_LEVEL_PIID = 2
local MODE_PIID = 7
local BUZZER_SIID = 5
local BUZZER_PIID = 1

-- Exact MIoT contract: solove.fan.f5new, solove-f5new:1.
-- Fan 2/1 on RW; 2/2 level 1/2/3 RW; 2/7 mode 0=Natural Wind,
-- 1=Straight Wind RW. Buzzer 5/1 is RW.
-- Horizontal angle 2/5 is a unitless 0..3 value and is not exposed.
-- The custom "electricity" 5/2 meaning is not inferred or exposed.
local MODE_TO_ST = {[0] = "naturalWind", [1] = "straightWind"}
local ST_TO_MODE = {naturalWind = 0, straightWind = 1}

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
local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local properties = {
        {siid = FAN_SIID, piid = POWER_PIID},
        {siid = FAN_SIID, piid = FAN_LEVEL_PIID},
        {siid = FAN_SIID, piid = MODE_PIID},
        {siid = BUZZER_SIID, piid = BUZZER_PIID}
    }
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end
    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid, piid, value = result.siid, result.piid, result.value
            if siid == FAN_SIID and piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(value and "on" or "off"))
            elseif siid == FAN_SIID and piid == FAN_LEVEL_PIID and type(value) == "number" then
                device:emit_event(fanLevelCap.fanLevel({value = tostring(value)}))
            elseif siid == FAN_SIID and piid == MODE_PIID and MODE_TO_ST[value] then
                device:emit_event(modeCap.fanMode({value = MODE_TO_ST[value]}))
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then
                device:emit_event(buzzerCap.buzzer({value = value and "on" or "off"}))
            end
        end
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
    local value = tonumber(command.args.fanLevel)
    if value ~= 1 and value ~= 2 and value ~= 3 then return end
    set_property(device, FAN_SIID, FAN_LEVEL_PIID, value, fanLevelCap.fanLevel({value = tostring(value)}))
end
local function set_mode_handler(_, device, command)
    local value = ST_TO_MODE[command.args.fanMode]
    if value ~= nil then
        set_property(device, FAN_SIID, MODE_PIID, value, modeCap.fanMode({value = command.args.fanMode}))
    end
end
local function set_buzzer_handler(_, device, command)
    local value = command.args.buzzer
    if value ~= "off" and value ~= "on" then return end
    set_property(device, BUZZER_SIID, BUZZER_PIID, value == "on", buzzerCap.buzzer({value = value}))
end
local function refresh_handler(_, device, _) pcall(poll_device_status, device) end
local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanLevelCap.fanLevel({value = "1"}))
    device:emit_event(modeCap.fanMode({value = "naturalWind"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
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

local driver = Driver("miot-solove-fan-f5new", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_added, init = device_init, removed = device_removed, infoChanged = device_info_changed},
    capability_handlers = {
        [capabilities.switch.ID] = {[capabilities.switch.commands.on.NAME] = switch_on_handler, [capabilities.switch.commands.off.NAME] = switch_off_handler},
        [fanLevelCap.ID] = {[fanLevelCap.commands.setFanLevel.NAME] = set_level_handler},
        [modeCap.ID] = {[modeCap.commands.setFanMode.NAME] = set_mode_handler},
        [buzzerCap.ID] = {[buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

driver:run()
