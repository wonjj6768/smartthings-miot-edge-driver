-- Baomi Air Purifier 450A Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.baomiAir450aMode"]
local fanLevelCap = capabilities["concertmirror08464.baomiAir450aFanLevel"]
local filterTypeCap = capabilities["concertmirror08464.baomiAir450aFilterType"]
local screenCap = capabilities["concertmirror08464.baomiAir450aScreen"]
local childLockCap = capabilities["concertmirror08464.baomiAir450aChildLock"]
local buzzerCap = capabilities["concertmirror08464.baomiAir450aBuzzer"]
local sleepCap = capabilities["concertmirror08464.baomiAir450aSleep"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "baomi-air-purifier-450a"

-- MIoT model: baomi.airpurifier.450a
-- specModel: baomi-450a
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:baomi-450a:1
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW
--   piid=2 fault, uint8, R, single no-fault value, not exposed
--   piid=4 mode, uint8, RW enum: 0=silent, 1=strong, 2=smart, 3=none
--     The vendor "none" placeholder is not offered as a selectable mode.
--   piid=5 fan-level, uint8, RW enum: 0..4 shown as level1..level5
-- Environment service (siid=3)
--   piid=4 pm2.5-density, uint16, R
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R, percent
-- Screen service (siid=7)
--   piid=1 on, bool, RW
-- Physical Controls Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW
-- Alarm service (siid=11)
--   piid=1 alarm, bool, RW
-- Custom service (siid=9)
--   piid=1 filter-type, uint8, RW enum: 0=anti-mite, 1=formaldehyde, 2=baby
--   piid=2 sleep-mode, bool, RW

local PURIFIER_SIID = 2
local POWER_PIID = 1
local MODE_PIID = 4
local FAN_LEVEL_PIID = 5

local ENVIRONMENT_SIID = 3
local PM25_PIID = 4

local FILTER_SIID = 4
local FILTER_LIFE_PIID = 1

local SCREEN_SIID = 7
local SCREEN_ON_PIID = 1

local LOCK_SIID = 8
local LOCK_PIID = 1

local ALARM_SIID = 11
local ALARM_PIID = 1

local CUSTOM_SIID = 9
local FILTER_TYPE_PIID = 1
local SLEEP_PIID = 2

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "silent",
    [1] = "strong",
    [2] = "smart"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    silent = 0,
    strong = 1,
    smart = 2
}

local FAN_LEVEL_TO_ST = {
    [0] = "level1",
    [1] = "level2",
    [2] = "level3",
    [3] = "level4",
    [4] = "level5"
}

local ST_TO_FAN_LEVEL = {
    level1 = 0,
    level2 = 1,
    level3 = 2,
    level4 = 3,
    level5 = 4
}

local FILTER_TYPE_TO_ST = {
    [0] = "mite",
    [1] = "formaldehyde",
    [2] = "babyCare"
}

local ST_TO_FILTER_TYPE = {
    mite = 0,
    formaldehyde = 1,
    babyCare = 2
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

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = PURIFIER_SIID, piid = POWER_PIID},
        {siid = PURIFIER_SIID, piid = MODE_PIID},
        {siid = PURIFIER_SIID, piid = FAN_LEVEL_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_ON_PIID},
        {siid = LOCK_SIID, piid = LOCK_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = CUSTOM_SIID, piid = FILTER_TYPE_PIID},
        {siid = CUSTOM_SIID, piid = SLEEP_PIID}
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
                elseif piid == FAN_LEVEL_PIID then
                    local level = FAN_LEVEL_TO_ST[value]
                    if level then
                        device:emit_event(fanLevelCap.fanLevel({value = level}))
                    end
                end
            elseif siid == ENVIRONMENT_SIID and piid == PM25_PIID then
                device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == SCREEN_SIID and piid == SCREEN_ON_PIID then
                device:emit_event(screenCap.screen({value = bool_to_st(value)}))
            elseif siid == LOCK_SIID and piid == LOCK_PIID then
                device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
            elseif siid == ALARM_SIID and piid == ALARM_PIID then
                device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
            elseif siid == CUSTOM_SIID then
                if piid == FILTER_TYPE_PIID then
                    local filterType = FILTER_TYPE_TO_ST[value]
                    if filterType then
                        device:emit_event(filterTypeCap.filterType({value = filterType}))
                    end
                elseif piid == SLEEP_PIID then
                    device:emit_event(sleepCap.sleepMode({value = bool_to_st(value)}))
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

local function set_fan_level_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local level = command.args.fanLevel
    local value = ST_TO_FAN_LEVEL[level]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, PURIFIER_SIID, FAN_LEVEL_PIID, value)
    if ok then
        device:emit_event(fanLevelCap.fanLevel({value = level}))
    end
end

local function set_filter_type_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local filterType = command.args.filterType
    local value = ST_TO_FILTER_TYPE[filterType]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, CUSTOM_SIID, FILTER_TYPE_PIID, value)
    if ok then
        device:emit_event(filterTypeCap.filterType({value = filterType}))
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

local set_screen_handler = make_bool_handler(SCREEN_SIID, SCREEN_ON_PIID, screenCap, "screen", "screen")
local set_child_lock_handler = make_bool_handler(LOCK_SIID, LOCK_PIID, childLockCap, "childLock", "childLock")
local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_sleep_handler = make_bool_handler(CUSTOM_SIID, SLEEP_PIID, sleepCap, "sleepMode", "sleepMode")

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(modeCap.airPurifierMode({value = "smart"}))
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(filterTypeCap.filterType({value = "mite"}))
    device:emit_event(screenCap.screen({value = "on"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(sleepCap.sleepMode({value = "off"}))
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

local driver = Driver("miot-baomi-air-purifier-450a", {
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
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fan_level_handler
        },
        [filterTypeCap.ID] = {
            [filterTypeCap.commands.setFilterType.NAME] = set_filter_type_handler
        },
        [screenCap.ID] = {
            [screenCap.commands.setScreen.NAME] = set_screen_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [sleepCap.ID] = {
            [sleepCap.commands.setSleepMode.NAME] = set_sleep_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
