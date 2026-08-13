local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-nwt-dehumidifier-nwt10l-" .. os.time(),
        label = "NWT 10l Dehumidifier",
        profile = "nwt-dehumidifier-nwt10l",
        manufacturer = "nwt",
        model = "nwt.derh.nwt10l",
        vendor_provided_label = "NWT 10l Dehumidifier"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
