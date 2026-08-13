local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-heater-ma8-" .. os.time(),
        label = "Xiaomi Heater MA8",
        profile = "xiaomi-heater-ma8",
        manufacturer = "Xiaomi",
        model = "xiaomi.heater.ma8",
        vendor_provided_label = "Xiaomi Heater MA8",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
