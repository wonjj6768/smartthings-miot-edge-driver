-- Mijia Smart Evaporative Humidifier Pro Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local modeCap = capabilities["concertmirror08464.xiaomiHum600ekMode"]
local targetHumidityCap = capabilities["concertmirror08464.xiaomiHum600ekTargetHumidity"]
local screenCap = capabilities["concertmirror08464.xiaomiHum600ekScreen"]
local screenBrightnessCap = capabilities["concertmirror08464.xiaomiHum600ekScreenBrightness"]
local buzzerCap = capabilities["concertmirror08464.xiaomiHum600ekBuzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiHum600ekChildLock"]
local overwetProtectCap = capabilities["concertmirror08464.xiaomiHum600ekOverwetProtect"]
local faultCap = capabilities["concertmirror08464.xiaomiHum600ekFault"]
local selfCleanCap = capabilities["concertmirror08464.xiaomiHum600ekSelfClean"]

local PROFILE_NAME = "xiaomi-humidifier-600ek"
local EXPECTED_CAPABILITY_ID = "concertmirror08464.xiaomiHum600ekSelfClean"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- Exact model: xiaomi.humidifier.600ek
-- specModel: xiaomi-600ek
-- URN: urn:miot-spec-v2:device:humidifier:0000A00E:xiaomi-600ek:2:0000D061
-- Native MIoT local contract: get_properties / set_properties with exact
-- siid/piid values below; self-clean uses the exact MIoT action identifiers.
--
-- Humidifier service (siid=2)
--   piid=1 power, bool, RW
--   piid=2 fault, uint8, R: 0=noFaults, 1=motorFault, 2=pumpFault,
--            3=pumpFail, 4=lowWater
--   piid=3 mode, uint8, RW: 0=constantHumidity, 1=sleep, 2=strong, 3=airDry
--   piid=5 target-humidity, uint8, RW, 40..70 %, step 1
--   piid=11 overwet-protect, bool, RW
-- Environment service (siid=3)
--   piid=1 relative-humidity, uint8, R, 0..100 %
-- Screen service (siid=6)
--   piid=1 on, bool, RW
--   piid=2 brightness, uint8, RW: 0=dim, 1=normal
-- Alarm service (siid=7)
--   piid=1 alarm, bool, RW
-- Physical Control Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW
-- Clean service (siid=10)
--   piid=1 self-clean, uint8, R: 1=ready, 2=inProgress, 3=finished
--   aiid=1 start-self-clean, action
--   aiid=2 stop-self-clean, action

local FEATURES = {
    {
        cap = modeCap,
        attribute = "mode",
        siid = 2,
        piid = 3,
        writable = true,
        command = "setMode",
        raw_to_st = {
            [0] = "constantHumidity",
            [1] = "sleep",
            [2] = "strong",
            [3] = "airDry",
        },
    },
    {
        cap = targetHumidityCap,
        attribute = "targetHumidity",
        siid = 2,
        piid = 5,
        writable = true,
        command = "setTargetHumidity",
        minimum = 40,
        maximum = 70,
        integer = true,
        unit = "%",
    },
    {
        cap = overwetProtectCap,
        attribute = "overwetProtect",
        siid = 2,
        piid = 11,
        writable = true,
        command = "setOverwetProtect",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        cap = screenCap,
        attribute = "screen",
        siid = 6,
        piid = 1,
        writable = true,
        command = "setScreen",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        cap = screenBrightnessCap,
        attribute = "screenBrightness",
        siid = 6,
        piid = 2,
        writable = true,
        command = "setScreenBrightness",
        raw_to_st = {[0] = "dim", [1] = "normal"},
    },
    {
        cap = buzzerCap,
        attribute = "buzzer",
        siid = 7,
        piid = 1,
        writable = true,
        command = "setBuzzer",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        cap = childLockCap,
        attribute = "childLock",
        siid = 8,
        piid = 1,
        writable = true,
        command = "setChildLock",
        raw_to_st = {[false] = "off", [true] = "on"},
    },
    {
        cap = faultCap,
        attribute = "fault",
        siid = 2,
        piid = 2,
        writable = false,
        raw_to_st = {
            [0] = "noFaults",
            [1] = "motorFault",
            [2] = "pumpFault",
            [3] = "pumpFail",
            [4] = "lowWater",
        },
    },
    {
        cap = selfCleanCap,
        attribute = "selfClean",
        siid = 10,
        piid = 1,
        writable = false,
        raw_to_st = {[1] = "ready", [2] = "inProgress", [3] = "finished"},
    },
}

for _, feature in ipairs(FEATURES) do
    if feature.raw_to_st then
        feature.st_to_raw = {}
        for raw, mapped in pairs(feature.raw_to_st) do
            feature.st_to_raw[mapped] = raw
        end
    end
end

local PROPERTIES = {
    {kind = "switch", siid = 2, piid = 1},
    {kind = "custom", siid = 2, piid = 2, feature = FEATURES[8]},
    {kind = "custom", siid = 2, piid = 3, feature = FEATURES[1]},
    {kind = "custom", siid = 2, piid = 5, feature = FEATURES[2]},
    {kind = "custom", siid = 2, piid = 11, feature = FEATURES[3]},
    {kind = "humidity", siid = 3, piid = 1},
    {kind = "custom", siid = 6, piid = 1, feature = FEATURES[4]},
    {kind = "custom", siid = 6, piid = 2, feature = FEATURES[5]},
    {kind = "custom", siid = 7, piid = 1, feature = FEATURES[6]},
    {kind = "custom", siid = 8, piid = 1, feature = FEATURES[7]},
    {kind = "custom", siid = 10, piid = 1, feature = FEATURES[9]},
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then
        return ip, token
    end
    return nil, nil
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

local function find_property(siid, piid)
    for _, property in ipairs(PROPERTIES) do
        if property.siid == siid and property.piid == piid then
            return property
        end
    end
    return nil
end

local function emit_custom(device, feature, raw)
    local value = raw
    if feature.raw_to_st then
        value = feature.raw_to_st[raw]
        if value == nil then return end
    end

    if feature.unit then
        device:emit_event(feature.cap[feature.attribute]({value = value, unit = feature.unit}))
    else
        device:emit_event(feature.cap[feature.attribute]({value = value}))
    end
end

local function emit_property(device, property, value)
    if property.kind == "switch" then
        device:emit_event(value and capabilities.switch.switch.on() or capabilities.switch.switch.off())
    elseif property.kind == "humidity" then
        device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
    elseif property.kind == "custom" then
        emit_custom(device, property.feature, value)
    end
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local request = {}
    for _, property in ipairs(PROPERTIES) do
        table.insert(request, {siid = property.siid, piid = property.piid})
    end

    local response = miot.gets(device, ip, token, request)
    if not response or not response.result then
        device.log.error("600EK get_properties returned no result")
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local property = find_property(result.siid, result.piid)
            if property then
                emit_property(device, property, result.value)
            end
        else
            device.log.warn(string.format(
                "600EK property read failed (siid=%s, piid=%s, code=%s)",
                tostring(result.siid), tostring(result.piid), tostring(result.code)
            ))
        end
    end
end

local function run_poll(device, source)
    local ok, err = pcall(poll_device_status, device)
    if not ok then
        device.log.error(string.format("600EK poll failed (%s): %s", source, tostring(err)))
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

local function schedule_poll(device, source)
    device.thread:call_with_delay(1, function()
        run_poll(device, source)
    end)
end

local function set_miot_property(device, property, value, source)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok, err = pcall(miot.set, device, ip, token, property.siid, property.piid, value)
    if not ok then
        device.log.error(string.format(
            "600EK set_properties failed (%s, siid=%d, piid=%d): %s",
            source, property.siid, property.piid, tostring(err)
        ))
        return
    end

    emit_property(device, property, value)
    schedule_poll(device, source)
end

local function switch_on_handler(_, device, _)
    set_miot_property(device, find_property(2, 1), true, "switch-on")
end

local function switch_off_handler(_, device, _)
    set_miot_property(device, find_property(2, 1), false, "switch-off")
end

local function set_custom_handler(device, feature, command)
    local requested = command.args[feature.attribute]
    local raw = requested

    if feature.st_to_raw then
        raw = feature.st_to_raw[requested]
        if raw == nil then return end
    else
        raw = tonumber(requested)
        if raw == nil then return end
        if feature.integer then raw = math.floor(raw + 0.5) end
        raw = clamp(raw, feature.minimum, feature.maximum)
    end

    set_miot_property(device, find_property(feature.siid, feature.piid), raw, feature.attribute)
end

local function run_self_clean_action(device, aiid, state, source)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok, err = pcall(miot.action, device, ip, token, 10, aiid, {})
    if not ok then
        device.log.error(string.format("600EK self-clean action failed (%s): %s", source, tostring(err)))
        return
    end

    device:emit_event(selfCleanCap.selfClean({value = state}))
    schedule_poll(device, source)
end

local function start_self_clean_handler(_, device, _)
    run_self_clean_action(device, 1, "inProgress", "self-clean-start")
end

local function stop_self_clean_handler(_, device, _)
    run_self_clean_action(device, 2, "ready", "self-clean-stop")
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(EXPECTED_CAPABILITY_ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function refresh_handler(_, device, _)
    ensure_profile(device)
    run_poll(device, "refresh")
end

local function device_added(_, device)
    ensure_profile(device)
    run_poll(device, "added")
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    stop_polling_timer(device)

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
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end

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

local capability_handlers = {
    [capabilities.switch.ID] = {
        [capabilities.switch.commands.on.NAME] = switch_on_handler,
        [capabilities.switch.commands.off.NAME] = switch_off_handler,
    },
    [selfCleanCap.ID] = {
        [selfCleanCap.commands.startSelfClean.NAME] = start_self_clean_handler,
        [selfCleanCap.commands.stopSelfClean.NAME] = stop_self_clean_handler,
    },
    [capabilities.refresh.ID] = {
        [capabilities.refresh.commands.refresh.NAME] = refresh_handler,
    },
}

for _, feature in ipairs(FEATURES) do
    if feature.writable then
        local handler_feature = feature
        capability_handlers[handler_feature.cap.ID] = {
            [handler_feature.cap.commands[handler_feature.command].NAME] = function(_, device, command)
                set_custom_handler(device, handler_feature, command)
            end,
        }
    end
end

local edge_driver = Driver("miot-xiaomi-humidifier-600ek", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed,
    },
    capability_handlers = capability_handlers,
})

edge_driver:run()
