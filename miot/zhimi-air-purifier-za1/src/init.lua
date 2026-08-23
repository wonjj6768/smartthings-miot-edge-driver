-- Zhimi Air Purifier ZA1 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local purifierModeAirPurifierMode = capabilities["concertmirror08464.zhimiAirZa1AirPurifierMode"]
local deviceControlsBuzzer = capabilities["concertmirror08464.zhimiAirZa1Buzzer"]
local deviceControlsChildLock = capabilities["concertmirror08464.zhimiAirZa1ChildLock"]
local deviceControlsLedBrightness = capabilities["concertmirror08464.zhimiAirZa1LedBrightness"]

local PROFILE_NAME = "zhimi-za1"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT spec: urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-za1:2
local AIR_PURIFIER_SIID = 2
local ENVIRONMENT_SIID = 3
local FILTER_SIID = 4

-- Air Purifier service (siid=2)
local POWER_PIID = 1  -- Switch Status, read/write/notify, bool
local MODE_PIID = 5   -- Mode, read/write/notify, 0=Auto, 1=Sleep, 2=Favorite

-- Environment service (siid=3)
local PM25_PIID = 6
local HUMIDITY_PIID = 7
local TEMPERATURE_PIID = 8

-- Filter service (siid=4)
local FILTER_LIFE_PIID = 3

-- MIoT 속성 ID - Device Controls
local BUZZER_SIID = 5
local BUZZER_PIID = 1
local LED_BRIGHTNESS_SIID = 6
local LED_BRIGHTNESS_PIID = 1
local CHILD_LOCK_SIID = 7
local CHILD_LOCK_PIID = 1
local LED_BRIGHTNESS_TO_ST = {[0] = "bright", [1] = "dim", [2] = "off"}
local ST_TO_LED_BRIGHTNESS = {bright = 0, dim = 1, off = 2}


local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite"
}

local ST_TO_MODE = {
    auto = 0,
    sleep = 1,
    favorite = 2
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = AIR_PURIFIER_SIID, piid = POWER_PIID},
        {siid = AIR_PURIFIER_SIID, piid = MODE_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID},
        {siid = BUZZER_SIID, piid = BUZZER_PIID},
        {siid = LED_BRIGHTNESS_SIID, piid = LED_BRIGHTNESS_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            if result.siid == AIR_PURIFIER_SIID then
                if result.piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(result.value and "on" or "off"))
                elseif result.piid == MODE_PIID then
                    local mode = MODE_TO_ST[result.value] or "auto"
                    device:emit_event(purifierModeAirPurifierMode.airPurifierMode({value = mode}))
                end
            elseif result.siid == ENVIRONMENT_SIID then
                if result.piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(result.value))
                elseif result.piid == PM25_PIID then
                    device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(result.value)))
                elseif result.piid == TEMPERATURE_PIID then
                    local temperature = {value = result.value, unit = "C"}
                    device:emit_event(capabilities.temperatureMeasurement.temperature(temperature))
                end
            elseif result.siid == FILTER_SIID and result.piid == FILTER_LIFE_PIID then
                device:emit_event(capabilities.filterState.filterLifeRemaining({value = result.value, unit = "%"}))
            elseif result.siid == BUZZER_SIID and result.piid == BUZZER_PIID then
                device:emit_event(deviceControlsBuzzer.buzzer({value = result.value and "on" or "off"}))
            elseif result.siid == LED_BRIGHTNESS_SIID and result.piid == LED_BRIGHTNESS_PIID then
                local brightness = LED_BRIGHTNESS_TO_ST[result.value]
                if brightness then
                    device:emit_event(deviceControlsLedBrightness.ledBrightness({value = brightness}))
                end
            elseif result.siid == CHILD_LOCK_SIID and result.piid == CHILD_LOCK_PIID then
                device:emit_event(deviceControlsChildLock.childLock({value = result.value and "on" or "off"}))
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
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
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
        device:emit_event(purifierModeAirPurifierMode.airPurifierMode({value = mode}))
    end
end

local function set_led_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.brightness
    local value = ST_TO_LED_BRIGHTNESS[brightness]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, LED_BRIGHTNESS_SIID, LED_BRIGHTNESS_PIID, value)
    if ok then
        device:emit_event(deviceControlsLedBrightness.ledBrightness({value = brightness}))
    end
end

local function set_buzzer_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.buzzer == "on"
    local ok = pcall(miot.set, device, ip, token, BUZZER_SIID, BUZZER_PIID, value)
    if ok then
        device:emit_event(deviceControlsBuzzer.buzzer({value = command.args.buzzer}))
    end
end

local function set_child_lock_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.childLock == "on"
    local ok = pcall(miot.set, device, ip, token, CHILD_LOCK_SIID, CHILD_LOCK_PIID, value)
    if ok then
        device:emit_event(deviceControlsChildLock.childLock({value = command.args.childLock}))
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(purifierModeAirPurifierMode.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(purifierModeAirPurifierMode.airPurifierMode({value = "auto"}))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.fineDustSensor.fineDustLevel(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(deviceControlsLedBrightness.ledBrightness({value = "bright"}))
    device:emit_event(deviceControlsBuzzer.buzzer({value = "off"}))
    device:emit_event(deviceControlsChildLock.childLock({value = "off"}))
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

local driver = Driver("miot-air-purifier-za1", {
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
        [purifierModeAirPurifierMode.ID] = {
            [purifierModeAirPurifierMode.commands.setAirPurifierMode.NAME] = set_air_purifier_mode_handler
        },
        [deviceControlsLedBrightness.ID] = {
            [deviceControlsLedBrightness.commands.setLedBrightness.NAME] = set_led_brightness_handler
        },
        [deviceControlsBuzzer.ID] = {
            [deviceControlsBuzzer.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [deviceControlsChildLock.ID] = {
            [deviceControlsChildLock.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
