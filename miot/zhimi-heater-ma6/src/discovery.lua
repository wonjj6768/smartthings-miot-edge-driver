local discovery = {}
function discovery.create_device(driver)
    return driver:try_create_device({type = "LAN", device_network_id = "miot-heater-zhimi-ma6-" .. os.time(),
        label = "Smartmi Heater MA6", profile = "zhimi-heater-ma6", manufacturer = "Zhimi",
        model = "zhimi.heater.ma6", vendor_provided_label = "Smartmi Heater MA6"})
end
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end
return discovery
