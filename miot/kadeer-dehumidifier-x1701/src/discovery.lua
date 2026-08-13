local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-kadeer-dehumidifier-x1701-" .. os.time(),
        label = "Kadeer X1701 Dehumidifier",
        profile = "kadeer-dehumidifier-x1701",
        manufacturer = "kadeer",
        model = "kadeer.derh.x1701",
        vendor_provided_label = "Kadeer X1701 Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
