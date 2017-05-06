local moduleInfo = {
	name = "customCommands",
	desc = "customCommands core",
	author = "PepeAmpere",
	date = "2017/02/13",
	license = "notAlicense",
}

-- moduel global structures
cmdCounter = 36000
customCommandsNameToID = {}
customCommandsIDToOverride = {}
customCommandsIDToName = {}
customCommandsDescriptions = {}
customCommandsNameToTeamID = {}
customCommandsNameToPlayerID = {}
customCommandsNameToWhitelist = {}
customCommandsNameToName = {} -- internal name to requested name, populated only once
customCommandsCountsPerTeam = {}

CUSTOM_COMMANDS_PER_TEAM_MAX = 100 + 1

customCommands = {

	-- INTERNAL (PRIVATE) MODULE FUNCTIONS
	
	-- @description Function which generates internal command key based on requested cmdName and playerID
	-- @privacy private to customCommands module
	-- @argument cmdName [string] cmdName as requested by player
	-- @argument playerID [number] Spring playerID
	-- @return internalCmdName [string] unique command name as key for all tables
	["CreateInternalCommandName"] = function(cmdName, playerID)
		return cmdName .. "_" .. playerID
	end,
	
	-- @description Function which encodes filtered cmdName => cmdID mapping
	-- @privacy private to customCommands module
	-- @argument fullTable [table] table customCommandsNameToID
	-- @argument playerID [number] Spring playerID
	-- @return encodedTable [string] filtered mapping as string
	["EncodeLocalNameToID"] = function(fullTable, playerID)
		local thisPlayersList = {}
		for internalCmdName, cmdID in pairs(fullTable) do
			if (customCommandsNameToPlayerID[internalCmdName] == playerID) then
				thisPlayersList[customCommandsNameToName[internalCmdName]] = cmdID
			end
		end
		return message.Encode(thisPlayersList)
	end,
	
	-- @description Function which encodes filtered cmdID => UIoverride table mapping
	-- @privacy private to customCommands module
	-- @argument fullTable [table] table customCommandsIDToOverride
	-- @argument playerID [number] Spring playerID
	-- @return encodedTable [string] filtered mapping as string
	["EncodeLocalOverride"] = function(fullTable, playerID)
		local thisPlayersList = {}
		for cmdID, UIoverride in pairs(fullTable) do
			if (customCommandsNameToPlayerID[customCommandsIDToName[cmdID]] == playerID) then
				thisPlayersList[cmdID] = UIoverride
			end
		end
		return message.Encode(thisPlayersList)
	end,
	
	-- @description Function for registering or updating custom command
	-- @privacy private to customCommands module
	-- @argument decodedMsg [table] decoded table of whole registration request containing all mandatory cmdDesc data
	-- @argument playerID [number] Spring playerID
	["RegisterCustomCommand"] = function(decodedMsg, playerID)
		local cmdName = decodedMsg.name
		local internalCmdName = customCommands.CreateInternalCommandName(cmdName, playerID)
		customCommandsNameToName[internalCmdName] = cmdName
		local _,_,_,teamID = Spring.GetPlayerInfo(playerID)
		if (customCommandsCountsPerTeam[teamID] == nil) then customCommandsCountsPerTeam[teamID] = 0 end -- init custom commands counter if first request

		-- 1) new registration allowed if 
		-- * limit of 1000 commands was not reached
		-- * given command name was not registered yet
		-- * given team has registered less than CUSTOM_COMMANDS_PER_TEAM_MAX custom commands already
		-- 2) overwrite registration data for already used command name
		-- * given command was registered
		-- * if requesting playerID matches saved playerID for given command name
		if ((customCommandsNameToID[internalCmdName] == nil and cmdCounter < 37000 and customCommandsCountsPerTeam[teamID] < CUSTOM_COMMANDS_PER_TEAM_MAX) or 
		(customCommandsNameToID[internalCmdName] ~= nil and customCommandsNameToPlayerID[internalCmdName] == playerID)) then
			local cmdID
			
			if (customCommandsNameToID[internalCmdName] == nil) then -- new command
				cmdID = cmdCounter -- take prepared new ID
				cmdCounter = cmdCounter + 1 -- prepare new ID
				customCommandsNameToID[internalCmdName] = cmdID -- to prevent commands with duplicit names and readding same command multiple times
				customCommandsIDToName[cmdID] = internalCmdName -- reverse mapping
				gadgetHandler:RegisterCMDID(cmdID)
				
				-- register owner player and owner team
				customCommandsNameToPlayerID[internalCmdName] = playerID
				customCommandsNameToTeamID[internalCmdName] = teamID
				
				-- increase commands counter
				customCommandsCountsPerTeam[teamID] = customCommandsCountsPerTeam[teamID] + 1
				
				-- name to cmdID mapping
				local encodedCustomCommandsNameToID = customCommands.EncodeLocalNameToID(customCommandsNameToID, playerID)
				message.SendSyncedInfoTeamPacked("CustomCommandsNameToID", encodedCustomCommandsNameToID , teamID) -- save mapping to global variable so any widget can reload it from there
			else -- already existing
				-- we remove all existing instance of old command to make sure it is not forgotten
				customCommands.RemoveCustomCommandFromAllUnits(cmdName, playerID)
			
				cmdID = customCommandsNameToID[internalCmdName]
			end
			
			customCommandsIDToOverride[cmdID] = decodedMsg.UIoverride
			
			-- update UI data, send notifications
			local encodedCustomCommandsIDToOverride = customCommands.EncodeLocalOverride(customCommandsIDToOverride, playerID)
            message.SendSyncedInfoTeamPacked("CustomCommandsIDToOverride", encodedCustomCommandsIDToOverride, teamID) -- save override info to global variable so any widget can reload it from there
			sendCustomMessage.CustomCommandUpdate(cmdID) -- event like notification for any widget
			sendCustomMessage.CustomCommandRegistered(cmdName, cmdID) -- notify all widgets about registration (no matter if new or overriden)
						
			-- construct valid commandDescription which does not contain invalid key=>value pairs
			local newCommandDescription = {
				id = cmdID,
				type = decodedMsg.type,
				name = cmdName,
				cursor = decodedMsg.cursor,
				action = decodedMsg.action,
				tooltip = decodedMsg.tooltip,
				hidden = decodedMsg.hidden,
				-- not used yet
				texture = decodedMsg.texture,
				queueing = decodedMsg.queueing,
				disabled = decodedMsg.disabled,
				showUnique = decodedMsg.showUnique,
				onlyTexture = decodedMsg.onlyTexture,
				params = decodedMsg.params,
			}
			
			customCommandsDescriptions[internalCmdName] = newCommandDescription			
			
			-- construct whitelist
			local whitelistMap = {}
			local msgWhitelist = decodedMsg.whitelist
			if (msgWhitelist ~= nil) then
				for i=1, #msgWhitelist do 
					whitelistMap[msgWhitelist[i]] = true
				end
				customCommandsNameToWhitelist[internalCmdName] = whitelistMap
			else -- clear it if updating command and there is no new whitelist
				customCommandsNameToWhitelist[internalCmdName] = nil
			end
			
			for _, unitID in pairs(Spring.GetTeamUnits(teamID)) do
				customCommands.UnitIncomming(unitID, Spring.GetUnitDefID(unitID), teamID, nil)
			end
		else
			Spring.Echo("[customCommands] Command [" .. cmdName .. "] was not registered because 1) limit reached or 2) trying to register command with already used name and you are not its owner")
		end
	end,
	
	-- FAKE DEREGISTRAION :)
	-- @description We just remove given command from all places where it was deployed
	-- @privacy private to customCommands module
	-- @argument internalCmdName [string] name of the command we want to deregister
	-- @argument playerID [number] Spring playerID
	-- @comment WARNING: the commandID is still occupied in engine!
	["RemoveCustomCommandFromAllUnits"] = function(cmdName, playerID)	
		local _,_,_,teamID = Spring.GetPlayerInfo(playerID)
		local internalCmdName = customCommands.CreateInternalCommandName(cmdName, playerID)
		local cmdDesc = customCommandsDescriptions[internalCmdName]
		if (cmdDesc ~= nil and cmdDesc.id ~= nil and customCommandsNameToPlayerID[internalCmdName] == playerID) then -- only registrator can remove all instances of his own command from all units
			for _, unitID in pairs(Spring.GetTeamUnits(teamID)) do
				local index = Spring.FindUnitCmdDesc(unitID, cmdDesc.id)
				if (index ~= nil) then
					Spring.RemoveUnitCmdDesc(unitID, index)
				end
			end
			customCommandsDescriptions[internalCmdName] = nil -- registration and internalCmdName => cmdID mapping is kept, but cmdDescription is deleted
		end
	end,
	
	-- PUBLIC MODULE FUNCTIONS

	-- @description handler API used for getting unit by any means which (re)sets the system to proper state once called (by adding, removing or updating available commands)
	-- @argument unitID [number] Spring unitID
	-- @argument unitDefID [number] Spring unitDefID
	-- @argument teamID [number] Spring teamID
	["UnitIncomming"] = function(unitID, unitDefID, teamID)
		unitName = UnitDefs[unitDefID].name
		for internalCmdName, cmdDesc in pairs(customCommandsDescriptions) do
			if (customCommandsNameToTeamID[internalCmdName] == teamID) then -- if ownded by proper team
				local whitelist = customCommandsNameToWhitelist[internalCmdName]
				if (whitelist == nil or whitelist[unitName]) then -- if no whitelist (= all units) or unit on the whitelist
					local index = Spring.FindUnitCmdDesc(unitID, cmdDesc.id)
					if (index == nil) then -- if not added already
						Spring.InsertUnitCmdDesc(unitID, cmdDesc)
					else -- or update only
						Spring.EditUnitCmdDesc(unitID, index, cmdDesc)
					end
				end
			else -- for taken units remove invalid commands (owned only by donator)
				local index = Spring.FindUnitCmdDesc(unitID, cmdDesc.id)
				if (index ~= nil) then 
					Spring.RemoveUnitCmdDesc(unitID, index)
				end
			end
		end
	end,
}