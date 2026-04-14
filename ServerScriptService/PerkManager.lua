-- @ScriptType: ModuleScript
-- ServerScriptService > PerkManager (ModuleScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataManager = require(script.Parent.DataManager)
local NetworkManager = require(script.Parent.NetworkManager)

local PerkManager = {}

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local EquipPerkRequest = Remotes:WaitForChild("EquipPerkRequest")

-- List of all valid perks in the game to prevent exploiting fake perk names
local ValidPerks = {
	["HighlightID"] = true, -- Civilian
	["ReplaceID"] = true,   -- Kira
	["FastResults"] = true, -- Mello
	["WiretapID"] = true    -- L
}

EquipPerkRequest.OnServerInvoke = function(player, slotNumber, perkName)
	-- 1. Validate the slot number (must be 1, 2, or 3)
	if type(slotNumber) ~= "number" or slotNumber < 1 or slotNumber > 3 then
		return false, "Invalid slot."
	end

	local profile = DataManager:GetProfile(player)
	if not profile then return false, "Data not loaded." end

	-- 2. Handle unequipping
	local slotString = "Slot" .. tostring(slotNumber)
	if perkName == "None" then
		profile.Data.EquippedPerks[slotString] = "None"
		NetworkManager:ReplicateData(player)
		return true, "Perk unequipped."
	end

	-- 3. Validate the perk exists in the game
	if not ValidPerks[perkName] then
		return false, "Perk does not exist."
	end

	-- 4. Verify the player actually owns the perk
	if not profile.Data.UnlockedPerks[perkName] then
		return false, "You do not own this perk."
	end

	-- 5. Prevent equipping the same perk in multiple slots
	for slot, equippedPerk in pairs(profile.Data.EquippedPerks) do
		if equippedPerk == perkName and slot ~= slotString then
			return false, "Perk already equipped in another slot."
		end
	end

	-- 6. Success! Update data and replicate to client
	profile.Data.EquippedPerks[slotString] = perkName
	NetworkManager:ReplicateData(player)

	return true, "Perk equipped successfully."
end

return PerkManager