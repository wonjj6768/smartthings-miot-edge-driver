local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miio-fan-air-ca23ad9-" .. os.time(),
        label = "Airmate Fan CA23AD9",
        profile = "air-fan-ca23ad9",
        manufacturer = "Air",
        model = "air.fan.ca23ad9",
        vendor_provided_label = "Airmate Fan CA23AD9"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
