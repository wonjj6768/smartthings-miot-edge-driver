-- Smartmi Heater MA6 Driver
local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local discovery = require "discovery"
local miot = require "miot"

local buzzerCap = capabilities["concertmirror08464.zhimiHeaterMa6Buzzer"]
local childLockCap = capabilities["concertmirror08464.zhimiHeaterMa6ChildLock"]
local modeCap = capabilities["concertmirror08464.zhimiHeaterMa6Mode"]
local heatLevelCap = capabilities["concertmirror08464.zhimiHeaterMa6HeatLevel"]
local lowWaterCap = capabilities["concertmirror08464.zhimiHeaterMa6LowWater"]
local POLLING_TIMER = "polling_timer"
local DEFAULT_POLLING_INTERVAL = 60
local PROFILE_NAME = "zhimi-heater-ma6"
local HEATER_SIID, POWER_PIID, FAULT_PIID, TARGET_PIID, MODE_PIID, HEAT_LEVEL_PIID = 2, 1, 2, 3, 4, 5
local ENVIRONMENT_SIID, TEMPERATURE_PIID, HUMIDITY_PIID = 4, 2, 1
local CHILD_LOCK_SIID, CHILD_LOCK_PIID = 5, 1
local BUZZER_SIID, BUZZER_PIID = 6, 1
local TARGET_MIN, TARGET_MAX, TARGET_STEP = 16, 28, 1

-- Exact MIoT contract: zhimi.heater.ma6, zhimi-ma6:1.
-- Heater 2/1 on RW, 2/2 fault 0=No Faults/1=Temperature Sensor Fault/
-- 2=LowWater R, 2/3 target 16..28 C RW, 2/4 raw Mode1..Mode4 RW,
-- 2/5 heat level 0/Low/High RW; environment 4/1 RH and 4/2 temperature R;
-- physical lock 5/1 RW and alarm/buzzer 6/1 RW.
local MODE_TO_ST = {[1]="modeOne",[2]="modeTwo",[3]="modeThree",[4]="modeFour"}
local ST_TO_MODE = {modeOne=1,modeTwo=2,modeThree=3,modeFour=4}
local LEVEL_TO_ST = {[0]="levelZero",[1]="low",[2]="high"}
local ST_TO_LEVEL = {levelZero=0,low=1,high=2}
local FAULT_TO_LOW_WATER = {[0]="normal",[1]="otherFault",[2]="lowWater"}
local function get_device_config(device)
    local ip, token = device.preferences.ipAddress, device.preferences.token
    if ip and ip ~= "" and token and #token == 32 then return ip, token end
    return nil, nil
end
local function ensure_profile(device)
    if not device:supports_capability_by_id(buzzerCap.ID, "main") then device:try_update_metadata({profile = PROFILE_NAME}) end
end
local function emit_range(device)
    device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
        value = {minimum = TARGET_MIN, maximum = TARGET_MAX, step = TARGET_STEP}, unit = "C"}))
end
local function emit_bool(device, attribute, value) device:emit_event(attribute({value = value and "on" or "off"})) end
local function poll_device_status(device)
    local ip, token = get_device_config(device)
    if not ip then return end
    local properties = {{siid=HEATER_SIID,piid=POWER_PIID},{siid=HEATER_SIID,piid=FAULT_PIID},
        {siid=HEATER_SIID,piid=TARGET_PIID},{siid=HEATER_SIID,piid=MODE_PIID},
        {siid=HEATER_SIID,piid=HEAT_LEVEL_PIID},{siid=ENVIRONMENT_SIID,piid=TEMPERATURE_PIID},
        {siid=ENVIRONMENT_SIID,piid=HUMIDITY_PIID},{siid=CHILD_LOCK_SIID,piid=CHILD_LOCK_PIID},
        {siid=BUZZER_SIID,piid=BUZZER_PIID}}
    local ok, response = pcall(miot.gets, device, ip, token, properties)
    if not ok or not response or not response.result then return end
    for _, result in ipairs(response.result) do
        if result.code == 0 then
            local siid, piid, value = result.siid, result.piid, result.value
            if siid == HEATER_SIID and piid == POWER_PIID then
                device:emit_event(capabilities.switch.switch(value and "on" or "off"))
            elseif siid == HEATER_SIID and piid == TARGET_PIID then
                device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value=value,unit="C"}))
            elseif siid == HEATER_SIID and piid == FAULT_PIID and FAULT_TO_LOW_WATER[value] then
                device:emit_event(lowWaterCap.lowWaterStatus({value=FAULT_TO_LOW_WATER[value]}))
            elseif siid == HEATER_SIID and piid == MODE_PIID and MODE_TO_ST[value] then
                device:emit_event(modeCap.heaterMode({value=MODE_TO_ST[value]}))
            elseif siid == HEATER_SIID and piid == HEAT_LEVEL_PIID and LEVEL_TO_ST[value] then
                device:emit_event(heatLevelCap.heatLevel({value=LEVEL_TO_ST[value]}))
            elseif siid == ENVIRONMENT_SIID and piid == TEMPERATURE_PIID then
                device:emit_event(capabilities.temperatureMeasurement.temperature({value=value,unit="C"}))
            elseif siid == ENVIRONMENT_SIID and piid == HUMIDITY_PIID then
                device:emit_event(capabilities.relativeHumidityMeasurement.humidity(value))
            elseif siid == CHILD_LOCK_SIID and piid == CHILD_LOCK_PIID then emit_bool(device, childLockCap.childLock, value)
            elseif siid == BUZZER_SIID and piid == BUZZER_PIID then emit_bool(device, buzzerCap.buzzer, value) end
        end
    end
end
local function start_polling_timer(device)
    device:set_field(POLLING_TIMER, device.thread:call_on_schedule(device.preferences.pollingInterval or DEFAULT_POLLING_INTERVAL,
        function() pcall(poll_device_status, device) end, "Polling"))
end
local function stop_polling_timer(device)
    local timer=device:get_field(POLLING_TIMER); if timer then device.thread:cancel_timer(timer); device:set_field(POLLING_TIMER,nil) end
end
local function set_property(device, siid, piid, value, event)
    local ip, token=get_device_config(device); if not ip then return false end
    local ok=pcall(miot.set,device,ip,token,siid,piid,value); if ok then device:emit_event(event); return true end; return false
end
local function switch_on_handler(_,device,_)
    if set_property(device,HEATER_SIID,POWER_PIID,true,capabilities.switch.switch.on()) then
        device.thread:call_with_delay(1,function() pcall(poll_device_status,device) end) end
end
local function switch_off_handler(_,device,_) set_property(device,HEATER_SIID,POWER_PIID,false,capabilities.switch.switch.off()) end
local function set_setpoint_handler(_,device,command)
    local value=math.max(TARGET_MIN,math.min(TARGET_MAX,math.floor(command.args.setpoint+0.5)))
    set_property(device,HEATER_SIID,TARGET_PIID,value,capabilities.thermostatHeatingSetpoint.heatingSetpoint({value=value,unit="C"}))
end
local function set_mode_handler(_,device,command)
    local value=ST_TO_MODE[command.args.heaterMode]
    if value then set_property(device,HEATER_SIID,MODE_PIID,value,modeCap.heaterMode({value=command.args.heaterMode})) end
end
local function set_heat_level_handler(_,device,command)
    local value=ST_TO_LEVEL[command.args.heatLevel]
    if value~=nil then set_property(device,HEATER_SIID,HEAT_LEVEL_PIID,value,heatLevelCap.heatLevel({value=command.args.heatLevel})) end
end
local function set_bool_handler(capability,attribute,siid,piid,argument)
    return function(_,device,command) local value=command.args[argument]; if value~="off" and value~="on" then return end
        set_property(device,siid,piid,value=="on",capability[attribute]({value=value})) end
end
local function refresh_handler(_,device,_) emit_range(device); pcall(poll_device_status,device) end
local function device_added(_,device)
    ensure_profile(device); device:emit_event(capabilities.switch.switch.off())
    device:emit_event(capabilities.temperatureMeasurement.temperature({value=0,unit="C"}))
    device:emit_event(capabilities.relativeHumidityMeasurement.humidity(0))
    device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpoint({value=TARGET_MIN,unit="C"})); emit_range(device)
    device:emit_event(modeCap.heaterMode({value="modeOne"}))
    device:emit_event(heatLevelCap.heatLevel({value="levelZero"}))
    device:emit_event(lowWaterCap.lowWaterStatus({value="normal"}))
    emit_bool(device,buzzerCap.buzzer,false); emit_bool(device,childLockCap.childLock,false)
end
local function device_init(_,device)
    ensure_profile(device); device:online(); emit_range(device); local ip=get_device_config(device)
    if ip then start_polling_timer(device); pcall(poll_device_status,device) end
end
local function device_removed(_,device) stop_polling_timer(device) end
local function device_info_changed(driver,device,_,args)
    ensure_profile(device); if not args.old_st_store or not args.old_st_store.preferences then return end
    local old,new=args.old_st_store.preferences,device.preferences
    if old.createDev==false and new.createDev==true then discovery.create_device(driver) end
    if old.ipAddress~=new.ipAddress or old.token~=new.token or old.pollingInterval~=new.pollingInterval then
        stop_polling_timer(device); local ip=get_device_config(device); if ip then start_polling_timer(device); pcall(poll_device_status,device) end end
end
local driver=Driver("miot-zhimi-heater-ma6",{discovery=discovery.handle_discovery,
    lifecycle_handlers={added=device_added,init=device_init,removed=device_removed,infoChanged=device_info_changed},
    capability_handlers={
        [capabilities.switch.ID]={[capabilities.switch.commands.on.NAME]=switch_on_handler,[capabilities.switch.commands.off.NAME]=switch_off_handler},
        [capabilities.thermostatHeatingSetpoint.ID]={[capabilities.thermostatHeatingSetpoint.commands.setHeatingSetpoint.NAME]=set_setpoint_handler},
        [modeCap.ID]={[modeCap.commands.setHeaterMode.NAME]=set_mode_handler},
        [heatLevelCap.ID]={[heatLevelCap.commands.setHeatLevel.NAME]=set_heat_level_handler},
        [buzzerCap.ID]={[buzzerCap.commands.setBuzzer.NAME]=set_bool_handler(buzzerCap,"buzzer",BUZZER_SIID,BUZZER_PIID,"buzzer")},
        [childLockCap.ID]={[childLockCap.commands.setChildLock.NAME]=set_bool_handler(childLockCap,"childLock",CHILD_LOCK_SIID,CHILD_LOCK_PIID,"childLock")},
        [capabilities.refresh.ID]={[capabilities.refresh.commands.refresh.NAME]=refresh_handler}}})
driver:run()
