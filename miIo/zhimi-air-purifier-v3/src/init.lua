-- Zhimi Air Purifier V3 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miio = require "miio"

local airModeAirPurifierMode = capabilities["concertmirror08464.zhimiAirV3AirPurifierMode"]
local deviceControlsBuzzer = capabilities["concertmirror08464.zhimiAirV3Buzzer"]
local deviceControlsChildLock = capabilities["concertmirror08464.zhimiAirV3ChildLock"]
local favoriteFanLevel = capabilities["concertmirror08464.zhimiAirV3FavoriteFanLevel"]
local deviceControlsLedBrightness = capabilities["concertmirror08464.zhimiAirV3LedBrightness"]

local PROFILE_NAME = "zhimi-v3"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- miIO model: zhimi.airpurifier.v3
-- Core read properties: power, mode, aqi, humidity, temp_dec, favorite_level,
-- filter1_life, led, led_b, buzzer, child_lock
-- Core write methods: set_power, set_mode, set_level_favorite, reset_filter1,
-- set_led, set_led_b, set_buzzer, set_child_lock
local STATUS_PROPERTIES = {
    "power",
    "mode",
    "aqi",
    "humidity",
    "temp_dec",
    "favorite_level",
    "filter1_life",
    "led",
    "led_b",
    "buzzer",
    "child_lock"
}

local MODE_TO_ST = {
    auto = "auto",
    silent = "sleep",
    favorite = "favorite",
    idle = "idle",
    medium = "medium",
    high = "high",
    strong = "strong",
    low = "low"
}
local ST_TO_MODE = {
    auto = "auto",
    sleep = "silent",
    favorite = "favorite",
    idle = "idle",
    medium = "medium",
    high = "high",
    strong = "strong",
    low = "low"
}
local FAVORITE_LEVEL_MIN = 0
local FAVORITE_LEVEL_MAX = 17
local SUPPORTED_MODES = {"auto", "sleep", "favorite", "idle", "medium", "high", "strong"}

local LED_BRIGHTNESS_TO_ST = {
    [0] = "bright",
    [1] = "dim",
    [2] = "off"
}
local ST_TO_LED_BRIGHTNESS = {
    bright = 0,
    dim = 1,
    off = 2
}

local function miio_on_off_to_st(value)
    if value == "on" or value == true then
        return "on"
    elseif value == "off" or value == false then
        return "off"
    end
    return nil
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function get_properties(device, ip, token)
    local response = miio.cmd(device, ip, token, "get_prop", STATUS_PROPERTIES)
    local values = {}

    if response and response.result then
        for index, property in ipairs(STATUS_PROPERTIES) do
            values[property] = response.result[index]
        end
    end

    return values
end

local emit_device_controls

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local ok, values = pcall(get_properties, device, ip, token)
    if not ok then
        device.log.error("V3 get_prop failed: " .. tostring(values))
        return
    end

    if values.power then
        device:emit_event(values.power == "on" and capabilities.switch.switch.on() or capabilities.switch.switch.off())
    end

    local mode = MODE_TO_ST[values.mode]
    if mode then
        device:emit_event(airModeAirPurifierMode.airPurifierMode({value = mode}))
    end

    if values.aqi and type(values.aqi) == "number" then
        device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(values.aqi)))
    end

    if values.humidity and type(values.humidity) == "number" then
        device:emit_event(capabilities.relativeHumidityMeasurement.humidity(values.humidity))
    end

    if values.temp_dec and type(values.temp_dec) == "number" then
        device:emit_event(capabilities.temperatureMeasurement.temperature({value = values.temp_dec / 10, unit = "C"}))
    end

    if values.favorite_level and type(values.favorite_level) == "number" then
        local level = clamp(math.floor(values.favorite_level), FAVORITE_LEVEL_MIN, FAVORITE_LEVEL_MAX)
        device:emit_event(favoriteFanLevel.favoriteFanLevel(level))
    end
    if values.filter1_life and type(values.filter1_life) == "number" then
        device:emit_event(capabilities.filterState.filterLifeRemaining({value = values.filter1_life, unit = "%"}))
    end

    emit_device_controls(device, values)
end

local function run_poll(device, source)
    local ok, err = pcall(poll_device_status, device)
    if not ok then
        device.log.error(string.format("V3 poll failed (%s): %s", source, tostring(err)))
    end
end

function emit_device_controls(device, values)
    local led_brightness = LED_BRIGHTNESS_TO_ST[values.led_b]
    if values.led == "off" then
        led_brightness = "off"
    elseif values.led == "on" and not led_brightness then
        led_brightness = "bright"
    end

    if led_brightness then
        device:emit_event(deviceControlsLedBrightness.ledBrightness({value = led_brightness}))
    end

    local buzzer = miio_on_off_to_st(values.buzzer)
    if buzzer then
        device:emit_event(deviceControlsBuzzer.buzzer({value = buzzer}))
    end

    local child_lock = miio_on_off_to_st(values.child_lock)
    if child_lock then
        device:emit_event(deviceControlsChildLock.childLock({value = child_lock}))
    end
end

local function start_polling_timer(device)
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

local function switch_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if ip and miio.set_prop(device, ip, token, "set_power", {"on"}) then
        device:emit_event(capabilities.switch.switch.on())
        device.thread:call_with_delay(1, function()
            run_poll(device, "switch-on")
        end)
    end
end

local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if ip and miio.set_prop(device, ip, token, "set_power", {"off"}) then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_air_purifier_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.mode
    local miio_mode = ST_TO_MODE[mode]
    if not miio_mode then return end

    miio.set_prop(device, ip, token, "set_power", {"on"})
    if miio.set_prop(device, ip, token, "set_mode", {miio_mode}) then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(airModeAirPurifierMode.airPurifierMode({value = mode}))
    end
end

local function set_favorite_fan_level_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local level = clamp(math.floor(command.args.favoriteFanLevel), FAVORITE_LEVEL_MIN, FAVORITE_LEVEL_MAX)

    miio.set_prop(device, ip, token, "set_power", {"on"})
    miio.set_prop(device, ip, token, "set_mode", {"favorite"})
    if miio.set_prop(device, ip, token, "set_level_favorite", {level}) then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(airModeAirPurifierMode.airPurifierMode({value = "favorite"}))
        device:emit_event(favoriteFanLevel.favoriteFanLevel(level))
        device.thread:call_with_delay(1, function()
            run_poll(device, "favorite-level")
        end)
    end
end
local function set_led_brightness_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local brightness = command.args.brightness
    local led_b = ST_TO_LED_BRIGHTNESS[brightness]
    if led_b == nil then return end

    local led_ok
    if brightness == "off" then
       led_ok = miio.set_prop(device, ip, token, "set_led", {"off"})
    else
       led_ok = miio.set_prop(device, ip, token, "set_led", {"on"})
    end

    local brightness_ok = miio.set_prop(device, ip, token, "set_led_b", {led_b})
    if led_ok and brightness_ok then
        device:emit_event(deviceControlsLedBrightness.ledBrightness({value = brightness}))
    end
end

local function set_buzzer_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local buzzer = command.args.buzzer
    if miio.set_prop(device, ip, token, "set_buzzer", {buzzer}) then
        device:emit_event(deviceControlsBuzzer.buzzer({value = buzzer}))
    end
end

local function set_child_lock_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local child_lock = command.args.childLock
    if miio.set_prop(device, ip, token, "set_child_lock", {child_lock}) then
        device:emit_event(deviceControlsChildLock.childLock({value = child_lock}))
    end
end

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    if miio.set_prop(device, ip, token, "reset_filter1", {}) then
        device.thread:call_with_delay(1, function()
            run_poll(device, "filter-reset")
        end)
    else
        device.log.error("V3 reset_filter1 failed")
    end
end

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    run_poll(device, "refresh")
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(favoriteFanLevel.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(airModeAirPurifierMode.airPurifierMode({value = "auto"}))
    device:emit_event(airModeAirPurifierMode.supportedAirPurifierModes({value = SUPPORTED_MODES}))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.fineDustSensor.fineDustLevel(0))
    device:emit_event(favoriteFanLevel.favoriteFanLevel(0))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(deviceControlsLedBrightness.ledBrightness({value = "bright"}))
    device:emit_event(deviceControlsBuzzer.buzzer({value = "off"}))
    device:emit_event(deviceControlsChildLock.childLock({value = "off"}))
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))

    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        run_poll(device, "init")
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
            run_poll(device, "preferences")
        end
    end
end

local driver = Driver("miio-air-purifier-v3", {
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
        [airModeAirPurifierMode.ID] = {
            [airModeAirPurifierMode.commands.setAirPurifierMode.NAME] = set_air_purifier_mode_handler
        },
        [favoriteFanLevel.ID] = {
            [favoriteFanLevel.commands.setFavoriteFanLevel.NAME] = set_favorite_fan_level_handler
        },        [deviceControlsLedBrightness.ID] = {
            [deviceControlsLedBrightness.commands.setLedBrightness.NAME] = set_led_brightness_handler
        },
        [deviceControlsBuzzer.ID] = {
            [deviceControlsBuzzer.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [deviceControlsChildLock.ID] = {
            [deviceControlsChildLock.commands.setChildLock.NAME] = set_child_lock_handler
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
