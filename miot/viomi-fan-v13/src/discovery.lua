local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-fan-viomi-v13-" .. os.time(),
        label = "Viomi Fan V13",
        profile = "viomi-fan-v13",
        manufacturer = "Viomi",
        model = "viomi.fan.v13",
        vendor_provided_label = "Viomi Fan V13"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
