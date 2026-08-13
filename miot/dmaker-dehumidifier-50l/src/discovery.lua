local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-dmaker-dehumidifier-50l-" .. os.time(),
        label = "Dmaker 50l Dehumidifier",
        profile = "dmaker-dehumidifier-50l",
        manufacturer = "dmaker",
        model = "dmaker.derh.50l",
        vendor_provided_label = "Dmaker 50l Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
