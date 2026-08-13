local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-deerma-humidifier-rz300-" .. os.time(),
        label = "Deerma Humidifier RZ300",
        profile = "deerma-humidifier-rz300",
        manufacturer = "Deerma",
        model = "deerma.humidifier.rz300",
        vendor_provided_label = "Deerma Humidifier RZ300",
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
