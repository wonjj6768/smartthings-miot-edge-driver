-- BJ352 Air Purifier Y106CM Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.bj352AirY106Mode"]
local fanLevelCap = capabilities["concertmirror08464.bj352AirY106FanLevel"]
local filterRightCap = capabilities["concertmirror08464.bj352AirY106FilterRight"]
local anionCap = capabilities["concertmirror08464.bj352AirY106Anion"]
local indicatorCap = capabilities["concertmirror08464.bj352AirY106Indicator"]
local screenCap = capabilities["concertmirror08464.bj352AirY106Screen"]
local childLockCap = capabilities["concertmirror08464.bj352AirY106ChildLock"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "bj352-air-purifier-y106cm"

-- MIoT model: bj352.airp.y106cm
-- specModel: bj352-y106cm
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:bj352-y106cm:1
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW
--   piid=4 mode, uint8, RW enum: 1=auto, 2=sleep, 4=manual
--   piid=5 fan-level, uint8, RW enum: 1..5
--   piid=6 anion, bool, RW
--   piid=2 fault plus piid=7..12 unnamed status/fault codes: vendor
--     diagnostics, not exposed
-- Environment service (siid=3)
--   piid=1 relative-humidity, float, R, percent
--   piid=4 pm2.5-density, uint16, R
--   piid=7 temperature, float, R, celsius
--   piid=9 tvoc-density, float, R, mg/m^3
--   piid=11 hcho-density, float, R, mg/m^3
--   piid=2 air-quality-index and piid=3 air-quality restate the PM2.5 reading
-- Left Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R, percent
--   aiid=1 reset-filter-life, Action -> filterState.resetFilter
-- Right Filter service (siid=11)
--   piid=1 filter-life-level, uint8, R, percent
-- Indicator Light service (siid=5)
--   piid=1 on, bool, RW
-- Physical Controls Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW
-- Other Features service (siid=9)
--   piid=2 screen, bool, RW
--   piid=1 child-lock duplicates siid=8, and piid=3/4 carry filter serial
--     strings, so neither is exposed
-- Smart Mode service (siid=10): PM and HCHO trigger thresholds are automation
--   configuration rather than a device control

local PURIFIER_SIID = 2
local POWER_PIID = 1
local MODE_PIID = 4
local FAN_LEVEL_PIID = 5
local ANION_PIID = 6

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1
local PM25_PIID = 4
local TEMPERATURE_PIID = 7
local TVOC_PIID = 9
local HCHO_PIID = 11

local FILTER_LEFT_SIID = 4
local FILTER_RIGHT_SIID = 11
local FILTER_LIFE_PIID = 1
local RESET_FILTER_LIFE_AIID = 1

local INDICATOR_SIID = 5
local INDICATOR_PIID = 1

local LOCK_SIID = 8
local LOCK_PIID = 1

local OTHER_SIID = 9
local SCREEN_PIID = 2

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [1] = "auto",
    [2] = "sleep",
    [4] = "manual"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    auto = 1,
    sleep = 2,
    manual = 4
}

local FAN_LEVEL_TO_ST = {
    [1] = "level1",
    [2] = "level2",
    [3] = "level3",
    [4] = "level4",
    [5] = "level5"
}

local ST_TO_FAN_LEVEL = {
    level1 = 1,
    level2 = 2,
    level3 = 3,
    level4 = 4,
    level5 = 5
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
        {siid = PURIFIER_SIID, piid = ANION_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = TVOC_PIID},
        {siid = ENVIRONMENT_SIID, piid = HCHO_PIID},
        {siid = FILTER_LEFT_SIID, piid = FILTER_LIFE_PIID},
        {siid = FILTER_RIGHT_SIID, piid = FILTER_LIFE_PIID},
        {siid = INDICATOR_SIID, piid = INDICATOR_PIID},
        {siid = LOCK_SIID, piid = LOCK_PIID},
        {siid = OTHER_SIID, piid = SCREEN_PIID}
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
                elseif piid == ANION_PIID then
                    device:emit_event(anionCap.anion({value = bool_to_st(value)}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == PM25_PIID then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == TVOC_PIID then
                    device:emit_event(capabilities.tvocMeasurement.tvocLevel({value = value, unit = "mg/m^3"}))
                elseif piid == HCHO_PIID then
                    device:emit_event(capabilities.formaldehydeMeasurement.formaldehydeLevel({value = value, unit = "mg/m^3"}))
                end
            elseif siid == FILTER_LEFT_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == FILTER_RIGHT_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(filterRightCap.filterLife({value = value, unit = "%"}))
            elseif siid == INDICATOR_SIID and piid == INDICATOR_PIID then
                device:emit_event(indicatorCap.indicatorLight({value = bool_to_st(value)}))
            elseif siid == LOCK_SIID and piid == LOCK_PIID then
                device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
            elseif siid == OTHER_SIID and piid == SCREEN_PIID then
                device:emit_event(screenCap.screen({value = bool_to_st(value)}))
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

local set_anion_handler = make_bool_handler(PURIFIER_SIID, ANION_PIID, anionCap, "anion", "anion")
local set_indicator_handler = make_bool_handler(INDICATOR_SIID, INDICATOR_PIID, indicatorCap, "indicatorLight", "indicatorLight")
local set_screen_handler = make_bool_handler(OTHER_SIID, SCREEN_PIID, screenCap, "screen", "screen")
local set_child_lock_handler = make_bool_handler(LOCK_SIID, LOCK_PIID, childLockCap, "childLock", "childLock")

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.action, device, ip, token, FILTER_LEFT_SIID, RESET_FILTER_LIFE_AIID, {})
    if ok then
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(modeCap.airPurifierMode({value = "auto"}))
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.tvocMeasurement.tvocLevel({value = 0, unit = "mg/m^3"}))
    device:emit_event(capabilities.formaldehydeMeasurement.formaldehydeLevel({value = 0, unit = "mg/m^3"}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(filterRightCap.filterLife({value = 100, unit = "%"}))
    device:emit_event(anionCap.anion({value = "off"}))
    device:emit_event(indicatorCap.indicatorLight({value = "on"}))
    device:emit_event(screenCap.screen({value = "on"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    pcall(poll_device_status, device)
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))

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

local driver = Driver("miot-bj352-air-purifier-y106cm", {
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
        [anionCap.ID] = {
            [anionCap.commands.setAnion.NAME] = set_anion_handler
        },
        [indicatorCap.ID] = {
            [indicatorCap.commands.setIndicatorLight.NAME] = set_indicator_handler
        },
        [screenCap.ID] = {
            [screenCap.commands.setScreen.NAME] = set_screen_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [capabilities.filterState.ID] = {
            [capabilities.filterState.commands.resetFilter.NAME] = reset_filter_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
