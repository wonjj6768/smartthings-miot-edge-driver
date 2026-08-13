local socket = require "socket"
local json = require "st.json"
local security = require "st.security"
local md5 = require "md5"

-- MIoT 프로토콜 모듈
local miot = {}

local PORT = 54321
local HEADER_SIZE = 32
local MAX_PROPERTIES_PER_REQUEST = 15
local DEV_ID = "dev_id"
local TIME_OFFSET = "time_offset"
local MESSAGE_ID = "message_id"
local HELLO_PACKET = "\x21\x31\x00\x20" .. string.rep("\xff", 28)
local AES_OPTIONS = { cipher = "aes128-cbc", padding = true }

-- 암호화 키/IV 생성
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

local function next_message_id(device)
    local message_id = ((device:get_field(MESSAGE_ID) or 0) % 9999) + 1
    device:set_field(MESSAGE_ID, message_id)
    return message_id
end

local function assert_success(response)
    local result = response and response.result and response.result[1]
    if not result or result.code ~= 0 then
        local code = result and result.code or "nil"
        error("MIoT 명령 실패: " .. tostring(code))
    end
    return response
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

-- MIoT 메시지 생성 (crypto params 반환하여 재사용)
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

    -- JSON 페이로드 생성
    local payload = json.encode({
        id = next_message_id(device),
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

-- 단일 속성 조회: miot.get(device, ip, token, siid, piid)
function miot.get(device, ip, token, siid, piid)
    return send_with_retry(device, ip, token, "get_properties", {
        {
            did = string.format("prop.%d.%d", siid, piid),
            siid = siid,
            piid = piid
        }
    })
end

-- 단일 속성 설정: miot.set(device, ip, token, siid, piid, value)
function miot.set(device, ip, token, siid, piid, value)
    local response = send_with_retry(device, ip, token, "set_properties", {
        {
            did = string.format("set.%d.%d", siid, piid),
            siid = siid,
            piid = piid,
            value = value
        }
    })
    return assert_success(response)
end

-- 다중 속성 조회: miot.gets(device, ip, token, properties)
function miot.gets(device, ip, token, properties)
    local combined_response = nil
    local combined_result = {}

    for first = 1, #properties, MAX_PROPERTIES_PER_REQUEST do
        local batch = {}
        local last = math.min(first + MAX_PROPERTIES_PER_REQUEST - 1, #properties)
        for index = first, last do
            local property = properties[index]
            table.insert(batch, {
                did = property.did or string.format("prop.%d.%d", property.siid, property.piid),
                siid = property.siid,
                piid = property.piid
            })
        end

        local response = send_with_retry(device, ip, token, "get_properties", batch)
        if not response or not response.result then
            return response
        end

        combined_response = combined_response or response
        for _, result in ipairs(response.result) do
            table.insert(combined_result, result)
        end
    end

    combined_response = combined_response or { result = {} }
    combined_response.result = combined_result
    return combined_response
end

-- 액션 호출: miot.action(device, ip, token, siid, aiid, params)
function miot.action(device, ip, token, siid, aiid, params)
    local response = send_with_retry(device, ip, token, "action", {
        did = string.format("call.%d.%d", siid, aiid),
        siid = siid,
        aiid = aiid,
        ["in"] = params or {}
    })
    return assert_success(response)
end

-- 커스텀 명령: miot.cmd(device, ip, token, method, params)
function miot.cmd(device, ip, token, method, params)
    return send_with_retry(device, ip, token, method, params)
end

return miot
