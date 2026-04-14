-- @ScriptType: LocalScript
-- StarterPlayerScripts > GameFlowUI (LocalScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GameStateSync = Remotes:WaitForChild("GameStateSync")
local SubmitLobbyVote = Remotes:WaitForChild("SubmitLobbyVote")

-- === GRITTY UI BUILDERS ===
local function createSharpFrame(name, size, position, bgColor, outlineColor)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(15, 15, 15)
	frame.BorderSizePixel = 2
	frame.BorderColor3 = outlineColor or Color3.fromRGB(60, 60, 60)
	return frame
end

local function createGrittyText(name, text, size, position)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Garamond
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextScaled = true
	label.TextStrokeTransparency = 0 
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	return label
end

-- === MAIN GUI SETUP ===
local gui = Instance.new("ScreenGui")
gui.Name = "GameFlowHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local MainContainer = createSharpFrame("Container", UDim2.new(0, 500, 0, 350), UDim2.new(0.5, -250, 0.4, -175))
MainContainer.Visible = false
MainContainer.Parent = gui

local HeaderText = createGrittyText("Header", "INTERMISSION", UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 10))
HeaderText.Parent = MainContainer

local TimerText = createGrittyText("Timer", "0.0", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 60))
TimerText.TextColor3 = Color3.fromRGB(180, 10, 10) -- Blood red timer
TimerText.Parent = MainContainer

local VotingFrame = Instance.new("Frame")
VotingFrame.Size = UDim2.new(1, 0, 1, -110)
VotingFrame.Position = UDim2.new(0, 0, 0, 110)
VotingFrame.BackgroundTransparency = 1
VotingFrame.Visible = false
VotingFrame.Parent = MainContainer

-- Timer Logic
local countdownActive = false
local endTime = 0

RunService.RenderStepped:Connect(function()
	if countdownActive then
		local timeLeft = endTime - os.clock()
		if timeLeft > 0 then
			TimerText.Text = string.format("%.1f", timeLeft)
		else
			TimerText.Text = "0.0"
			countdownActive = false
		end
	end
end)

-- Helper to create voting buttons
local function buildVoteButtons(options, parentFrame, positionX, category)
	local yOffset = 0
	local buttons = {}

	local title = createGrittyText("CatTitle", category, UDim2.new(0, 200, 0, 30), UDim2.new(positionX, 0, 0, 0))
	title.Parent = parentFrame

	for _, option in ipairs(options) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 200, 0, 40)
		btn.Position = UDim2.new(positionX, 0, 0, 40 + yOffset)
		btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		btn.BorderSizePixel = 2
		btn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		btn.Text = ""
		btn.Parent = parentFrame

		local label = createGrittyText("Label", option, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
		label.Parent = btn
		table.insert(buttons, btn)

		btn.MouseButton1Click:Connect(function()
			-- Deselect others in category
			for _, b in ipairs(buttons) do b.BorderColor3 = Color3.fromRGB(60, 60, 60) end
			-- Select this one
			btn.BorderColor3 = Color3.fromRGB(180, 10, 10)
			-- Tell server
			SubmitLobbyVote:FireServer(category, option)
		end)

		yOffset += 50
	end
end

buildVoteButtons({"Classic", "X-Kira", "Misa"}, VotingFrame, 0.1, "GAMEMODE")
buildVoteButtons({"Warehouse", "City Streets", "Headquarters"}, VotingFrame, 0.5, "MAP")

-- === STATE LISTENER ===
GameStateSync.OnClientEvent:Connect(function(state, duration)
	if state == "Intermission" then
		MainContainer.Visible = true
		VotingFrame.Visible = false
		HeaderText.Text = "INTERMISSION"
		endTime = os.clock() + duration
		countdownActive = true

	elseif state == "Voting" then
		MainContainer.Visible = true
		VotingFrame.Visible = true
		HeaderText.Text = "VOTE NOW"
		endTime = os.clock() + duration
		countdownActive = true

		-- Reset button colors for a new vote
		for _, desc in ipairs(VotingFrame:GetDescendants()) do
			if desc:IsA("TextButton") then desc.BorderColor3 = Color3.fromRGB(60, 60, 60) end
		end

	elseif state == "Action" or state == "Lobby" then
		MainContainer.Visible = false
		countdownActive = false
	end
end)