-- Kadeer Fan L22XH2 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanLevelCap = capabilities["concertmirror08464.kadeerFanL22xh2FanLevel"]
local verticalAngleCap = capabilities["concertmirror08464.kadeerFanL22xh2VerticalAngleV2"]
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "kadeer-fan-l22xh2"
local FAN_SIID = 2
local POWER_PIID = 1
local FAN_LEVEL_PIID = 2
local HORIZONTAL_SWING_PIID = 3
local VERTICAL_SWING_PIID = 4
local VERTICAL_ANGLE_PIID = 5

-- Exact MIoT contract: kadeer.fan.l22xh2, kadeer-l22xh2:1.
-- 2/1 on RW; 2/2 fan level 1..24 RW; 2/3 horizontal swing RW;
-- 2/4 vertical swing RW; 2/5 vertical included angle 0=30, 1=60,
-- 2=90 RW. Anion 2/6 and custom timing 3/1 are not exposed.
local ANGLE_TO_ST = {[0] = "30", [1] = "60", [2] = "90"}
local ST_TO_ANGLE = {['30'] = 0, ['60'] = 1, ['90'] = 2}
local SUPPORTED_OSCILLATION_MODES = {"off", "horizontal", "vertical", "all"}

local function get_device_config(device)
    local ip, token = device.preferences.ipAddress, device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end
local function ensure_profile(device)
    if not device:supports_capability_by_id(verticalAngleCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end
local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local properties = {
        {siid = FAN_SIID, piid = POWER_PIID}, {siid = FAN_SIID, piid = FAN_LEVEL_PIID},
        {siid = FAN_SIID, piid = HORIZONTAL_SWING_PIID}, {siid = FAN_SIID, piid = VERTICAL_SWING_PIID},
        {siid = FAN_SIID, piid = VERTICAL_ANGLE_PIID}
    }
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end
    local horizontal_swing = nil
    local vertical_swing = nil
    for _, result in ipairs(response.result) do
        if result.code == 0 and result.siid == FAN_SIID then
            local piid, value = result.piid, result.value
            if piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(value and "on" or "off"))
            elseif piid == FAN_LEVEL_PIID and type(value) == "number" then
                device:emit_event(fanLevelCap.fanLevel({value = value}))
            elseif piid == HORIZONTAL_SWING_PIID then
                horizontal_swing = value
            elseif piid == VERTICAL_SWING_PIID then
                vertical_swing = value
            elseif piid == VERTICAL_ANGLE_PIID and ANGLE_TO_ST[value] then
                device:emit_event(verticalAngleCap.verticalAngle({value = ANGLE_TO_ST[value]}))
            end
        end
    end
    if horizontal_swing ~= nil or vertical_swing ~= nil then
        local mode = "off"
        if horizontal_swing and vertical_swing then
            mode = "all"
        elseif horizontal_swing then
            mode = "horizontal"
        elseif vertical_swing then
            mode = "vertical"
        end
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(mode))
    end
end
local function start_polling_timer(device)
    local timer = device.thread:call_on_schedule(device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL,
        function() pcall(poll_device_status, device) end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end
local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then device.thread:cancel_timer(timer); device:set_field(POLLING_TIMER, nil) end
end
local function set_property(device, piid, value, event)
    local ip, token = get_device_config(device)
    if not ip then return false end
    local ok = pcall(miot.set, device, ip, token, FAN_SIID, piid, value)
    if ok then device:emit_event(event); return true end
    return false
end
local function switch_on_handler(_, device, _)
    if set_property(device, POWER_PIID, true, capabilities.switch.switch.on()) then
        device.thread:call_with_delay(1, function() pcall(poll_device_status, device) end)
    end
end
local function switch_off_handler(_, device, _) set_property(device, POWER_PIID, false, capabilities.switch.switch.off()) end
local function set_level_handler(_, device, command)
    local value = math.max(1, math.min(24, math.floor(tonumber(command.args.fanLevel) or 1)))
    set_property(device, FAN_LEVEL_PIID, value, fanLevelCap.fanLevel({value = value}))
end
local function set_horizontal_swing_handler(_, device, command)
    local value = command.args.fanOscillationMode
    if value ~= "off" and value ~= "horizontal" and value ~= "vertical" and value ~= "all" then return end
    local ip, token = get_device_config(device)
    if not ip then return end
    local horizontal = value == "horizontal" or value == "all"
    local vertical = value == "vertical" or value == "all"
    local ok_horizontal = pcall(miot.set, device, ip, token, FAN_SIID, HORIZONTAL_SWING_PIID, horizontal)
    local ok_vertical = pcall(miot.set, device, ip, token, FAN_SIID, VERTICAL_SWING_PIID, vertical)
    if ok_horizontal and ok_vertical then
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(value))
    end
end
local function set_vertical_angle_handler(_, device, command)
    local value = ST_TO_ANGLE[command.args.verticalAngle]
    if value ~= nil then
        set_property(device, VERTICAL_ANGLE_PIID, value,
            verticalAngleCap.verticalAngle({value = command.args.verticalAngle}))
    end
end
local function refresh_handler(_, device, _) pcall(poll_device_status, device) end
local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanLevelCap.fanLevel({value = 1}))
    device:emit_event(capabilities.fanOscillationMode.supportedFanOscillationModes({value = SUPPORTED_OSCILLATION_MODES}))
    device:emit_event(capabilities.fanOscillationMode.fanOscillationMode("off"))
    device:emit_event(verticalAngleCap.verticalAngle({value = "30"}))
end
local function device_init(_, device)
    ensure_profile(device); device:online()
    local ip = get_device_config(device)
    if ip then start_polling_timer(device); pcall(poll_device_status, device) end
end
local function device_removed(_, device) stop_polling_timer(device) end
local function device_info_changed(driver, device, _, args)
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end
    local old, new = args.old_st_store.preferences, device.preferences
    if old.createDev == false and new.createDev == true then discovery.create_device(driver) end
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        local ip = get_device_config(device)
        if ip then start_polling_timer(device); pcall(poll_device_status, device) end
    end
end

local driver = Driver("miot-kadeer-fan-l22xh2", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {added = device_added, init = device_init, removed = device_removed, infoChanged = device_info_changed},
    capability_handlers = {
        [capabilities.switch.ID] = {[capabilities.switch.commands.on.NAME] = switch_on_handler, [capabilities.switch.commands.off.NAME] = switch_off_handler},
        [fanLevelCap.ID] = {[fanLevelCap.commands.setFanLevel.NAME] = set_level_handler},
        [capabilities.fanOscillationMode.ID] = {[capabilities.fanOscillationMode.commands.setFanOscillationMode.NAME] = set_horizontal_swing_handler},
        [verticalAngleCap.ID] = {[verticalAngleCap.commands.setVerticalAngle.NAME] = set_vertical_angle_handler},
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
})

driver:run()
