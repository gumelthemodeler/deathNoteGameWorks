-- @ScriptType: LocalScript
-- StarterPlayerScripts > DeathCinematics (LocalScript)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PlayDeathCinematic = Remotes:WaitForChild("PlayDeathCinematic")

-- Create the blood-red vignette overlay
local gui = Instance.new("ScreenGui")
gui.Name = "DeathOverlay"
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local vignette = Instance.new("Frame")
vignette.Size = UDim2.new(1, 0, 1, 0)
vignette.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
vignette.BackgroundTransparency = 1
vignette.BorderSizePixel = 0
vignette.Parent = gui

PlayDeathCinematic.OnClientEvent:Connect(function(dyingPlayers)
	-- Check if the local player is one of the victims
	local isDying = false
	for _, p in ipairs(dyingPlayers) do
		if p == player then
			isDying = true
			break
		end
	end

	local camera = workspace.CurrentCamera
	local originalFOV = camera.FieldOfView

	if isDying then
		-- 1. Heart Attack Visuals for the Victim
		-- Heartbeat zoom effect
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 6, true)
		local fovTween = TweenService:Create(camera, tweenInfo, {FieldOfView = 50})

		-- Red screen fade
		local colorTweenInfo = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local fadeTween = TweenService:Create(vignette, colorTweenInfo, {BackgroundTransparency = 0.2})

		fovTween:Play()
		fadeTween:Play()

		-- Simulate falling/stumbling by removing humanoid control
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 0
			player.Character.Humanoid.JumpPower = 0
		end

		task.wait(3.5)

		-- Fade to black just before they actually die
		local blackFadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear)
		local blackFade = TweenService:Create(vignette, blackFadeInfo, {BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0})
		blackFade:Play()

		task.wait(1)
		vignette.BackgroundTransparency = 1 -- Reset for next round

	else
		-- 2. Survivor Visuals (Optional: A slight camera jolt or a global heartbeat sound)
		local joltInfo = TweenInfo.new(0.1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 1, true)
		local joltTween = TweenService:Create(camera, joltInfo, {FieldOfView = 75})
		joltTween:Play()
	end
end)