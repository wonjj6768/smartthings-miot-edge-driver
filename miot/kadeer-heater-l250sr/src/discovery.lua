local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-kadeer-heater-l250sr-" .. os.time(),
        label = "Kadeer L250 Heater",
        profile = "kadeer-heater-l250sr",
        manufacturer = "kadeer",
        model = "kadeer.heater.l250sr",
        vendor_provided_label = "Kadeer L250 Heater"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
