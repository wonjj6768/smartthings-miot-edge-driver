local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-airpurifier-xiaomi-cpa5-" .. os.time(),
        label = "Xiaomi Smart Pet Care Air Purifier",
        profile = "xiaomi-air-purifier-cpa5",
        manufacturer = "Xiaomi",
        model = "xiaomi.airp.cpa5",
        vendor_provided_label = "Xiaomi Smart Pet Care Air Purifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
