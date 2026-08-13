local discovery = {}
function discovery.create_device(driver)
    return driver:try_create_device({type = "LAN", device_network_id = "miot-heater-zhimi-za3-" .. os.time(),
        label = "Smartmi Heater ZA3", profile = "zhimi-heater-za3", manufacturer = "Zhimi",
        model = "zhimi.heater.za3", vendor_provided_label = "Smartmi Heater ZA3"})
end
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end
return discovery
