local log = require "log"

local discovery = {}

-- 장치 생성
function discovery.create_device(driver)
    local success, err = pcall(function()
        driver:try_create_device({
            type = "LAN",
            device_network_id = "philips-sread1-" .. os.time(),
            label = "Philips Smart Desk Lamp",
            profile = "philips-sread1",
            manufacturer = "Philips",
            model = "philips.light.sread1",
            vendor_provided_label = "Philips Smart Desk Lamp",
        })
    end)
    
    if not success then
        log.error("장치 생성 실패: " .. tostring(err))
    end
    
    return success
end

-- 장치 검색 핸들러
function discovery.handle_discovery(driver, opts, cont)
    if #driver:get_devices() == 0 then
        discovery.create_device(driver)
    end
end

return discovery
