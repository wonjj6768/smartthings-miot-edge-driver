local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-deerma-humidifier-ct500-" .. os.time(),
        label = "Deerma Humidifier CT500",
        profile = "deerma-humidifier-ct500",
        manufacturer = "Deerma",
        model = "deerma.humidifier.ct500",
        vendor_provided_label = "Deerma Humidifier CT500",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
