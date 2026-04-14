-- @ScriptType: ModuleScript
-- ServerScriptService > VotingManager (ModuleScript)
local VotingManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CastVoteEvent = Remotes:FindFirstChild("CastVoteEvent") or Instance.new("RemoteEvent")
CastVoteEvent.Name = "CastVoteEvent"
CastVoteEvent.Parent = Remotes

local UpdateVotingUIEvent = Remotes:FindFirstChild("UpdateVotingUIEvent") or Instance.new("RemoteEvent")
UpdateVotingUIEvent.Name = "UpdateVotingUIEvent"
UpdateVotingUIEvent.Parent = Remotes

VotingManager.Votes = {} 
VotingManager.IsVotingActive = false

function VotingManager.StartVoting()
	VotingManager.Votes = {}
	VotingManager.IsVotingActive = true

	-- LAZY LOADED
	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

	local alivePlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		local role = RoleManager.GetPlayerRole(player)
		if role and role.IsAlive then
			table.insert(alivePlayers, player.Name)
		end
	end

	UpdateVotingUIEvent:FireAllClients("Start", alivePlayers)
	print("[VOTING] Meeting started. Awaiting votes.")
end

CastVoteEvent.OnServerEvent:Connect(function(player, targetName)
	if not VotingManager.IsVotingActive then return end

	-- LAZY LOADED
	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

	local role = RoleManager.GetPlayerRole(player)
	if not role or not role.IsAlive then return end 

	VotingManager.Votes[player.Name] = targetName
	print("[VOTING] " .. player.Name .. " voted for " .. targetName)
end)

function VotingManager.EndVotingAndTally()
	VotingManager.IsVotingActive = false
	UpdateVotingUIEvent:FireAllClients("End")

	-- LAZY LOADED
	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

	local voteCounts = { ["Skip"] = 0 }
	local highestVotes = 0
	local playerToExecute = nil
	local tie = false

	for voter, target in pairs(VotingManager.Votes) do
		if not voteCounts[target] then voteCounts[target] = 0 end
		voteCounts[target] += 1
	end

	for target, count in pairs(voteCounts) do
		if count > highestVotes then
			highestVotes = count
			playerToExecute = target
			tie = false
		elseif count == highestVotes then
			tie = true
		end
	end

	if tie or playerToExecute == "Skip" or playerToExecute == nil then
		print("[VOTING] Voting ended in a tie or skip. No one is executed.")
		return nil
	else
		print("[VOTING] The server has decided to execute: " .. playerToExecute)

		local executedTarget = Players:FindFirstChild(playerToExecute)
		if executedTarget then
			local role = RoleManager.GetPlayerRole(executedTarget)
			if role then role:Die() end
		end

		return playerToExecute
	end
end

return VotingManager