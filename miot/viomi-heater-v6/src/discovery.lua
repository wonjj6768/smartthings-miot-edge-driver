local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-viomi-heater-v6-" .. os.time(),
        label = "Viomi Heater V6",
        profile = "viomi-heater-v6",
        manufacturer = "Viomi",
        model = "viomi.heater.v6",
        vendor_provided_label = "Viomi Heater V6",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
