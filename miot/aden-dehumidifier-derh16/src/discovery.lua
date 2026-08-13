local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-aden-dehumidifier-derh16-" .. os.time(),
        label = "Aden D16 Dehumidifier",
        profile = "aden-dehumidifier-derh16",
        manufacturer = "aden",
        model = "aden.derh.derh16",
        vendor_provided_label = "Aden D16 Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
