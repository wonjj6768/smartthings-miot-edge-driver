local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-ha2-" .. os.time(),
        label = "Mijia Purifying Evaporative Humidifier 3 Pro",
        profile = "xiaomi-humidifier-ha2",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.ha2",
        vendor_provided_label = "Mijia Purifying Evaporative Humidifier 3 Pro"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
