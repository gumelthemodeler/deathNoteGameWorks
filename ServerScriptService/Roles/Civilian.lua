-- @ScriptType: ModuleScript
-- ServerScriptService > Roles > Civilian (ModuleScript)
local BaseRole = require(script.Parent.BaseRole)

local Civilian = setmetatable({}, BaseRole)
Civilian.__index = Civilian

function Civilian.new(player)
	local self = setmetatable(BaseRole.new(player), Civilian)
	self.RoleName = "Civilian"
	self.Team = "Civilian"
	return self
end

-- Perk interaction: Highlight ID
function Civilian:HighlightOwnID()
	if not self.CurrentID then return false, "You don't have an ID to highlight." end
	-- TODO: Fire remote to client to render a sharp-edged, colored outline ESP around their ID
	return true, "ID Highlighted."
end

return Civilian