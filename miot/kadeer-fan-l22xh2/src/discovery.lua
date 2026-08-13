local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-fan-kadeer-l22xh2-" .. os.time(),
        label = "Kadeer Fan L22XH2",
        profile = "kadeer-fan-l22xh2",
        manufacturer = "Kadeer",
        model = "kadeer.fan.l22xh2",
        vendor_provided_label = "Kadeer Fan L22XH2"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
