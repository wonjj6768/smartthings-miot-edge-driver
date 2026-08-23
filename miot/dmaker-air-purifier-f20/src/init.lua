-- Dmaker Air Purifier F20 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.dmakerAirF20Mode"]
local doorOpenCap = capabilities["concertmirror08464.dmakerAirF20DoorOpen"]
local screenCap = capabilities["concertmirror08464.dmakerAirF20Screen"]
local brightnessCap = capabilities["concertmirror08464.dmakerAirF20Brightness"]
local buzzerCap = capabilities["concertmirror08464.dmakerAirF20Buzzer"]
local volumeCap = capabilities["concertmirror08464.dmakerAirF20Volume"]
local childLockCap = capabilities["concertmirror08464.dmakerAirF20ChildLock"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "dmaker-air-purifier-f20"

-- MIoT model: dmaker.airpurifier.f20
-- specModel: dmaker-f20
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:dmaker-f20:2
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW
--   piid=2 fault, uint16, R, raw code, not exposed
--   piid=4 mode, uint8, RW enum: 0=auto, 1=sleep, 2..4=level1..3, 5=favorite
--   piid=6 door-state, bool, R (filter cover open)
--   piid=7 fan-level mirrors the same enum as piid=4, so only the mode
--     property is exposed to avoid two controls for one device setting
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, percent
--   piid=4 pm2.5-density, float, R
--   piid=5 pm10-density, float, R
--   piid=7 temperature, float, R, celsius
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R, percent
--   piid=2..5 filter time and airflow counters: cumulative stats, not exposed
-- Alarm service (siid=6)
--   piid=1 alarm, bool, RW
--   piid=2 volume, uint8, RW range 0..100
-- Screen service (siid=7)
--   piid=1 on, bool, RW
--   piid=2 brightness, uint8, RW range 0..100
-- Physical Controls Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW
-- dm-sevice service (siid=9): favorite motor speed, motor feedback, filter
--   events, and PM debug values are vendor tuning fields, not exposed

local PURIFIER_SIID = 2
local POWER_PIID = 1
local MODE_PIID = 4
local DOOR_STATE_PIID = 6

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1
local PM25_PIID = 4
local PM10_PIID = 5
local TEMPERATURE_PIID = 7

local FILTER_SIID = 4
local FILTER_LIFE_PIID = 1

local ALARM_SIID = 6
local ALARM_PIID = 1
local VOLUME_PIID = 2

local SCREEN_SIID = 7
local SCREEN_ON_PIID = 1
local BRIGHTNESS_PIID = 2

local LOCK_SIID = 8
local LOCK_PIID = 1

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "level1",
    [3] = "level2",
    [4] = "level3",
    [5] = "favorite"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    auto = 0,
    sleep = 1,
    level1 = 2,
    level2 = 3,
    level3 = 4,
    favorite = 5
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(modeCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function bool_to_st(value)
    return value and "on" or "off"
end

local function clamp_percent(value)
    return math.max(0, math.min(100, math.floor(value + 0.5)))
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = PURIFIER_SIID, piid = POWER_PIID},
        {siid = PURIFIER_SIID, piid = MODE_PIID},
        {siid = PURIFIER_SIID, piid = DOOR_STATE_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM10_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = ALARM_SIID, piid = VOLUME_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_ON_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID},
        {siid = LOCK_SIID, piid = LOCK_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == PURIFIER_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(bool_to_st(value)))
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value]
                    if mode then
                        device:emit_event(modeCap.airPurifierMode({value = mode}))
                    end
                elseif piid == DOOR_STATE_PIID then
                    device:emit_event(doorOpenCap.doorOpen({value = value and "open" or "closed"}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == PM25_PIID then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
                elseif piid == PM10_PIID then
                    device:emit_event(capabilities.dustSensor.dustLevel(math.floor(value)))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                end
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == ALARM_SIID then
                if piid == ALARM_PIID then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                elseif piid == VOLUME_PIID then
                    device:emit_event(volumeCap.buzzerVolume({value = value, unit = "%"}))
                end
            elseif siid == SCREEN_SIID then
                if piid == SCREEN_ON_PIID then
                    device:emit_event(screenCap.screen({value = bool_to_st(value)}))
                elseif piid == BRIGHTNESS_PIID then
                    device:emit_event(brightnessCap.screenBrightness({value = value, unit = "%"}))
                end
            elseif siid == LOCK_SIID and piid == LOCK_PIID then
                device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
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

local function switch_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, PURIFIER_SIID, POWER_PIID, true)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, PURIFIER_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.airPurifierMode
    local value = ST_TO_MODE[mode]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, PURIFIER_SIID, MODE_PIID, value)
    if ok then
        device:emit_event(modeCap.airPurifierMode({value = mode}))
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function make_bool_handler(siid, piid, capability, attribute, argument)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local requested = command.args[argument]
        local ok = pcall(miot.set, device, ip, token, siid, piid, requested == "on")
        if ok then
            device:emit_event(capability[attribute]({value = requested}))
        end
    end
end

local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_screen_handler = make_bool_handler(SCREEN_SIID, SCREEN_ON_PIID, screenCap, "screen", "screen")
local set_child_lock_handler = make_bool_handler(LOCK_SIID, LOCK_PIID, childLockCap, "childLock", "childLock")

local function make_percent_handler(siid, piid, capability, attribute, argument)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local requested = tonumber(command.args[argument])
        if not requested then return end

        local value = clamp_percent(requested)
        local ok = pcall(miot.set, device, ip, token, siid, piid, value)
        if ok then
            device:emit_event(capability[attribute]({value = value, unit = "%"}))
        end
    end
end

local set_volume_handler = make_percent_handler(ALARM_SIID, VOLUME_PIID, volumeCap, "buzzerVolume", "buzzerVolume")
local set_brightness_handler = make_percent_handler(SCREEN_SIID, BRIGHTNESS_PIID, brightnessCap, "screenBrightness", "screenBrightness")

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(modeCap.airPurifierMode({value = "auto"}))
    device:emit_event(doorOpenCap.doorOpen({value = "closed"}))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.dustSensor.dustLevel(0))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(screenCap.screen({value = "on"}))
    device:emit_event(brightnessCap.screenBrightness({value = 100, unit = "%"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(volumeCap.buzzerVolume({value = 50, unit = "%"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    pcall(poll_device_status, device)
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))

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
    if not args.old_st_store or not args.old_st_store.preferences then
        return
    end

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

local driver = Driver("miot-dmaker-air-purifier-f20", {
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
        [modeCap.ID] = {
            [modeCap.commands.setAirPurifierMode.NAME] = set_mode_handler
        },
        [screenCap.ID] = {
            [screenCap.commands.setScreen.NAME] = set_screen_handler
        },
        [brightnessCap.ID] = {
            [brightnessCap.commands.setScreenBrightness.NAME] = set_brightness_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [volumeCap.ID] = {
            [volumeCap.commands.setBuzzerVolume.NAME] = set_volume_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
