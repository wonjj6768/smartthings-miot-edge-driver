local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-fan-solove-f5new-" .. os.time(),
        label = "Solove Fan F5 New",
        profile = "solove-fan-f5new",
        manufacturer = "Solove",
        model = "solove.fan.f5new",
        vendor_provided_label = "Solove Fan F5 New"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
