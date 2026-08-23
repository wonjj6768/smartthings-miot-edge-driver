-- Xiaomi Smart Air Purifier Elite Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local controlsUv = capabilities["concertmirror08464.zhimiAirMeb1Uv"]
local controlsAirPurifierMode = capabilities["concertmirror08464.zhimiAirMeb1AirPurifierMode"]
local controlsBuzzer = capabilities["concertmirror08464.zhimiAirMeb1Buzzer"]
local controlsChildLock = capabilities["concertmirror08464.zhimiAirMeb1ChildLock"]
local controlsFanLevel = capabilities["concertmirror08464.zhimiAirMeb1FanLevel"]
local controlsDisplayBrightness = capabilities["concertmirror08464.zhimiAirMeb1DisplayLevel"]
local controlsPlasma = capabilities["concertmirror08464.zhimiAirMeb1Plasma"]

local PROFILE_NAME = "zhimi-air-purifier-meb1"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT model: zhimi.airp.meb1
-- Source: Xiaomi Smart Air Purifier Elite model docs, Home Assistant Xiaomi Miot Auto user report,
-- and MIoT spec zhimi-meb1 v1.
-- Air purifier service (siid=2)
local AIR_PURIFIER_SIID = 2
local POWER_PIID = 1             -- RW bool
local FAULT_PIID = 2             -- R enum, diagnostic only
local MODE_PIID = 4              -- RW enum: 0 auto, 1 sleep, 2 favorite, 3 manual
local FAN_LEVEL_PIID = 5         -- RW enum: 1 level1, 2 level2, 3 level3
local PLASMA_PIID = 6            -- RW bool
local UV_PIID = 7                -- RW bool

-- Environment service (siid=3)
local ENVIRONMENT_SIID = 3
local HUMIDITY_PIID = 1          -- R uint8, 0..100 %
local PM25_PIID = 4              -- R float, 0..1000 ug/m3
local TEMPERATURE_PIID = 7       -- R float, -30..100 C
local PM10_PIID = 8              -- R float, 0..100 ug/m3
local AIR_QUALITY_PIID = 9       -- R enum, not exposed

-- Filter service (siid=4)
local FILTER_SIID = 4
local FILTER_LIFE_PIID = 1       -- R uint8, 0..100 %
local FILTER_USED_TIME_PIID = 3  -- R uint16 hours, not exposed
local RESET_FILTER_AIID = 1      -- Action -> filterState.resetFilter

-- Alarm service (siid=6)
local BUZZER_SIID = 6
local BUZZER_PIID = 1            -- RW bool

-- Physical controls locked service (siid=8)
local CHILD_LOCK_SIID = 8
local CHILD_LOCK_PIID = 1        -- RW bool

-- Screen service (siid=13)
local SCREEN_SIID = 13
local DISPLAY_BRIGHTNESS_PIID = 2 -- RW enum: 0 off, 1 bright, 2 brightest

-- Favorite, display unit, custom diagnostics, filter-time, AQI heartbeat, and
-- RFID services are intentionally not exposed as core SmartThings controls.

local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite",
    [3] = "manual"
}

local ST_TO_MODE = {
    auto = 0,
    sleep = 1,
    favorite = 2,
    manual = 3
}

local FAN_LEVEL_TO_ST = {
    [1] = "level1",
    [2] = "level2",
    [3] = "level3"
}

local ST_TO_FAN_LEVEL = {
    level1 = 1,
    level2 = 2,
    level3 = 3
}

local DISPLAY_BRIGHTNESS_TO_ST = {
    [0] = "off",
    [1] = "bright",
    [2] = "brightest"
}

local ST_TO_DISPLAY_BRIGHTNESS = {
    off = 0,
    bright = 1,
    brightest = 2
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function bool_to_on_off(value)
    return value and "on" or "off"
end

local poll_device_status

local function schedule_refresh(device)
    device.thread:call_with_delay(1, function()
        pcall(poll_device_status, device)
    end)
end

poll_device_status = function(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = AIR_PURIFIER_SIID, piid = POWER_PIID},
        {siid = AIR_PURIFIER_SIID, piid = MODE_PIID},
        {siid = AIR_PURIFIER_SIID, piid = FAN_LEVEL_PIID},
        {siid = AIR_PURIFIER_SIID, piid = PLASMA_PIID},
        {siid = AIR_PURIFIER_SIID, piid = UV_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM10_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = BUZZER_SIID, piid = BUZZER_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID},
        {siid = SCREEN_SIID, piid = DISPLAY_BRIGHTNESS_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok then
        return
    end

    if not response or not response.result then
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == AIR_PURIFIER_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(bool_to_on_off(value)))
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value]
                    if mode then
                        device:emit_event(controlsAirPurifierMode.airPurifierMode({value = mode}))
                    end
                elseif piid == FAN_LEVEL_PIID then
                    local level = FAN_LEVEL_TO_ST[value]
                    if level then
                        device:emit_event(controlsFanLevel.fanLevel({value = level}))
                    end
                elseif piid == PLASMA_PIID then
                    device:emit_event(controlsPlasma.plasma({value = bool_to_on_off(value)}))
                elseif piid == UV_PIID then
                    device:emit_event(controlsUv.uv({value = bool_to_on_off(value)}))
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == PM25_PIID then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(math.floor(value)))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == PM10_PIID then
                    device:emit_event(capabilities.dustSensor.dustLevel(math.floor(value)))
                end
            elseif siid == FILTER_SIID and piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then
                device:emit_event(controlsBuzzer.buzzer({value = bool_to_on_off(value)}))
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                device:emit_event(controlsChildLock.childLock({value = bool_to_on_off(value)}))
            elseif siid == SCREEN_SIID and piid == DISPLAY_BRIGHTNESS_PIID then
                local brightness = DISPLAY_BRIGHTNESS_TO_ST[value]
                if brightness then
                    device:emit_event(controlsDisplayBrightness.displayBrightness({value = brightness}))
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

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        schedule_refresh(device)
    end
end

local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_air_purifier_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.mode
    local value = ST_TO_MODE[mode]
    if value == nil then return end

    pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, value)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(controlsAirPurifierMode.airPurifierMode({value = mode}))
        schedule_refresh(device)
    end
end

local function set_fan_level_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local fan_level = command.args.fanLevel
    local value = ST_TO_FAN_LEVEL[fan_level]
    if value == nil then return end

    pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)
    pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, ST_TO_MODE.manual)

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, FAN_LEVEL_PIID, value)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(controlsAirPurifierMode.airPurifierMode({value = "manual"}))
        device:emit_event(controlsFanLevel.fanLevel({value = fan_level}))
        schedule_refresh(device)
    end
end

local function set_display_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.brightness
    local value = ST_TO_DISPLAY_BRIGHTNESS[brightness]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, DISPLAY_BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(controlsDisplayBrightness.displayBrightness({value = brightness}))
    end
end

local function set_plasma_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local plasma = command.args.plasma
    local value = plasma == "on"
    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, PLASMA_PIID, value)
    if ok then
        device:emit_event(controlsPlasma.plasma({value = plasma}))
    end
end

local function set_uv_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local uv = command.args.uv
    local value = uv == "on"
    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, UV_PIID, value)
    if ok then
        device:emit_event(controlsUv.uv({value = uv}))
    end
end

local function set_buzzer_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local buzzer = command.args.buzzer
    local value = buzzer == "on"
    local ok = pcall(miot.set, device, ip, token, BUZZER_SIID, BUZZER_PIID, value)
    if ok then
        device:emit_event(controlsBuzzer.buzzer({value = buzzer}))
    end
end

local function set_child_lock_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local child_lock = command.args.childLock
    local value = child_lock == "on"
    local ok = pcall(miot.set, device, ip, token, CHILD_LOCK_SIID, CHILD_LOCK_PIID, value)
    if ok then
        device:emit_event(controlsChildLock.childLock({value = child_lock}))
    end
end

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_AIID, {})
    if ok then
        schedule_refresh(device)
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(controlsUv.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(controlsAirPurifierMode.airPurifierMode({value = "auto"}))
    device:emit_event(controlsFanLevel.fanLevel({value = "level1"}))
    device:emit_event(controlsDisplayBrightness.displayBrightness({value = "brightest"}))
    device:emit_event(controlsPlasma.plasma({value = "off"}))
    device:emit_event(controlsUv.uv({value = "off"}))
    device:emit_event(controlsBuzzer.buzzer({value = "off"}))
    device:emit_event(controlsChildLock.childLock({value = "off"}))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.dustSensor.dustLevel(0))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
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

local driver = Driver("miot-air-purifier-meb1", {
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
        [controlsAirPurifierMode.ID] = {
            [controlsAirPurifierMode.commands.setAirPurifierMode.NAME] = set_air_purifier_mode_handler
        },
        [controlsFanLevel.ID] = {
            [controlsFanLevel.commands.setFanLevel.NAME] = set_fan_level_handler
        },
        [controlsDisplayBrightness.ID] = {
            [controlsDisplayBrightness.commands.setDisplayBrightness.NAME] = set_display_brightness_handler
        },
        [controlsPlasma.ID] = {
            [controlsPlasma.commands.setPlasma.NAME] = set_plasma_handler
        },
        [controlsUv.ID] = {
            [controlsUv.commands.setUv.NAME] = set_uv_handler
        },
        [controlsBuzzer.ID] = {
            [controlsBuzzer.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [controlsChildLock.ID] = {
            [controlsChildLock.commands.setChildLock.NAME] = set_child_lock_handler
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
