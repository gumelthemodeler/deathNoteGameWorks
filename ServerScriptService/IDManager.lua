-- @ScriptType: ModuleScript
-- ServerScriptService > IDManager (ModuleScript)
local IDManager = {}
local Players = game:GetService("Players")

-- A folder in Workspace containing parts where IDs can spawn
local SpawnLocations = workspace:WaitForChild("IDSpawns"):GetChildren() 

function IDManager.GenerateIDsForLobby()
	-- Clean up old IDs
	local oldIDs = workspace:FindFirstChild("ActiveIDs")
	if oldIDs then oldIDs:Destroy() end

	local activeIDsFolder = Instance.new("Folder")
	activeIDsFolder.Name = "ActiveIDs"
	activeIDsFolder.Parent = workspace

	local availableSpawns = {}
	for _, spawnPoint in ipairs(SpawnLocations) do
		table.insert(availableSpawns, spawnPoint)
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if #availableSpawns == 0 then
			warn("Not enough spawn locations for IDs!")
			break
		end

		-- Grab a random spawn and remove it from the available pool
		local randomIndex = math.random(1, #availableSpawns)
		local spawnLocation = availableSpawns[randomIndex]
		table.remove(availableSpawns, randomIndex)

		-- Create the physical ID 
		local newID = game.ServerStorage.Templates.IDTemplate:Clone()
		newID:SetAttribute("OwnerName", player.Name)
		newID:SetAttribute("OwnerID", player.UserId)
		newID:SetAttribute("Wiretapped", false)

		-- Position it slightly above the spawn part
		newID.CFrame = spawnLocation.CFrame * CFrame.new(0, 1, 0)
		newID.Parent = activeIDsFolder
	end

	print("[SYSTEM] All player IDs have been scattered.")
end

return IDManager