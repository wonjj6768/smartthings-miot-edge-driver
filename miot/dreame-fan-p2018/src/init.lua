-- Dreame Fan P2018 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanSpeedPercent = capabilities["fanSpeedPercent"]
local modeCap = capabilities["concertmirror08464.dreameFanP2018Mode"]
local horizontalAngleCap = capabilities["concertmirror08464.dreameFanP2018HorizontalAngleV2"]
local swingAngleCap = capabilities["concertmirror08464.dreameFanP2018SwingAngleV2"]
local windReverseCap = capabilities["concertmirror08464.dreameFanP2018WindReverse"]
local screenCap = capabilities["concertmirror08464.dreameFanP2018Screen"]
local buzzerCap = capabilities["concertmirror08464.dreameFanP2018Buzzer"]
local childLockCap = capabilities["concertmirror08464.dreameFanP2018ChildLock"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "dreame-fan-p2018"
local FAN_SIID = 2
local POWER_PIID = 1
local FAN_LEVEL_PIID = 2
local HORIZONTAL_ANGLE_PIID = 5
local WIND_REVERSE_PIID = 17
local MODE_PIID = 18
local HORIZONTAL_SWING_PIID = 19
local SWING_ANGLE_PIID = 20
local CHILD_LOCK_SIID = 9
local CHILD_LOCK_PIID = 1
local BUZZER_SIID = 12
local BUZZER_PIID = 1
local SCREEN_SIID = 13
local SCREEN_PIID = 1
local ENVIRONMENT_SIID = 14
local TEMPERATURE_PIID = 1
local HUMIDITY_PIID = 2

-- Exact MIoT contract: dreame.fan.p2018, dreame-p2018:1.
-- Fan: 2/1 on RW; 2/2 level 1..100 RW; 2/5 absolute horizontal angle
-- -75..75 RW; 2/17 wind reverse RW; 2/18 mode 1..5 RW; 2/19 horizontal
-- swing RW; 2/20 included angle 30/60/90/120/150 RW.
-- Other exposed services: child lock 9/1, buzzer 12/1, screen 13/1,
-- temperature 14/1 C and relative humidity 14/2 percent.
local MODE_TO_ST = {
    [1] = "straightWind",
    [2] = "naturalWind",
    [3] = "smart",
    [4] = "circularWind",
    [5] = "purification"
}
local ST_TO_MODE = {straightWind = 1, naturalWind = 2, smart = 3, circularWind = 4, purification = 5}
local VALID_SWING_ANGLES = {[30] = true, [60] = true, [90] = true, [120] = true, [150] = true}
local SUPPORTED_OSCILLATION_MODES = {"off", "horizontal"}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(horizontalAngleCap.ID, "main") then
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
        {siid = FAN_SIID, piid = POWER_PIID},
        {siid = FAN_SIID, piid = FAN_LEVEL_PIID},
        {siid = FAN_SIID, piid = HORIZONTAL_ANGLE_PIID},
        {siid = FAN_SIID, piid = WIND_REVERSE_PIID},
        {siid = FAN_SIID, piid = MODE_PIID},
        {siid = FAN_SIID, piid = HORIZONTAL_SWING_PIID},
        {siid = FAN_SIID, piid = SWING_ANGLE_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID},
        {siid = BUZZER_SIID, piid = BUZZER_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID}
    }
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end
    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid, piid, value = result.siid, result.piid, result.value
            if siid == FAN_SIID and piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(value and "on" or "off"))
            elseif siid == FAN_SIID and piid == FAN_LEVEL_PIID and type(value) == "number" then
                device:emit_event(fanSpeedPercent.percent({value = value, unit = "%"}))
            elseif siid == FAN_SIID and piid == HORIZONTAL_ANGLE_PIID and type(value) == "number" then
                device:emit_event(horizontalAngleCap.horizontalAngle({value = tostring(math.floor(value))}))
            elseif siid == FAN_SIID and piid == WIND_REVERSE_PIID then
                emit_bool(device, windReverseCap.windReverse, value)
            elseif siid == FAN_SIID and piid == MODE_PIID and MODE_TO_ST[value] then
                device:emit_event(modeCap.fanMode({value = MODE_TO_ST[value]}))
            elseif siid == FAN_SIID and piid == HORIZONTAL_SWING_PIID then
                device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(value and "horizontal" or "off"))
            elseif siid == FAN_SIID and piid == SWING_ANGLE_PIID and VALID_SWING_ANGLES[value] then
                device:emit_event(swingAngleCap.swingAngle({value = tostring(value)}))
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                emit_bool(device, childLockCap.childLock, value)
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then
                emit_bool(device, buzzerCap.buzzer, value)
            elseif siid == SCREEN_SIID and piid == SCREEN_PIID then
                emit_bool(device, screenCap.screen, value)
            elseif siid == ENVIRONMENT_SIID and piid == TEMPERATURE_PIID and type(value) == "number" then
                device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
            elseif siid == ENVIRONMENT_SIID and piid == HUMIDITY_PIID and type(value) == "number" then
                device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
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
local function switch_off_handler(_, device, _)
    set_property(device, FAN_SIID, POWER_PIID, false, capabilities.switch.switch.off())
end
local function set_speed_handler(_, device, command)
    local value = math.max(1, math.min(100, math.floor(command.args.percent)))
    set_property(device, FAN_SIID, FAN_LEVEL_PIID, value, fanSpeedPercent.percent({value = value, unit = "%"}))
end
local function set_oscillation_handler(_, device, command)
    local value = command.args.fanOscillationMode
    if value ~= "off" and value ~= "horizontal" then return end
    set_property(device, FAN_SIID, HORIZONTAL_SWING_PIID, value == "horizontal",
        capabilities.fanOscillationMode.fanOscillationMode(value))
end
local function set_mode_handler(_, device, command)
    local value = ST_TO_MODE[command.args.fanMode]
    if value then set_property(device, FAN_SIID, MODE_PIID, value, modeCap.fanMode({value = command.args.fanMode})) end
end
local function set_horizontal_angle_handler(_, device, command)
    local value = tonumber(command.args.horizontalAngle)
    if not value then return end
    value = math.max(-75, math.min(75, math.floor(value)))
    set_property(device, FAN_SIID, HORIZONTAL_ANGLE_PIID, value,
        horizontalAngleCap.horizontalAngle({value = tostring(value)}))
end
local function set_swing_angle_handler(_, device, command)
    local value = tonumber(command.args.swingAngle)
    if VALID_SWING_ANGLES[value] then
        set_property(device, FAN_SIID, SWING_ANGLE_PIID, value, swingAngleCap.swingAngle({value = tostring(value)}))
    end
end
local function set_bool_handler(capability, attribute, siid, piid, arg_name)
    return function(_, device, command)
        local value = command.args[arg_name]
        if value ~= "off" and value ~= "on" then return end
        set_property(device, siid, piid, value == "on", capability[attribute]({value = value}))
    end
end
local function refresh_handler(_, device, _) pcall(poll_device_status, device) end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanSpeedPercent.percent({value = 1, unit = "%"}))
    device:emit_event(capabilities.fanOscillationMode.supportedFanOscillationModes({value = SUPPORTED_OSCILLATION_MODES}))
    device:emit_event(capabilities.fanOscillationMode.fanOscillationMode("off"))
    device:emit_event(modeCap.fanMode({value = "straightWind"}))
    device:emit_event(horizontalAngleCap.horizontalAngle({value = "0"}))
    device:emit_event(swingAngleCap.swingAngle({value = "30"}))
    emit_bool(device, windReverseCap.windReverse, false)
    emit_bool(device, screenCap.screen, false)
    emit_bool(device, buzzerCap.buzzer, false)
    emit_bool(device, childLockCap.childLock, false)
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
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

local driver = Driver("miot-dreame-fan-p2018", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_added, init = device_init, removed = device_removed, infoChanged = device_info_changed},
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = switch_on_handler,
            [capabilities.switch.commands.off.NAME] = switch_off_handler
        },
        [fanSpeedPercent.ID] = {[fanSpeedPercent.commands.setPercent.NAME] = set_speed_handler},
        [capabilities.fanOscillationMode.ID] = {
            [capabilities.fanOscillationMode.commands.setFanOscillationMode.NAME] = set_oscillation_handler
        },
        [modeCap.ID] = {[modeCap.commands.setFanMode.NAME] = set_mode_handler},
        [horizontalAngleCap.ID] = {[horizontalAngleCap.commands.setHorizontalAngle.NAME] = set_horizontal_angle_handler},
        [swingAngleCap.ID] = {[swingAngleCap.commands.setSwingAngle.NAME] = set_swing_angle_handler},
        [windReverseCap.ID] = {[windReverseCap.commands.setWindReverse.NAME] = set_bool_handler(windReverseCap, "windReverse", FAN_SIID, WIND_REVERSE_PIID, "windReverse")},
        [screenCap.ID] = {[screenCap.commands.setScreen.NAME] = set_bool_handler(screenCap, "screen", SCREEN_SIID, SCREEN_PIID, "screen")},
        [buzzerCap.ID] = {[buzzerCap.commands.setBuzzer.NAME] = set_bool_handler(buzzerCap, "buzzer", BUZZER_SIID, BUZZER_PIID, "buzzer")},
        [childLockCap.ID] = {[childLockCap.commands.setChildLock.NAME] = set_bool_handler(childLockCap, "childLock", CHILD_LOCK_SIID, CHILD_LOCK_PIID, "childLock")},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

driver:run()
