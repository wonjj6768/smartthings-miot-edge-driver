-- Philips Light Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local socket = require "socket"
local log = require "log"
local discovery = require "discovery"
local miio = require "miio"

-- 상수 정의

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60

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
    
    -- 전원 상태
    local power = miio.get_prop(device, ip, token, "power")
    if power then
        device:emit_event(power == "on" and capabilities.switch.switch.on() or capabilities.switch.switch.off())
    end
    socket.sleep(0.5)

    -- 밝기
    local bright = miio.get_prop(device, ip, token, "bright")
    if bright and type(bright) == "number" then
        device:emit_event(capabilities.switchLevel.level(bright))
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
    if ip and miio.set_prop(device, ip, token, "set_power", {"on"}) then
        device:emit_event(capabilities.switch.switch.on())
    end
end

-- 전원 끄기
local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if ip and miio.set_prop(device, ip, token, "set_power", {"off"}) then
        device:emit_event(capabilities.switch.switch.off())
    end
end

-- 밝기 설정
local function set_level_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local level = math.max(1, math.min(100, command.args.level))
    if miio.set_prop(device, ip, token, "set_bright", {level}) then
        device:emit_event(capabilities.switchLevel.level(level))
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
    device:emit_event(capabilities.switchLevel.level(0))
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

local driver = Driver("philips-sread1", {
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
        [capabilities.switchLevel.ID] = {
            [capabilities.switchLevel.commands.setLevel.NAME] = set_level_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
