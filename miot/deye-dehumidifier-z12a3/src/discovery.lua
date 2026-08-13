local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-deye-dehumidifier-z12a3-" .. os.time(),
        label = "Deye Z12 Dehumidifier",
        profile = "deye-dehumidifier-z12a3",
        manufacturer = "deye",
        model = "deye.derh.z12a3",
        vendor_provided_label = "Deye Z12 Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
