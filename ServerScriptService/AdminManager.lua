-- @ScriptType: Script
-- ServerScriptService > AdminManager (Script)
local Players = game:GetService("Players")
local DataManager = require(game.ServerScriptService:WaitForChild("DataManager"))
local NetworkManager = require(game.ServerScriptService:WaitForChild("NetworkManager"))
local GameStateManager = require(game.ServerScriptService:WaitForChild("GameStateManager"))
local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

local RolesFolder = game.ServerScriptService:WaitForChild("Roles")
local KiraClass = require(RolesFolder:WaitForChild("Kira"))
local CivilianClass = require(RolesFolder:WaitForChild("Civilian"))
local LClass = require(RolesFolder:WaitForChild("L"))
local MelloClass = require(RolesFolder:WaitForChild("Mello"))

local Admins = {
	["gumelthemodeler"] = true,
	["girthbender1209"] = true,
	["slayerboy_epic"] = true
}

local PREFIX = "/"

local function ProcessCommand(player, message)
	if not Admins[player.Name] then return end

	local args = string.split(message, " ")
	local command = string.lower(args[1])

	if command == PREFIX .. "giveapples" then
		local targetName = args[2]
		local amount = tonumber(args[3])
		if targetName and amount then
			local targetPlayer = Players:FindFirstChild(targetName)
			if targetPlayer then
				local profile = DataManager:GetProfile(targetPlayer)
				if profile then
					profile.Data.Apples += amount
					NetworkManager:ReplicateData(targetPlayer)
					print("[ADMIN] Gave " .. amount .. " Apples to " .. targetPlayer.Name)
				end
			end
		end

	elseif command == PREFIX .. "giveperk" then
		local targetName = args[2]
		local perkName = args[3]
		if targetName and perkName then
			local targetPlayer = Players:FindFirstChild(targetName)
			if targetPlayer then
				local profile = DataManager:GetProfile(targetPlayer)
				if profile then
					profile.Data.UnlockedPerks[perkName] = true
					NetworkManager:ReplicateData(targetPlayer)
					print("[ADMIN] Unlocked perk '" .. perkName .. "' for " .. targetPlayer.Name)
				end
			end
		end

	elseif command == PREFIX .. "forcestate" then
		local newState = args[2]
		if newState then
			GameStateManager.SetState(newState)
			print("[ADMIN] " .. player.Name .. " forced game state to: " .. newState)
		end

	elseif command == PREFIX .. "setrole" then
		local targetName = args[2]
		local roleName = args[3]

		if targetName and roleName then
			local targetPlayer = Players:FindFirstChild(targetName)
			if targetPlayer then
				if string.lower(roleName) == "kira" then
					RoleManager.ActiveRoles[targetPlayer] = KiraClass.new(targetPlayer)
				elseif string.lower(roleName) == "l" then
					RoleManager.ActiveRoles[targetPlayer] = LClass.new(targetPlayer)
				elseif string.lower(roleName) == "mello" then
					RoleManager.ActiveRoles[targetPlayer] = MelloClass.new(targetPlayer)
				else
					RoleManager.ActiveRoles[targetPlayer] = CivilianClass.new(targetPlayer)
				end
				print("[ADMIN] Set " .. targetPlayer.Name .. "'s role to " .. roleName)
			end
		end

		-- NEW COMMAND: Start the Lobby sequence instantly
	elseif command == PREFIX .. "start" then
		local forceEvent = game.ServerScriptService.GameStateManager:FindFirstChild("ForceStartEvent")
		if forceEvent then
			forceEvent:Fire()
			print("[ADMIN] Forced the lobby sequence to begin!")
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		ProcessCommand(player, message)
	end)
end)