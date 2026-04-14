-- @ScriptType: ModuleScript
-- ServerScriptService > RoleManager (ModuleScript)
local RoleManager = {}

RoleManager.ActiveRoles = {} 

function RoleManager.AssignRoles(gamemode, playersList)
	RoleManager.ActiveRoles = {}
	local shuffledPlayers = {}

	-- LAZY LOADED 
	local RolesFolder = script.Parent:WaitForChild("Roles")
	local KiraClass = require(RolesFolder:WaitForChild("Kira"))
	local CivilianClass = require(RolesFolder:WaitForChild("Civilian"))
	local LClass = require(RolesFolder:WaitForChild("L"))
	local MelloClass = require(RolesFolder:WaitForChild("Mello"))

	for _, p in ipairs(playersList) do table.insert(shuffledPlayers, p) end
	for i = #shuffledPlayers, 2, -1 do
		local j = math.random(i)
		shuffledPlayers[i], shuffledPlayers[j] = shuffledPlayers[j], shuffledPlayers[i]
	end

	if gamemode == "Classic" then
		for i, player in ipairs(shuffledPlayers) do
			if i == 1 then
				RoleManager.ActiveRoles[player] = KiraClass.new(player)
			elseif i == 2 then
				RoleManager.ActiveRoles[player] = LClass.new(player)
			elseif i == 3 then
				RoleManager.ActiveRoles[player] = MelloClass.new(player)
			else
				RoleManager.ActiveRoles[player] = CivilianClass.new(player)
			end
		end
	end

	print("[SYSTEM] Roles have been distributed for gamemode: " .. gamemode)
end

function RoleManager.GetPlayerRole(player)
	return RoleManager.ActiveRoles[player]
end

return RoleManager