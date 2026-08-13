local discovery = {}
function discovery.create_device(driver)
    return driver:try_create_device({type = "LAN", device_network_id = "miot-heater-zhimi-ma5-" .. os.time(),
        label = "Smartmi Heater MA5", profile = "zhimi-heater-ma5", manufacturer = "Zhimi",
        model = "zhimi.heater.ma5", vendor_provided_label = "Smartmi Heater MA5"})
end
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end
return discovery
