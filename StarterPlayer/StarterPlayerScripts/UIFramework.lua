-- @ScriptType: LocalScript
-- StarterPlayerScripts > UIFramework (LocalScript)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local MainGui = Instance.new("ScreenGui")
MainGui.Name = "DeathNoteHUD"
MainGui.ResetOnSpawn = false
MainGui.IgnoreGuiInset = true
MainGui.Parent = playerGui

-- === THE BUILDER FUNCTIONS ===
-- These ensure a uniform, sharp, and gritty aesthetic across the entire game.

local function createSharpFrame(name, size, position, bgColor, outlineColor)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = bgColor or Color3.fromRGB(15, 15, 15) -- Very dark grey/black

	-- Strict sharp edges with distinct colored outlines
	frame.BorderSizePixel = 2
	frame.BorderColor3 = outlineColor or Color3.fromRGB(100, 10, 10) -- Default grim red

	return frame
end

local function createGrittyText(name, text, size, position, alignment)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.Garamond -- Fits a medieval/rustic grim aesthetic
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextScaled = true
	label.TextXAlignment = alignment or Enum.TextXAlignment.Center

	-- Dark stroke to make the steel-like text pop against any background
	label.TextStrokeTransparency = 0 
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

	return label
end

-- === HUD CONSTRUCTION ===

local function BuildActionHUD()
	-- Main container for the bottom-right corner
	local hudContainer = createSharpFrame("HUDContainer", 
		UDim2.new(0, 320, 0, 120), 
		UDim2.new(1, -340, 1, -140), 
		Color3.fromRGB(10, 10, 10), 
		Color3.fromRGB(150, 0, 0) -- Sharp red outline
	)
	hudContainer.Parent = MainGui

	-- Role Display Text
	local roleLabel = createGrittyText("RoleText", "ROLE: UNASSIGNED", 
		UDim2.new(1, -20, 0, 30), 
		UDim2.new(0, 10, 0, 5),
		Enum.TextXAlignment.Left
	)
	roleLabel.Parent = hudContainer

	-- Perk Loadout Boxes (3 Slots)
	for i = 1, 3 do
		-- Create the sharp perk boxes with a subtle grey outline until active
		local perkBox = createSharpFrame("PerkSlot" .. i, 
			UDim2.new(0, 80, 0, 60), 
			UDim2.new(0, 10 + ((i-1) * 90), 0, 45), 
			Color3.fromRGB(25, 25, 25), 
			Color3.fromRGB(60, 60, 60)
		)
		perkBox.Parent = hudContainer

		local perkText = createGrittyText("PerkName", "EMPTY", 
			UDim2.new(1, -4, 1, -4), 
			UDim2.new(0, 2, 0, 2)
		)
		perkText.Parent = perkBox
	end

	return hudContainer, roleLabel
end

-- Initialize the visual elements
local ActionHUD, RoleTextLabel = BuildActionHUD()

-- === NETWORKING INTEGRATION ===
-- Listen to the DataManager we built earlier to update the UI
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DataUpdateEvent = Remotes:WaitForChild("DataUpdateEvent")

DataUpdateEvent.OnClientEvent:Connect(function(updatedData)
	-- Update the perk boxes dynamically when data changes
	for i = 1, 3 do
		local slotName = "Slot" .. tostring(i)
		local equippedPerk = updatedData.EquippedPerks[slotName]
		local perkBox = ActionHUD:FindFirstChild("PerkSlot" .. i)

		if perkBox then
			perkBox.PerkName.Text = equippedPerk

			-- Visually highlight the box with a colored outline if a perk is equipped
			if equippedPerk ~= "None" then
				perkBox.BorderColor3 = Color3.fromRGB(150, 0, 0)
			else
				perkBox.BorderColor3 = Color3.fromRGB(60, 60, 60)
			end
		end
	end
end)

-- === VOTING UI CONSTRUCTION ===
local CastVoteEvent = Remotes:WaitForChild("CastVoteEvent")
local UpdateVotingUIEvent = Remotes:WaitForChild("UpdateVotingUIEvent")

local VotingContainer = nil

local function BuildVotingScreen(alivePlayers)
	if VotingContainer then VotingContainer:Destroy() end

	-- Deep dark backdrop taking up most of the screen
	VotingContainer = createSharpFrame("VotingScreen", 
		UDim2.new(0, 600, 0, 400), 
		UDim2.new(0.5, -300, 0.5, -200), 
		Color3.fromRGB(15, 15, 15), 
		Color3.fromRGB(120, 10, 10) -- Grim red outline
	)
	VotingContainer.Parent = MainGui

	local title = createGrittyText("Title", "WHO IS KIRA?", 
		UDim2.new(1, 0, 0, 40), 
		UDim2.new(0, 0, 0, 10)
	)
	title.Parent = VotingContainer

	-- Scrolling Frame to hold player names (sharp edges, hidden scrollbar)
	local scrollList = Instance.new("ScrollingFrame")
	scrollList.Size = UDim2.new(1, -40, 1, -120)
	scrollList.Position = UDim2.new(0, 20, 0, 60)
	scrollList.BackgroundTransparency = 1
	scrollList.BorderSizePixel = 0
	scrollList.ScrollBarThickness = 4
	scrollList.ScrollBarImageColor3 = Color3.fromRGB(120, 10, 10)
	scrollList.Parent = VotingContainer

	-- Grid Layout for the voting boxes
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 270, 0, 50)
	grid.CellPadding = UDim2.new(0, 10, 0, 10)
	grid.Parent = scrollList

	-- Create a sharp button for every alive player
	for _, playerName in ipairs(alivePlayers) do
		-- Using TextButton instead of Frame so it can be clicked
		local playerBtn = Instance.new("TextButton")
		playerBtn.Name = playerName
		playerBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		playerBtn.BorderSizePixel = 2
		playerBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		playerBtn.Text = "" -- We use a custom label for the gritty font
		playerBtn.Parent = scrollList

		local nameLabel = createGrittyText("NameLabel", playerName, 
			UDim2.new(1, -20, 1, 0), 
			UDim2.new(0, 10, 0, 0),
			Enum.TextXAlignment.Left
		)
		nameLabel.Parent = playerBtn

		-- Hover and Click Effects
		playerBtn.MouseEnter:Connect(function()
			playerBtn.BorderColor3 = Color3.fromRGB(150, 150, 150)
		end)
		playerBtn.MouseLeave:Connect(function()
			playerBtn.BorderColor3 = Color3.fromRGB(60, 60, 60)
		end)

		playerBtn.MouseButton1Click:Connect(function()
			CastVoteEvent:FireServer(playerName)
			-- Visual feedback that vote was cast
			playerBtn.BorderColor3 = Color3.fromRGB(150, 0, 0)
			title.Text = "VOTE CAST: " .. string.upper(playerName)
		end)
	end

	-- The SKIP Button at the bottom
	local skipBtn = Instance.new("TextButton")
	skipBtn.Size = UDim2.new(0, 200, 0, 40)
	skipBtn.Position = UDim2.new(0.5, -100, 1, -50)
	skipBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	skipBtn.BorderSizePixel = 2
	skipBtn.BorderColor3 = Color3.fromRGB(80, 80, 80)
	skipBtn.Text = ""
	skipBtn.Parent = VotingContainer

	local skipLabel = createGrittyText("SkipLabel", "SKIP VOTE", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
	skipLabel.Parent = skipBtn

	skipBtn.MouseButton1Click:Connect(function()
		CastVoteEvent:FireServer("Skip")
		skipBtn.BorderColor3 = Color3.fromRGB(150, 0, 0)
		title.Text = "VOTE CAST: SKIP"
	end)
end

-- Listen for the server telling us to open/close the voting screen
UpdateVotingUIEvent.OnClientEvent:Connect(function(action, alivePlayers)
	if action == "Start" then
		BuildVotingScreen(alivePlayers)
	elseif action == "End" then
		if VotingContainer then
			VotingContainer:Destroy()
			VotingContainer = nil
		end
	end
end)

-- === TASK UI CONSTRUCTION ===
local UpdateTaskUIEvent = Remotes:WaitForChild("UpdateTaskUIEvent")

-- Create the sharp container in the top-left of the screen
local TaskContainer = createSharpFrame("TaskContainer", 
	UDim2.new(0, 250, 0, 150), 
	UDim2.new(0, 20, 0, 20), 
	Color3.fromRGB(15, 15, 15), 
	Color3.fromRGB(80, 80, 80) -- Cold steel outline
)
TaskContainer.Parent = MainGui

local TaskHeader = createGrittyText("TaskHeader", "OBJECTIVES", 
	UDim2.new(1, 0, 0, 30), 
	UDim2.new(0, 0, 0, 5)
)
TaskHeader.Parent = TaskContainer

-- Global Progress Bar Background (Sharp edges)
local BarBG = createSharpFrame("GlobalTaskBarBG", 
	UDim2.new(1, -20, 0, 15), 
	UDim2.new(0, 10, 0, 40), 
	Color3.fromRGB(5, 5, 5), 
	Color3.fromRGB(40, 40, 40)
)
BarBG.Parent = TaskContainer

-- Global Progress Bar Fill
local BarFill = Instance.new("Frame")
BarFill.Name = "Fill"
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(30, 150, 30) -- Toxic/Gritty Green
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBG

-- Scrolling frame to hold the text list of tasks
local TaskListLayout = Instance.new("ScrollingFrame")
TaskListLayout.Size = UDim2.new(1, -20, 1, -70)
TaskListLayout.Position = UDim2.new(0, 10, 0, 65)
TaskListLayout.BackgroundTransparency = 1
TaskListLayout.BorderSizePixel = 0
TaskListLayout.ScrollBarThickness = 2
TaskListLayout.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
TaskListLayout.Parent = TaskContainer

local ListLogic = Instance.new("UIListLayout")
ListLogic.Padding = UDim.new(0, 5)
ListLogic.Parent = TaskListLayout

UpdateTaskUIEvent.OnClientEvent:Connect(function(assignedTasks, globalCompleted, globalRequired)
	-- Clear old list
	for _, child in ipairs(TaskListLayout:GetChildren()) do
		if child:IsA("TextLabel") then child:Destroy() end
	end

	-- Populate new list
	for _, taskName in ipairs(assignedTasks) do
		local tLabel = createGrittyText(taskName, 
			UDim2.new(1, 0, 0, 20), 
			UDim2.new(0, 0, 0, 0),
			Enum.TextXAlignment.Left
		)
		tLabel.Text = "> " .. taskName
		tLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		tLabel.Parent = TaskListLayout
	end

	-- Update global bar math
	local fillPercentage = 0
	if globalRequired > 0 then
		fillPercentage = globalCompleted / globalRequired
	end

	BarFill.Size = UDim2.new(fillPercentage, 0, 1, 0)

	-- If they finished all personal tasks, turn their header green
	if #assignedTasks == 0 then
		TaskHeader.TextColor3 = Color3.fromRGB(30, 150, 30)
		TaskHeader.Text = "OBJECTIVES COMPLETE"
	else
		TaskHeader.TextColor3 = Color3.fromRGB(220, 220, 220)
		TaskHeader.Text = "OBJECTIVES"
	end
end)