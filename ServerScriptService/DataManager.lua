-- @ScriptType: ModuleScript
-- ServerScriptService > DataManager (ModuleScript)
local DataManager = {}

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore("DeathNoteData_v1")

DataManager.Profiles = {}

-- The default save file
local ProfileTemplate = {
	Apples = 0,               
	PremiumCoins = 0,         
	UnlockedPerks = {},       
	EquippedPerks = {         
		Slot1 = "None",
		Slot2 = "None",
		Slot3 = "None"
	},
	UnlockedEmotes = {},
	EquippedEmotes = {},
	EquippedShinigami = "None",
	GamesPlayed = 0,
	KiraWins = 0,
	CivilianWins = 0
}

-- Helper function to deep copy the template
local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then v = DeepCopy(v) else copy[k] = v end
	end
	return copy
end

local function PlayerAdded(player)
	local data = nil
	local success, err = pcall(function()
		data = PlayerDataStore:GetAsync("Player_" .. player.UserId)
	end)

	-- Load existing data or give them the template
	local profileData = data or DeepCopy(ProfileTemplate)

	-- Reconcile missing keys (in case we add new stuff to the template later)
	for k, v in pairs(ProfileTemplate) do
		if profileData[k] == nil then profileData[k] = v end
	end

	-- Wrap it to match our previous structure so other scripts don't break
	DataManager.Profiles[player] = { Data = profileData }
	print("[DATA] Loaded profile for " .. player.Name)
end

local function PlayerRemoving(player)
	local profile = DataManager.Profiles[player]
	if profile then
		local success, err = pcall(function()
			PlayerDataStore:SetAsync("Player_" .. player.UserId, profile.Data)
		end)
		if success then
			print("[DATA] Saved profile for " .. player.Name)
		else
			warn("[DATA] Failed to save for " .. player.Name .. ": " .. tostring(err))
		end
		DataManager.Profiles[player] = nil
	end
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

-- Public function to get a player's data
function DataManager:GetProfile(player)
	return self.Profiles[player]
end

return DataManager