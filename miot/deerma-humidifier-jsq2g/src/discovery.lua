local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-deerma-humidifier-jsq2g-" .. os.time(),
        label = "Deerma Humidifier JSQ2G",
        profile = "deerma-humidifier-jsq2g",
        manufacturer = "Deerma",
        model = "deerma.humidifier.jsq2g",
        vendor_provided_label = "Deerma Humidifier JSQ2G",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
