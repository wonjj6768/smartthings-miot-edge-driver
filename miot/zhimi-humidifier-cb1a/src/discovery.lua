local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-zhimi-humidifier-cb1a-" .. os.time(),
        label = "Zhimi Humidifier CB1A",
        profile = "zhimi-humidifier-cb1a",
        manufacturer = "Zhimi",
        model = "zhimi.humidifier.cb1a",
        vendor_provided_label = "Zhimi Humidifier CB1A",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
