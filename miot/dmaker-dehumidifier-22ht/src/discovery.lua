local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-dmaker-dehumidifier-22ht-" .. os.time(),
        label = "Dmaker 22ht Dehumidifier",
        profile = "dmaker-dehumidifier-22ht",
        manufacturer = "dmaker",
        model = "dmaker.derh.22ht",
        vendor_provided_label = "Dmaker 22ht Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
