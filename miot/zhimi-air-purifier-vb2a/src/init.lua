-- Zhimi Air Purifier VB2A Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.zhimiAirVb2aMode"]
local fanLevelCap = capabilities["concertmirror08464.zhimiAirVb2aFanLevel"]
local buzzerCap = capabilities["concertmirror08464.zhimiAirVb2aBuzzer"]
local childLockCap = capabilities["concertmirror08464.zhimiAirVb2aChildLock"]
local displayCap = capabilities["concertmirror08464.zhimiAirVb2aDisplay"]
local displayLevelCap = capabilities["concertmirror08464.zhimiAirVb2aDisplayLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "zhimi-air-purifier-vb2a"

-- MIoT model: zhimi.airp.vb2a
-- specModel: zhimi-vb2a
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-vb2a:1
--
-- Air Purifier service (siid=2)
--   piid=1 fault, uint8, R; 0=No faults, 1=m1_run, 2=m1_stuck, 3=no_sensor, 4=error_hum, 5=error_temp, 6=timer_error1, 7=timer_error2: not exposed
--   piid=2 on, bool, RW -> switch
--   piid=4 fan-level, uint8, RW; 1=Level1, 2=Level2, 3=Level3, 0=Sleep -> zhimiAirVb2aFanLevel.fanLevel
--   piid=5 mode, uint8, RW; 0=Auto, 1=Sleep, 2=Favorite, 3=None -> zhimiAirVb2aMode.airPurifierMode
-- Environment service (siid=3)
--   piid=6 pm2.5-density, float, R; range 0..600 step 1 -> dustSensor.fineDustLevel
--   piid=7 relative-humidity, uint8, R; range 0..100 step 1 percentage -> relativeHumidityMeasurement
--   piid=8 temperature, float, R; range -40..125 step 0.1 -> temperatureMeasurement
-- Filter service (siid=4)
--   piid=3 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
--   piid=5 filter-used-time, uint16, R; range 0..18000 step 1 hours: not exposed
-- Alarm service (siid=5)
--   piid=1 alarm, bool, RW -> zhimiAirVb2aBuzzer.buzzer
--   piid=2 volume, uint8, RW; range 0..100 step 1 percentage: not exposed
-- Indicator Light service (siid=6)
--   piid=1 brightness, uint8, RW; 0=brightest, 1=glimmer, 2=not bright -> zhimiAirVb2aDisplayLevel.displayLevel
--   piid=6 on, bool, RW -> zhimiAirVb2aDisplay.display
-- Physical Control Locked service (siid=7)
--   piid=1 physical-controls-locked, bool, RW -> zhimiAirVb2aChildLock.childLock
-- button service (siid=8)
--   piid=1 button-pressed, string, R: not exposed
-- filter-time service (siid=9)
--   piid=1 filter-max-time, int32, RW; range 2000..8000 step 1 hours: not exposed
--   piid=2 filter-hour-used-debug, int32, RW; range 0..8000 step 1 hours: not exposed
-- motor-speed service (siid=10)
--   piid=2 m1-high, int32, RW; range 300..2100 step 10: not exposed
--   piid=3 m1-med, int32, RW; range 300..2100 step 10: not exposed
--   piid=4 m1-med-l, int32, RW; range 300..2100 step 10: not exposed
--   piid=5 m1-low, int32, RW; range 300..2100 step 10: not exposed
--   piid=6 m1-silent, int32, RW; range 300..2100 step 10: not exposed
--   piid=7 m1-favorite, int32, R; range 300..2300 step 10: not exposed
--   piid=8 motor1-speed, int32, R; range 0..10000 step 1: not exposed
--   piid=9 motor1-set-speed, int32, R; range 0..10000 step 1: not exposed
--   piid=10 favorite-level, int32, RW; range 0..9 step 1: not exposed
-- use-time service (siid=12)
--   piid=1 use-time, int32, R; range 0..2147483647 step 1 seconds: not exposed
-- aqi service (siid=13)
--   piid=1 purify-volume, int32, R; range 0..2147483647 step 1: not exposed
--   piid=2 average-aqi, int32, R; range 0..600 step 1: not exposed
--   piid=3 average-aqi-cnt, int32, R; range 0..2147483647 step 1: not exposed
--   piid=4 aqi-zone, string, R: not exposed
--   piid=5 sensor-state, int32, R; 0=waiting, 1=ready: not exposed
--   piid=6 aqi-goodh, int32, RW; range 36..114 step 1: not exposed
--   piid=7 aqi-runstate, int32, R; 0=continue, 1=hold, 2=sleep: not exposed
--   piid=8 aqi-state, int32, R; 0=AQI_GOOD_L, 1=AQI_GOOD_H, 2=AQI_MID_L, 3=AQI_MID_H, 4=AQI_BAD_L, 5=AQI_BAD_H: not exposed
--   piid=9 aqi-updata-heartbeat, uint16, W; range 1..65535 step 1 seconds: not exposed
-- rfid service (siid=14)
--   piid=1 rfid-tag, string, R: not exposed
--   piid=2 rfid-factory-id, string, R: not exposed
--   piid=3 rfid-product-id, string, R: not exposed
--   piid=4 rfid-time, string, R: not exposed
--   piid=5 rfid-serial-num, string, R: not exposed
-- others service (siid=15)
--   piid=1 app-extra, int32, RW; range 0..2147483647 step 1: not exposed
--   piid=2 main-channel, int32, R; range 0..2147483647 step 1: not exposed
--   piid=3 slave-channel, int32, R; range 0..2147483647 step 1: not exposed
--   piid=4 cola, string, RW: not exposed
--   piid=5 buttom-door, string, R: not exposed
--   piid=6 reboot-cause, int32, R; 0=REASON_HW_BOOT, 1=REASON_USER_REBOOT, 2=REASON_UPDATE, 3=REASON_WDT: not exposed
--   piid=7 manual-level, int32, R; 1=level1, 2=level2, 3=level3: not exposed
--   piid=8 powertime, int32, R; range 0..2147483647 step 1: not exposed
--   piid=9 country-code, int32, RW; 91=印度, 44=分销英文, 852=中国香港, 886=中国台湾, 82=韩国: not exposed

local AIR_PURIFIER_SIID = 2
local ON_PIID = 2
local FAN_LEVEL_PIID = 4
local MODE_PIID = 5

local ENVIRONMENT_SIID = 3
local PM2_5_DENSITY_PIID = 6
local RELATIVE_HUMIDITY_PIID = 7
local TEMPERATURE_PIID = 8

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 3

local ALARM_SIID = 5
local ALARM_PIID = 1

local INDICATOR_LIGHT_SIID = 6
local BRIGHTNESS_PIID = 1
local ON2_PIID = 6

local PHYSICAL_CONTROLS_LOCKED_SIID = 7
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite",
    [3] = "none"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    ["auto"] = 0,
    ["favorite"] = 2,
    ["none"] = 3,
    ["sleep"] = 1
}

-- MIoT -> SmartThings
local FAN_LEVEL_TO_ST = {
    [0] = "sleep",
    [1] = "level1",
    [2] = "level2",
    [3] = "level3"
}

-- SmartThings -> MIoT
local ST_TO_FAN_LEVEL = {
    ["level1"] = 1,
    ["level2"] = 2,
    ["level3"] = 3,
    ["sleep"] = 0
}

-- MIoT -> SmartThings
local BRIGHTNESS_TO_ST = {
    [0] = "brightest",
    [1] = "dim",
    [2] = "off"
}

-- SmartThings -> MIoT
local ST_TO_BRIGHTNESS = {
    ["brightest"] = 0,
    ["dim"] = 1,
    ["off"] = 2
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
    if not device:supports_capability_by_id("concertmirror08464.zhimiAirVb2aMode", "main") then
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
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = ON2_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = BRIGHTNESS_PIID}
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
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == RELATIVE_HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == PM2_5_DENSITY_PIID then
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
            elseif siid == INDICATOR_LIGHT_SIID then
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

    local ok = pcall(miot.set, device, ip, token, INDICATOR_LIGHT_SIID, BRIGHTNESS_PIID, value)
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

local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_childLock_handler = make_bool_handler(PHYSICAL_CONTROLS_LOCKED_SIID, PHYSICAL_CONTROLS_LOCKED_PIID, childLockCap, "childLock", "childLock")
local set_display_handler = make_bool_handler(INDICATOR_LIGHT_SIID, ON2_PIID, displayCap, "display", "display")

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(airPurifierModeCap.airPurifierMode({value = "auto"}))
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayCap.display({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "brightest"}))
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

local driver = Driver("miot-zhimi-air-purifier-vb2a", {
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
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
