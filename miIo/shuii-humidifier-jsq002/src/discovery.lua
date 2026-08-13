local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miio-shuii-humidifier-jsq002-" .. os.time(),
        label = "Shuii Humidifier JSQ002",
        profile = "shuii-humidifier-jsq002",
        manufacturer = "Shuii",
        model = "shuii.humidifier.jsq002",
        vendor_provided_label = "Shuii Humidifier JSQ002",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
