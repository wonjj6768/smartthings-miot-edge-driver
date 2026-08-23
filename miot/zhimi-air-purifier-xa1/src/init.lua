-- Zhimi Air Purifier XA1 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.zhimiAirXa1Mode"]
local fanLevelCap = capabilities["concertmirror08464.zhimiAirXa1FanLevel"]
local anionCap = capabilities["concertmirror08464.zhimiAirXa1Anion"]
local buzzerCap = capabilities["concertmirror08464.zhimiAirXa1Buzzer"]
local childLockCap = capabilities["concertmirror08464.zhimiAirXa1ChildLock"]
local displayCap = capabilities["concertmirror08464.zhimiAirXa1Display"]
local displayLevelCap = capabilities["concertmirror08464.zhimiAirXa1DisplayLevel"]
local shutterAngleCap = capabilities["concertmirror08464.zhimiAirXa1ShutterAngle"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "zhimi-air-purifier-xa1"

-- MIoT model: zhimi.airpurifier.xa1
-- specModel: zhimi-xa1
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-xa1:2
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=No Faults, 2= Motor Stuck, 3=No Sensor, 4=Error Hum, 5=Error Temp, 6=Error TVOC: not exposed
--   piid=3 fan-level, uint8, RW; 1=Level1, 2=Level2, 3=Level3 -> zhimiAirXa1FanLevel.fanLevel
--   piid=4 mode, uint8, RW; 0=Auto, 1=Sleep, 2=Favorite, 3=None -> zhimiAirXa1Mode.airPurifierMode
--   piid=5 anion, bool, RW -> zhimiAirXa1Anion.anion
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R; range 0..100 step 1 percentage -> relativeHumidityMeasurement
--   piid=4 pm2.5-density, float, R; range 0..1000 step 1 μg/m3 -> dustSensor.fineDustLevel
--   piid=7 temperature, float, R; range -30..100 step 0.1 celsius -> temperatureMeasurement
--   piid=8 tvoc-density, int32, R; range 0..500 step 1 μg/m3 -> tvocMeasurement
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
--   piid=3 filter-used-time, uint16, R; range 0..10000 step 1 hours: not exposed
-- indicator-light service (siid=6)
--   piid=2 on, bool, RW -> zhimiAirXa1Display.display
--   piid=3 led-status, uint8, RW; 0=Close, 1=Auto, 2=Brightest, 3=Bright -> zhimiAirXa1DisplayLevel.displayLevel
-- button service (siid=8)
--   piid=1 button-pressed, string, R: not exposed
-- filter-time service (siid=9)
--   piid=2 filter-used-debug, int32, W; range 0..8000 step 1 hours: not exposed
-- motor-speed service (siid=10)
--   piid=8 motor-speed, int32, R; range 0..1000 step 1: not exposed
--   piid=9 motor-set-speed, int32, R; range 0..10000 step 1: not exposed
--   piid=10 favorite-level, int32, RW; range 0..9 step 1: not exposed
-- other service (siid=11)
--   piid=2 main-channel, uint32, R; range 0..99999999 step 1: not exposed
--   piid=3 slave-channel, uint32, R; range 0..99999999 step 1: not exposed
--   piid=5 buttom-door, bool, R: not exposed
--   piid=6 reboot-cause, uint32, R; 0=REASON_HW_BOOT, 1=REASON_USER_REBOOT, 2=REASON_UPDATE, 3=REASON_WDT: not exposed
--   piid=7 manual-level, int32, R; 1=Level1, 2=Level2, 3=Level3: not exposed
--   piid=8 light-value, int32, R; range 0..330 step 1: not exposed
--   piid=9 light-set, int32, R; range 0..15 step 1: not exposed
--   piid=10 shutter-angle, uint8, RW; 0=30°, 1=60°, 2=90° -> zhimiAirXa1ShutterAngle.shutterAngle
-- aqi service (siid=12)
--   piid=1 purify-volume, uint32, R; range 0..2147483600 step 1: not exposed
--   piid=2 average-aqi, uint32, R; range 0..600 step 1: not exposed
--   piid=3 average-aqi-cnt, int32, R; range 0..2147483600 step 1: not exposed
--   piid=4 aqi-zone, string, R: not exposed
--   piid=7 aqi-state, int32, R; 0=AQI_GOOD_L, 1=AQI_GOOD_H, 2=AQI_MID_L, 3=AQI_MID_H, 4=AQI_BAD_L, 5=AQI_BAD_H: not exposed
--   piid=8 aqi-updata-heartbeat, int32, RW; range 0..65535 step 1: not exposed
--   piid=10 tvoc-level, uint8, R; 0=优, 1=良, 2=中, 3=差: not exposed
--   piid=11 ethanol, int32, R; range 0..99999999 step 1: not exposed
--   piid=12 sgp-serial, int32, R; range 0..99999999 step 1: not exposed
--   piid=13 sgp-version, uint32, R; range 0..99999999 step 1: not exposed
--   piid=14 pm-updata, uint32, R; range 0..600 step 1 μg/m3: not exposed
--   piid=15 voc-updata, uint32, R; range 0..500 step 1 μg/m3: not exposed
-- rfid service (siid=13)
--   piid=1 rfid-tag, string, R: not exposed
--   piid=2 rfid-factory-id, string, R: not exposed
--   piid=3 rfid-product-id, string, R: not exposed
--   piid=4 rfid-time, string, R: not exposed
--   piid=5 rfid-serial-num, string, R: not exposed
-- Physical Control Locked service (siid=14)
--   piid=1 physical-controls-locked, bool, RW -> zhimiAirXa1ChildLock.childLock
-- Alarm service (siid=15)
--   piid=1 alarm, bool, RW -> zhimiAirXa1Buzzer.buzzer

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local FAN_LEVEL_PIID = 3
local MODE_PIID = 4
local ANION_PIID = 5

local ENVIRONMENT_SIID = 3
local RELATIVE_HUMIDITY_PIID = 1
local PM2_5_DENSITY_PIID = 4
local TEMPERATURE_PIID = 7
local TVOC_DENSITY_PIID = 8

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 1

local INDICATOR_LIGHT_SIID = 6
local ON2_PIID = 2
local LED_STATUS_PIID = 3

local OTHER_SIID = 11
local SHUTTER_ANGLE_PIID = 10

local PHYSICAL_CONTROLS_LOCKED_SIID = 14
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

local ALARM_SIID = 15
local ALARM_PIID = 1

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
    [1] = "level1",
    [2] = "level2",
    [3] = "level3"
}

-- SmartThings -> MIoT
local ST_TO_FAN_LEVEL = {
    ["level1"] = 1,
    ["level2"] = 2,
    ["level3"] = 3
}

-- MIoT -> SmartThings
local LED_STATUS_TO_ST = {
    [0] = "off",
    [1] = "auto",
    [2] = "brightest",
    [3] = "bright"
}

-- SmartThings -> MIoT
local ST_TO_LED_STATUS = {
    ["auto"] = 1,
    ["bright"] = 3,
    ["brightest"] = 2,
    ["off"] = 0
}

-- MIoT -> SmartThings
local SHUTTER_ANGLE_TO_ST = {
    [0] = "thirty",
    [1] = "sixty",
    [2] = "ninety"
}

-- SmartThings -> MIoT
local ST_TO_SHUTTER_ANGLE = {
    ["ninety"] = 2,
    ["sixty"] = 1,
    ["thirty"] = 0
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
    if not device:supports_capability_by_id("concertmirror08464.zhimiAirXa1Mode", "main") then
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
        {siid = ENVIRONMENT_SIID, piid = TVOC_DENSITY_PIID},
        {siid = AIR_PURIFIER_SIID, piid = ANION_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = ON2_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = LED_STATUS_PIID},
        {siid = OTHER_SIID, piid = SHUTTER_ANGLE_PIID}
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
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == RELATIVE_HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == PM2_5_DENSITY_PIID then
                    device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(value)))
                elseif piid == TVOC_DENSITY_PIID then
                    device:emit_event(capabilities.tvocMeasurement.tvocLevel({value = value, unit = "ug/m3"}))
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
                elseif piid == LED_STATUS_PIID then
                    local mapped = LED_STATUS_TO_ST[value]
                    if mapped then
                        device:emit_event(displayLevelCap.displayLevel({value = mapped}))
                    end
                end
            elseif siid == OTHER_SIID then
                if piid == SHUTTER_ANGLE_PIID then
                    local mapped = SHUTTER_ANGLE_TO_ST[value]
                    if mapped then
                        device:emit_event(shutterAngleCap.shutterAngle({value = mapped}))
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
    local value = ST_TO_LED_STATUS[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, INDICATOR_LIGHT_SIID, LED_STATUS_PIID, value)
    if ok then
        device:emit_event(displayLevelCap.displayLevel({value = requested}))
    end
end

local function set_shutterAngle_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.shutterAngle
    local value = ST_TO_SHUTTER_ANGLE[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, OTHER_SIID, SHUTTER_ANGLE_PIID, value)
    if ok then
        device:emit_event(shutterAngleCap.shutterAngle({value = requested}))
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
    device:emit_event(anionCap.anion({value = "off"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayCap.display({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "off"}))
    device:emit_event(shutterAngleCap.shutterAngle({value = "thirty"}))
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

local driver = Driver("miot-zhimi-air-purifier-xa1", {
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
        [shutterAngleCap.ID] = {
            [shutterAngleCap.commands.setShutterAngle.NAME] = set_shutterAngle_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
