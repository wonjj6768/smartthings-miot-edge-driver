local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-fan-dreame-p2018-" .. os.time(),
        label = "Dreame Fan P2018",
        profile = "dreame-fan-p2018",
        manufacturer = "Dreame",
        model = "dreame.fan.p2018",
        vendor_provided_label = "Dreame Fan P2018"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
