-- @ScriptType: ModuleScript
-- ServerScriptService > WinManager (ModuleScript)
local WinManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GameOverEvent = Remotes:FindFirstChild("GameOverEvent") or Instance.new("RemoteEvent")
GameOverEvent.Name = "GameOverEvent"
GameOverEvent.Parent = Remotes

local WIN_APPLES = 50
local LOSS_APPLES = 10

function WinManager.CheckWinConditions()
	-- LAZY LOADED
	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

	local aliveKiras = 0
	local aliveCivilians = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local role = RoleManager.GetPlayerRole(player)
		if role and role.IsAlive then
			if role.Team == "Kira" then
				aliveKiras += 1
			else
				aliveCivilians += 1
			end
		end
	end

	if aliveKiras == 0 then return "Civilian"
	elseif aliveKiras >= aliveCivilians and aliveKiras > 0 then return "Kira" end

	return nil 
end

function WinManager.ProcessGameOver(winningTeam)
	print("[WIN MANAGER] GAME OVER! Winners: " .. winningTeam)
	GameOverEvent:FireAllClients(winningTeam)

	-- LAZY LOADED
	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))
	local DataManager = require(game.ServerScriptService:WaitForChild("DataManager"))
	local NetworkManager = require(game.ServerScriptService:WaitForChild("NetworkManager"))

	for _, player in ipairs(Players:GetPlayers()) do
		local role = RoleManager.GetPlayerRole(player)
		local profile = DataManager:GetProfile(player)

		if role and profile then
			profile.Data.GamesPlayed += 1

			if role.Team == winningTeam then
				profile.Data.Apples += WIN_APPLES
				if winningTeam == "Kira" then profile.Data.KiraWins += 1 else profile.Data.CivilianWins += 1 end
			else
				profile.Data.Apples += LOSS_APPLES
			end
			NetworkManager:ReplicateData(player)
		end
	end

	task.wait(8)
	return true
end

return WinManager