-- @ScriptType: ModuleScript
-- ServerScriptService > Roles > Kira (ModuleScript)
local BaseRole = require(script.Parent:WaitForChild("BaseRole"))

local Kira = setmetatable({}, BaseRole)
Kira.__index = Kira

function Kira.new(player)
	local self = setmetatable(BaseRole.new(player), Kira)
	self.RoleName = "Kira"
	self.Team = "Kira"
	self.HasKilledThisCycle = false
	return self
end

local function VerifyFaceVisibility(kiraChar, targetChar)
	local kiraHead = kiraChar:FindFirstChild("Head")
	local targetHead = targetChar:FindFirstChild("Head")
	local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

	if not (kiraHead and targetHead and targetHRP) then return false end

	local directionToKira = (kiraHead.Position - targetHead.Position).Unit
	local targetLookVector = targetHRP.CFrame.LookVector

	if targetLookVector:Dot(directionToKira) < 0 then return false end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {kiraChar}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local rayDirection = targetHead.Position - kiraHead.Position
	local rayResult = workspace:Raycast(kiraHead.Position, rayDirection, raycastParams)

	if rayResult then
		if rayResult.Instance:IsDescendantOf(targetChar) then return true else return false end
	end
	return false
end

function Kira:WriteInNotebook(targetPlayer, targetID)
	if not self.IsAlive then return false, "You are dead." end
	if self.HasKilledThisCycle then return false, "You can only kill once per cycle." end
	if not targetPlayer then return false, "Invalid target." end

	local kiraChar = self.Player.Character
	local targetChar = targetPlayer.Character
	if not kiraChar or not targetChar then return false, "Characters not found." end

	local hasSeenFace = VerifyFaceVisibility(kiraChar, targetChar)

	if hasSeenFace then
		self.HasKilledThisCycle = true
		print("[KIRA] " .. self.Player.Name .. " has written " .. targetPlayer.Name .. "'s name!")

		-- QUEUE THE DEATH
		local DeathManager = require(game.ServerScriptService:WaitForChild("DeathManager"))
		DeathManager.QueueDeath(targetPlayer)

		local gsm = game.ServerScriptService:WaitForChild("GameStateManager")
		local killEvent = gsm:FindFirstChild("KiraExecutedKillEvent")
		if killEvent then killEvent:Fire() end

		return true, "Target marked for death."
	else
		return false, "You must see their face and have clear line of sight."
	end
end

function Kira:ResetCycle()
	self.HasKilledThisCycle = false
end

return Kira