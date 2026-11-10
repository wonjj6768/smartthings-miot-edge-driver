local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-600-" .. os.time(),
        label = "Mijia Evaporative Humidifier 3 (600 mL/h)",
        profile = "xiaomi-humidifier-600",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.600",
        vendor_provided_label = "Mijia Evaporative Humidifier 3 (600 mL/h)",
    })
end

function discovery.handle_discovery(driver, _, _)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
