local socket = require "socket"
local json = require "st.json"
local security = require "st.security"
local md5 = require "md5"

-- miIO 프로토콜 모듈
local miio = {}

-- 상수 정의

local PORT = 54321
local HEADER_SIZE = 32
local DEV_ID = "dev_id"
local TIME_OFFSET = "time_offset"
local HELLO_PACKET = "\x21\x31\x00\x20" .. string.rep("\xff", 28)
local AES_OPTIONS = { cipher = "aes128-cbc", padding = true }
local msg_id = 0

-- 내부 헬퍼 함수

-- 암호화 키/IV 생성 (한 번만 계산하여 재사용)
local function get_crypto_params(token)
    local token_bin = md5.hex_to_bin(token)
    local key = md5.sum(token_bin)
    local iv = md5.sum(key .. token_bin)
    return token_bin, key, iv
end

-- UDP 소켓 생성
local function create_udp()
    local udp = socket.udp()
    if not udp then error("UDP 소켓 생성 실패") end
    udp:setsockname("0.0.0.0", 0)
    udp:settimeout(5)
    return udp
end

-- 장치 캐시 초기화
local function clear_device_cache(device)
    device:set_field(DEV_ID, nil)
    device:set_field(TIME_OFFSET, nil)
end

-- Hello 메시지 전송 (장치 검색)
local function send_hello(ip)
    local udp = create_udp()
    
    udp:sendto(HELLO_PACKET, ip, PORT)
    
    local response = udp:receive()
    udp:close()
    
    if not response then error("장치 응답 없음") end
    
    -- 응답에서 device_id와 timestamp 추출 (Big Endian 32bit)
    local device_id = string.unpack(">I4", response:sub(9, 12))
    local device_time = string.unpack(">I4", response:sub(13, 16))
    local time_offset = os.time() - device_time
    
    return device_id, time_offset
end

-- miIO 메시지 생성 (crypto params 반환하여 재사용)
local function create_message(device, ip, token, method, params, force_hello)
    -- 장치 정보가 없거나 강제 갱신이면 Hello 전송
    if device:get_field(DEV_ID) == nil or force_hello then
        local ok, dev_id, time_off = pcall(send_hello, ip)
        if not ok then
            clear_device_cache(device)
            error("Hello 실패: " .. tostring(dev_id))
        end
        device:set_field(DEV_ID, dev_id)
        device:set_field(TIME_OFFSET, time_off)
    end
    
    -- 메시지 ID 증가
    msg_id = (msg_id % 9999) + 1
    
    -- JSON 페이로드 생성
    local payload = json.encode({
        id = msg_id,
        method = method,
        params = params or {}
    }) .. '\x00'
    
    -- 암호화 키 생성 (한 번만 계산)
    local token_bin, key, iv = get_crypto_params(token)
    
    -- 페이로드 암호화
    local opts = { cipher = AES_OPTIONS.cipher, iv = iv, padding = AES_OPTIONS.padding }
    local encrypted = security.encrypt_bytes(payload, key, opts)
    
    -- 헤더 생성 (magic + length(2bytes) + reserved(4bytes) + device_id + timestamp)
    local device_id = device:get_field(DEV_ID)
    local timestamp = os.time() - device:get_field(TIME_OFFSET)
    local length = HEADER_SIZE + #encrypted
    local header = string.pack(">c2 I2 I4 I4 I4", "\x21\x31", length, 0, device_id, timestamp) .. token_bin
    
    -- 체크섬 추가
    local checksum = md5.sum(header .. encrypted)
    header = header:sub(1, 16) .. checksum
    
    -- 메시지와 함께 key, iv 반환 (복호화에 재사용)
    return header .. encrypted, key, iv
end

-- 명령 전송 및 응답 수신
local function send_command(device, ip, token, method, params, retry)
    local udp = create_udp()
    
    -- 메시지 전송 (key, iv 함께 반환받아 재사용)
    local message, key, iv = create_message(device, ip, token, method, params, retry)
    udp:sendto(message, ip, PORT)
    
    -- 응답 수신
    local response = udp:receive()
    udp:close()
    
    if not response then error("장치 응답 없음") end
    
    -- 응답 복호화 (create_message에서 반환받은 key, iv 재사용)
    local encrypted_data = response:sub(HEADER_SIZE + 1)
    local opts = { cipher = AES_OPTIONS.cipher, iv = iv, padding = AES_OPTIONS.padding }
    local decrypted = security.decrypt_bytes(encrypted_data, key, opts)
    
    return json.decode(decrypted)
end

-- 재시도 로직 포함 명령 전송
local function send_with_retry(device, ip, token, method, params)
    -- 첫 번째 시도
    local ok, response = pcall(send_command, device, ip, token, method, params, false)
    if ok then return response end
    
    -- 실패시 캐시 클리어 후 재시도
    clear_device_cache(device)
    return send_command(device, ip, token, method, params, true)
end

-- 공개 API

-- 단일 속성 조회: miio.get_prop(device, ip, token, prop_name)
function miio.get_prop(device, ip, token, prop_name)
    local response = send_with_retry(device, ip, token, "get_prop", {prop_name})
    if response and response.result and response.result[1] ~= nil then
        return response.result[1]
    end
    return nil
end

-- 속성 설정: miio.set_prop(device, ip, token, method, params)
function miio.set_prop(device, ip, token, method, params)
    local response = send_with_retry(device, ip, token, method, params)
    return response and response.result and response.result[1] == "ok"
end

-- 커스텀 명령: miio.cmd(device, ip, token, method, params)
function miio.cmd(device, ip, token, method, params)
    return send_with_retry(device, ip, token, method, params)
end

return miio
