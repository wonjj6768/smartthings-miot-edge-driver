-- Xiaomi Air Purifier CPA4 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.xiaomiAirCpa4Mode"]
local buzzerCap = capabilities["concertmirror08464.xiaomiAirCpa4Buzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiAirCpa4ChildLock"]
local displayLevelCap = capabilities["concertmirror08464.xiaomiAirCpa4DisplayLevel"]
local fanLevelCap = capabilities["concertmirror08464.xiaomiAirCpa4FanLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "xiaomi-air-purifier-cpa4"

-- MIoT model: xiaomi.airp.cpa4
-- specModel: xiaomi-cpa4
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-cpa4:2
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=No Faults, 2=Motor Stuck, 3=Sensor Lost: not exposed
--   piid=4 mode, uint8, RW; 0=Auto, 1=Sleep, 2=Favorite -> xiaomiAirCpa4Mode.airPurifierMode
-- Environment service (siid=3)
--   piid=4 pm2.5-density, uint16, R; range 0..600 step 1 μg/m3 -> dustSensor.fineDustLevel
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
--   aiid=1 reset-filter-life, Action -> filterState.resetFilter
--   piid=3 filter-used-time, uint16, R; range 0..65535 step 1 hours: not exposed
--   piid=4 filter-left-time, uint16, R; range 0..1000 step 1 days: not exposed
-- Alarm service (siid=6)
--   piid=1 alarm, bool, RW -> xiaomiAirCpa4Buzzer.buzzer
-- Physical Control Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW -> xiaomiAirCpa4ChildLock.childLock
-- custom-service service (siid=9)
--   piid=1 motor-speed-rpm, uint16, R; range 0..2500 step 1: not exposed
--   piid=10 country-code, uint16, RW; 17230=CN, 17749=EU, 21576=TH, 19024=JP, 21843=US, 19282=KR, 21591=TW, 18766=IN: not exposed
--   piid=11 favorite-level, uint8, RW; range 0..14 step 1 -> xiaomiAirCpa4FanLevel.fanLevel
--   piid=12 filter-used-time-dbg, uint16, W; range 0..7000 step 1 hours: not exposed
-- aqi service (siid=11)
--   piid=4 aqi-updata-heartbeat, uint16, RW; range 0..65535 step 1: not exposed
-- Screen service (siid=13)
--   piid=2 brightness, uint8, RW; 0=Close, 1=Bright, 2=Brightness -> xiaomiAirCpa4DisplayLevel.displayLevel

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local MODE_PIID = 4

local ENVIRONMENT_SIID = 3
local PM2_5_DENSITY_PIID = 4

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 1
local RESET_FILTER_LIFE_AIID = 1

local ALARM_SIID = 6
local ALARM_PIID = 1

local PHYSICAL_CONTROLS_LOCKED_SIID = 8
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

local CUSTOM_SERVICE_SIID = 9
local FAVORITE_LEVEL_PIID = 11

local SCREEN_SIID = 13
local BRIGHTNESS_PIID = 2

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    ["auto"] = 0,
    ["favorite"] = 2,
    ["sleep"] = 1
}

-- MIoT -> SmartThings
local BRIGHTNESS_TO_ST = {
    [0] = "off",
    [1] = "bright",
    [2] = "bright2"
}

-- SmartThings -> MIoT
local ST_TO_BRIGHTNESS = {
    ["bright"] = 1,
    ["bright2"] = 2,
    ["off"] = 0
}

local FAVORITE_LEVEL_MIN = 0
local FAVORITE_LEVEL_MAX = 14

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    if not device:supports_capability_by_id("concertmirror08464.xiaomiAirCpa4Mode", "main") then
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
        {siid = AIR_PURIFIER_SIID, piid = ON_PIID},
        {siid = AIR_PURIFIER_SIID, piid = MODE_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM2_5_DENSITY_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID},
        {siid = CUSTOM_SERVICE_SIID, piid = FAVORITE_LEVEL_PIID}
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

            if siid == AIR_PURIFIER_SIID then
                if piid == ON_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == MODE_PIID then
                    local mapped = MODE_TO_ST[value]
                    if mapped then
                        device:emit_event(airPurifierModeCap.airPurifierMode({value = mapped}))
                    end
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == PM2_5_DENSITY_PIID then
                    device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(value)))
                end
            elseif siid == FILTER_SIID then
                if piid == FILTER_LIFE_LEVEL_PIID then
                    device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
                end
            elseif siid == ALARM_SIID then
                if piid == ALARM_PIID then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                end
            elseif siid == PHYSICAL_CONTROLS_LOCKED_SIID then
                if piid == PHYSICAL_CONTROLS_LOCKED_PIID then
                    device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
                end
            elseif siid == SCREEN_SIID then
                if piid == BRIGHTNESS_PIID then
                    local mapped = BRIGHTNESS_TO_ST[value]
                    if mapped then
                        device:emit_event(displayLevelCap.displayLevel({value = mapped}))
                    end
                end
            elseif siid == CUSTOM_SERVICE_SIID then
                if piid == FAVORITE_LEVEL_PIID then
                    device:emit_event(fanLevelCap.fanLevel({value = value}))
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

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, ON_PIID, true)
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

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, ON_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_airPurifierMode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.airPurifierMode
    local value = ST_TO_MODE[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, value)
    if ok then
        device:emit_event(airPurifierModeCap.airPurifierMode({value = requested}))
    end
end

local function set_displayLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.displayLevel
    local value = ST_TO_BRIGHTNESS[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(displayLevelCap.displayLevel({value = requested}))
    end
end

local function set_fanLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = tonumber(command.args.fanLevel)
    if not requested then return end

    local value = math.max(FAVORITE_LEVEL_MIN, math.min(FAVORITE_LEVEL_MAX, math.floor(requested)))
    local ok = pcall(miot.set, device, ip, token, CUSTOM_SERVICE_SIID, FAVORITE_LEVEL_PIID, value)
    if ok then
        device:emit_event(fanLevelCap.fanLevel({value = value}))
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
local set_childLock_handler = make_bool_handler(PHYSICAL_CONTROLS_LOCKED_SIID, PHYSICAL_CONTROLS_LOCKED_PIID, childLockCap, "childLock", "childLock")

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_LIFE_AIID, {})
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
    device:emit_event(airPurifierModeCap.airPurifierMode({value = "auto"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "off"}))
    device:emit_event(fanLevelCap.fanLevel({value = 0}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
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

local driver = Driver("miot-xiaomi-air-purifier-cpa4", {
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
        [airPurifierModeCap.ID] = {
            [airPurifierModeCap.commands.setAirPurifierMode.NAME] = set_airPurifierMode_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_childLock_handler
        },
        [displayLevelCap.ID] = {
            [displayLevelCap.commands.setDisplayLevel.NAME] = set_displayLevel_handler
        },
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fanLevel_handler
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
