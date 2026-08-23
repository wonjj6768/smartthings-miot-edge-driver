-- Zhimi Air Purifier V7 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miio = require "miio"

local airModeAirPurifierMode = capabilities["concertmirror08464.zhimiAirV7AirPurifierMode"]
local deviceControlsBuzzer = capabilities["concertmirror08464.zhimiAirV7Buzzer"]
local deviceControlsChildLock = capabilities["concertmirror08464.zhimiAirV7ChildLock"]
local favoriteFanLevel = capabilities["concertmirror08464.zhimiAirV7FavoriteFanLevel"]
local indicatorLight = capabilities["concertmirror08464.zhimiAirV7IndicatorLight"]

local PROFILE_NAME = "zhimi-v7"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- miIO model: zhimi.airpurifier.v7
-- Core read properties: power, mode, aqi, humidity, temp_dec, favorite_level,
-- filter1_life, led, volume, child_lock
-- Core write methods: set_power, set_mode, set_level_favorite, set_led,
-- set_volume, set_child_lock
local STATUS_PROPERTIES = {
    "power",
    "mode",
    "aqi",
    "humidity",
    "temp_dec",
    "favorite_level",
    "filter1_life",
    "led",
    "volume",
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
local SUPPORTED_MODES = {"auto", "sleep", "favorite"}

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
    if not response or type(response.result) ~= "table" then
        local response_error = response and response.error
        local code = response_error and response_error.code or "unknown"
        local message = response_error and response_error.message or "missing result"
        error(string.format("get_prop response error code=%s message=%s", tostring(code), tostring(message)))
    end

    local values = {}
    for index, property in ipairs(STATUS_PROPERTIES) do
        values[property] = response.result[index]
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
        device.log.error("V7 get_prop failed: " .. tostring(values))
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
        device.log.error(string.format("V7 poll failed (%s): %s", source, tostring(err)))
    end
end

function emit_device_controls(device, values)
    local indicator = miio_on_off_to_st(values.led)
    if indicator then
        device:emit_event(indicatorLight.indicatorLight({value = indicator}))
    end

    if type(values.volume) == "number" then
        local sound = values.volume > 0 and "on" or "off"
        device:emit_event(deviceControlsBuzzer.buzzer({value = sound}))
    end

    local child_lock = miio_on_off_to_st(values.child_lock)
    if child_lock then
        device:emit_event(deviceControlsChildLock.childLock({value = child_lock}))
    end
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
local function set_indicator_light_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.indicatorLight
    if value ~= "on" and value ~= "off" then return end

    if miio.set_prop(device, ip, token, "set_led", {value}) then
        device:emit_event(indicatorLight.indicatorLight({value = value}))
    end
end

local function set_buzzer_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local buzzer = command.args.buzzer
    local volume = buzzer == "on" and 100 or buzzer == "off" and 0 or nil
    if volume and miio.set_prop(device, ip, token, "set_volume", {volume}) then
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

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    run_poll(device, "refresh")
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(indicatorLight.ID, "main") then
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
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
    device:emit_event(indicatorLight.indicatorLight({value = "on"}))
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
        run_poll(device, "init")
    else
        device.log.error("V7 polling disabled: invalid or missing IP/token preferences")
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

local driver = Driver("miio-air-purifier-v7", {
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
        },
        [indicatorLight.ID] = {
            [indicatorLight.commands.setIndicatorLight.NAME] = set_indicator_light_handler
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
