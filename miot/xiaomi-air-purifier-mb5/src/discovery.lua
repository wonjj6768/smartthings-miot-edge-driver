local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-airpurifier-xiaomi-mb5-" .. os.time(),
        label = "Mijia Smart Air Purifier 6",
        profile = "xiaomi-air-purifier-mb5",
        manufacturer = "Xiaomi",
        model = "xiaomi.airp.mb5",
        vendor_provided_label = "Mijia Smart Air Purifier 6"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
