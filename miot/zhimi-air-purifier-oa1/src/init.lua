-- Zhimi Air Purifier OA1 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanLevelCap = capabilities["concertmirror08464.zhimiAirOa1FanLevel"]
local buzzerCap = capabilities["concertmirror08464.zhimiAirOa1Buzzer"]
local childLockCap = capabilities["concertmirror08464.zhimiAirOa1ChildLock"]
local displayLevelCap = capabilities["concertmirror08464.zhimiAirOa1DisplayLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "zhimi-air-purifier-oa1"

-- MIoT model: zhimi.airpurifier.oa1
-- specModel: zhimi-oa1
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:zhimi-oa1:1
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=No Faults, 1=Motor-stuck: not exposed
--   piid=5 fan-level, uint8, RW; 1=Level1, 2=Level2, 3=Level3, 4=Level4 -> zhimiAirOa1FanLevel.fanLevel
--   piid=6 brightness, bool, RW -> zhimiAirOa1DisplayLevel.displayLevel
--   piid=7 alarm, bool, RW -> zhimiAirOa1Buzzer.buzzer
--   piid=9 physical-controls-locked, bool, RW -> zhimiAirOa1ChildLock.childLock
--   piid=10 working-time, uint32, R; range 0..2147483647 step 1 seconds: not exposed
-- Filter service (siid=4)
--   piid=1 filter-used-time, uint32, R; range 0..6480000 step 1 seconds: not exposed
--   piid=2 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
-- other service (siid=5)
--   piid=2 filter-used-debug, uint32, W; range 0..6480000 step 1 hours: not exposed
--   piid=7 speed-actual, uint16, R; range 0..5000 step 1: not exposed
--   piid=8 speed-set, uint16, R; range 300..5000 step 1: not exposed
--   piid=9 door, string, R: not exposed
--   piid=10 ring-mac, string, RW: not exposed
--   piid=11 ring-rssi, uint16, R; range 0..200 step 1: not exposed
--   piid=12 reboot-cause, uint16, R; 0=REASON_HW_BOOT, 1=REASON_USER_REBOOT, 2=REASON_UPDATE, 3=REASON_WDT: not exposed

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local FAN_LEVEL_PIID = 5
local BRIGHTNESS_PIID = 6
local ALARM_PIID = 7
local PHYSICAL_CONTROLS_LOCKED_PIID = 9

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 2

-- MIoT -> SmartThings
local FAN_LEVEL_TO_ST = {
    [1] = "level1",
    [2] = "level2",
    [3] = "level3",
    [4] = "level4"
}

-- SmartThings -> MIoT
local ST_TO_FAN_LEVEL = {
    ["level1"] = 1,
    ["level2"] = 2,
    ["level3"] = 3,
    ["level4"] = 4
}

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    if not device:supports_capability_by_id("concertmirror08464.zhimiAirOa1FanLevel", "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function bool_to_st(value)
    return value and "on" or "off"
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then
        return
    end

    local properties = {
        {siid = AIR_PURIFIER_SIID, piid = ON_PIID},
        {siid = AIR_PURIFIER_SIID, piid = FAN_LEVEL_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = AIR_PURIFIER_SIID, piid = ALARM_PIID},
        {siid = AIR_PURIFIER_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = AIR_PURIFIER_SIID, piid = BRIGHTNESS_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then
        return
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == AIR_PURIFIER_SIID then
                if piid == ON_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == FAN_LEVEL_PIID then
                    local mapped = FAN_LEVEL_TO_ST[value]
                    if mapped then
                        device:emit_event(fanLevelCap.fanLevel({value = mapped}))
                    end
                elseif piid == ALARM_PIID then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                elseif piid == PHYSICAL_CONTROLS_LOCKED_PIID then
                    device:emit_event(childLockCap.childLock({value = bool_to_st(value)}))
                elseif piid == BRIGHTNESS_PIID then
                    device:emit_event(displayLevelCap.displayLevel({value = bool_to_st(value)}))
                end
            elseif siid == FILTER_SIID then
                if piid == FILTER_LIFE_LEVEL_PIID then
                    device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
                end
            end
        end
    end
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function()
        pcall(poll_device_status, device)
    end, "Polling")
    device:set_field(POLLING_TIMER, timer)
end

local function stop_polling_timer(device)
    local timer = device:get_field(POLLING_TIMER)
    if timer then
        device.thread:cancel_timer(timer)
        device:set_field(POLLING_TIMER, nil)
    end
end

local function switch_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, ON_PIID, true)
    if ok then
        device:emit_event(capabilities.switch.switch.on())
        device.thread:call_with_delay(1, function()
            pcall(poll_device_status, device)
        end)
    end
end

local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, ON_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_fanLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.fanLevel
    local value = ST_TO_FAN_LEVEL[requested]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, AIR_PURIFIER_SIID, FAN_LEVEL_PIID, value)
    if ok then
        device:emit_event(fanLevelCap.fanLevel({value = requested}))
    end
end

local function make_bool_handler(siid, piid, capability, attribute, argument)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local requested = command.args[argument]
        local ok = pcall(miot.set, device, ip, token, siid, piid, requested == "on")
        if ok then
            device:emit_event(capability[attribute]({value = requested}))
        end
    end
end

local set_buzzer_handler = make_bool_handler(AIR_PURIFIER_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_childLock_handler = make_bool_handler(AIR_PURIFIER_SIID, PHYSICAL_CONTROLS_LOCKED_PIID, childLockCap, "childLock", "childLock")
local set_displayLevel_handler = make_bool_handler(AIR_PURIFIER_SIID, BRIGHTNESS_PIID, displayLevelCap, "displayLevel", "displayLevel")

local function refresh_handler(_, device, _)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanLevelCap.fanLevel({value = "level1"}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "off"}))
    pcall(poll_device_status, device)
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {}}))

    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        pcall(poll_device_status, device)
    end
end

local function device_removed(_, device)
    stop_polling_timer(device)
end

local function device_info_changed(driver, device, _, args)
    if not args.old_st_store or not args.old_st_store.preferences then
        return
    end

    local old = args.old_st_store.preferences
    local new = device.preferences

    if old.createDev == false and new.createDev == true then
        discovery.create_device(driver)
    end

    if old.ipAddress ~= new.ipAddress or old.token ~= new.token or old.pollingInterval ~= new.pollingInterval then
        stop_polling_timer(device)

        local ip = get_device_config(device)
        if ip then
            start_polling_timer(device)
            pcall(poll_device_status, device)
        end
    end
end

local driver = Driver("miot-zhimi-air-purifier-oa1", {
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
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fanLevel_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_childLock_handler
        },
        [displayLevelCap.ID] = {
            [displayLevelCap.commands.setDisplayLevel.NAME] = set_displayLevel_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
