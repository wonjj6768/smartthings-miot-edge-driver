-- Mijia Mist-Free Humidifier 3 Pro Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local controlsMode = capabilities["concertmirror08464.xiaomiHumAirmxMode"]
local controlsTargetHumidity = capabilities["concertmirror08464.xiaomiHumAirmxTargetHumidity"]
local controlsAutomaticAirDrying = capabilities["concertmirror08464.xiaomiHumAirmxAutoAirDrying"]
local controlsIndicatorBrightness = capabilities["concertmirror08464.xiaomiHumAirmxIndicatorLevel"]
local controlsChildLock = capabilities["concertmirror08464.xiaomiHumAirmxChildLock"]
local controlsAlarm = capabilities["concertmirror08464.xiaomiHumAirmxAlarm"]
local controlsIndicatorLight = capabilities["concertmirror08464.xiaomiHumAirmxIndicatorLight"]
local controlsIndicatorMode = capabilities["concertmirror08464.xiaomiHumAirmxIndicatorMode"]
local controlsOverwetProtect = capabilities["concertmirror08464.xiaomiHumAirmxOverwetProtect"]
local statsFault = capabilities["concertmirror08464.xiaomiHumAirmxFault"]
local statsWaterLevel = capabilities["concertmirror08464.xiaomiHumAirmxWaterLevel"]
local statsWaterStatus = capabilities["concertmirror08464.xiaomiHumAirmxWaterStatus"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT model: xiaomi.humidifier.airmx
-- specModel: xiaomi-3pro
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-3pro:1:0000D061
--
-- Humidifier service (siid=2)
--   piid=1 power, bool, RW
--   piid=2 fault, uint8, R: 0=noFaults, 1=pumpFault, 2=lowWater, 3=pumpLowWater
--   piid=3 mode, uint8, RW: 0=constantHumidity, 1=strong, 2=sleep, 3=airDry, 4=clean, 5=descale, 6=none
--   piid=5 target-humidity, uint8, RW, 40..70 %, step 1
--   piid=11 water-level, uint8, R, 0..100 %, step 1
--   piid=12 automatic-air-drying, bool, RW
--   piid=13 air-dry-remain-time, uint16, R, seconds, diagnostic, not exposed
--   piid=14 overwet-protect, bool, RW
--   event aiid=1 low-water-level, reflected through fault/waterStatus polling
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, 0..100 %
--   piid=2 temperature, float, R, -50..50 C
-- Physical Control Locked service (siid=11)
--   piid=1 physical-controls-locked, bool, RW
-- Alarm service (siid=14)
--   piid=1 alarm, bool, RW
-- Indicator Light service (siid=15)
--   piid=1 switch-status, bool, RW
--   piid=2 mode, uint8, RW: 1=auto, 2=manual
--   piid=3 brightness, uint8, RW, 1..5, step 1
-- Filter service (siid=18)
--   piid=1 filter-life-level, uint8, R, 0..100 %
--   aiid=1 reset-filter-life, action

local HUMIDIFIER_SIID = 2
local POWER_PIID = 1
local FAULT_PIID = 2
local MODE_PIID = 3
local TARGET_HUMIDITY_PIID = 5
local WATER_LEVEL_PIID = 11
local AUTOMATIC_AIR_DRYING_PIID = 12
local OVERWET_PROTECT_PIID = 14

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1
local TEMPERATURE_PIID = 2

local CHILD_LOCK_SIID = 11
local CHILD_LOCK_PIID = 1

local ALARM_SIID = 14
local ALARM_PIID = 1

local INDICATOR_LIGHT_SIID = 15
local INDICATOR_LIGHT_PIID = 1
local INDICATOR_MODE_PIID = 2
local INDICATOR_BRIGHTNESS_PIID = 3

local FILTER_SIID = 18
local FILTER_LIFE_PIID = 1
local RESET_FILTER_AI_ID = 1

local MODE_TO_ST = {
    [0] = "constantHumidity",
    [1] = "strong",
    [2] = "sleep",
    [3] = "airDry",
    [4] = "clean",
    [5] = "descale",
    [6] = "none"
}

local ST_TO_MODE = {
    constantHumidity = 0,
    strong = 1,
    sleep = 2,
    airDry = 3,
    clean = 4,
    descale = 5,
    none = 6
}

local FAULT_TO_ST = {
    [0] = "noFaults",
    [1] = "pumpFault",
    [2] = "lowWater",
    [3] = "pumpLowWater"
}

local INDICATOR_MODE_TO_ST = {
    [1] = "auto",
    [2] = "manual"
}

local ST_TO_INDICATOR_MODE = {
    auto = 1,
    manual = 2
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function bool_to_st(value)
    return value and "on" or "off"
end

local function emit_fault(device, value)
    local fault = FAULT_TO_ST[value]
    if fault then
        device:emit_event(statsFault.fault({value = fault}))
        device:emit_event(statsWaterStatus.waterStatus({value = (fault == "lowWater" or fault == "pumpLowWater") and "lowWater" or "normal"}))
    end
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = HUMIDIFIER_SIID, piid = POWER_PIID},
        {siid = HUMIDIFIER_SIID, piid = FAULT_PIID},
        {siid = HUMIDIFIER_SIID, piid = MODE_PIID},
        {siid = HUMIDIFIER_SIID, piid = TARGET_HUMIDITY_PIID},
        {siid = HUMIDIFIER_SIID, piid = WATER_LEVEL_PIID},
        {siid = HUMIDIFIER_SIID, piid = AUTOMATIC_AIR_DRYING_PIID},
        {siid = HUMIDIFIER_SIID, piid = OVERWET_PROTECT_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = INDICATOR_LIGHT_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = INDICATOR_MODE_PIID},
        {siid = INDICATOR_LIGHT_SIID, piid = INDICATOR_BRIGHTNESS_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID}
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

            if siid == HUMIDIFIER_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == FAULT_PIID then
                    emit_fault(device, value)
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value]
                    if mode then
                        device:emit_event(controlsMode.mode({value = mode}))
                    end
                elseif piid == TARGET_HUMIDITY_PIID then
                    device:emit_event(controlsTargetHumidity.targetHumidity({value = value, unit = "%"}))
                elseif piid == WATER_LEVEL_PIID then
                    device:emit_event(statsWaterLevel.waterLevel({value = value, unit = "%"}))
                elseif piid == AUTOMATIC_AIR_DRYING_PIID then
                    device:emit_event(controlsAutomaticAirDrying.automaticAirDrying({value = bool_to_st(value)}))
                elseif piid == OVERWET_PROTECT_PIID then
                    device:emit_event(controlsOverwetProtect.overwetProtect({value = bool_to_st(value)}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                end
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                device:emit_event(controlsChildLock.childLock({value = bool_to_st(value)}))
            elseif siid == ALARM_SIID and piid == ALARM_PIID then
                device:emit_event(controlsAlarm.alarm({value = bool_to_st(value)}))
            elseif siid == INDICATOR_LIGHT_SIID then
                if piid == INDICATOR_LIGHT_PIID then
                    device:emit_event(controlsIndicatorLight.indicatorLight({value = bool_to_st(value)}))
                elseif piid == INDICATOR_MODE_PIID then
                    local indicator_mode = INDICATOR_MODE_TO_ST[value]
                    if indicator_mode then
                        device:emit_event(controlsIndicatorMode.indicatorMode({value = indicator_mode}))
                    end
                elseif piid == INDICATOR_BRIGHTNESS_PIID then
                    device:emit_event(controlsIndicatorBrightness.indicatorBrightness({value = value}))
                end
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
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

    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
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

    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.mode
    local value = ST_TO_MODE[mode]
    if value == nil then return end

    pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, MODE_PIID, value)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(controlsMode.mode({value = mode}))
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function set_target_humidity_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local humidity = math.max(40, math.min(70, command.args.humidity))
    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, TARGET_HUMIDITY_PIID, humidity)
    if ok then
        device:emit_event(controlsTargetHumidity.targetHumidity({value = humidity, unit = "%"}))
    end
end

local function set_alarm_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local alarm = command.args.alarm
    local ok = pcall(miot.set, device, ip, token, ALARM_SIID, ALARM_PIID, alarm == "on")
    if ok then
        device:emit_event(controlsAlarm.alarm({value = alarm}))
    end
end

local function set_child_lock_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local child_lock = command.args.childLock
    local ok = pcall(miot.set, device, ip, token, CHILD_LOCK_SIID, CHILD_LOCK_PIID, child_lock == "on")
    if ok then
        device:emit_event(controlsChildLock.childLock({value = child_lock}))
    end
end

local function set_indicator_light_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local indicator_light = command.args.indicatorLight
    local ok = pcall(miot.set, device, ip, token, INDICATOR_LIGHT_SIID, INDICATOR_LIGHT_PIID, indicator_light == "on")
    if ok then
        device:emit_event(controlsIndicatorLight.indicatorLight({value = indicator_light}))
    end
end

local function set_indicator_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local indicator_mode = command.args.indicatorMode
    local value = ST_TO_INDICATOR_MODE[indicator_mode]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, INDICATOR_LIGHT_SIID, INDICATOR_MODE_PIID, value)
    if ok then
        device:emit_event(controlsIndicatorMode.indicatorMode({value = indicator_mode}))
    end
end

local function set_indicator_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = math.max(1, math.min(5, command.args.brightness))
    local ok = pcall(miot.set, device, ip, token, INDICATOR_LIGHT_SIID, INDICATOR_BRIGHTNESS_PIID, brightness)
    if ok then
        device:emit_event(controlsIndicatorBrightness.indicatorBrightness({value = brightness}))
    end
end

local function set_overwet_protect_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local overwet = command.args.overwetProtect
    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, OVERWET_PROTECT_PIID, overwet == "on")
    if ok then
        device:emit_event(controlsOverwetProtect.overwetProtect({value = overwet}))
    end
end

local function set_automatic_air_drying_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local air_drying = command.args.automaticAirDrying
    local ok = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, AUTOMATIC_AIR_DRYING_PIID, air_drying == "on")
    if ok then
        device:emit_event(controlsAutomaticAirDrying.automaticAirDrying({value = air_drying}))
    end
end

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_AI_ID, {})
    if ok then
        device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(controlsMode.ID, "main") then
        device:try_update_metadata({profile = "xiaomi-humidifier-airmx"})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(controlsMode.mode({value = "constantHumidity"}))
    device:emit_event(controlsTargetHumidity.targetHumidity({value = 50, unit = "%"}))
    device:emit_event(controlsAlarm.alarm({value = "off"}))
    device:emit_event(controlsChildLock.childLock({value = "off"}))
    device:emit_event(controlsIndicatorLight.indicatorLight({value = "on"}))
    device:emit_event(controlsIndicatorMode.indicatorMode({value = "auto"}))
    device:emit_event(controlsIndicatorBrightness.indicatorBrightness({value = 5}))
    device:emit_event(controlsOverwetProtect.overwetProtect({value = "off"}))
    device:emit_event(controlsAutomaticAirDrying.automaticAirDrying({value = "off"}))
    device:emit_event(statsFault.fault({value = "noFaults"}))
    device:emit_event(statsWaterStatus.waterStatus({value = "normal"}))
    device:emit_event(statsWaterLevel.waterLevel({value = 0, unit = "%"}))
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

local driver = Driver("miot-xiaomi-humidifier-airmx", {
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
        [controlsMode.ID] = {
            [controlsMode.commands.setMode.NAME] = set_mode_handler
        },
        [controlsTargetHumidity.ID] = {
            [controlsTargetHumidity.commands.setTargetHumidity.NAME] = set_target_humidity_handler
        },
        [controlsAlarm.ID] = {
            [controlsAlarm.commands.setAlarm.NAME] = set_alarm_handler
        },
        [controlsChildLock.ID] = {
            [controlsChildLock.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [controlsIndicatorLight.ID] = {
            [controlsIndicatorLight.commands.setIndicatorLight.NAME] = set_indicator_light_handler
        },
        [controlsIndicatorMode.ID] = {
            [controlsIndicatorMode.commands.setIndicatorMode.NAME] = set_indicator_mode_handler
        },
        [controlsIndicatorBrightness.ID] = {
            [controlsIndicatorBrightness.commands.setIndicatorBrightness.NAME] = set_indicator_brightness_handler
        },
        [controlsOverwetProtect.ID] = {
            [controlsOverwetProtect.commands.setOverwetProtect.NAME] = set_overwet_protect_handler
        },
        [controlsAutomaticAirDrying.ID] = {
            [controlsAutomaticAirDrying.commands.setAutomaticAirDrying.NAME] = set_automatic_air_drying_handler
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
