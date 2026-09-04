local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-600ek-" .. os.time(),
        label = "Mijia Smart Evaporative Humidifier Pro",
        profile = "xiaomi-humidifier-600ek",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.600ek",
        vendor_provided_label = "Mijia Smart Evaporative Humidifier Pro",
    })
end

function discovery.handle_discovery(driver, _, _)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
