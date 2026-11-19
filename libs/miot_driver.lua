-- Shared runtime for explicit exact-model MIoT contracts. Transport remains in miot.lua.
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local miot = require "miot"

local runtime = {}
local POLLING_TIMER = "polling_timer"
local READBACK_TIMER = "readback_timer"
local DEFAULT_POLLING_INTERVAL = 60

function runtime.run(contract)
    local MODEL = contract.model
    local PROFILE_NAME = contract.profile
    local properties = contract.properties
    local actions = contract.actions or {}

    local function log_failure(device, operation, reason)
        local message = tostring(reason)
        local token = device.preferences.token
        if token and #token == 32 then
            message = message:gsub(token, "[redacted]")
                :gsub(token:lower(), "[redacted]"):gsub(token:upper(), "[redacted]")
        end
        device.log.error(MODEL .. " " .. operation .. " failed: " .. message)
    end

    local function get_device_config(device)
        local ip, token = device.preferences.ipAddress, device.preferences.token
        if ip and ip ~= "" and token and #token == 32 and token:match("^%x+$") then
            return ip, token
        end
    end

    local function component_of(item)
        return item.component or "main"
    end

    local function emit(device, item, attribute, payload)
        local component = device.profile.components[component_of(item)]
        device:emit_component_event(component, item.cap[attribute](payload))
    end

    local function ensure_profile(device)
        local required = {{cap = capabilities.refresh}}
        for _, item in ipairs(properties) do required[#required + 1] = item end
        for _, item in ipairs(actions) do required[#required + 1] = item end
        for _, item in ipairs(required) do
            if not device:supports_capability_by_id(item.cap.ID, component_of(item)) then
                device:try_update_metadata({profile = PROFILE_NAME})
                return true
            end
        end
        return false
    end

    local function emit_supported_commands(device)
        for _, item in ipairs(actions) do
            if item.cap.ID == capabilities.filterState.ID then
                emit(device, item, "supportedFilterCommands", {value = {"resetFilter"}})
            end
        end
    end

    local function numeric_value(item, value)
        if type(value) ~= "number" or value ~= value then return nil end
        if item.minimum and value < item.minimum or item.maximum and value > item.maximum then return nil end
        if item.step then
            local steps = (value - (item.minimum or 0)) / item.step
            if math.abs(steps - math.floor(steps + 0.5)) > 0.000001 then return nil end
        end
        return value
    end

    local function poll_device_status(device)
        local ip, token = get_device_config(device)
        if not ip then return end
        local received = false
        -- New firmware can reject a batch; each request has an independent result/error.
        for _, item in ipairs(properties) do
            local operation = string.format("get_properties siid=%d piid=%d", item.siid, item.piid)
            local ok, response = pcall(miot.get, device, ip, token, item.siid, item.piid)
            local result = ok and type(response) == "table" and type(response.result) == "table"
                and response.result[1] or nil
            if not ok then
                log_failure(device, operation, response)
            elseif not result or result.code ~= 0 or result.value == nil then
                local rpc = type(response) == "table" and response.error
                local reason = rpc and (tostring(rpc.code) .. ": " .. tostring(rpc.message))
                    or "property code=" .. tostring(result and result.code) .. "; missing value/result"
                log_failure(device, operation, reason)
            elseif result.siid ~= item.siid or result.piid ~= item.piid then
                log_failure(device, operation, "response property identity mismatch")
            else
                local value
                if item.raw_to_st then
                    value = item.raw_to_st[result.value]
                else
                    value = numeric_value(item, result.value)
                end
                if value == nil then
                    log_failure(device, operation, "unsupported value=" .. tostring(result.value))
                else
                    received = true
                    emit(device, item, item.attribute, {value = value, unit = item.unit})
                end
            end
        end
        if received then device:online() end
    end

    local function cancel_timer(device, field)
        local timer = device:get_field(field)
        if timer then
            device.thread:cancel_timer(timer)
            device:set_field(field, nil)
        end
    end

    local function schedule_status_refresh(device)
        cancel_timer(device, READBACK_TIMER)
        device:set_field(READBACK_TIMER, device.thread:call_with_delay(1, function()
            device:set_field(READBACK_TIMER, nil)
            if not ensure_profile(device) then
                emit_supported_commands(device)
                poll_device_status(device)
            end
        end, "MIoT readback"))
    end

    local function set_property(device, item, value)
        local ip, token = get_device_config(device)
        if not ip then
            log_failure(device, "set_properties", "IP/token configuration is incomplete")
            return
        end
        local ok, response = pcall(miot.set, device, ip, token, item.siid, item.piid, value)
        if not ok then
            log_failure(device, string.format("set_properties siid=%d piid=%d", item.siid, item.piid), response)
            return
        end
        schedule_status_refresh(device)
    end

    local function make_property_handler(item, fixed)
        return function(_, device, command)
            if (command.component or "main") ~= component_of(item) then
                log_failure(device, item.command or "switch", "unsupported component")
                return
            end
            local value = fixed
            if value == nil then
                value = command.args[item.argument or item.attribute]
                if item.st_to_raw then
                    value = item.st_to_raw[value]
                else
                    value = numeric_value(item, value)
                end
            end
            if value == nil then
                log_failure(device, item.command or item.cap.ID, "unsupported command value")
                return
            end
            set_property(device, item, value)
        end
    end

    local function make_action_handler(routes)
        return function(_, device, command)
            local item = routes[command.component or "main"]
            if not item then
                log_failure(device, command.command, "unsupported component")
                return
            end
            local ip, token = get_device_config(device)
            if not ip then
                log_failure(device, "action", "IP/token configuration is incomplete")
                return
            end
            local ok, response = pcall(miot.action, device, ip, token, item.siid, item.aiid, {})
            if not ok then
                log_failure(device, string.format("action siid=%d aiid=%d", item.siid, item.aiid), response)
                return
            end
            schedule_status_refresh(device)
        end
    end

    local function refresh_handler(_, device)
        if ensure_profile(device) then
            schedule_status_refresh(device)
            return
        end
        emit_supported_commands(device)
        poll_device_status(device)
    end

    local function start_polling_timer(device)
        cancel_timer(device, POLLING_TIMER)
        local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
        device:set_field(POLLING_TIMER, device.thread:call_on_schedule(interval, function()
            if not ensure_profile(device) then poll_device_status(device) end
        end, "MIoT polling"))
    end

    local function device_init(driver, device)
        cancel_timer(device, POLLING_TIMER)
        cancel_timer(device, READBACK_TIMER)
        local ip = get_device_config(device)
        if ip then start_polling_timer(device) end
        refresh_handler(driver, device)
    end

    local function device_removed(_, device)
        cancel_timer(device, POLLING_TIMER)
        cancel_timer(device, READBACK_TIMER)
    end

    local function device_info_changed(driver, device, _, args)
        local old = args.old_st_store and args.old_st_store.preferences
        if not old then return end
        local new = device.preferences
        if old.createDev ~= true and new.createDev == true then contract.discovery.create_device(driver) end
        if old.ipAddress ~= new.ipAddress or old.token ~= new.token then
            device:set_field("dev_id", nil)
            device:set_field("time_offset", nil)
        end
        if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
            device_init(driver, device)
        end
    end

    local capability_handlers = {
        [capabilities.refresh.ID] = {[capabilities.refresh.commands.refresh.NAME] = refresh_handler}
    }
    for _, item in ipairs(properties) do
        if item.cap.ID == capabilities.switch.ID then
            capability_handlers[item.cap.ID] = {
                [capabilities.switch.commands.on.NAME] = make_property_handler(item, true),
                [capabilities.switch.commands.off.NAME] = make_property_handler(item, false)
            }
        elseif item.command then
            capability_handlers[item.cap.ID] = {
                [item.cap.commands[item.command].NAME] = make_property_handler(item)
            }
        end
    end
    local action_routes = {}
    for _, item in ipairs(actions) do
        action_routes[item.cap.ID] = action_routes[item.cap.ID] or {}
        local routes = action_routes[item.cap.ID]
        routes[item.command] = routes[item.command] or {}
        routes[item.command][component_of(item)] = item
    end
    for id, commands in pairs(action_routes) do
        capability_handlers[id] = capability_handlers[id] or {}
        for command, routes in pairs(commands) do
            capability_handlers[id][command] = make_action_handler(routes)
        end
    end
    local driver = Driver(contract.name, {
        discovery = contract.discovery.handle_discovery,
        lifecycle_handlers = {
            added = refresh_handler, init = device_init, driverSwitched = device_init,
            doConfigure = refresh_handler, infoChanged = device_info_changed, removed = device_removed
        },
        capability_handlers = capability_handlers
    })
    driver:run()
end

return runtime
