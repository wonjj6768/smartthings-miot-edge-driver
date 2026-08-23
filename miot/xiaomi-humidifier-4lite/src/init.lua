-- Xiaomi Humidifier 4lite Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local controlsMode = capabilities["concertmirror08464.xiaomiHum4liteMode"]
local controlsTargetHumidity = capabilities["concertmirror08464.xiaomiHum4liteTargetHumidity"]
local controlsChildLock = capabilities["concertmirror08464.xiaomiHum4liteChildLock"]
local controlsScreenBrightness = capabilities["concertmirror08464.xiaomiHum4liteScreenLevel"]
local controlsAlarm = capabilities["concertmirror08464.xiaomiHum4liteAlarm"]
local controlsOverwetProtect = capabilities["concertmirror08464.xiaomiHum4liteOverwetProtect"]
local statsFault = capabilities["concertmirror08464.xiaomiHum4liteFault"]
local statsWaterStatus = capabilities["concertmirror08464.xiaomiHum4liteWaterStatus"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT model: xiaomi.humidifier.4lite
-- specModel: xiaomi-4lite
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-4lite:2:0000D061
--
-- Humidifier service (siid=2)
--   piid=1 power, bool, RW
--   piid=2 fault, uint8, R: 0=noFaults, 1=motorFault, 2=pumpFault, 3=pumpFail, 4=lowWater
--   piid=3 mode, uint8, RW: 0=constantHumidity, 1=sleep, 2=strong, 3=airDry
--   piid=5 target-humidity, uint8, RW, 40..70 %, step 1
--   piid=10 air-dry-remain-time, uint16, R, minutes, auxiliary, not exposed
--   piid=11 overwet-protect, bool, RW
--   event aiid=1 low-water-level, reflected through fault/waterStatus polling
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, 0..100 %
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R, 0..100 %
--   aiid=1 reset-filter-life, action
-- Screen service (siid=6)
--   piid=1 on, bool, RW
--   piid=2 brightness, uint8, RW: 0=dim, 1=normal
-- Alarm service (siid=7)
--   piid=1 alarm, bool, RW
-- Physical Control Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW

local HUMIDIFIER_SIID = 2
local POWER_PIID = 1
local FAULT_PIID = 2
local MODE_PIID = 3
local TARGET_HUMIDITY_PIID = 5
local OVERWET_PROTECT_PIID = 11

local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1

local FILTER_SIID = 4
local FILTER_LIFE_PIID = 1
local RESET_FILTER_AI_ID = 1

local SCREEN_SIID = 6
local SCREEN_ON_PIID = 1
local SCREEN_BRIGHTNESS_PIID = 2

local ALARM_SIID = 7
local ALARM_PIID = 1

local CHILD_LOCK_SIID = 8
local CHILD_LOCK_PIID = 1

local MODE_TO_ST = {
    [0] = "constantHumidity",
    [1] = "sleep",
    [2] = "strong",
    [3] = "airDry"
}

local ST_TO_MODE = {
    constantHumidity = 0,
    sleep = 1,
    strong = 2,
    airDry = 3
}

local FAULT_TO_ST = {
    [0] = "noFaults",
    [1] = "motorFault",
    [2] = "pumpFault",
    [3] = "pumpFail",
    [4] = "lowWater"
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

local function emit_fault(device, value)
    local fault = FAULT_TO_ST[value]
    if fault then
        device:emit_event(statsFault.fault({value = fault}))
        device:emit_event(statsWaterStatus.waterStatus({value = fault == "lowWater" and "lowWater" or "normal"}))
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
        {siid = HUMIDIFIER_SIID, piid = OVERWET_PROTECT_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_ON_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_BRIGHTNESS_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then
        return
    end

    local screen_on = nil
    local screen_brightness = nil

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
                elseif piid == OVERWET_PROTECT_PIID then
                    device:emit_event(controlsOverwetProtect.overwetProtect({value = bool_to_st(value)}))
                end
            elseif siid == ENVIRONMENT_SIID and piid == HUMIDITY_PIID then
                device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == SCREEN_SIID then
                if piid == SCREEN_ON_PIID then
                    screen_on = value
                elseif piid == SCREEN_BRIGHTNESS_PIID then
                    screen_brightness = value
                end
            elseif siid == ALARM_SIID and piid == ALARM_PIID then
                device:emit_event(controlsAlarm.alarm({value = bool_to_st(value)}))
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                device:emit_event(controlsChildLock.childLock({value = bool_to_st(value)}))
            end
        end
    end

    if screen_on == false then
        device:emit_event(controlsScreenBrightness.screenBrightness({value = "off"}))
    elseif screen_brightness ~= nil then
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

local function set_screen_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.screenBrightness
    if brightness == "off" then
        local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_ON_PIID, false)
        if ok then
            device:emit_event(controlsScreenBrightness.screenBrightness({value = "off"}))
        end
        return
    end

    local value = ST_TO_SCREEN_BRIGHTNESS[brightness]
    if value == nil then return end

    pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_ON_PIID, true)
    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(controlsScreenBrightness.screenBrightness({value = brightness}))
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
        device:try_update_metadata({profile = "xiaomi-humidifier-4lite"})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(controlsMode.mode({value = "constantHumidity"}))
    device:emit_event(controlsTargetHumidity.targetHumidity({value = 50, unit = "%"}))
    device:emit_event(controlsAlarm.alarm({value = "off"}))
    device:emit_event(controlsChildLock.childLock({value = "off"}))
    device:emit_event(controlsScreenBrightness.screenBrightness({value = "normal"}))
    device:emit_event(controlsOverwetProtect.overwetProtect({value = "off"}))
    device:emit_event(statsFault.fault({value = "noFaults"}))
    device:emit_event(statsWaterStatus.waterStatus({value = "normal"}))
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

local driver = Driver("miot-xiaomi-humidifier-4lite", {
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
