local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-viomi-heater-v10-" .. os.time(),
        label = "Viomi V10 Heater",
        profile = "viomi-heater-v10",
        manufacturer = "viomi",
        model = "viomi.heater.v10",
        vendor_provided_label = "Viomi V10 Heater"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
