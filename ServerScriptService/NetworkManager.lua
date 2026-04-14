-- @ScriptType: ModuleScript
-- ServerScriptService > NetworkManager (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.DataManager)

local NetworkManager = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DataUpdateEvent = Remotes:WaitForChild("DataUpdateEvent")
local GetInitialData = Remotes:WaitForChild("GetInitialData")

-- Allows the client to request its data right when it loads in
GetInitialData.OnServerInvoke = function(player)
	local profile = DataManager:GetProfile(player)
	if profile then
		return profile.Data
	end
	return nil
end

-- Call this function whenever we change a player's data on the server
function NetworkManager:ReplicateData(player)
	local profile = DataManager:GetProfile(player)
	if profile then
		DataUpdateEvent:FireClient(player, profile.Data)
	end
end

return NetworkManager