-- @ScriptType: ModuleScript
-- ServerScriptService > GameStateManager (ModuleScript)
local GameStateManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateChanged = Instance.new("BindableEvent")

local KiraExecutedKill = script:FindFirstChild("KiraExecutedKillEvent") or Instance.new("BindableEvent")
KiraExecutedKill.Name = "KiraExecutedKillEvent"
KiraExecutedKill.Parent = script

local ForceStartEvent = script:FindFirstChild("ForceStartEvent") or Instance.new("BindableEvent")
ForceStartEvent.Name = "ForceStartEvent"
ForceStartEvent.Parent = script

-- NEW: Network event to sync the timer and UI with the clients
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GameStateSync = Remotes:FindFirstChild("GameStateSync") or Instance.new("RemoteEvent")
GameStateSync.Name = "GameStateSync"
GameStateSync.Parent = Remotes

-- NEW: Network event to catch the client's votes
local SubmitLobbyVote = Remotes:FindFirstChild("SubmitLobbyVote") or Instance.new("RemoteEvent")
SubmitLobbyVote.Name = "SubmitLobbyVote"
SubmitLobbyVote.Parent = Remotes

GameStateManager.CurrentState = "Lobby"
GameStateManager.CurrentGamemode = "Classic"
GameStateManager.MinPlayers = 4
GameStateManager.CycleCount = 0

function GameStateManager.SetState(newState)
	GameStateManager.CurrentState = newState
	print("[SERVER] State transitioned to: " .. newState)
	StateChanged:Fire(newState)
end

function GameStateManager.StartGameLoop()
	task.spawn(function()
		while true do
			local state = GameStateManager.CurrentState

			if state == "Lobby" then
				GameStateSync:FireAllClients("Lobby", 0)
				local forceStarted = false
				local forceConnection = ForceStartEvent.Event:Connect(function()
					forceStarted = true
				end)

				repeat task.wait(1) until #Players:GetPlayers() >= GameStateManager.MinPlayers or forceStarted
				forceConnection:Disconnect()

				GameStateManager.SetState("Intermission")

			elseif state == "Intermission" then
				-- Broadcast 10 seconds to clients
				GameStateSync:FireAllClients("Intermission", 10)
				task.wait(10) 
				GameStateManager.SetState("Voting")

			elseif state == "Voting" then
				-- Broadcast 15 seconds to clients
				GameStateSync:FireAllClients("Voting", 15)
				task.wait(15) 

				-- For now, default to Classic. Later we will tally the SubmitLobbyVote results here.
				GameStateManager.CurrentGamemode = "Classic"
				GameStateManager.CycleCount = 1

				local roleMod = script.Parent:WaitForChild("RoleManager")
				local RoleManager = require(roleMod)
				RoleManager.AssignRoles(GameStateManager.CurrentGamemode, Players:GetPlayers())

				local spawnLoc = workspace:FindFirstChild("SpawnLocation")
				local baseSpawnPos = spawnLoc and spawnLoc.Position + Vector3.new(0, 5, 0) or Vector3.new(0, 50, 0)

				for _, player in ipairs(Players:GetPlayers()) do
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local offset = Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
						player.Character.HumanoidRootPart.CFrame = CFrame.new(baseSpawnPos + offset)
					end
				end

				GameStateManager.SetState("Action")

			elseif state == "Action" then
				-- Hide the lobby UI on clients
				GameStateSync:FireAllClients("Action", 0)

				local taskMod = script.Parent:WaitForChild("TaskManager")
				local TaskManager = require(taskMod)
				TaskManager.AssignTasks()

				local cycleEnded = false
				local killConnection
				local taskWinConnection

				killConnection = KiraExecutedKill.Event:Connect(function()
					cycleEnded = true
				end)

				local tasksFinishedEvent = taskMod:FindFirstChild("TasksFinishedEvent")
				if tasksFinishedEvent then
					taskWinConnection = tasksFinishedEvent.Event:Connect(function()
						cycleEnded = true
						local winMod = script.Parent:WaitForChild("WinManager")
						local WinManager = require(winMod)
						WinManager.ProcessGameOver("Civilian")
						GameStateManager.SetState("Lobby")
					end)
				end

				repeat task.wait(0.5) until cycleEnded

				if killConnection then killConnection:Disconnect() end
				if taskWinConnection then taskWinConnection:Disconnect() end

				if GameStateManager.CurrentState == "Action" then
					GameStateManager.SetState("Meeting")
				end

			elseif state == "Meeting" then
				-- Meeting phase logic remains unchanged
				local dmMod = script.Parent:WaitForChild("DeathManager")
				local DeathManager = require(dmMod)
				DeathManager.PlayDeathSequence()

				local votingMod = script.Parent:WaitForChild("VotingManager")
				local VotingManager = require(votingMod)
				VotingManager.StartVoting()

				task.wait(30) 
				local executedPlayer = VotingManager.EndVotingAndTally()
				task.wait(3) 

				local winMod = script.Parent:WaitForChild("WinManager")
				local WinManager = require(winMod)
				local winningTeam = WinManager.CheckWinConditions()

				if winningTeam then
					WinManager.ProcessGameOver(winningTeam)
					GameStateManager.SetState("Lobby") 
				else
					GameStateManager.CycleCount += 1
					GameStateManager.SetState("Action")
				end
			end

			task.wait(1)
		end
	end)
end

return GameStateManager