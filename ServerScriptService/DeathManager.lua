-- @ScriptType: ModuleScript
-- ServerScriptService > DeathManager (ModuleScript)
local DeathManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- Create the remote event to trigger client visuals
local PlayDeathCinematic = Remotes:FindFirstChild("PlayDeathCinematic") or Instance.new("RemoteEvent")
PlayDeathCinematic.Name = "PlayDeathCinematic"
PlayDeathCinematic.Parent = Remotes

DeathManager.PendingDeaths = {}

function DeathManager.QueueDeath(targetPlayer)
	-- Add the victim to the queue
	table.insert(DeathManager.PendingDeaths, targetPlayer)
	print("[DEATH MANAGER] " .. targetPlayer.Name .. " queued for death.")
end

function DeathManager.PlayDeathSequence()
	-- If nobody died (e.g., time ran out or cycle skipped), skip the sequence
	if #DeathManager.PendingDeaths == 0 then return end

	print("[DEATH MANAGER] Playing death cinematics...")

	-- Tell all clients to play the cinematic. Pass the list of dying players so clients know who is having the heart attack.
	PlayDeathCinematic:FireAllClients(DeathManager.PendingDeaths)

	-- Wait exactly 4 seconds for the cinematic heart attack to play out
	task.wait(4)

	local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

	-- Officially kill them on the server
	for _, player in ipairs(DeathManager.PendingDeaths) do
		local role = RoleManager.GetPlayerRole(player)
		if role then
			role:Die() 
		end
	end

	-- Clear the queue for the next cycle
	DeathManager.PendingDeaths = {}
end

return DeathManager