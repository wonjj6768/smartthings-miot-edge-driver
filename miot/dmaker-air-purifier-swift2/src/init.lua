-- Dmaker Air Purifier Swift 2 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.dmakerAirSwift2Mode"]
local fanLevelCap = capabilities["concertmirror08464.dmakerAirSwift2FanLevel"]
local fanOnCap = capabilities["concertmirror08464.dmakerAirSwift2FanOn"]
local fanSpeedCap = capabilities["concertmirror08464.dmakerAirSwift2FanSpeed"]
local swingCap = capabilities["concertmirror08464.dmakerAirSwift2Swing"]
local swingAngleCap = capabilities["concertmirror08464.dmakerAirSwift2SwingAngle"]
local anionCap = capabilities["concertmirror08464.dmakerAirSwift2Anion"]
local screenCap = capabilities["concertmirror08464.dmakerAirSwift2Screen"]
local buzzerCap = capabilities["concertmirror08464.dmakerAirSwift2Buzzer"]
local volumeCap = capabilities["concertmirror08464.dmakerAirSwift2Volume"]
local childLockCap = capabilities["concertmirror08464.dmakerAirSwift2ChildLock"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "dmaker-air-purifier-swift2"

-- MIoT model: dmaker.airp.swift2
-- specModel: dmaker-swift2
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:dmaker-swift2:1
--
-- This model combines a purifier and a circulating fan, so the fan service is
-- exposed with its own on switch, 1..100 speed, swing, and swing angle.
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW
--   piid=2 fault, uint8, R, vendor code, not exposed
--   piid=4 mode, uint8, RW enum: 0=smart, 1=sleep, 2=purification, 3=fan
--   piid=7 fan-level, uint8, RW enum: 1..3 (purifier stage)
--   piid=8 anion, bool, RW
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, percent
--   piid=4 pm2.5-density, float, R
--   piid=7 temperature, float, R, celsius
--   piid=8 voc-density, uint16, R, ppb
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R, percent
--   piid=2 filter-left-time is a countdown duplicate of the life level
-- Alarm service (siid=6)
--   piid=1 alarm, bool, RW
--   piid=2 volume, uint8, RW enum 0..3
-- Screen service (siid=7)
--   piid=2 brightness, uint8, RW enum: 0=off, 1=auto, 2=half, 3=full
-- Physical Controls Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW
-- Fan service (siid=10)
--   piid=1 on, bool, RW
--   piid=2 fan-level, uint8, RW range 1..100
--   piid=3 horizontal-swing, bool, RW
--   piid=5 horizontal-swing-included-angle, uint8, RW 30/60/90
-- dm-sevice service (siid=9): fan-mode purify overrides, per-mode rise angles,
--   anion state machine, and the filter rate setter are vendor tuning fields

local PURIFIER_SIID = 2
local POWER_PIID = 1
local MODE_PIID = 4
local PURIFIER_LEVEL_PIID = 7
local ANION_PIID = 8

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1
local PM25_PIID = 4
local TEMPERATURE_PIID = 7
local VOC_PIID = 8

local FILTER_SIID = 4
local FILTER_LIFE_PIID = 1

local ALARM_SIID = 6
local ALARM_PIID = 1
local VOLUME_PIID = 2

local SCREEN_SIID = 7
local BRIGHTNESS_PIID = 2

local LOCK_SIID = 8
local LOCK_PIID = 1

local FAN_SIID = 10
local FAN_ON_PIID = 1
local FAN_SPEED_PIID = 2
local FAN_SWING_PIID = 3
local FAN_ANGLE_PIID = 5

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "smart",
    [1] = "sleep",
    [2] = "purification",
    [3] = "fan"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    smart = 0,
    sleep = 1,
    purification = 2,
    fan = 3
}

local LEVEL_TO_ST = {
    [1] = "level1",
    [2] = "level2",
    [3] = "level3"
}

local ST_TO_LEVEL = {
    level1 = 1,
    level2 = 2,
    level3 = 3
}

local BRIGHTNESS_TO_ST = {
    [0] = "off",
    [1] = "auto",
    [2] = "half",
    [3] = "full"
}

local ST_TO_BRIGHTNESS = {
    off = 0,
    auto = 1,
    half = 2,
    full = 3
}

local ANGLE_TO_ST = {
    [30] = "deg30",
    [60] = "deg60",
    [90] = "deg90"
}

local ST_TO_ANGLE = {
    deg30 = 30,
    deg60 = 60,
    deg90 = 90
}

local VOLUME_MAX = 3
local FAN_SPEED_MIN = 1
local FAN_SPEED_MAX = 100

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
        {siid = PURIFIER_SIID, piid = PURIFIER_LEVEL_PIID},
        {siid = PURIFIER_SIID, piid = ANION_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = VOC_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = ALARM_SIID, piid = VOLUME_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID},
        {siid = LOCK_SIID, piid = LOCK_PIID},
        {siid = FAN_SIID, piid = FAN_ON_PIID},
        {siid = FAN_SIID, piid = FAN_SPEED_PIID},
        {siid = FAN_SIID, piid = FAN_SWING_PIID},
        {siid = FAN_SIID, piid = FAN_ANGLE_PIID}
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
                elseif piid == PURIFIER_LEVEL_PIID then
                    local level = LEVEL_TO_ST[value]
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
                elseif piid == VOC_PIID then
                    device:emit_event(capabilities.tvocMeasurement.tvocLevel({value = value, unit = "ppb"}))
                end
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == ALARM_SIID then
                if piid == ALARM_PIID then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                elseif piid == VOLUME_PIID then
                    device:emit_event(volumeCap.buzzerVolume({value = value}))
                end
            elseif siid == SCREEN_SIID and piid == BRIGHTNESS_PIID then
                local brightness = BRIGHTNESS_TO_ST[value]
                if brightness then
                    device:emit_event(screenCap.screenBrightness({value = brightness}))
                end
            elseif siid == LOCK_SIID and piid == LOCK_PIID then
                device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
            elseif siid == FAN_SIID then
                if piid == FAN_ON_PIID then
                    device:emit_event(fanOnCap.fanOn({value = bool_to_st(value)}))
                elseif piid == FAN_SPEED_PIID then
                    device:emit_event(fanSpeedCap.fanSpeed({value = value, unit = "%"}))
                elseif piid == FAN_SWING_PIID then
                    device:emit_event(swingCap.horizontalSwing({value = bool_to_st(value)}))
                elseif piid == FAN_ANGLE_PIID then
                    local angle = ANGLE_TO_ST[value]
                    if angle then
                        device:emit_event(swingAngleCap.swingAngle({value = angle}))
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
    local value = ST_TO_LEVEL[level]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, PURIFIER_SIID, PURIFIER_LEVEL_PIID, value)
    if ok then
        device:emit_event(fanLevelCap.fanLevel({value = level}))
    end
end

local function set_screen_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.screenBrightness
    local value = ST_TO_BRIGHTNESS[brightness]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(screenCap.screenBrightness({value = brightness}))
    end
end

local function set_swing_angle_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local angle = command.args.swingAngle
    local value = ST_TO_ANGLE[angle]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, FAN_SIID, FAN_ANGLE_PIID, value)
    if ok then
        device:emit_event(swingAngleCap.swingAngle({value = angle}))
    end
end

local function set_fan_speed_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = tonumber(command.args.fanSpeed)
    if not requested then return end

    local value = math.max(FAN_SPEED_MIN, math.min(FAN_SPEED_MAX, math.floor(requested + 0.5)))
    local ok = pcall(miot.set, device, ip, token, FAN_SIID, FAN_SPEED_PIID, value)
    if ok then
        device:emit_event(fanSpeedCap.fanSpeed({value = value, unit = "%"}))
    end
end

local function set_volume_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = tonumber(command.args.buzzerVolume)
    if not requested then return end

    local value = math.max(0, math.min(VOLUME_MAX, math.floor(requested + 0.5)))
    local ok = pcall(miot.set, device, ip, token, ALARM_SIID, VOLUME_PIID, value)
    if ok then
        device:emit_event(volumeCap.buzzerVolume({value = value}))
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
local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_child_lock_handler = make_bool_handler(LOCK_SIID, LOCK_PIID, childLockCap, "childLock", "childLock")
local set_fan_on_handler = make_bool_handler(FAN_SIID, FAN_ON_PIID, fanOnCap, "fanOn", "fanOn")
local set_swing_handler = make_bool_handler(FAN_SIID, FAN_SWING_PIID, swingCap, "horizontalSwing", "horizontalSwing")

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
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.tvocMeasurement.tvocLevel({value = 0, unit = "ppb"}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(fanOnCap.fanOn({value = "off"}))
    device:emit_event(fanSpeedCap.fanSpeed({value = 1, unit = "%"}))
    device:emit_event(swingCap.horizontalSwing({value = "off"}))
    device:emit_event(swingAngleCap.swingAngle({value = "deg30"}))
    device:emit_event(anionCap.anion({value = "off"}))
    device:emit_event(screenCap.screenBrightness({value = "auto"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(volumeCap.buzzerVolume({value = 2}))
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

local driver = Driver("miot-dmaker-air-purifier-swift2", {
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
        [fanOnCap.ID] = {
            [fanOnCap.commands.setFanOn.NAME] = set_fan_on_handler
        },
        [fanSpeedCap.ID] = {
            [fanSpeedCap.commands.setFanSpeed.NAME] = set_fan_speed_handler
        },
        [swingCap.ID] = {
            [swingCap.commands.setHorizontalSwing.NAME] = set_swing_handler
        },
        [swingAngleCap.ID] = {
            [swingAngleCap.commands.setSwingAngle.NAME] = set_swing_angle_handler
        },
        [anionCap.ID] = {
            [anionCap.commands.setAnion.NAME] = set_anion_handler
        },
        [screenCap.ID] = {
            [screenCap.commands.setScreenBrightness.NAME] = set_screen_handler
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
