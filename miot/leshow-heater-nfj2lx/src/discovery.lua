local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-leshow-heater-nfj2lx-" .. os.time(),
        label = "Leshow NFJ2 Heater",
        profile = "leshow-heater-nfj2lx",
        manufacturer = "leshow",
        model = "leshow.heater.nfj2lx",
        vendor_provided_label = "Leshow NFJ2 Heater"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
