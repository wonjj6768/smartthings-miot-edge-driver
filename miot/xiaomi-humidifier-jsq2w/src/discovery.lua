local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-jsq2w-" .. os.time(),
        label = "Xiaomi Smart Humidifier 2",
        profile = "xiaomi-humidifier-jsq2w",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.jsq2w",
        vendor_provided_label = "Xiaomi Smart Humidifier 2"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
