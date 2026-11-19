local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-jsq2g-" .. os.time(),
        label = "Mijia Smart Anti-bacterial Humidifier 2",
        profile = "xiaomi-humidifier-jsq2g",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.jsq2g",
        vendor_provided_label = "Mijia Smart Anti-bacterial Humidifier 2"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
