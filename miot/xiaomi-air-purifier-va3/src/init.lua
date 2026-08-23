-- Xiaomi Air Purifier VA3 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.xiaomiAirVa3Mode"]
local fanLevelCap = capabilities["concertmirror08464.xiaomiAirVa3FanLevel"]
local anionCap = capabilities["concertmirror08464.xiaomiAirVa3Anion"]
local uvCap = capabilities["concertmirror08464.xiaomiAirVa3Uv"]
local buzzerCap = capabilities["concertmirror08464.xiaomiAirVa3Buzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiAirVa3ChildLock"]
local displayCap = capabilities["concertmirror08464.xiaomiAirVa3Display"]
local displayLevelCap = capabilities["concertmirror08464.xiaomiAirVa3DisplayLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "xiaomi-air-purifier-va3"

-- MIoT model: xiaomi.airp.va3
-- specModel: xiaomi-va3
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-va3:2
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=No Faults, 1=Sensor PM Error, 2=Sensor Temp Hum Error, 3=Sensor Hcho Error, 4=Filter Error, 5=Motor Error: not exposed
--   piid=4 mode, uint8, RW; 0=Auto, 3=Sleep, 5=Favorite, 6=None -> xiaomiAirVa3Mode.airPurifierMode
--   piid=5 fan-level, uint8, RW; 0=Level1, 1=Level2, 2=Level3 -> xiaomiAirVa3FanLevel.fanLevel
--   piid=6 anion, bool, RW -> xiaomiAirVa3Anion.anion
--   piid=7 uv, bool, RW -> xiaomiAirVa3Uv.uv
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R; range 0..100 step 1 percentage -> relativeHumidityMeasurement
--   piid=3 air-quality, uint8, R; 0=Excellent, 1=Good, 2=Moderate, 3=Poor, 4=Heavy Pollution, 5=Hazardous: not exposed
--   piid=4 pm2.5-density, uint16, R; range 0..1000 step 1 μg/m3 -> dustSensor.fineDustLevel
--   piid=5 pm10-density, uint8, R; range 0..100 step 1 -> dustSensor.dustLevel
--   piid=7 temperature, float, R; range -30..100 step 0.1 celsius -> temperatureMeasurement
--   piid=11 hcho-density, float, R; range 0..1 step 0.001 mg/m3 -> formaldehydeMeasurement
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
--   aiid=1 reset-filter-life, Action -> filterState.resetFilter
--   piid=2 filter-left-time, uint16, R; range 0..10000 step 1 hours: not exposed
--   piid=3 filter-used-time, uint16, R; range 0..10000 step 1 hours: not exposed
-- Alarm service (siid=6)
--   piid=1 alarm, bool, RW -> xiaomiAirVa3Buzzer.buzzer
-- Screen service (siid=7)
--   piid=1 on, bool, RW -> xiaomiAirVa3Display.display
--   piid=2 brightness, uint8, RW; 0=Dim, 1=Normal -> xiaomiAirVa3DisplayLevel.displayLevel
-- Physical Control Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW -> xiaomiAirVa3ChildLock.childLock
-- Air Purifier Favorite service (siid=9)
--   piid=1 fan-level, uint8, RW; 0=0, 1=1, 2=2, 3=3, 4=4, 5=5, 6=6, 7=7, 8=8, 9=9, 10=10: not exposed
-- filter-debug service (siid=10)
--   piid=1 filter-used-time, uint16, W; range 0..10000 step 1 hours: not exposed
--   piid=2 filter-used-life, uint8, W; range 0..100 step 1 percentage: not exposed
-- filter-tag service (siid=11)
--   piid=1 tag, string, R: not exposed
--   piid=2 factory-id, string, R: not exposed
--   piid=3 product-id, string, R: not exposed
--   piid=4 date, string, R: not exposed
--   piid=5 serial-number, string, R: not exposed
-- aqi service (siid=12)
--   piid=1 update-heartbeat, uint16, RW; range 0..65535 step 1: not exposed
-- custom-service service (siid=13)
--   piid=1 favorite-square, string, R: not exposed
--   piid=2 reboot-cause, uint8, R; 1=Power, 2=External-pin, 3=Software, 4=IWDG, 5=Unknown: not exposed
--   piid=3 motor-rpm-set, uint16, R; range 0..10000 step 1: not exposed
--   piid=4 motor-rpm-feedback, uint16, R; range 0..10000 step 1: not exposed
--   piid=5 hcho-tag, string, R: not exposed
--   piid=6 iic-error-cnt, uint16, R; range 0..65535 step 1: not exposed
--   piid=7 hcho-original, float, R; range 0..10 step 0.001 mg/m3: not exposed
--   piid=10 common-property, string, R: not exposed
--   piid=11 motor-rpm-debug, uint16, W; range 0..10000 step 1: not exposed
--   piid=12 particle-abnormal-on, bool, RW: not exposed
-- Self Check service (siid=14)
--   piid=1 self-check-items, uint8, R; 0=All, 1=Motor, 2=Filter, 3=HCHO-Sensor, 4=Particle-Sensor, 5=Temp-Sensor, 6=Top-Switch, 7=Door-Hall, 8=Key-Power, 9=Key-Mode, 10=Key-Info, 11=Key-Curve, 12=Key-Led: not exposed
--   piid=2 self-check-results, string, R: not exposed
--   piid=3 manual-check-results, uint8, RW; 0=Normal, 1=Abnormal, 2=Ignore: not exposed

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local MODE_PIID = 4
local FAN_LEVEL_PIID = 5
local ANION_PIID = 6
local UV_PIID = 7

local ENVIRONMENT_SIID = 3
local RELATIVE_HUMIDITY_PIID = 1
local PM2_5_DENSITY_PIID = 4
local PM10_DENSITY_PIID = 5
local TEMPERATURE_PIID = 7
local HCHO_DENSITY_PIID = 11

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 1
local RESET_FILTER_LIFE_AIID = 1

local ALARM_SIID = 6
local ALARM_PIID = 1

local SCREEN_SIID = 7
local ON2_PIID = 1
local BRIGHTNESS_PIID = 2

local PHYSICAL_CONTROLS_LOCKED_SIID = 8
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [3] = "sleep",
    [5] = "favorite",
    [6] = "none"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    ["auto"] = 0,
    ["favorite"] = 5,
    ["none"] = 6,
    ["sleep"] = 3
}

-- MIoT -> SmartThings
local FAN_LEVEL_TO_ST = {
    [0] = "level1",
    [1] = "level2",
    [2] = "level3"
}

-- SmartThings -> MIoT
local ST_TO_FAN_LEVEL = {
    ["level1"] = 0,
    ["level2"] = 1,
    ["level3"] = 2
}

-- MIoT -> SmartThings
local BRIGHTNESS_TO_ST = {
    [0] = "dim",
    [1] = "bright"
}

-- SmartThings -> MIoT
local ST_TO_BRIGHTNESS = {
    ["bright"] = 1,
    ["dim"] = 0
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
    if not device:supports_capability_by_id("concertmirror08464.xiaomiAirVa3Mode", "main") then
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
        {siid = AIR_PURIFIER_SIID, piid = FAN_LEVEL_PIID},
        {siid = ENVIRONMENT_SIID, piid = RELATIVE_HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM2_5_DENSITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM10_DENSITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = HCHO_DENSITY_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = AIR_PURIFIER_SIID, piid = ANION_PIID},
        {siid = AIR_PURIFIER_SIID, piid = UV_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = SCREEN_SIID, piid = ON2_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID}
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
                elseif piid == FAN_LEVEL_PIID then
                    local mapped = FAN_LEVEL_TO_ST[value]
                    if mapped then
                        device:emit_event(fanLevelCap.fanLevel({value = mapped}))
                    end
                elseif piid == ANION_PIID then
                    device:emit_event(anionCap.anion({value = bool_to_st(value)}))
                elseif piid == UV_PIID then
                    device:emit_event(uvCap.uv({value = bool_to_st(value)}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == RELATIVE_HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == PM2_5_DENSITY_PIID then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
                elseif piid == PM10_DENSITY_PIID then
                    device:emit_event(capabilities.dustSensor.dustLevel(math.floor(value)))
                elseif piid == HCHO_DENSITY_PIID then
                    device:emit_event(capabilities.formaldehydeMeasurement.formaldehydeLevel({value = value, unit = "mg/m^3"}))
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
                if piid == ON2_PIID then
                    device:emit_event(displayCap.display({value = bool_to_st(value)}))
                elseif piid == BRIGHTNESS_PIID then
                    local mapped = BRIGHTNESS_TO_ST[value]
                    if mapped then
                        device:emit_event(displayLevelCap.displayLevel({value = mapped}))
                    end
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

local function set_fanLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.fanLevel
    local value = ST_TO_FAN_LEVEL[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, FAN_LEVEL_PIID, value)
    if ok then
        device:emit_event(fanLevelCap.fanLevel({value = requested}))
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

local set_anion_handler = make_bool_handler(AIR_PURIFIER_SIID, ANION_PIID, anionCap, "anion", "anion")
local set_uv_handler = make_bool_handler(AIR_PURIFIER_SIID, UV_PIID, uvCap, "uv", "uv")
local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_childLock_handler = make_bool_handler(PHYSICAL_CONTROLS_LOCKED_SIID, PHYSICAL_CONTROLS_LOCKED_PIID, childLockCap, "childLock", "childLock")
local set_display_handler = make_bool_handler(SCREEN_SIID, ON2_PIID, displayCap, "display", "display")

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
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(anionCap.anion({value = "off"}))
    device:emit_event(uvCap.uv({value = "off"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayCap.display({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "dim"}))
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

local driver = Driver("miot-xiaomi-air-purifier-va3", {
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
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fanLevel_handler
        },
        [anionCap.ID] = {
            [anionCap.commands.setAnion.NAME] = set_anion_handler
        },
        [uvCap.ID] = {
            [uvCap.commands.setUv.NAME] = set_uv_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_childLock_handler
        },
        [displayCap.ID] = {
            [displayCap.commands.setDisplay.NAME] = set_display_handler
        },
        [displayLevelCap.ID] = {
            [displayLevelCap.commands.setDisplayLevel.NAME] = set_displayLevel_handler
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
