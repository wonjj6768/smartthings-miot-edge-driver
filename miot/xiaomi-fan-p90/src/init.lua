-- Mijia Smart DC Inverter Circulation Fan Pro Driver

local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local fanModeCap = capabilities["concertmirror08464.xiaomiFanP90FanMode"]
local indicatorLightCap = capabilities["concertmirror08464.xiaomiFanP90IndicatorLight"]
local buzzerCap = capabilities["concertmirror08464.xiaomiFanP90Buzzer"]
local childLockCap = capabilities["concertmirror08464.xiaomiFanP90ChildLock"]
local leftAngleCap = capabilities["concertmirror08464.xiaomiFanP90LeftAngleV2"]
local rightAngleCap = capabilities["concertmirror08464.xiaomiFanP90RightAngleV2"]
local upAngleCap = capabilities["concertmirror08464.xiaomiFanP90UpAngleV2"]
local downAngleCap = capabilities["concertmirror08464.xiaomiFanP90DownAngleV2"]
local fanSpeedPercent = capabilities["fanSpeedPercent"]

local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "xiaomi-fan-p90"

-- MIoT model: xiaomi.fan.p90
-- Spec model: xiaomi-p90
-- Protocol proof: authenticated exact-model LAN get_properties responses with code=0
-- were recorded in flynnpark commit c6117c494b7015351d02174c3dd30a97b9af0ae6.
-- Fan service (siid=2)
local FAN_SIID = 2
local POWER_PIID = 1                 -- RW bool
local FAULT_PIID = 2                 -- R uint8, diagnostic only
local MODE_PIID = 3                  -- RW 0=Straight, 1=Natural
local FAN_SPEED_PIID = 4             -- RW 1..100, step 1
local HORIZONTAL_SWING_PIID = 6      -- RW bool
local VERTICAL_SWING_PIID = 8        -- RW bool
local OFF_TO_CENTER_PIID = 13        -- RW bool, auxiliary and not exposed

-- Screen service (siid=6)
local SCREEN_SIID = 6
local SCREEN_PIID = 1                -- RW bool

-- Alarm service (siid=7)
local BUZZER_SIID = 7
local BUZZER_PIID = 1                -- RW bool

-- Physical controls locked service (siid=8)
local CHILD_LOCK_SIID = 8
local CHILD_LOCK_PIID = 1            -- RW bool

-- Delay service (siid=9), not exposed.
local DELAY_SIID = 9
local DELAY_ENABLED_PIID = 1         -- RW bool
local DELAY_TIME_PIID = 2            -- RW minutes
local DELAY_REMAIN_TIME_PIID = 3     -- R minutes

-- Xiaomi dm-service (siid=11)
local DM_SERVICE_SIID = 11
local SYMMETRICAL_SWING_H_PIID = 1   -- RW bool, helper flag and not exposed
local LEFT_ANGLE_PIID = 2            -- RW 10..120, step 10
local RIGHT_ANGLE_PIID = 3           -- RW 0..110, step 10
local SYMMETRICAL_SWING_V_PIID = 4   -- RW bool, helper flag and not exposed
local UP_ANGLE_PIID = 5              -- RW 10..100, step 10
local DOWN_ANGLE_PIID = 6            -- RW 0..90, step 10
local DM_FAN_SPEED_PIID = 7          -- RW 1..100, duplicate and not exposed
local LOOP_MODE_ACTION_IID = 1       -- Shortcut action, not exposed
local LOOP_GEAR_ACTION_IID = 2       -- Shortcut action, not exposed

local MODE_TO_ST = {
    [0] = "normal",
    [1] = "nature"
}

local ST_TO_MODE = {
    normal = 0,
    nature = 1
}

local SUPPORTED_OSCILLATION_MODES = {"off", "horizontal", "vertical", "all"}

local ANGLE_PROPERTIES = {
    [LEFT_ANGLE_PIID] = {capability = leftAngleCap, attribute = leftAngleCap.leftAngle, argument = "leftAngle", minimum = 10, maximum = 120},
    [RIGHT_ANGLE_PIID] = {capability = rightAngleCap, attribute = rightAngleCap.rightAngle, argument = "rightAngle", minimum = 0, maximum = 110},
    [UP_ANGLE_PIID] = {capability = upAngleCap, attribute = upAngleCap.upAngle, argument = "upAngle", minimum = 10, maximum = 100},
    [DOWN_ANGLE_PIID] = {capability = downAngleCap, attribute = downAngleCap.downAngle, argument = "downAngle", minimum = 0, maximum = 90}
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
    if not device:supports_capability_by_id(downAngleCap.ID, "main") then
        device:try_update_metadata({profile = PROFILE_NAME})
    end
end

local function emit_on_off(device, capability_attribute, value)
    device:emit_event(capability_attribute({value = value and "on" or "off"}))
end

local function emit_angle(device, piid, value)
    local angle = ANGLE_PROPERTIES[piid]
    if angle and type(value) == "number" then
        device:emit_event(angle.attribute({value = tostring(math.floor(value))}))
    end
end

local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end

    local properties = {
        {siid = FAN_SIID, piid = POWER_PIID},
        {siid = FAN_SIID, piid = MODE_PIID},
        {siid = FAN_SIID, piid = FAN_SPEED_PIID},
        {siid = FAN_SIID, piid = HORIZONTAL_SWING_PIID},
        {siid = FAN_SIID, piid = VERTICAL_SWING_PIID},
        {siid = SCREEN_SIID, piid = SCREEN_PIID},
        {siid = BUZZER_SIID, piid = BUZZER_PIID},
        {siid = CHILD_LOCK_SIID, piid = CHILD_LOCK_PIID},
        {siid = DM_SERVICE_SIID, piid = LEFT_ANGLE_PIID},
        {siid = DM_SERVICE_SIID, piid = RIGHT_ANGLE_PIID},
        {siid = DM_SERVICE_SIID, piid = UP_ANGLE_PIID},
        {siid = DM_SERVICE_SIID, piid = DOWN_ANGLE_PIID}
    }

    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end

    local horizontal_swing = nil
    local vertical_swing = nil

    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid = result.siid
            local piid = result.piid
            local value = result.value

            if siid == FAN_SIID then
                if piid == POWER_PIID then
                    device:emit_event(capabilities.switch.switch(value and "on" or "off"))
                elseif piid == MODE_PIID then
                    local mode = MODE_TO_ST[value]
                    if mode then
                        device:emit_event(fanModeCap.fanMode({value = mode}))
                    end
                elseif piid == FAN_SPEED_PIID then
                    device:emit_event(fanSpeedPercent.percent({value = value, unit = "%"}))
                elseif piid == HORIZONTAL_SWING_PIID then
                    horizontal_swing = value
                elseif piid == VERTICAL_SWING_PIID then
                    vertical_swing = value
                end
            elseif siid == SCREEN_SIID and piid == SCREEN_PIID then
                emit_on_off(device, indicatorLightCap.indicatorLight, value)
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then
                emit_on_off(device, buzzerCap.buzzer, value)
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then
                emit_on_off(device, childLockCap.childLock, value)
            elseif siid == DM_SERVICE_SIID then
                emit_angle(device, piid, value)
            end
        end
    end

    if horizontal_swing ~= nil or vertical_swing ~= nil then
        local mode = "off"
        if horizontal_swing and vertical_swing then
            mode = "all"
        elseif horizontal_swing then
            mode = "horizontal"
        elseif vertical_swing then
            mode = "vertical"
        end
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(mode))
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

    local ok = pcall(miot.set, device, ip, token, FAN_SIID, POWER_PIID, true)
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

    local ok = pcall(miot.set, device, ip, token, FAN_SIID, POWER_PIID, false)
    if ok then
        device:emit_event(capabilities.switch.switch.off())
    end
end

local function set_fan_speed_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local speed = math.max(1, math.min(100, command.args.percent))
    local ok = pcall(miot.set, device, ip, token, FAN_SIID, FAN_SPEED_PIID, speed)
    if ok then
        device:emit_event(fanSpeedPercent.percent({value = speed, unit = "%"}))
    end
end

local function set_fan_oscillation_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.fanOscillationMode
    if mode ~= "off" and mode ~= "horizontal" and mode ~= "vertical" and mode ~= "all" then return end

    local horizontal = mode == "horizontal" or mode == "all"
    local vertical = mode == "vertical" or mode == "all"
    local ok_horizontal = pcall(miot.set, device, ip, token, FAN_SIID, HORIZONTAL_SWING_PIID, horizontal)
    local ok_vertical = pcall(miot.set, device, ip, token, FAN_SIID, VERTICAL_SWING_PIID, vertical)
    if ok_horizontal and ok_vertical then
        device:emit_event(capabilities.fanOscillationMode.fanOscillationMode(mode))
    end
end

local function set_fan_mode_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local mode = command.args.mode
    local value = ST_TO_MODE[mode]
    if value == nil then return end

    local ok = pcall(miot.set, device, ip, token, FAN_SIID, MODE_PIID, value)
    if ok then
        device:emit_event(fanModeCap.fanMode({value = mode}))
    end
end

local function set_indicator_light_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.indicatorLight
    local ok = pcall(miot.set, device, ip, token, SCREEN_SIID, SCREEN_PIID, value == "on")
    if ok then
        device:emit_event(indicatorLightCap.indicatorLight({value = value}))
    end
end

local function set_buzzer_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.buzzer
    local ok = pcall(miot.set, device, ip, token, BUZZER_SIID, BUZZER_PIID, value == "on")
    if ok then
        device:emit_event(buzzerCap.buzzer({value = value}))
    end
end

local function set_child_lock_handler(_, device, command)
    local ip, token = get_device_config(device)
    if not ip then return end

    local value = command.args.childLock
    local ok = pcall(miot.set, device, ip, token, CHILD_LOCK_SIID, CHILD_LOCK_PIID, value == "on")
    if ok then
        device:emit_event(childLockCap.childLock({value = value}))
    end
end

local function make_angle_handler(piid)
    return function(_, device, command)
        local ip, token = get_device_config(device)
        if not ip then return end

        local property = ANGLE_PROPERTIES[piid]
        local angle = tonumber(command.args[property.argument])
        if not angle or angle < property.minimum or angle > property.maximum or angle % 10 ~= 0 then return end

        local ok = pcall(miot.set, device, ip, token, DM_SERVICE_SIID, piid, angle)
        if ok then
            device:emit_event(property.attribute({value = tostring(angle)}))
        end
    end
end

local function refresh_handler(_, device, _)
    ensure_profile(device)
    pcall(poll_device_status, device)
end

local function device_added(_, device)
    ensure_profile(device)
    device:emit_event(capabilities.switch.switch.off())
    device:emit_event(fanSpeedPercent.percent({value = 1, unit = "%"}))
    device:emit_event(capabilities.fanOscillationMode.supportedFanOscillationModes({value = SUPPORTED_OSCILLATION_MODES}))
    device:emit_event(capabilities.fanOscillationMode.fanOscillationMode("off"))
    device:emit_event(fanModeCap.fanMode({value = "normal"}))
    device:emit_event(indicatorLightCap.indicatorLight({value = "on"}))
    device:emit_event(buzzerCap.buzzer({value = "off"}))
    device:emit_event(childLockCap.childLock({value = "off"}))
end

local function device_init(_, device)
    ensure_profile(device)
    device:online()

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
    ensure_profile(device)
    if not args.old_st_store or not args.old_st_store.preferences then return end

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

local driver = Driver("miot-xiaomi-fan-p90", {
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
        [fanSpeedPercent.ID] = {
            [fanSpeedPercent.commands.setPercent.NAME] = set_fan_speed_handler
        },
        [capabilities.fanOscillationMode.ID] = {
            [capabilities.fanOscillationMode.commands.setFanOscillationMode.NAME] = set_fan_oscillation_mode_handler
        },
        [fanModeCap.ID] = {
            [fanModeCap.commands.setFanMode.NAME] = set_fan_mode_handler
        },
        [indicatorLightCap.ID] = {
            [indicatorLightCap.commands.setIndicatorLight.NAME] = set_indicator_light_handler
        },
        [buzzerCap.ID] = {
            [buzzerCap.commands.setBuzzer.NAME] = set_buzzer_handler
        },
        [childLockCap.ID] = {
            [childLockCap.commands.setChildLock.NAME] = set_child_lock_handler
        },
        [leftAngleCap.ID] = {
            [leftAngleCap.commands.setLeftAngle.NAME] = make_angle_handler(LEFT_ANGLE_PIID)
        },
        [rightAngleCap.ID] = {
            [rightAngleCap.commands.setRightAngle.NAME] = make_angle_handler(RIGHT_ANGLE_PIID)
        },
        [upAngleCap.ID] = {
            [upAngleCap.commands.setUpAngle.NAME] = make_angle_handler(UP_ANGLE_PIID)
        },
        [downAngleCap.ID] = {
            [downAngleCap.commands.setDownAngle.NAME] = make_angle_handler(DOWN_ANGLE_PIID)
        },
        [capabilities.refresh.ID] = {
            [capabilities.refresh.commands.refresh.NAME] = refresh_handler
        }
    }
})

driver:run()
