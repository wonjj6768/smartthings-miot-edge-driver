local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-leshow-humidifier-jsq3-" .. os.time(),
        label = "Leshow Humidifier JSQ3",
        profile = "leshow-humidifier-jsq3",
        manufacturer = "Leshow",
        model = "leshow.humidifier.jsq3",
        vendor_provided_label = "Leshow Humidifier JSQ3",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
