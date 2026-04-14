-- @ScriptType: Script
-- ServerScriptService > IDInteractionManager (Script)
local Players = game:GetService("Players")
local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

-- This function will be called by our IDManager right after an ID is spawned
local function SetupIDInteraction(idModel)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Examine"
	prompt.ObjectText = "Dropped ID"
	prompt.HoldDuration = 0.5
	prompt.RequiresLineOfSight = true -- Forces players to actually look at it
	prompt.MaxActivationDistance = 8
	prompt.Parent = idModel.PrimaryPart or idModel

	prompt.Triggered:Connect(function(player)
		-- 1. Get the player's active OOP role class
		local role = RoleManager.GetPlayerRole(player)
		if not role or not role.IsAlive then return end

		-- 2. Route the action based on their specific role
		if role.RoleName == "Civilian" or role.RoleName == "Kira" then
			-- Civilians and Kira both just pick up the ID
			local success, msg = role:PickUpID(idModel)
			if success then
				idModel.Parent = game.ServerStorage -- Hide it from the map securely
				prompt.Enabled = false
			end

		elseif role.RoleName == "L" then
			-- L scans the ID immediately
			role:ScanID(idModel)
			-- L does not pick it up, leaving it as bait

		elseif role.RoleName == "Mello" then
			-- Mello queues it for the next round
			role:QueueInvestigation(idModel)
		end
	end)
end

-- If we go back to our IDManager module, we would call `SetupIDInteraction(newID)` 
-- right after parenting the newID to the ActiveIDs folder.