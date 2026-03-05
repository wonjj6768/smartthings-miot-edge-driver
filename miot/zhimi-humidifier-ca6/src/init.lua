-- Zhimi Humidifier CA6 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local discovery = require "discovery"
local miot = require "miot"

-- 커스텀 Capability 참조

local cap_fanmode = capabilities["connectamber53538.zhimica6fanmode"]
local cap_waterlevel = capabilities["connectamber53538.zhimica6waterlevel"]
local cap_targethumidity = capabilities["connectamber53538.zhimica6targethumidity"]
local cap_drymode = capabilities["connectamber53538.zhimihumidifierdrymode"]

-- 상수 정의

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

-- MIoT 서비스 ID (스펙 기준)
local HUMIDIFIER_SIID = 2       -- 가습기
local ENVIRONMENT_SIID = 3      -- 환경 센서

-- MIoT 속성 ID (가습기 서비스)
local POWER_PIID = 1            -- 전원 on/off
local FAN_LEVEL_PIID = 5        -- 팬 레벨 (0=Fav, 1=Auto, 2=Sleep)
local TARGET_HUMIDITY_PIID = 6  -- 목표 습도
local WATER_LEVEL_PIID = 7      -- 수위
local AUTO_DRY_PIID = 8         -- 자동 건조

-- MIoT 속성 ID (환경 센서)
local TEMPERATURE_PIID = 7      -- 온도
local HUMIDITY_PIID = 9         -- 상대 습도

-- 변환 테이블

-- 팬 레벨 변환 (MIoT -> Capability)
local FAN_LEVEL_TO_MODE = {
    [0] = "fav",
    [1] = "auto",
    [2] = "sleep"
}

-- 팬 모드 변환 (Capability -> MIoT)
local FAN_MODE_TO_LEVEL = {
    fav = 0,
    auto = 1,
    sleep = 2
}

-- 수위 변환 (MIoT -> Capability)
local WATER_LEVEL_TO_STATUS = {
    [0] = "empty",
    [1] = "low",
    [2] = "full"
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
        {siid = HUMIDIFIER_SIID, piid = FAN_LEVEL_PIID},
        {siid = HUMIDIFIER_SIID, piid = TARGET_HUMIDITY_PIID},
        {siid = HUMIDIFIER_SIID, piid = WATER_LEVEL_PIID},
        {siid = HUMIDIFIER_SIID, piid = AUTO_DRY_PIID},
        {siid = ENVIRONMENT_SIID, piid = TEMPERATURE_PIID},
        {siid = ENVIRONMENT_SIID, piid = HUMIDITY_PIID}
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
                elseif piid == FAN_LEVEL_PIID then
                    local mode = FAN_LEVEL_TO_MODE[value] or "auto"
                    device:emit_event(cap_fanmode.fanMode({value = mode}))
                elseif piid == TARGET_HUMIDITY_PIID then
                    device:emit_event(cap_targethumidity.targetHumidity({value = value, unit = "%"}))
                elseif piid == WATER_LEVEL_PIID then
                    local status = WATER_LEVEL_TO_STATUS[value] or "empty"
                    device:emit_event(cap_waterlevel.waterLevel({value = status}))
                elseif piid == AUTO_DRY_PIID then
                    device:emit_event(cap_drymode.dryMode({value = value and "on" or "off"}))
                end
            -- 환경 센서 데이터
            elseif siid == ENVIRONMENT_SIID then
                if piid == TEMPERATURE_PIID then
                    device:emit_event(capabilities.temperatureMeasurement.temperature({value = value, unit = "C"}))
                elseif piid == HUMIDITY_PIID then
                    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
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

-- 팬 모드 설정
local function set_fan_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local mode = command.args.mode
    local level = FAN_MODE_TO_LEVEL[mode]
    if level == nil then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, FAN_LEVEL_PIID, level)
    if ok then
        device:emit_event(cap_fanmode.fanMode({value = mode}))
    end
end

-- 팬 모드 단축 명령 (setFav, setAuto, setSleep)
local function set_fav_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, FAN_LEVEL_PIID, 0)
    if ok then
        device:emit_event(cap_fanmode.fanMode({value = "fav"}))
    end
end

local function set_auto_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, FAN_LEVEL_PIID, 1)
    if ok then
        device:emit_event(cap_fanmode.fanMode({value = "auto"}))
    end
end

local function set_sleep_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, FAN_LEVEL_PIID, 2)
    if ok then
        device:emit_event(cap_fanmode.fanMode({value = "sleep"}))
    end
end

-- 목표 습도 설정
local function set_target_humidity_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local humidity = command.args.humidity
    -- 스펙에서 30-60% 범위 제한
    humidity = math.max(30, math.min(60, humidity))
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, TARGET_HUMIDITY_PIID, humidity)
    if ok then
        device:emit_event(cap_targethumidity.targetHumidity({value = humidity, unit = "%"}))
    end
end

-- 건조 모드 설정
local function set_dry_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local mode = command.args.mode
    local value = (mode == "on")
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, AUTO_DRY_PIID, value)
    if ok then
        device:emit_event(cap_drymode.dryMode({value = mode}))
    end
end

local function dry_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, AUTO_DRY_PIID, true)
    if ok then
        device:emit_event(cap_drymode.dryMode({value = "on"}))
    end
end

local function dry_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end
    
    local ok, _ = pcall(miot.set, device, ip, token, HUMIDIFIER_SIID, AUTO_DRY_PIID, false)
    if ok then
        device:emit_event(cap_drymode.dryMode({value = "off"}))
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
    device:emit_event(cap_fanmode.fanMode({value = "auto"}))
    device:emit_event(cap_targethumidity.targetHumidity({value = 40, unit = "%"}))
    device:emit_event(cap_waterlevel.waterLevel({value = "full"}))
    device:emit_event(cap_drymode.dryMode({value = "off"}))
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

local driver = Driver("miot-humidifier-ca6", {
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
            [cap_fanmode.commands.setFanMode.NAME] = set_fan_mode_handler,
            [cap_fanmode.commands.setFav.NAME] = set_fav_handler,
            [cap_fanmode.commands.setAuto.NAME] = set_auto_handler,
            [cap_fanmode.commands.setSleep.NAME] = set_sleep_handler
        },
        [cap_targethumidity.ID] = {
            [cap_targethumidity.commands.setTargetHumidity.NAME] = set_target_humidity_handler
        },
        [cap_drymode.ID] = {
            [cap_drymode.commands.setDryMode.NAME] = set_dry_mode_handler,
            [cap_drymode.commands.on.NAME] = dry_on_handler,
            [cap_drymode.commands.off.NAME] = dry_off_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
