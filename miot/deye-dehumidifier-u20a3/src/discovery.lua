local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-deye-dehumidifier-u20a3-" .. os.time(),
        label = "Deye U20 Dehumidifier",
        profile = "deye-dehumidifier-u20a3",
        manufacturer = "deye",
        model = "deye.derh.u20a3",
        vendor_provided_label = "Deye U20 Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
