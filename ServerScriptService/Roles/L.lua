-- @ScriptType: ModuleScript
-- ServerScriptService > Roles > L (ModuleScript)
local BaseRole = require(script.Parent.BaseRole)

local L = setmetatable({}, BaseRole)
L.__index = L

function L.new(player)
	local self = setmetatable(BaseRole.new(player), L)
	self.RoleName = "L"
	self.Team = "Civilian"
	return self
end

function L:ScanID(targetID)
	-- Checks the ID's assigned owner to see if they are Kira
	local idOwner = targetID:GetAttribute("OwnerName")
	-- We will query the RoleManager later to check this player's actual role
	print("[L-SCAN] Scanning ID belonging to: " .. tostring(idOwner))
	return true
end

function L:WiretapID(targetID)
	-- Perk interaction
	targetID:SetAttribute("Wiretapped", true)
	return true, "ID Wiretapped."
end

return L