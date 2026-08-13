local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-p3-" .. os.time(),
        label = "Xiaomi Humidifier P3",
        profile = "xiaomi-humidifier-p3",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.p3",
        vendor_provided_label = "Xiaomi Humidifier P3",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
