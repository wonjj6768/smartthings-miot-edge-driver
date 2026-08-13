-- Shuii Humidifier JSQ002 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miio = require "miio"

local fanLevelCap = capabilities["concertmirror08464.shuiiHumJsq002FanLevel"]
local heaterCap = capabilities["concertmirror08464.shuiiHumJsq002Heater"]
local targetHumidityCap = capabilities["concertmirror08464.shuiiHumJsq002TargetHumidity"]
local waterLevelCodeCap = capabilities["concertmirror08464.shuiiHumJsq002WaterLevelCode"]
local targetTemperatureCap = capabilities["concertmirror08464.shuiiHumJsq002TargetTemperature"]
local indicatorBrightnessCap = capabilities["concertmirror08464.shuiiJsq002IndicatorBrightness"]
local buzzerCap = capabilities["concertmirror08464.shuiiHumJsq002Buzzer"]
local childLockCap = capabilities["concertmirror08464.shuiiHumJsq002ChildLock"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "shuii-humidifier-jsq002"

-- Exact model: shuii.humidifier.jsq002
-- specModel: shuii-jsq002
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:shuii-jsq002:1
-- Exact classic miIO mapping from hass-xiaomi-miot MIIO_TO_MIOT_SPECS:
-- get_props -> power, gear, humidity, ledLevel, temperature, waterLevel,
--              heat, beaPower, childLock, targetTemp, targetHumidity
-- Writes: on_off, set_gear, warm_on, set_humidity, set_temp, set_led,
--         buzzer_on, set_lock. In Miio2MiotHelper, setter=True resolves to
--         set_<prop>, so the gear setter is the classic set_gear method.

local PROPERTY_NAMES = {
    "power", "gear", "humidity", "ledLevel", "temperature", "waterLevel",
    "heat", "beaPower", "childLock", "targetTemp", "targetHumidity"
}

local FAN_LEVEL = {[1] = "level1", [2] = "level2", [3] = "level3"}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function emit_on_off(device, cap, attr, value)
    device:emit_event(cap[attr]({value = value == 1 and "on" or "off"}))
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local response = miio.cmd(device, ip, token, "get_props", {})
    if not response or type(response.result) ~= "table" then return end
    local values = {}
    for index, name in ipairs(PROPERTY_NAMES) do values[name] = response.result[index] end

    if type(values.power) == "number" then
        local usable_water = values.waterLevel ~= 0 and values.waterLevel ~= 6
        device:emit_event(capabilities.switch.switch(values.power == 1 and usable_water and "on" or "off"))
    end
    if FAN_LEVEL[values.gear] then
        device:emit_event(fanLevelCap.fanLevel({value = FAN_LEVEL[values.gear]}))
    end
    if type(values.humidity) == "number" then
        device:emit_event(capabilities.relativeHumidityMeasurement.humidity(values.humidity))
    end
    if type(values.temperature) == "number" then
        device:emit_event(capabilities.temperatureMeasurement.temperature({value = values.temperature, unit = "C"}))
    end
    if type(values.waterLevel) == "number" and values.waterLevel >= 1 and values.waterLevel <= 5 then
        device:emit_event(waterLevelCodeCap.waterLevelCode({value = values.waterLevel}))
    end
    if type(values.targetHumidity) == "number" then
        device:emit_event(targetHumidityCap.targetHumidity({value = values.targetHumidity, unit = "%"}))
    end
    if type(values.targetTemp) == "number" then
        device:emit_event(targetTemperatureCap.targetTemperature({value = values.targetTemp, unit = "C"}))
    end
    if type(values.ledLevel) == "number" then
        device:emit_event(indicatorBrightnessCap.indicatorBrightness({value = values.ledLevel}))
    end
    if type(values.heat) == "number" then emit_on_off(device, heaterCap, "heater", values.heat) end
    if type(values.beaPower) == "number" then emit_on_off(device, buzzerCap, "buzzer", values.beaPower) end
    if type(values.childLock) == "number" then emit_on_off(device, childLockCap, "childLock", values.childLock) end
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function() pcall(poll_device_status, device) end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

local function call_setter(device, method, params, emit)
    local ip, token = get_device_config(device)
    if not ip then return end
    if miio.set_prop(device, ip, token, method, params) then
        if emit then emit() end
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end

local function switch_on_handler(_, device, _)
    call_setter(device, "on_off", {1}, function() device:emit_event(capabilities.switch.switch.on()) end)
end

local function switch_off_handler(_, device, _)
    call_setter(device, "on_off", {0}, function() device:emit_event(capabilities.switch.switch.off()) end)
end

local function set_heater_handler(_, device, command)
    local requested = command.args.heater
    call_setter(device, "warm_on", {requested == "on" and 1 or 0},
        function() device:emit_event(heaterCap.heater({value = requested})) end)
end

local function set_fan_level_handler(_, device, command)
    local requested = command.args.fanLevel
    local wire_value = ({level1 = 1, level2 = 2, level3 = 3})[requested]
    if not wire_value then return end
    call_setter(device, "set_gear", {wire_value},
        function() device:emit_event(fanLevelCap.fanLevel({value = requested})) end)
end

local function set_target_humidity_handler(_, device, command)
    local requested = clamp(math.floor(command.args.targetHumidity + 0.5), 30, 90)
    call_setter(device, "set_humidity", {requested},
        function() device:emit_event(targetHumidityCap.targetHumidity({value = requested, unit = "%"})) end)
end

local function set_target_temperature_handler(_, device, command)
    local requested = clamp(math.floor(command.args.targetTemperature + 0.5), 30, 60)
    call_setter(device, "set_temp", {requested},
        function() device:emit_event(targetTemperatureCap.targetTemperature({value = requested, unit = "C"})) end)
end

local function set_indicator_brightness_handler(_, device, command)
    local requested = clamp(math.floor(command.args.indicatorBrightness + 0.5), 1, 3)
    call_setter(device, "set_led", {requested},
        function() device:emit_event(indicatorBrightnessCap.indicatorBrightness({value = requested})) end)
end

local function set_buzzer_handler(_, device, command)
    local requested = command.args.buzzer
    call_setter(device, "buzzer_on", {requested == "on" and 1 or 0},
        function() device:emit_event(buzzerCap.buzzer({value = requested})) end)
end

local function set_child_lock_handler(_, device, command)
    local requested = command.args.childLock
    call_setter(device, "set_lock", {requested == "on" and 1 or 0},
        function() device:emit_event(childLockCap.childLock({value = requested})) end)
end

local function refresh_handler(_, device, _)
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(fanLevelCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    pcall(poll_device_status, device)
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    stop_polling_timer(device)
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
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old = args.old_st_store.preferences
    local new = device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            pcall(poll_device_status, device)
        end
    end
end

local edge_driver = Driver("miio-shuii-humidifier-jsq002", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added, init = device_init, removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = switch_on_handler,
            [capabilities.switch.commands.off.NAME] = switch_off_handler
        },
        [fanLevelCap.ID] = {[fanLevelCap.commands.setFanLevel.NAME] = set_fan_level_handler},
        [heaterCap.ID] = {[heaterCap.commands.setHeater.NAME] = set_heater_handler},
        [targetHumidityCap.ID] = {[targetHumidityCap.commands.setTargetHumidity.NAME] = set_target_humidity_handler},
        [targetTemperatureCap.ID] = {[targetTemperatureCap.commands.setTargetTemperature.NAME] = set_target_temperature_handler},
        [indicatorBrightnessCap.ID] = {[indicatorBrightnessCap.commands.setIndicatorBrightness.NAME] = set_indicator_brightness_handler},
        [buzzerCap.ID] = {[buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler},
        [childLockCap.ID] = {[childLockCap.commands.setChildLock.NAME] = set_child_lock_handler},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

edge_driver:run()
