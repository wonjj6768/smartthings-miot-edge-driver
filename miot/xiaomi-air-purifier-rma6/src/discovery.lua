local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-airp-rma6-" .. os.time(),
        label = "Mijia Smart Air Purifier 6C",
        profile = "xiaomi-air-purifier-rma6",
        manufacturer = "Xiaomi",
        model = "xiaomi.airp.rma6",
        vendor_provided_label = "Mijia Smart Air Purifier 6C"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
