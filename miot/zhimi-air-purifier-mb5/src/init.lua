-- Zhimi Air Purifier MB5 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local discovery = require "discovery"
local miot = require "miot"

-- 커스텀 Capability 참조

local fanMode = capabilities["connectamber53538.zhimiairpurifierfanmode"]
local fanSpeed = capabilities["connectamber53538.zhimiairpurifierfanspeed"]

-- 상수 정의

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT 서비스 ID (zhimi-mb5 스펙 기준)
local AIR_PURIFIER_SIID = 2   -- 공기청정기
local ENVIRONMENT_SIID = 3    -- 환경 센서
local FILTER_SIID = 4         -- 필터

-- MIoT 속성 ID - Air Purifier (siid=2)
local POWER_PIID = 1          -- 전원 on/off
local MODE_PIID = 4           -- 모드 (Auto=0, Sleep=1, Favorite=2, Manual=3)
local FAN_LEVEL_PIID = 5      -- 팬 레벨 (1, 2, 3)

-- MIoT 속성 ID - Environment (siid=3)
local HUMIDITY_PIID = 1       -- 습도
local PM25_PIID = 4           -- PM2.5
local TEMPERATURE_PIID = 7    -- 온도

-- MIoT 속성 ID - Filter (siid=4)
local FILTER_LIFE_PIID = 1    -- 필터 수명 레벨 (%)

-- 모드 매핑: MIoT value -> SmartThings fanMode
-- Auto=0, Sleep=1, Favorite=2, Manual=3
local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite",
    [3] = "manual"
}

-- 역매핑: SmartThings mode -> MIoT value
local ST_TO_MODE = {
    ["auto"] = 0,
    ["sleep"] = 1,
    ["favorite"] = 2,
    ["manual"] = 3
}

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
        -- 공기청정기
        {siid = AIR_PURIFIER_SIID, piid = POWER_PIID},
        {siid = AIR_PURIFIER_SIID, piid = MODE_PIID},
        {siid = AIR_PURIFIER_SIID, piid = FAN_LEVEL_PIID},
        -- 환경 센서
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM25_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        -- 필터
        {siid = FILTER_SIID, piid = FILTER_LIFE_PIID}
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
            
            -- 공기청정기 데이터
            if siid == AIR_PURIFIER_SIID then
                if piid == POWER_PIID then
                    if value then
                        device:emit_event(capabilities.switch.switch.on())
                    else
                        device:emit_event(capabilities.switch.switch.off())
                    end
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value] or "auto"
                    device:emit_event(fanMode.fanMode(mode))
                elseif piid == FAN_LEVEL_PIID then
                    device:emit_event(fanSpeed.fanSpeed(value))
                end
            -- 환경 센서 데이터
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == PM25_PIID then
                    device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(value)))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                end
            -- 필터 데이터
            elseif siid == FILTER_SIID then
                if piid == FILTER_LIFE_PIID then    
                    device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
                end
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

-- 전원 켜기
local function handle_on(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        -- 폴링해서 현재 모드/팬레벨 가져오기
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

-- 전원 끄기
local function handle_off(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

-- 모드 설정 (커스텀 capability)
local function handle_set_fan_mode(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local mode = command.args.mode
    local mode_value = ST_TO_MODE[mode]
    
    if mode_value then
        -- 먼저 전원이 꺼져있으면 켜기
        pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)
        
        local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, mode_value)
        if ok then
            device:emit_event(capabilities.switch.switch.on())
            device:emit_event(fanMode.fanMode(mode))
        end
    end
end

-- 팬 속도 설정 (커스텀 capability, 1-3)
local function handle_set_fan_speed(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local speed = command.args.speed
    
    -- 유효한 팬 레벨 (1-3)
    local level = math.max(1, math.min(3, speed))
    
    -- 먼저 전원이 꺼져있으면 켜기
    pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, POWER_PIID, true)
    
    -- Manual 모드(3)로 변경 후 팬 레벨 설정
    pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, 3)
    
    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, FAN_LEVEL_PIID, level)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(fanSpeed.fanSpeed(level))
        device:emit_event(fanMode.fanMode("manual"))
    end
end

-- 새로고침
local function refresh_handler(_, device, _)
    pcall(poll_device_status, device)
end

-- 라이프사이클 핸들러

-- 장치 추가됨
local function device_added(_, device)
    -- 초기값 설정
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanMode.fanMode("auto"))
    device:emit_event(fanSpeed.fanSpeed(1))
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.fineDustSensor.fineDustLevel(0))
    device:emit_event(capabilities.filterState.filterState.normal())
    device:emit_event(capabilities.filterState.filterLifeRemaining({value = 100, unit = "%"}))
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

local driver = Driver("miot-air-purifier-mb5", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = handle_on,
            [capabilities.switch.commands.off.NAME] = handle_off
        },
        [fanMode.ID] = {
            [fanMode.commands.setFanMode.NAME] = handle_set_fan_mode
        },
        [fanSpeed.ID] = {
            [fanSpeed.commands.setFanSpeed.NAME] = handle_set_fan_speed
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
