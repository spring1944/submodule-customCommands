local moduleInfo = {
	name = "customCommandsMessageSenderInternal",
	desc = "Internal API",
	author = "PepeAmpere",
	date = "2017-02-19",
	license = "MIT",
}

local newSendCustomMessage = {
	["CustomCommandUpdate"] = function(cmdID)
		-- mandatory
		if (cmdID == nil or type(cmdID) ~= "number") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [CustomCommandUpdate] with wrong parameter for [cmdID]") end
		
		message.SendSyncedToUnsyncedDecoded("CustomCommandUpdate", cmdID)
	end,
	
	["CustomCommandRegistered"] = function(cmdName, cmdID)
		-- mandatory
		if (cmdName == nil or type(cmdName) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [CustomCommandRegistered] with wrong parameter for [cmdName]") end
		if (cmdID == nil or type(cmdID) ~= "number") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [CustomCommandRegistered] with wrong parameter for [cmdID]") end
		
		local newMessage = {
			subject = "CustomCommandRegistered",
			name = cmdName,
			id = cmdID,
		}
		
		message.SendSyncedToUnsynced(newMessage)
	end,
}

-- END OF MODULE DEFINITIONS --

-- update global structures 
message.AttachCustomSender(newSendCustomMessage, moduleInfo)
