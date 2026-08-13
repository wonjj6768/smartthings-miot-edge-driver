local discovery = {}
function discovery.create_device(driver)
    return driver:try_create_device({type = "LAN", device_network_id = "miot-heater-zhimi-zb1a-" .. os.time(),
        label = "Smartmi Heater ZB1A", profile = "zhimi-heater-zb1a", manufacturer = "Zhimi",
        model = "zhimi.heater.zb1a", vendor_provided_label = "Smartmi Heater ZB1A"})
end
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end
return discovery
