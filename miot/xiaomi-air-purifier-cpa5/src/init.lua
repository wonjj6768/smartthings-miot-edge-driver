-- Xiaomi Air Purifier CPA5 Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local airPurifierModeCap = capabilities["concertmirror08464.xiaomiAirCpa5Mode"]
local buzzerCap = capabilities["concertmirror08464.xiaomiAirCpa5Buzzer"]
local petLockCap = capabilities["concertmirror08464.xiaomiAirCpa5PetLock"]
local displayLevelCap = capabilities["concertmirror08464.xiaomiAirCpa5DisplayLevel"]
local fanLevelCap = capabilities["concertmirror08464.xiaomiAirCpa5FanLevel"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "xiaomi-air-purifier-cpa5"
local EXPECTED_CAPABILITY_IDS = {
    "concertmirror08464.xiaomiAirCpa5Mode",
    "concertmirror08464.xiaomiAirCpa5Buzzer",
    "concertmirror08464.xiaomiAirCpa5PetLock",
    "concertmirror08464.xiaomiAirCpa5DisplayLevel",
    "concertmirror08464.xiaomiAirCpa5FanLevel"
}

-- MIoT model: xiaomi.airp.cpa5
-- specModel: xiaomi-cpa5
-- URN: urn:miot-spec-v2:device:air-purifier:0000A007:xiaomi-cpa5:1:0000D050
--
-- Air Purifier service (siid=2)
--   piid=1 on, bool, RW -> switch
--   piid=2 fault, uint8, R; 0=No Faults, 2=Motor Stuck, 3=PM Error: not exposed
--   piid=3 mode, uint8, RW; 0=Auto, 1=Sleep, 2=Favorite/Manual -> xiaomiAirCpa5Mode.airPurifierMode
-- Environment service (siid=3)
--   piid=4 pm2.5-density, uint16, R; range 0..600 step 1 μg/m3 -> fineDustSensor.fineDustLevel
-- Filter service (siid=4)
--   piid=1 filter-life-level, uint8, R; range 0..100 step 1 percentage -> filterState.filterLifeRemaining
--   aiid=1 reset-filter-life, Action -> filterState.resetFilter
--   piid=3 filter-used-time, uint16, R; range 0..65535 step 1 hours: not exposed
--   piid=4 filter-left-time, uint16, R; range 0..1000 step 1 days: not exposed
-- Screen service (siid=6)
--   piid=2 brightness, uint8, RW; 0=Close, 1=Bright, 2=Dim -> xiaomiAirCpa5DisplayLevel.displayLevel
-- Alarm service (siid=7)
--   piid=1 alarm, bool, RW -> xiaomiAirCpa5Buzzer.buzzer
-- Physical Control Locked service (siid=8)
--   piid=1 physical-controls-locked, bool, RW -> xiaomiAirCpa5PetLock.petLock
-- Air Purifier Favorite service (siid=9)
--   piid=1 fan-level, uint8, RW; values 0..14 -> xiaomiAirCpa5FanLevel.fanLevel
-- Custom Service (siid=10)
--   piid=1 motor-speed-rpm, uint16, R; range 0..2500 step 1: not exposed
--   piid=2 country-code, uint16, RW: not exposed
--   piid=4 filter-used-time-dbg, uint16, W; range 0..7000 step 1 hours: not exposed
--   aiid=1 toggle-mode, Action: not exposed
-- aqi service (siid=11)
--   piid=1 aqi-updata-heartbeat, uint16, RW; range 0..65535 step 1: not exposed

local AIR_PURIFIER_SIID = 2
local ON_PIID = 1
local MODE_PIID = 3

local ENVIRONMENT_SIID = 3
local PM2_5_DENSITY_PIID = 4

local FILTER_SIID = 4
local FILTER_LIFE_LEVEL_PIID = 1
local RESET_FILTER_LIFE_AIID = 1

local SCREEN_SIID = 6
local BRIGHTNESS_PIID = 2

local ALARM_SIID = 7
local ALARM_PIID = 1

local PHYSICAL_CONTROLS_LOCKED_SIID = 8
local PHYSICAL_CONTROLS_LOCKED_PIID = 1

local AIR_PURIFIER_FAVORITE_SIID = 9
local FAN_LEVEL_PIID = 1

-- MIoT -> SmartThings
local MODE_TO_ST = {
    [0] = "auto",
    [1] = "sleep",
    [2] = "favorite"
}

-- SmartThings -> MIoT
local ST_TO_MODE = {
    ["auto"] = 0,
    ["favorite"] = 2,
    ["sleep"] = 1
}

-- MIoT -> SmartThings
local BRIGHTNESS_TO_ST = {
    [0] = "off",
    [1] = "bright",
    [2] = "dim"
}

-- SmartThings -> MIoT
local ST_TO_BRIGHTNESS = {
    ["bright"] = 1,
    ["dim"] = 2,
    ["off"] = 0
}

local FAN_LEVEL_MIN = 0
local FAN_LEVEL_MAX = 14

local function get_device_config(device)
    local ip = device.preferences.ipAddress
    local token = device.preferences.token

    if ip and ip ~= "" and token and #token == 32 then
        return ip, token
    end
    return nil, nil
end

local function ensure_profile(device)
    for _, capability_id in ipairs(EXPECTED_CAPABILITY_IDS) do
        if not device:supports_capability_by_id(capability_id, "main") then
            device:try_update_metadata({profile = PROFILE_NAME})
            return true
        end
    end
    return false
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
        {siid = AIR_PURIFIER_SIID, piid = MODE_PIID},
        {siid = ENVIRONMENT_SIID, piid = PM2_5_DENSITY_PIID},
        {siid = FILTER_SIID, piid = FILTER_LIFE_LEVEL_PIID},
        {siid = SCREEN_SIID, piid = BRIGHTNESS_PIID},
        {siid = ALARM_SIID, piid = ALARM_PIID},
        {siid = PHYSICAL_CONTROLS_LOCKED_SIID, piid = PHYSICAL_CONTROLS_LOCKED_PIID},
        {siid = AIR_PURIFIER_FAVORITE_SIID, piid = FAN_LEVEL_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok then
        device.log.error("CPA5 get_properties failed: " .. tostring(response))
        return false
    end
    if not response or type(response.result) ~= "table" then
        device.log.error("CPA5 get_properties returned no result")
        return false
    end

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == AIR_PURIFIER_SIID then
                if piid == ON_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == MODE_PIID then
                    local mapped = MODE_TO_ST[value]
                    if mapped then
                        device:emit_event(airPurifierModeCap.airPurifierMode({value = mapped}))
                    end
                end
            elseif siid == ENVIRONMENT_SIID then
                if piid == PM2_5_DENSITY_PIID then
                    device:emit_event(capabilities.fineDustSensor.fineDustLevel(math.floor(value)))
                end
            elseif siid == FILTER_SIID then
                if piid == FILTER_LIFE_LEVEL_PIID then
                    device:emit_event(capabilities.filterState.filterLifeRemaining({value = value, unit = "%"}))
                end
            elseif siid == ALARM_SIID then
                if piid == ALARM_PIID then
                    device:emit_event(buzzerCap.buzzer({value = bool_to_st(value)}))
                end
            elseif siid == PHYSICAL_CONTROLS_LOCKED_SIID then
                if piid == PHYSICAL_CONTROLS_LOCKED_PIID then
                    device:emit_event(petLockCap.petLock({value = bool_to_st(value)}))
                end
            elseif siid == SCREEN_SIID then
                if piid == BRIGHTNESS_PIID then
                    local mapped = BRIGHTNESS_TO_ST[value]
                    if mapped then
                        device:emit_event(displayLevelCap.displayLevel({value = mapped}))
                    end
                end
            elseif siid == AIR_PURIFIER_FAVORITE_SIID then
                if piid == FAN_LEVEL_PIID then
                    device:emit_event(fanLevelCap.fanLevel({value = value}))
                end
            end
        else
            device.log.error(string.format(
                "CPA5 get_properties result failed (siid=%s piid=%s code=%s)",
                tostring(result.siid),
                tostring(result.piid),
                tostring(result.code)
            ))
        end
    end

    return true
end

local function poll_safely(device, source)
    local ok, result = pcall(poll_device_status, device)
    if not ok then
        device.log.error(string.format("CPA5 poll failed (%s): %s", source, tostring(result)))
        return false
    end
    return result
end

local function start_polling_timer(device)
    local interval = device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL
    local timer = device.thread:call_on_schedule(interval, function()
        poll_safely(device, "scheduled")
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

local function set_property(device, ip, token, siid, piid, value, name)
    local ok, response = pcall(miot.set, device, ip, token, siid, piid, value)
    if not ok then
        device.log.error("CPA5 set " .. name .. " failed: " .. tostring(response))
        return false
    end
    return true
end

local function switch_on_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    if set_property(device, ip, token, AIR_PURIFIER_SIID, ON_PIID, true, "power") then
        device:emit_event(capabilities.switch.switch.on())
        device.thread:call_with_delay(1, function()
            poll_safely(device, "power on")
        end)
    end
end

local function switch_off_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    if set_property(device, ip, token, AIR_PURIFIER_SIID, ON_PIID, false, "power") then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_airPurifierMode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.airPurifierMode
    local value = ST_TO_MODE[requested]
    if value == nil then return end

    if set_property(device, ip, token, AIR_PURIFIER_SIID, MODE_PIID, value, "mode") then
        device:emit_event(airPurifierModeCap.airPurifierMode({value = requested}))
    end
end

local function set_displayLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = command.args.displayLevel
    local value = ST_TO_BRIGHTNESS[requested]
    if value == nil then return end

    if set_property(device, ip, token, SCREEN_SIID, BRIGHTNESS_PIID, value, "display brightness") then
        device:emit_event(displayLevelCap.displayLevel({value = requested}))
    end
end

local function set_fanLevel_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local requested = tonumber(command.args.fanLevel)
    if not requested or requested % 1 ~= 0 or requested < FAN_LEVEL_MIN or requested > FAN_LEVEL_MAX then
        return
    end

    if set_property(device, ip, token, AIR_PURIFIER_FAVORITE_SIID, FAN_LEVEL_PIID, requested, "fan level") then
        device:emit_event(fanLevelCap.fanLevel({value = requested}))
    end
end

local function make_bool_handler(siid, piid, capability, attribute, argument)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local requested = command.args[argument]
        if set_property(device, ip, token, siid, piid, requested == "on", attribute) then
            device:emit_event(capability[attribute]({value = requested}))
        end
    end
end

local set_buzzer_handler = make_bool_handler(ALARM_SIID, ALARM_PIID, buzzerCap, "buzzer", "buzzer")
local set_petLock_handler = make_bool_handler(
    PHYSICAL_CONTROLS_LOCKED_SIID,
    PHYSICAL_CONTROLS_LOCKED_PIID,
    petLockCap,
    "petLock",
    "petLock"
)

local function reset_filter_handler(_, device, _)
    local ip, token = get_device_config(device)
    if not ip then return end

    local ok, response = pcall(miot.action, device, ip, token, FILTER_SIID, RESET_FILTER_LIFE_AIID, {})
    if not ok then
        device.log.error("CPA5 reset filter life failed: " .. tostring(response))
        return
    end

    device.thread:call_with_delay(1, function()
        poll_safely(device, "filter reset")
    end)
end

local function refresh_handler(_, device, _)
    ensure_profile(device)
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    poll_safely(device, "refresh")
end

local function device_added(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(airPurifierModeCap.airPurifierMode({value = "auto"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(petLockCap.petLock({value = "off"}))
    device:emit_event(displayLevelCap.displayLevel({value = "off"}))
    device:emit_event(fanLevelCap.fanLevel({value = 0}))
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))
    poll_safely(device, "added")
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()
    device:emit_event(capabilities.filterState.supportedFilterCommands({value = {"resetFilter"}}))

    local ip = get_device_config(device)
    if ip then
        start_polling_timer(device)
        poll_safely(device, "init")
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
            poll_safely(device, "preferences changed")
        end
    end
end

local driver = Driver("miot-xiaomi-air-purifier-cpa5", {
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
        [airPurifierModeCap.ID] = {
            [airPurifierModeCap.commands.setAirPurifierMode.NAME] = set_airPurifierMode_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [petLockCap.ID] = {
            [petLockCap.commands.setPetLock.NAME] = set_petLock_handler
        },
        [displayLevelCap.ID] = {
            [displayLevelCap.commands.setDisplayLevel.NAME] = set_displayLevel_handler
        },
        [fanLevelCap.ID] = {
            [fanLevelCap.commands.setFanLevel.NAME] = set_fanLevel_handler
        },
        [capabilities.filterState.ID] = {
            [capabilities.filterState.commands.resetFilter.NAME] = reset_filter_handler
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
