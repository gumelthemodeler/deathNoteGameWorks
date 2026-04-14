-- @ScriptType: ModuleScript
-- ServerScriptService > Roles > Mello (ModuleScript)
local BaseRole = require(script.Parent.BaseRole)

local Mello = setmetatable({}, BaseRole)
Mello.__index = Mello

function Mello.new(player)
	local self = setmetatable(BaseRole.new(player), Mello)
	self.RoleName = "Mello"
	self.Team = "Civilian"
	self.PendingInvestigation = nil 
	return self
end

function Mello:QueueInvestigation(targetID)
	local idOwner = targetID:GetAttribute("OwnerName")
	self.PendingInvestigation = idOwner
	print("[MELLO] Queued investigation on: " .. tostring(idOwner) .. " for next round.")
end

function Mello:ProcessPendingInvestigation()
	if self.PendingInvestigation then
		-- TODO: Check if PendingInvestigation is Kira. If yes, grant Mello the gun.
		print("[MELLO] Processing results for: " .. self.PendingInvestigation)
		self.PendingInvestigation = nil
	end
end

return Mello