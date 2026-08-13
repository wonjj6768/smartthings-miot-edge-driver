local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-viomi-heater-v5-" .. os.time(),
        label = "Viomi V5 Heater",
        profile = "viomi-heater-v5",
        manufacturer = "viomi",
        model = "viomi.heater.v5",
        vendor_provided_label = "Viomi V5 Heater"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
