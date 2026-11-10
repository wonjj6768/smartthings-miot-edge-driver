local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local PROFILE_NAME = "xiaomi-humidifier-600"
local MODEL = "xiaomi.humidifier.600"
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local selfCleanCap = capabilities["concertmirror08464.xiaomiHum600SelfClean"]
local filterLifeCap = capabilities["concertmirror08464.xiaomiHum600FilterLife"]

local FEATURES = {
    {cap = capabilities["concertmirror08464.xiaomiHum600Mode"], attribute = "mode", siid = 2, piid = 3,
        command = "setMode", raw_to_st = {[0] = "constantHumidity", [1] = "sleep", [2] = "strong", [3] = "airDry"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600TargetHumidity"], attribute = "targetHumidity", siid = 2,
        piid = 5, command = "setTargetHumidity", minimum = 40, maximum = 70, integer = true, unit = "%"},
    {cap = capabilities["concertmirror08464.xiaomiHum600OverwetProtect"], attribute = "overwetProtect", siid = 2,
        piid = 11, command = "setOverwetProtect", raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600Screen"], attribute = "screen", siid = 6, piid = 1,
        command = "setScreen", raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600ScreenBrightness"], attribute = "screenBrightness",
        siid = 6, piid = 2, command = "setScreenBrightness", raw_to_st = {[0] = "dim", [1] = "normal"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600Buzzer"], attribute = "buzzer", siid = 7, piid = 1,
        command = "setBuzzer", raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600ChildLock"], attribute = "childLock", siid = 8, piid = 1,
        command = "setChildLock", raw_to_st = {[false] = "off", [true] = "on"}},
    {cap = capabilities["concertmirror08464.xiaomiHum600Fault"], attribute = "fault", siid = 2, piid = 2,
        raw_to_st = {[0] = "noFaults", [1] = "motorFault", [2] = "pumpFault", [3] = "pumpFail", [4] = "lowWater"}},
    {cap = selfCleanCap, attribute = "selfClean", siid = 10, piid = 1,
        raw_to_st = {[1] = "ready", [2] = "inProgress", [3] = "finished"}},
    {cap = filterLifeCap, attribute = "filterLife", siid = 4, piid = 1,
        minimum = 0, maximum = 100, integer = true, unit = "%"}
}

local PROPERTIES = {{kind = "power", siid = 2, piid = 1}, {kind = "humidity", siid = 3, piid = 1}}
for _, feature in ipairs(FEATURES) do
    if feature.raw_to_st then
        feature.st_to_raw = {}
        for raw, value in pairs(feature.raw_to_st) do feature.st_to_raw[value] = raw end
    end
    PROPERTIES[#PROPERTIES + 1] = {kind = "custom", siid = feature.siid, piid = feature.piid, feature = feature}
end

local function get_device_config(device)
    local ip, token = device.preferences.ipAddress, device.preferences.token
    if ip and ip ~= "" and token and #token == 32 and token:match("^[0-9a-fA-F]+$") then return ip, token end
    return nil, nil
end

local function ensure_profile(device)
    for _, property in ipairs(PROPERTIES) do
        local cap = property.kind == "power" and capabilities.switch or
            property.kind == "humidity" and capabilities.relativeHumidityMeasurement or property.feature.cap
        if not device:supports_capability_by_id(cap.ID, "main") then
            device:try_update_metadata({profile = PROFILE_NAME})
            return false
        end
    end
    return true
end

local function find_property(siid, piid)
    for _, property in ipairs(PROPERTIES) do
        if property.siid == siid and property.piid == piid then return property end
    end
end

local function valid_number(value, minimum, maximum, integer)
    return type(value) == "number" and value >= minimum and value <= maximum and
        (not integer or value % 1 == 0)
end

local function emit_property(device, property, raw)
    if property.kind == "power" then
        if type(raw) ~= "boolean" then return false end
        device:emit_event(raw and capabilities.switch.switch.on() or capabilities.switch.switch.off())
    elseif property.kind == "humidity" then
        if not valid_number(raw, 0, 100, true) then return false end
        device:emit_event(capabilities.relativeHumidityMeasurement.humidity(raw))
    else
        local feature, value = property.feature, raw
        if feature.raw_to_st then
            value = feature.raw_to_st[raw]
            if value == nil then return false end
        elseif not valid_number(raw, feature.minimum, feature.maximum, feature.integer) then
            return false
        end
        local event = {value = value}
        if feature.unit then event.unit = feature.unit end
        device:emit_event(feature.cap[feature.attribute](event))
    end
    return true
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip or not ensure_profile(device) then return end
    local requested = {}
    for _, property in ipairs(PROPERTIES) do
        requested[#requested + 1] = {siid = property.siid, piid = property.piid}
    end
    local response = miot.gets(device, ip, token, requested)
    if not response or type(response.result) ~= "table" then
        local detail = response and response.error
        device.log.error(MODEL .. " get_properties failed: " ..
            (detail and tostring(detail.code) .. " " .. tostring(detail.message) or "missing result"))
        return
    end
    local observed = false
    for _, result in ipairs(response.result) do
        local property = find_property(result.siid, result.piid)
        if result.code == 0 and property then
            if emit_property(device, property, result.value) then
                observed = true
            else
                device.log.warn(string.format("%s invalid property value at%d/%d", MODEL, result.siid, result.piid))
            end
        elseif result.code ~= 0 then
            device.log.warn(string.format("%s get_properties %s/%s failed: code=%s", MODEL,
                tostring(result.siid), tostring(result.piid), tostring(result.code)))
        end
    end
    if observed then device:online() end
end

local function run_poll(device, operation)
    local ok, err = pcall(poll_device_status, device)
    if not ok then device.log.error(MODEL .. " get_properties failed (" .. operation .. "): " .. tostring(err)) end
end

local function schedule_poll(device, operation)
    device.thread:call_with_delay(1, function() run_poll(device, operation) end)
end

local function set_property(device, siid, piid, value)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok, err = pcall(miot.set, device, ip, token, siid, piid, value)
    if not ok then
        device.log.error(string.format("%s set_properties %d/%d failed: %s", MODEL, siid, piid, tostring(err)))
        return
    end
    schedule_poll(device, "set-properties")
end

local function run_action(device, siid, aiid)
    local ip, token = get_device_config(device)
    if not ip then return end
    local ok, err = pcall(miot.action, device, ip, token, siid, aiid, {})
    if not ok then
        device.log.error(string.format("%s action %d/%d failed: %s", MODEL, siid, aiid, tostring(err)))
        return
    end
    schedule_poll(device, "action")
end

local function set_custom_handler(device, feature, command)
    local requested = command.args[feature.attribute]
    local value = requested
    if feature.st_to_raw then
        value = feature.st_to_raw[requested]
        if value == nil then return end
    elseif not valid_number(value, feature.minimum, feature.maximum, feature.integer) then
        return
    end
    set_property(device, feature.siid, feature.piid, value)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

local function device_init(_, device)
    local ready = ensure_profile(device)
    stop_polling_timer(device)
    local ip = get_device_config(device)
    if ip then
        device:set_field(POLLING_TIMER, device.thread:call_on_schedule(
            device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL,
            function() run_poll(device, "timer") end, "Polling"))
        if ready then run_poll(device, "init") end
    end
end

local function refresh_handler(_, device, _)
    run_poll(device, "refresh")
end

local function device_info_changed(driver, device, _, args)
    local old = args.old_st_store and args.old_st_store.preferences
    if not old then return end
    local new = device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        device_init(driver, device)
    end
end

local handlers = {
    [capabilities.switch.ID] = {
        [capabilities.switch.commands.on.NAME] = function(_, device) set_property(device, 2, 1, true) end,
        [capabilities.switch.commands.off.NAME] = function(_, device) set_property(device, 2, 1, false) end
    },
    [selfCleanCap.ID] = {
        [selfCleanCap.commands.startSelfClean.NAME] = function(_, device) run_action(device, 10, 1) end,
        [selfCleanCap.commands.stopSelfClean.NAME] = function(_, device) run_action(device, 10, 2) end
    },
    [filterLifeCap.ID] = {
        [filterLifeCap.commands.resetFilter.NAME] = function(_, device) run_action(device, 4, 1) end
    },
    [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
}
for _, feature in ipairs(FEATURES) do
    if feature.command then
        local current = feature
        handlers[current.cap.ID] = {[current.cap.commands[current.command].NAME] = function(_, device, command)
            set_custom_handler(device, current, command)
        end}
    end
end

local driver = Driver("miot-xiaomi-humidifier-600", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_init, init = device_init, driverSwitched = device_init,
        infoChanged = device_info_changed, removed = function(_, device) stop_polling_timer(device) end},
    capability_handlers = handlers
})
driver:run()
