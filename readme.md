customCommands 3.0.1
===

This modu#le allows you to

* define custom commands as players from widgets
* module backend handles
  * registration/unregistration of commands
  * informing rest of the game synced way about changes and stored synced list of all commands readable by their owners
  * informing unsynced modules (UI, custom widgets) about changes via unsynced handlers

  
Actual development references
---

* this [trello task](https://trello.com/c/3LCxnPjX/) - there you find also example widget using this technology
 
Mandatory to access the API of custom commands module
---

1. have game compatible with notAmodules (TBD, link)
2. use next code in any gadget or widget where you plan to utilize customCommands
	* it implies also having "message" module as dependency (and its dependencies) (TBD, link)

```
-- get madatory module operators
VFS.Include("LuaRules/modules.lua") -- modules table
VFS.Include(modules.attach.data.path .. modules.attach.data.head) -- attach lib module

-- get other madatory dependencies
attach.Module(modules, "message") -- communication backend load
attach.Module(modules, "customCommands") -- this module load
```

Widget developers just care about using this code, because it is up to game developer to provide all dependencies


Registering one command
---

```
sendCustomMessage.RegisterCustomCommand({
	type = CMDTYPE.ICON_MAP,
	name = 'Convoy',
	cursor = 'Attack',
	action = 'Convoy',
	tooltip = 'Some convoy behavior',
	hidden = false,
	UIoverride = { texture = 'LuaUI/Images/commands/bold/sprint.png' },
	whitelist = {armpw} -- optional
	
	-- there are also some optional items, check more in example widget
})
```

Reading full commands Name to ID mapping
---

As key we use for mapping we take string you sent as name in a command definition, e.g. `name = 'Convoy',`

```
local rawCustomCommandsList = Spring.GetTeamRulesParam(Spring.GetMyTeamID(), "CustomCommandsNameToID")
if (rawCustomCommandsList ~= nil) then		
	local fullMapping = message.Decode(rawCustomCommandsList)
end
```

But you can just check notification messages (containing only name and id of the newly registered command) which you access next way:

```
-- EVENT HANDLING SYSTEM EXAMPLE

function CustomCommandRegistered(cmdName, cmdID)
	Spring.Echo("Command [" .. cmdName .. "] was registered under ID [" .. cmdID .. "]")
end

function widget:Initialize ()
	widgetHandler:RegisterGlobal('CustomCommandRegistered', CustomCommandRegistered)
end
```

Deregistering
---

Happens via just sending the name of the command you want to deregister

```
sendCustomMessage.DeregisterCustomCommand(cmdDesc.name)
```

Updating existing command parameters
---

Happens same as registration

1) send your data again via `sendCustomMessage.RegisterCustomCommand` and the overwrite happens internally
2) you are informed by new event `CustomCommandRegistered` about update

Limitations
---

* currenlty constants not exposed for customizing (e.g. ID index counter, max commands per player, etc.)
* currenlty prepare UI update data for one UI framework (Chili NOTA UI), but do limit user to use own system (optional registration parameters allows you to use default spring system extensivelly)