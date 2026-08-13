local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-heater-ma4-" .. os.time(),
        label = "Xiaomi Heater MA4",
        profile = "xiaomi-heater-ma4",
        manufacturer = "Xiaomi",
        model = "xiaomi.heater.ma4",
        vendor_provided_label = "Xiaomi Heater MA4",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
