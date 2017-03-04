local moduleInfo = {
	name = "customCommandsMessageReceiverSynced",
	desc = "API for receiving messages triggering synced code.",
	author = "PepeAmpere",
	date = "2017-02-13",
	license = "notAlicense",
}

local newReceiveCustomMessage = {
	["RegisterCustomCommand"] = function(decodedMsg, playerID, context)
		if (decodedMsg ~= nil and decodedMsg.name ~= nil) then
			customCommands.RegisterCustomCommand(decodedMsg, playerID)
		else
			Spring.Echo("[customCommandsMessageReceiverSynced] Command [" .. decodedMsg.name .. "] was not registered due invalid input")
		end
	end,
	
	["DeregisterCustomCommand"] = function(decodedMsg, playerID, context)
		if (decodedMsg ~= nil and decodedMsg.name ~= nil) then
			-- we currently have no way how to trully deregister given command, we just remove its instances from all units
			customCommands.RemoveCustomCommandFromAllUnits(decodedMsg.name, playerID)
		else
			Spring.Echo("[customCommandsMessageReceiverSynced] Command [" .. decodedMsg.name .. "] was not deregistered due invalid input")
		end
	end,
}

-- END OF MODULE DEFINITIONS --

-- update global structures 
message.AttachCustomReceiver(newReceiveCustomMessage, moduleInfo)
