-- @ScriptType: LocalScript
-- StarterPlayerScripts > VictoryScreen (LocalScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GameOverEvent = Remotes:WaitForChild("GameOverEvent")

-- === UI BUILDER HELPERS (Keeping the gritty aesthetic) ===
local function createSharpFrame(name, size, position, bgColor)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = bgColor
	frame.BorderSizePixel = 0
	return frame
end

local function createGrittyText(name, size, position)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.Garamond
	label.TextScaled = true
	label.TextStrokeTransparency = 0 
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	return label
end

-- === BUILD THE HUD ===
local gui = Instance.new("ScreenGui")
gui.Name = "EndGameOverlay"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- The main backdrop that fades in
local backdrop = createSharpFrame("Backdrop", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(10, 10, 10))
backdrop.BackgroundTransparency = 1
backdrop.Parent = gui

-- The massive victory text
local titleText = createGrittyText("Title", UDim2.new(1, 0, 0, 100), UDim2.new(0, 0, 0.4, -50))
titleText.TextTransparency = 1
titleText.TextStrokeTransparency = 1
titleText.Parent = backdrop

-- The subtle subtitle for rewards
local subText = createGrittyText("Subtitle", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0.4, 60))
subText.TextTransparency = 1
subText.TextStrokeTransparency = 1
subText.TextColor3 = Color3.fromRGB(200, 200, 200)
subText.Parent = backdrop

-- === EVENT LISTENER ===
GameOverEvent.OnClientEvent:Connect(function(winningTeam)
	-- 1. Setup the aesthetics based on who won
	if winningTeam == "Kira" then
		titleText.Text = "KIRA WINS"
		titleText.TextColor3 = Color3.fromRGB(180, 10, 10) -- Grim Red
	else
		titleText.Text = "JUSTICE PREVAILS"
		titleText.TextColor3 = Color3.fromRGB(220, 220, 220) -- Cold Steel White
	end

	-- Note: The server handles the actual math for giving apples, this just lets them know
	subText.Text = "APPLES AWARDED. CHECK LOADOUT."

	-- 2. Fade in the background to hide the map
	local bgTweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local bgFade = TweenService:Create(backdrop, bgTweenInfo, {BackgroundTransparency = 0.1})
	bgFade:Play()

	task.wait(1)

	-- 3. Fade in the Text aggressively
	local textTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local titleFade = TweenService:Create(titleText, textTweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0})
	local subFade = TweenService:Create(subText, textTweenInfo, {TextTransparency = 0, TextStrokeTransparency = 0})

	titleFade:Play()
	subFade:Play()

	-- 4. Hold the screen so players can read it and the server has time to reset
	-- The WinManager waits 8 seconds total, so we wait 5 here.
	task.wait(5)

	-- 5. Fade to pitch black right as the server teleports everyone back to the lobby
	local pitchBlackTween = TweenService:Create(backdrop, TweenInfo.new(1), {BackgroundTransparency = 0})
	local textHideTween = TweenService:Create(titleText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1})
	local subHideTween = TweenService:Create(subText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1})

	textHideTween:Play()
	subHideTween:Play()
	pitchBlackTween:Play()

	task.wait(1.5)

	-- 6. Reset for the next game
	backdrop.BackgroundTransparency = 1
end)