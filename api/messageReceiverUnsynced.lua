local moduleInfo = {
	name = "customCommandsMessageReceiverUnsynced",
	desc = "Internal API for triggerring unsynced code.",
	author = "PepeAmpere",
	date = "2017-02-19",
	license = "notAlicense",
}

local newReceiveCustomMessage = {	
	["CustomCommandUpdate"] = function(_, cmdID)
		if (Script.LuaUI('CustomCommandUpdate')) then
			Script.LuaUI.CustomCommandUpdate(cmdID)
		end
	end,
	
	["CustomCommandRegistered"] = function(_, encodedMessage)
		local decodedMsg = message.Decode(encodedMessage)
		if (Script.LuaUI('CustomCommandRegistered')) then
			Script.LuaUI.CustomCommandRegistered(decodedMsg.name, decodedMsg.id)
		end
	end,
}

-- END OF MODULE DEFINITIONS --

-- update global structures 
message.AttachCustomReceiver(newReceiveCustomMessage, moduleInfo)
