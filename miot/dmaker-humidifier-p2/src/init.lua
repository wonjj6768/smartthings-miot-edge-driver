-- Dmaker Humidifier P2 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local controlsMode = capabilities["concertmirror08464.dmakerHumP2Mode"]
local controlsTargetHumidity = capabilities["concertmirror08464.dmakerHumP2TargetHumidity"]
local controlsChildLock = capabilities["concertmirror08464.dmakerHumP2ChildLock"]
local controlsAlarm = capabilities["concertmirror08464.dmakerHumP2Alarm"]
local controlsScreenBrightness = capabilities["concertmirror08464.dmakerHumP2ScreenBrightness"]
local controlsScreen = capabilities["concertmirror08464.dmakerHumP2Screen"]
local controlsOverwetProtect = capabilities["concertmirror08464.dmakerHumP2OverwetProtect"]
local statsFault = capabilities["concertmirror08464.dmakerHumP2Fault"]
local statsWaterLevel = capabilities["concertmirror08464.dmakerHumP2WaterLevel"]
local statsWaterStatus = capabilities["concertmirror08464.dmakerHumP2WaterStatus"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local MAX_GET_PROPERTIES = 8

-- MIoT model: dmaker.humidifier.p2
-- specModel: dmaker-p2
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:dmaker-p2:2
--
-- Humidifier service (siid=2)
--   piid=1 power, bool, RW
--   piid=2 fault, uint8, R: 0=noFaults, 1=motorFault, 2=pumpFault, 3=lowWater, 4=sensorFault, 5=fullWater
--   piid=3 mode, uint8, RW: 0=constantHumidity, 1=sleep, 2=strong
--   piid=6 target-humidity, uint8, RW, 40..70 %, step 1
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, 0..100 %
--   piid=7 temperature, float, R, C
-- Alarm service (siid=4)
--   piid=1 alarm, bool, RW
-- Physical Control Locked service (siid=6)
--   piid=1 physical-controls-locked, bool, RW
-- dm-service (siid=7)
--   piid=2 water-status, uint8, R: 0=normal, 1=lowWater, 2=full
--   piid=3 water-level, uint8, R, 0..16
--   piid=4 over-wet-protect, bool, RW
-- Screen service (siid=8)
--   piid=1 on, bool, RW
--   piid=2 brightness, uint8, RW: 0=dim, 1=normal
-- Filter service (siid=9)
--   piid=1 filter-life-level, uint8, R, 0..100 %
--   aiid=1 reset-filter-life, action

local HUMIDIFIER_SIID = 2
local POWER_PIID = 1
local FAULT_PIID = 2
local MODE_PIID = 3
local TARGET_HUMIDITY_PIID = 6

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1
local TEMPERATURE_PIID = 7

local ALARM_SIID = 4
local ALARM_PIID = 1

local CHILD_LOCK_SIID = 6
local CHILD_LOCK_PIID = 1

local DM_SERVICE_SIID = 7
local WATER_STATUS_PIID = 2
local WATER_LEVEL_PIID = 3
local OVERWET_PROTECT_PIID = 4

local SCREEN_SIID = 8
local SCREEN_ON_PIID = 1
local SCREEN_BRIGHTNESS_PIID = 2

local FILTER_SIID = 9
local FILTER_LIFE_PIID = 1
local RESET_FILTER_AI_ID = 1

local MODE_TO_ST = {
    [0] = "constantHumidity",
    [1] = "sleep",
    [2] = "strong"
}

local ST_TO_MODE = {
    constantHumidity = 0,
    sleep = 1,
    strong = 2
}

local FAULT_TO_ST = {
    [0] = "noFaults",
    [1] = "motorFault",
    [2] = "pumpFault",
    [3] = "lowWater",
    [4] = "sensorFault",
    [5] = "fullWater"
}

local WATER_STATUS_TO_ST = {
    [0] = "normal",
    [1] = "lowWater",
    [2] = "full"
}

local SCREEN_BRIGHTNESS_TO_ST = {
    [0] = "dim",
    [1] = "normal"
}

local ST_TO_SCREEN_BRIGHTNESS = {
    dim = 0,
    normal = 1
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

local function get_property_results(device, ip, token, properties)
    local results = {}

    for i = 1, #properties, MAX_GET_PROPERTIES do
        local chunk = {}
        for j = i, math.min(i + MAX_GET_PROPERTIES - 1, #properties) do
            table.insert(chunk, properties[j])
        end

        local ok, response = pcall(miot.gets, device, ip, token, chunk)
        if not ok or not response or not response.result then
            return nil
        end

        for _, result in ipairs(response.result) do
            table.insert(results, result)
        end
    end

    return results
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
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID},
        {siid = DM_SERVICE_SIID, piid = WATER_STATUS_PIID},
        {siid = DM_SERVICE_SIID, piid = WATER_LEVEL_PIID},
        {siid = DM_SERVICE_SIID, piid = OVERWET_PROTECT_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_ON_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_BRIGHTNESS_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID}
    }

    local results = get_property_results(device, ip, token, properties)
    if not results then
        return
    end

    local screen_on = nil
    local screen_brightness = nil

    for _, result in ipairs(results) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == HUMIDIFIER_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == FAULT_PIID then
                    local fault = FAULT_TO_ST[value]
                    if fault then
                        device:emit_event(statsFault.fault({value = fault}))
                    end
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value]
                    if mode then
                        device:emit_event(controlsMode.mode({value = mode}))
                    end
                elseif piid == TARGET_HUMIDITY_PIID then
                    device:emit_event(controlsTargetHumidity.targetHumidity({value = value, unit = "%"}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                end
            elseif siid == ALARM_SIID and piid == ALARM_PIID then
                device:emit_event(controlsAlarm.alarm({value = bool_to_st(value)}))
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                device:emit_event(controlsChildLock.childLock({value = bool_to_st(value)}))
            elseif siid == DM_SERVICE_SIID then
                if piid == WATER_STATUS_PIID then
                    local water_status = WATER_STATUS_TO_ST[value]
                    if water_status then
                        device:emit_event(statsWaterStatus.waterStatus({value = water_status}))
                    end
                elseif piid == OVERWET_PROTECT_PIID then
                    device:emit_event(controlsOverwetProtect.overwetProtect({value = bool_to_st(value)}))
                elseif piid == WATER_LEVEL_PIID then
                    device:emit_event(statsWaterLevel.waterLevel({value = value}))
                end
            elseif siid == SCREEN_SIID then
                if piid == SCREEN_ON_PIID then
                    screen_on = value
                elseif piid == SCREEN_BRIGHTNESS_PIID then
                    screen_brightness = value
                end
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            end
        end
    end

    if screen_on ~= nil then
        device:emit_event(controlsScreen.screen({value = bool_to_st(screen_on)}))
    end

    if screen_brightness ~= nil then
        local brightness = SCREEN_BRIGHTNESS_TO_ST[screen_brightness]
        if brightness then
            device:emit_event(controlsScreenBrightness.screenBrightness({value = brightness}))
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

local function set_screen_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local screen = command.args.screen
    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_ON_PIID, screen == "on")
    if ok then
        device:emit_event(controlsScreen.screen({value = screen}))
    end
end

local function set_screen_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.screenBrightness
    local value = ST_TO_SCREEN_BRIGHTNESS[brightness]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(controlsScreenBrightness.screenBrightness({value = brightness}))
    end
end

local function set_overwet_protect_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local overwet = command.args.overwetProtect
    local ok = pcall(miot.set, device, ip, token, DM_SERVICE_SIID, OVERWET_PROTECT_PIID, overwet == "on")
    if ok then
        device:emit_event(controlsOverwetProtect.overwetProtect({value = overwet}))
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
        device:try_update_metadata({profile = "dmaker-humidifier-p2"})
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
    device:emit_event(controlsScreen.screen({value = "on"}))
    device:emit_event(controlsScreenBrightness.screenBrightness({value = "normal"}))
    device:emit_event(controlsOverwetProtect.overwetProtect({value = "off"}))
    device:emit_event(statsFault.fault({value = "noFaults"}))
    device:emit_event(statsWaterStatus.waterStatus({value = "normal"}))
    device:emit_event(statsWaterLevel.waterLevel({value = 0}))
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

local driver = Driver("miot-dmaker-humidifier-p2", {
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
        [controlsScreen.ID] = {
            [controlsScreen.commands.setScreen.NAME] = set_screen_handler
        },
        [controlsScreenBrightness.ID] = {
            [controlsScreenBrightness.commands.setScreenBrightness.NAME] = set_screen_brightness_handler
        },
        [controlsOverwetProtect.ID] = {
            [controlsOverwetProtect.commands.setOverwetProtect.NAME] = set_overwet_protect_handler
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
