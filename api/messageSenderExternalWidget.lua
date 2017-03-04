local moduleInfo = {
	name = "customCommandsMessageSenderExternalWidget",
	desc = "API helper for external widgets using the module",
	author = "PepeAmpere",
	date = "2017-02-13",
	license = "notAlicense",
}

-- @description public API for anyone who wants to inject or edit custom commands via own widget
local newSendCustomMessage = {
	["RegisterCustomCommand"] = function(commandDescription)
		
		-- mandatory
		if (commandDescription == nil or type(commandDescription) ~= "table") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription]") end
		if (commandDescription.type == nil or type(commandDescription.type) ~= "number") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.type]") end
		if (commandDescription.name == nil or type(commandDescription.name ) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.name]") end
		if (commandDescription.cursor == nil or type(commandDescription.cursor) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.cursor]") end
		if (commandDescription.action == nil or type(commandDescription.action) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.action]") end
		if (commandDescription.tooltip == nil or type(commandDescription.tooltip) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.tooltip]") end
		if (commandDescription.hidden == nil or type(commandDescription.hidden) ~= "boolean") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.hidden]") end
		
		-- NOTA UI mandatory
		if (commandDescription.UIoverride == nil or type(commandDescription.UIoverride) ~= "table") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.UIoverride]") end
				
		-- optional for Spring
		if (commandDescription.texture ~= nil and type(commandDescription.texture) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.texture]") end
		if (commandDescription.queueing ~= nil and type(commandDescription.queueing) ~= "boolean") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.queueing]") end
		if (commandDescription.disabled ~= nil and type(commandDescription.disabled) ~= "boolean") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.disabled]") end
		if (commandDescription.showUnique ~= nil and type(commandDescription.showUnique) ~= "boolean") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.showUnique]") end
		if (commandDescription.onlyTexture ~= nil and type(commandDescription.onlyTexture) ~= "boolean") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.onlyTexture]") end
		if (commandDescription.params ~= nil and type(commandDescription.params) ~= "table") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [RegisterCustomCommand] with wrong parameter for [commandDescription.params]") end
		
		-- optional 
		if (commandDescription.whitelist ~= nil and type(commandDescription.whitelist) ~= "table") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [registerCustomCommand] with wrong parameter for [commandDescription.whitelist]") end
		
		commandDescription["subject"] = "RegisterCustomCommand"
			
		message.SendRules(commandDescription)
	end,
	
	["DeregisterCustomCommand"] = function(commandName)
	
		if (commandName == nil or type(commandName) ~= "string") then Spring.Echo("[" .. moduleInfo.name ..  "]" .. "WARNING: Attempt to send message [DeregisterCustomCommand] with wrong parameter for [commandName]") end
		
		local newMessage = {
			subject = "DeregisterCustomCommand",
			name = commandName,
		}
		message.SendRules(newMessage)
	end,
}

-- END OF MODULE DEFINITIONS --

-- update global structures 
message.AttachCustomSender(newSendCustomMessage, moduleInfo)
