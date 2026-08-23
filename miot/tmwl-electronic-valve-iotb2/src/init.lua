-- TMWL Electronic Valve IOTB2 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local energyUsage = capabilities["concertmirror08464.tmwlValveEnergyUsage"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local EXPECTED_PROFILE_NAME = "tmwl-electronic-valve-iotb2"

-- MIoT model: tmwl.valve.iotb2
-- specModel: tmwl-iotb2
-- URN: urn:miot-spec-v2:device:electronic-valve:0000A0A7:tmwl-iotb2:1
--
-- Electronic Valve service (siid=2)
--   piid=1 valve-switch, bool, RW: true=open, false=closed
--   piid=2 target-water-level, uint16, RW, not exposed
--   piid=3 fault, uint8, R, 0..100, not exposed
-- Power Consumption service (siid=3)
--   piid=1 power-consumption, float, R, kWh
--   piid=6 electric-power, float, R, watt
-- device-detail service (siid=4): terminal temperature, current, and MCU
--   diagnostics, not exposed
-- device-enablesetting (siid=6), device-valuesetting (siid=7), and
--   device-lock (siid=8): protection thresholds and lock internals, not exposed

local VALVE_SIID = 2
local VALVE_SWITCH_PIID = 1

local POWER_SIID = 3
local ENERGY_PIID = 1
local POWER_PIID = 6

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
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
        {siid = VALVE_SIID, piid = VALVE_SWITCH_PIID},
        {siid = POWER_SIID, piid = ENERGY_PIID},
        {siid = POWER_SIID, piid = POWER_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == VALVE_SIID and piid == VALVE_SWITCH_PIID then
                device:emit_event(value and capabilities.valve.valve.open() or capabilities.valve.valve.closed())
            elseif siid == POWER_SIID then
                if piid == ENERGY_PIID then
                    device:emit_event(energyUsage.energyUsage({value = value, unit = "kWh"}))
                elseif piid == POWER_PIID then
                    device:emit_event(capabilities.powerMeter.power({value = value, unit = "W"}))
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

local function valve_open_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, VALVE_SIID, VALVE_SWITCH_PIID, true)
    if ok then
        device:emit_event(capabilities.valve.valve.open())
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function valve_close_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, VALVE_SIID, VALVE_SWITCH_PIID, false)
    if ok then
        device:emit_event(capabilities.valve.valve.closed())
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function refresh_handler(_, device, _)
    pcall(poll_device_status, device)
end

local function ensure_profile(device)
    if not device:supports_capability_by_id(energyUsage.ID, "main") then
        device:try_update_metadata({profile = EXPECTED_PROFILE_NAME})
    end
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.valve.valve.closed())
    device:emit_event(capabilities.powerMeter.power({value = 0, unit = "W"}))
    device:emit_event(energyUsage.energyUsage({value = 0, unit = "kWh"}))
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()

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

local driver = Driver("miot-tmwl-electronic-valve-iotb2", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.valve.ID] = {
            [capabilities.valve.commands.open.NAME] = valve_open_handler,
            [capabilities.valve.commands.close.NAME] = valve_close_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
