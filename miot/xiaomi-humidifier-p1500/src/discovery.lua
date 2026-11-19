local discovery = {}

function discovery.create_device(driver)
    return driver:try_create_device({
        type = "LAN",
        device_network_id = "miot-xiaomi-humidifier-p1500-" .. os.time(),
        label = "Mijia Mist-Free Humidifier 3 1500mL/h",
        profile = "xiaomi-humidifier-p1500",
        manufacturer = "Xiaomi",
        model = "xiaomi.humidifier.p1500",
        vendor_provided_label = "Mijia Mist-Free Humidifier 3 1500mL/h"
    })
end

function discovery.handle_discovery(driver)
    if #driver:get_devices() == 0 then discovery.create_device(driver) end
end

return discovery
