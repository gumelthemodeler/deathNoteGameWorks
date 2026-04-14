-- @ScriptType: ModuleScript
-- ServerScriptService > Roles > BaseRole (ModuleScript)
local BaseRole = {}
BaseRole.__index = BaseRole

function BaseRole.new(player)
	local self = setmetatable({}, BaseRole)
	self.Player = player
	self.RoleName = "Unassigned"
	self.Team = "Neutral"
	self.IsAlive = true
	self.CurrentID = nil 

	return self
end

function BaseRole:PickUpID(idObject)
	if not self.IsAlive then return false end
	self.CurrentID = idObject
	print(self.Player.Name .. " picked up an ID.")
	return true
end

function BaseRole:Die()
	self.IsAlive = false

	-- Physically kill the Roblox character
	if self.Player and self.Player.Character then
		local humanoid = self.Player.Character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end

	-- Drop their ID if they were holding one
	if self.CurrentID then
		self.CurrentID.Parent = workspace.ActiveIDs
		-- Reset position to where they died
		if self.Player.Character and self.Player.Character.PrimaryPart then
			self.CurrentID.CFrame = self.Player.Character.PrimaryPart.CFrame * CFrame.new(0, -1, 0)
		end
		self.CurrentID = nil
	end

	print("[SYSTEM] " .. self.Player.Name .. " has died.")
end

return BaseRole