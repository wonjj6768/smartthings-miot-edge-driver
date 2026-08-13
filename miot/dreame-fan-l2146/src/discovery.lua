local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-fan-dreame-l2146-" .. os.time(),
        label = "Dreame Fan L2146",
        profile = "dreame-fan-l2146",
        manufacturer = "Dreame",
        model = "dreame.fan.l2146",
        vendor_provided_label = "Dreame Fan L2146"
    })
end

function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
