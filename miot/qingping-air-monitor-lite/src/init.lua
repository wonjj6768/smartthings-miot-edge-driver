-- Qingping Air Monitor Lite Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local discovery = require "discovery"
local miot = require "miot"

-- 상수 정의

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT 서비스 ID
local ENVIRONMENT_SIID = 3  -- 환경 센서
local BATTERY_SIID = 4      -- 배터리

-- MIoT 속성 ID
local HUMIDITY_PIID = 1     -- 습도
local PM25_PIID = 4         -- PM2.5
local PM10_PIID = 5         -- PM10
local TEMPERATURE_PIID = 7  -- 온도
local CO2_PIID = 8          -- CO2
local BATTERY_PIID = 1      -- 배터리 레벨

-- 헬퍼 함수

-- 장치 설정 확인 (IP, 토큰)
local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token
    
    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

-- 폴링 함수

-- 장치 상태 조회
local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end
    
    -- 조회할 속성 목록
    local properties = {
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM10_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = CO2_PIID},
        {siid = BATTERY_SIID, piid = BATTERY_PIID}
    }
    
    -- MIoT로 속성 조회
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok then
        return
    end
    
    if not response or not response.result then
        return
    end
    
    -- 응답 처리
    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value
            
            -- 환경 센서 데이터
            if siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == PM25_PIID then
                    device:emit_event(capabilities.dustSensor.fineDustLevel(value))
                elseif piid == PM10_PIID then
                    device:emit_event(capabilities.dustSensor.dustLevel(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == CO2_PIID then
                    device:emit_event(capabilities.carbonDioxideMeasurement.carbonDioxide(value))
                end
            -- 배터리 데이터
            elseif siid == BATTERY_SIID and piid == BATTERY_PIID then
                device:emit_event(capabilities.battery.battery(value))
            end
        end
    end
end

-- 폴링 타이머 시작
local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function()
        pcall(poll_device_status, device)
    end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end

-- 폴링 타이머 중지
local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

-- 명령 핸들러

-- 새로고침
local function refresh_handler(_, device, _)
    pcall(poll_device_status, device)
end

-- 라이프사이클 핸들러

-- 장치 추가됨
local function device_added(_, device)
    -- 초기값 설정
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.dustSensor.fineDustLevel(0))
    device:emit_event(capabilities.dustSensor.dustLevel(0))
    device:emit_event(capabilities.carbonDioxideMeasurement.carbonDioxide(0))
    device:emit_event(capabilities.battery.battery(0))
end

-- 장치 초기화
local function device_init(_, device)
    device:online()
    
    local ip, token = get_device_config(device)
    if ip then
        start_polling_timer(device)
        pcall(poll_device_status, device)
    end
end

-- 장치 제거됨
local function device_removed(_, device)
    stop_polling_timer(device)
end

-- 설정 변경됨
local function device_info_changed(driver, device, _, args)
    if not args.old_st_store or not args.old_st_store.preferences then
        return
    end
    
    local old = args.old_st_store.preferences
    local new = device.preferences
    
    -- 새 장치 생성 요청
    if old.createDev == false and new.createDev == true then
        discovery.create_device(driver)
    end
    
    -- 설정이 변경되면 폴링 재시작
    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)
        
        local ip, token = get_device_config(device)
        if ip then
            start_polling_timer(device)
            pcall(poll_device_status, device)
        end
    end
end

-- 드라이버 실행

local driver = Driver("miot-air-monitor", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()