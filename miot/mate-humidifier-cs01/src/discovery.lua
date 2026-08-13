local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-mate-humidifier-cs01-" .. os.time(),
        label = "Mate Humidifier CS01",
        profile = "mate-humidifier-cs01",
        manufacturer = "Mate",
        model = "mate.humidifier.cs01",
        vendor_provided_label = "Mate Humidifier CS01",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
