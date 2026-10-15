local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-air-purifier-xiaomi-mb6-" .. os.time(),
        label = "Mijia Smart Air Purifier Max",
        profile = "xiaomi-air-purifier-mb6",
        manufacturer = "Xiaomi",
        model = "xiaomi.airp.mb6",
        vendor_provided_label = "Mijia Smart Air Purifier Max"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
