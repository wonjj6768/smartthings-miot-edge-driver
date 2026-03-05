-- Xiaomi Humidifier P800 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local discovery = require "discovery"
local miot = require "miot"

-- 커스텀 Capability 참조

local cap_fanmode = capabilities["connectamber53538.xiaomip800mode"]
local cap_targethumidity = capabilities["connectamber53538.xiaomip800targethumidity"]

-- 상수 정의

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT 서비스 ID (P800 스펙 기준)
local HUMIDIFIER_SIID = 2       -- 가습기
local ENVIRONMENT_SIID = 3      -- 환경 센서

-- MIoT 속성 ID (가습기 서비스 siid=2)
local POWER_PIID = 1            -- 전원 on/off
local MODE_PIID = 3             -- 모드 (0=Constant, 1=Sleep, 2=Strong)
local TARGET_HUMIDITY_PIID = 6  -- 목표 습도 (40-70%)

-- MIoT 속성 ID (환경 센서 siid=3)
local HUMIDITY_PIID = 1         -- 상대 습도
local TEMPERATURE_PIID = 7      -- 온도

-- 변환 테이블

-- 모드 변환 (MIoT -> Capability)
local MODE_TO_ST = {
    [0] = "constant",
    [1] = "sleep",
    [2] = "strong"
}

-- 모드 변환 (Capability -> MIoT)
local ST_TO_MODE = {
    constant = 0,
    sleep = 1,
    strong = 2
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
        {siid = HUMIDIFIER_SIID, piid = POWER_PIID},
        {siid = HUMIDIFIER_SIID, piid = MODE_PIID},
        {siid = HUMIDIFIER_SIID, piid = TARGET_HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID}
    }
    
    -- MIoT로 속성 조회
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok then
        log.error("폴링 실패: " .. tostring(response))
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
            
            -- 가습기 데이터
            if siid == HUMIDIFIER_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value] or "constant"
                    device:emit_event(cap_fanmode.fanMode({value = mode}))
                elseif piid == TARGET_HUMIDITY_PIID then
                    device:emit_event(cap_targethumidity.targetHumidity({value = value, unit = "%"}))
                end
            -- 환경 센서 데이터
            elseif siid == ENVIRONMENT_SIID then
                if piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
                elseif piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
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
local function switch_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        -- 상태 갱신
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

-- 전원 끄기
local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

-- 모드 설정
local function set_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local mode = command.args.mode
    local mode_value = ST_TO_MODE[mode]
    if mode_value == nil then return end
    
    -- 전원이 꺼져있으면 먼저 켜기
    pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, MODE_PIID, mode_value)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(cap_fanmode.fanMode({value = mode}))
    end
end

-- 모드 단축 명령
local function set_constant_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, MODE_PIID, 0)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(cap_fanmode.fanMode({value = "constant"}))
    end
end

local function set_sleep_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, MODE_PIID, 1)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(cap_fanmode.fanMode({value = "sleep"}))
    end
end

local function set_strong_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, POWER_PIID, true)
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, MODE_PIID, 2)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device:emit_event(cap_fanmode.fanMode({value = "strong"}))
    end
end

-- 목표 습도 설정
local function set_target_humidity_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local humidity = command.args.humidity
    -- P800 스펙에서 40-70% 범위 제한
    humidity = math.max(40, math.min(70, humidity))
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, TARGET_HUMIDITY_PIID, humidity)
    if ok then
        device:emit_event(cap_targethumidity.targetHumidity({value = humidity, unit = "%"}))
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
    device:emit_event(capabilities.temperatureMeasurement.temperature({value = 0, unit = "C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(cap_fanmode.fanMode({value = "constant"}))
    device:emit_event(cap_targethumidity.targetHumidity({value = 50, unit = "%"}))
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

local driver = Driver("miot-humidifier-p800", {
    discovery = discovery.handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed,
        infoChanged = device_info_changed
    },
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = switch_on_handler,
            [capabilities.switch.commands.off.NAME] = switch_off_handler
        },
        [cap_fanmode.ID] = {
            [cap_fanmode.commands.setFanMode.NAME] = set_mode_handler,
            [cap_fanmode.commands.setConstant.NAME] = set_constant_handler,
            [cap_fanmode.commands.setSleep.NAME] = set_sleep_handler,
            [cap_fanmode.commands.setStrong.NAME] = set_strong_handler
        },
        [cap_targethumidity.ID] = {
            [cap_targethumidity.commands.setTargetHumidity.NAME] = set_target_humidity_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
