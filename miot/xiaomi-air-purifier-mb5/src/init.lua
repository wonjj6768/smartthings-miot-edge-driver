-- Mijia Smart Air Purifier 6 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.xiaomiAirMb5Mode"]
local fanLevelCap = capabilities["concertmirror08464.xiaomiAirMb5FanLevel"]
local favoriteFanLevelCap = capabilities["concertmirror08464.xiaomiAirMb5FavoriteFanLevel"]
local airQualityCap = capabilities["concertmirror08464.xiaomiAirMb5AirQuality"]
local anionCap = capabilities["concertmirror08464.xiaomiAirMb5Anion"]
local uvCap = capabilities["concertmirror08464.xiaomiAirMb5Uv"]
local buzzerCap = capabilities["concertmirror08464.xiaomiAirMb5Buzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiAirMb5ChildLock"]
local displayCap = capabilities["concertmirror08464.xiaomiAirMb5Display"]
local displayLevelCap = capabilities["concertmirror08464.xiaomiAirMb5DisplayLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "xiaomi-air-purifier-mb5"
local EXPECTED_CAPABILITY_IDS = {
    airPurifierModeCap.ID,
    fanLevelCap.ID,
    favoriteFanLevelCap.ID,
    capabilities.veryFineDustSensor.ID,
    airQualityCap.ID,
    anionCap.ID,
    uvCap.ID,
    buzzerCap.ID,
    childLockCap.ID,
    displayCap.ID,
    displayLevelCap.ID
}

-- MIoT model: xiaomi.airp.mb5
-- specModel: xiaomi-mb5
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-mb5:1:0000D050
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=None, 1=PM, 2=temperature/humidity,
--     3=no filter, 4=motor stuck: not exposed
--   piid=4 mode, uint8, RW; 0=Auto, 3=Sleep, 5=Favorite, 6=None/Idle
--     -> xiaomiAirMb5Mode.airPurifierMode
--   piid=5 fan-level, uint8, RW; 0=Level1, 1=Level2, 2=Level3
--     -> xiaomiAirMb5FanLevel.fanLevel
--   piid=6 anion, bool, RW -> xiaomiAirMb5Anion.anion
--   piid=7 uv, bool, RW -> xiaomiAirMb5Uv.uv
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R; 0..100 step 1 percentage
--     -> relativeHumidityMeasurement
--   piid=3 air-quality, uint8, R; 0=Excellent, 1=Good, 2=Moderate,
--     3=Poor, 4=Heavy Pollution, 5=Hazardous -> xiaomiAirMb5AirQuality.airQuality
--   piid=4 pm2.5-density, uint16, R; 0..1000 step 1 μg/m3
--     -> dustSensor.fineDustLevel
--   piid=5 pm10-density, uint16, R; 0..100 step 1 -> dustSensor.dustLevel
--   piid=7 temperature, float, R; -30..100 step 0.1 celsius
--     -> temperatureMeasurement
--   piid=9 pm1, uint16, R; 0..1000 step 1 μg/m3
--     -> veryFineDustSensor.veryFineDustLevel
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R; 0..100 step 1 percentage
--     -> filterState.filterLifeRemaining
--   piid=2 filter-left-time, uint16, R; 0..10000 step 1 hours: not exposed
--   piid=3 filter-used-time, uint16, R; 0..10000 step 1 hours: not exposed
--   aiid=1 reset-filter-life, Action -> filterState.resetFilter
-- Alarm service (siid=6)
--   piid=1 alarm, bool, RW -> xiaomiAirMb5Buzzer.buzzer
-- Screen service (siid=7)
--   piid=1 on, bool, RW -> xiaomiAirMb5Display.display
--   piid=2 brightness, uint8, RW; 0=Dim, 1=Normal
--     -> xiaomiAirMb5DisplayLevel.displayLevel
-- Physical Controls Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW -> xiaomiAirMb5ChildLock.childLock
-- Air Purifier Favorite service (siid=9)
--   piid=1 fan-level, uint8, RW; values 0..11
--     -> xiaomiAirMb5FavoriteFanLevel.favoriteFanLevel
-- Private filter debug/tag, AQI heartbeat, country, RPM, reboot cause and
-- device events are not exposed. The exact spec has no separate pet-lock property.

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local MODE_PIID = 4
local FAN_LEVEL_PIID = 5
local ANION_PIID = 6
local UV_PIID = 7

local ENVIRONMENT_SIID = 3
local RELATIVE_HUMIDITY_PIID = 1
local AIR_QUALITY_PIID = 3
local PM2_5_DENSITY_PIID = 4
local PM10_DENSITY_PIID = 5
local TEMPERATURE_PIID = 7
local PM1_PIID = 9

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 1
local RESET_FILTER_LIFE_AIID = 1

local ALARM_SIID = 6
local ALARM_PIID = 1

local SCREEN_SIID = 7
local SCREEN_ON_PIID = 1
local BRIGHTNESS_PIID = 2

local PHYSICAL_CONTROLS_LOCKED_SIID = 8
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

local FAVORITE_SIID = 9
local FAVORITE_FAN_LEVEL_PIID = 1

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [3] = "sleep",
    [5] = "favorite",
    [6] = "idle"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    auto = 0,
    sleep = 3,
    favorite = 5,
    idle = 6
}

-- MIoT -> SmartThings
local FAN_LEVEL_TO_ST = {
    [0] = "level1",
    [1] = "level2",
    [2] = "level3"
}

-- SmartThings -> MIoT
local ST_TO_FAN_LEVEL = {
    level1 = 0,
    level2 = 1,
    level3 = 2
}

-- MIoT -> SmartThings
local AIR_QUALITY_TO_ST = {
    [0] = "excellent",
    [1] = "good",
    [2] = "moderate",
    [3] = "poor",
    [4] = "heavyPollution",
    [5] = "hazardous"
}

-- MIoT -> SmartThings
local BRIGHTNESS_TO_ST = {
    [0] = "dim",
    [1] = "normal"
}

-- SmartThings -> MIoT
local ST_TO_BRIGHTNESS = {
    dim = 0,
    normal = 1
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    for _, capability_id in ipairs(EXPECTED_CAPABILITY_IDS) do
        if not device:supports_capability_by_id(capability_id, "main") then
            local ok, err = pcall(device.try_update_metadata, device, {profile = PROFILE_NAME})
            if not ok then
                device.log.error("MB5 profile update failed: " .. tostring(err))
            end
            return
        end
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
        {siid = AIR_PURIFIER_SIID, piid = ANION_PIID},
        {siid = AIR_PURIFIER_SIID, piid = UV_PIID},
        {siid = ENVIRONMENT_SIID, piid = RELATIVE_HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = AIR_QUALITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM2_5_DENSITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM10_DENSITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM1_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_ON_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = FAVORITE_SIID, piid = FAVORITE_FAN_LEVEL_PIID}
    }

    local response = miot.gets(device, ip, token, properties)
    if not response or type(response.result) ~= "table" then
        local response_error = response and response.error
        local code = response_error and response_error.code or "unknown"
        local message = response_error and response_error.message or "missing result"
        error(string.format("get_properties response error code=%s message=%s", tostring(code), tostring(message)))
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == AIR_PURIFIER_SIID then
                if piid == ON_PIID and type(value) == "boolean" then
                    device:emit_event(value and capabilities.switch.switch.on() or capabilities.switch.switch.off())
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
                elseif piid == ANION_PIID and type(value) == "boolean" then
                    device:emit_event(anionCap.anion({value = bool_to_st(value)}))
                elseif piid == UV_PIID and type(value) == "boolean" then
                    device:emit_event(uvCap.uv({value = bool_to_st(value)}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == RELATIVE_HUMIDITY_PIID and type(value) == "number" then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID and type(value) == "number" then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == AIR_QUALITY_PIID then
                    local mapped = AIR_QUALITY_TO_ST[value]
                    if mapped then
                        device:emit_event(airQualityCap.airQuality({value = mapped}))
                    end
                elseif piid == PM2_5_DENSITY_PIID and type(value) == "number" then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
                elseif piid == PM10_DENSITY_PIID and type(value) == "number" then
                    device:emit_event(capabilities.dustSensor.dustLevel(math.floor(value)))
                elseif piid == PM1_PIID and type(value) == "number" then
                    device:emit_event(capabilities.veryFineDustSensor.veryFineDustLevel({
                        value = math.floor(value),
                        unit = "μg/m^3"
                    }))
                end
            elseif siid == FILTER_SIID then
                if piid == FILTER_LIFE_LEVEL_PIID and type(value) == "number" then
                    device:emit_event(capabilities.filterState.filterLifeRemaining({
                        value = math.floor(value),
                        unit = "%"
                    }))
                end
            elseif siid == ALARM_SIID then
                if piid == ALARM_PIID and type(value) == "boolean" then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                end
            elseif siid == SCREEN_SIID then
                if piid == SCREEN_ON_PIID and type(value) == "boolean" then
                    device:emit_event(displayCap.display({value = bool_to_st(value)}))
                elseif piid == BRIGHTNESS_PIID then
                    local mapped = BRIGHTNESS_TO_ST[value]
                    if mapped then
                        device:emit_event(displayLevelCap.displayLevel({value = mapped}))
                    end
                end
            elseif siid == PHYSICAL_CONTROLS_LOCKED_SIID then
                if piid == PHYSICAL_CONTROLS_LOCKED_PIID and type(value) == "boolean" then
                    device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
                end
            elseif siid == FAVORITE_SIID then
                if piid == FAVORITE_FAN_LEVEL_PIID and type(value) == "number" then
                    device:emit_event(favoriteFanLevelCap.favoriteFanLevel(math.floor(value)))
                end
            end
        else
            device.log.error(string.format(
                "MB5 get_properties property failed siid=%s piid=%s code=%s",
                tostring(result.siid),
                tostring(result.piid),
                tostring(result.code)
            ))
        end
    end
end

local function run_poll(device, source)
    local ok, err = pcall(poll_device_status, device)
    if not ok then
        device.log.error(string.format("MB5 poll failed (%s): %s", source, tostring(err)))
    end
end

local function schedule_poll(device, source)
    device.thread:call_with_delay(1, function()
        run_poll(device, source)
    end)
end

local function start_polling_timer(device)
    local existing_timer = device:get_field(POLLING_TIMER)
    if existing_timer then
        device.thread:cancel_timer(existing_timer)
    end

    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function()
        run_poll(device, "timer")
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

local function set_miot_property(device, siid, piid, value, source)
    local ip, token = get_device_config(device)
    if not ip then
        device.log.error("MB5 " .. source .. " failed: invalid or missing IP/token preferences")
        return false
    end

    local ok, err = pcall(miot.set, device, ip, token, siid, piid, value)
    if not ok then
        device.log.error("MB5 " .. source .. " failed: " .. tostring(err))
        return false
    end

    schedule_poll(device, source)
    return true
end

local function switch_on_handler(_, device, _)
    if set_miot_property(device, AIR_PURIFIER_SIID, ON_PIID, true, "power-on") then
        device:emit_event(capabilities.switch.switch.on())
    end
end

local function switch_off_handler(_, device, _)
    if set_miot_property(device, AIR_PURIFIER_SIID, ON_PIID, false, "power-off") then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_air_purifier_mode_handler(_, device, command)
    local requested = command.args.airPurifierMode
    local value = ST_TO_MODE[requested]
    if value == nil then
        return
    end

    if set_miot_property(device, AIR_PURIFIER_SIID, MODE_PIID, value, "mode") then
        device:emit_event(airPurifierModeCap.airPurifierMode({value = requested}))
    end
end

local function set_fan_level_handler(_, device, command)
    local requested = command.args.fanLevel
    local value = ST_TO_FAN_LEVEL[requested]
    if value == nil then
        return
    end

    if set_miot_property(device, AIR_PURIFIER_SIID, FAN_LEVEL_PIID, value, "fan-level") then
        device:emit_event(fanLevelCap.fanLevel({value = requested}))
    end
end

local function set_favorite_fan_level_handler(_, device, command)
    local requested = command.args.favoriteFanLevel
    if type(requested) ~= "number" or requested < 0 or requested > 11 then
        return
    end

    local value = math.floor(requested)
    if set_miot_property(device, FAVORITE_SIID, FAVORITE_FAN_LEVEL_PIID, value, "favorite-fan-level") then
        device:emit_event(favoriteFanLevelCap.favoriteFanLevel(value))
    end
end

local function set_display_level_handler(_, device, command)
    local requested = command.args.displayLevel
    local value = ST_TO_BRIGHTNESS[requested]
    if value == nil then
        return
    end

    if set_miot_property(device, SCREEN_SIID, BRIGHTNESS_PIID, value, "display-level") then
        device:emit_event(displayLevelCap.displayLevel({value = requested}))
    end
end

local function make_bool_handler(siid, piid, capability, attribute, argument, source)
    return function(_, device, command)
        local requested = command.args[argument]
        if requested ~= "on" and requested ~= "off" then
            return
        end

        if set_miot_property(device, siid, piid, requested == "on", source) then
            device:emit_event(capability[attribute]({value = requested}))
        end
    end
end

local set_anion_handler = make_bool_handler(
    AIR_PURIFIER_SIID, ANION_PIID, anionCap, "anion", "anion", "anion"
)
local set_uv_handler = make_bool_handler(
    AIR_PURIFIER_SIID, UV_PIID, uvCap, "uv", "uv", "uv"
)
local set_buzzer_handler = make_bool_handler(
    ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer", "buzzer"
)
local set_child_lock_handler = make_bool_handler(
    PHYSICAL_CONTROLS_LOCKED_SIID,
    PHYSICAL_CONTROLS_LOCKED_PIID,
    childLockCap,
    "childLock",
    "childLock",
    "child-lock"
)
local set_display_handler = make_bool_handler(
    SCREEN_SIID, SCREEN_ON_PIID, displayCap, "display", "display", "display"
)

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then
        device.log.error("MB5 reset-filter failed: invalid or missing IP/token preferences")
        return
    end

    local ok, err = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_LIFE_AIID, {})
    if not ok then
        device.log.error("MB5 reset-filter failed: " .. tostring(err))
        return
    end

    schedule_poll(device, "reset-filter")
end

local function refresh_handler(_, device, _)
    ensure_profile(device)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    run_poll(device, "refresh")
end

local function emit_initial_state(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(airPurifierModeCap.airPurifierMode({value = "auto"}))
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(favoriteFanLevelCap.favoriteFanLevel(0))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.dustSensor.dustLevel(0))
    device:emit_event(capabilities.veryFineDustSensor.veryFineDustLevel({value = 0, unit = "μg/m^3"}))
    device:emit_event(airQualityCap.airQuality({value = "excellent"}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(anionCap.anion({value = "off"}))
    device:emit_event(uvCap.uv({value = "off"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayCap.display({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "normal"}))
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    emit_initial_state(device)
    run_poll(device, "added")
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))

    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        run_poll(device, "init")
    else
        device.log.error("MB5 polling disabled: invalid or missing IP/token preferences")
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

    if old.createDev ~= true and new.createDev == true then
        discovery.create_device(driver)
    end

    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)

        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            run_poll(device, "preferences")
        else
            device.log.error("MB5 polling disabled: invalid or missing IP/token preferences")
        end
    end
end

local driver = Driver("miot-xiaomi-air-purifier-mb5", {
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
            [airPurifierModeCap.commands.setAirPurifierMode.NAME] = set_air_purifier_mode_handler
        },
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fan_level_handler
        },
        [favoriteFanLevelCap.ID] = {
            [favoriteFanLevelCap.commands.setFavoriteFanLevel.NAME] = set_favorite_fan_level_handler
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
            [childLockCap.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [displayCap.ID] = {
            [displayCap.commands.setDisplay.NAME] = set_display_handler
        },
        [displayLevelCap.ID] = {
            [displayLevelCap.commands.setDisplayLevel.NAME] = set_display_level_handler
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
