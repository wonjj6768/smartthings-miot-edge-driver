local discovery = {}

local function create_device(driver)
    local profile = "xiaomi-fan-p90"
    local model = "xiaomi.fan.p90"
    local device_network_id = "miot-fan-xiaomi-p90-" .. tostring(os.time())

    driver:try_create_device({
        type = "LAN",
        device_network_id = device_network_id,
        label = "Mijia Smart DC Inverter Circulation Fan Pro",
        profile = profile,
        manufacturer = "Xiaomi",
        model = model,
        vendor_provided_label = "Xiaomi Fan P90"
    })
end

function discovery.handle_discovery(driver, _, should_continue)
    if should_continue() then
        create_device(driver)
    end
end

discovery.create_device = create_device

return discovery
