local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-nwt-dehumidifier-330ef-" .. os.time(),
        label = "NWT 330ef Dehumidifier",
        profile = "nwt-dehumidifier-330ef",
        manufacturer = "nwt",
        model = "nwt.derh.330ef",
        vendor_provided_label = "NWT 330ef Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
