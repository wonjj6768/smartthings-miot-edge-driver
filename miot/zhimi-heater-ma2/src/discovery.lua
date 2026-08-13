local discovery = {}
function discovery.create_device(driver)
    return driver:try_create_device({type = "LAN", device_network_id = "miot-heater-zhimi-ma2-" .. os.time(),
        label = "Smartmi Heater MA2", profile = "zhimi-heater-ma2", manufacturer = "Zhimi",
        model = "zhimi.heater.ma2", vendor_provided_label = "Smartmi Heater MA2"})
end
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end
return discovery
