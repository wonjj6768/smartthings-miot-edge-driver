local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-leshow-heater-bs2-" .. os.time(),
        label = "Leshow BS2 Heater",
        profile = "leshow-heater-bs2",
        manufacturer = "leshow",
        model = "leshow.heater.bs2",
        vendor_provided_label = "Leshow BS2 Heater"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
