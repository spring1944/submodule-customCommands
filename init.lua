-- universal load for customCommands module
-- if you want customize it for your game, load your configs BEFORE including this file

local MODULE_NAME = "customCommands"
Spring.Echo("-- " .. MODULE_NAME .. " LOADING --")

------------------------------------------------------

-- MANDATORY
-- check required modules
if (modules == nil) then Spring.Echo("[" .. MODULE_NAME .. "] ERROR: required madatory config [modules] listing paths for modules is missing") end
if (attach == nil) then Spring.Echo("[" .. MODULE_NAME .. "] ERROR: required madatory library [attach] for loading files and modules is missing") end
if (message == nil) then Spring.Echo("[" .. MODULE_NAME .. "] ERROR: required madatory module [message] for communication is missing") end

------------------------------------------------------

local thisModuleData = modules[MODULE_NAME]
local THIS_MODULE_DATA_PATH = thisModuleData.data.path

-- LOAD INTERNAL MODULE FUNCTIONALITY
if (widget) then
	attach.File(THIS_MODULE_DATA_PATH .. "api/messageSenderExternalWidget.lua") -- API helper for external widgets
else
	if (gadgetHandler:IsSyncedCode()) then
		attach.File(THIS_MODULE_DATA_PATH .. "api/messageSenderInternal.lua") -- API helper for internal usage
		attach.File(THIS_MODULE_DATA_PATH .. "api/messageReceiverSynced.lua") -- hard API for processing inputs into synced code
		attach.File(THIS_MODULE_DATA_PATH .. "customCommands.lua") -- core customCommands library with main functionality of the module
	else
		attach.File(THIS_MODULE_DATA_PATH .. "api/messageReceiverUnsynced.lua") -- hard API for processing inputs into unsynced code
	end
end
------------------------------------------------------

Spring.Echo("-- " .. MODULE_NAME .. " LOADING FINISHED --")