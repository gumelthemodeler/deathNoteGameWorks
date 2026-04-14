-- @ScriptType: ModuleScript
-- ServerScriptService > TaskManager (ModuleScript)
local TaskManager = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RoleManager = require(game.ServerScriptService:WaitForChild("RoleManager"))

-- Network communication for the UI
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UpdateTaskUIEvent = Remotes:FindFirstChild("UpdateTaskUIEvent") or Instance.new("RemoteEvent")
UpdateTaskUIEvent.Name = "UpdateTaskUIEvent"
UpdateTaskUIEvent.Parent = Remotes

-- Internal server event to end the game if tasks are done
local TasksFinishedEvent = script:FindFirstChild("TasksFinishedEvent") or Instance.new("BindableEvent")
TasksFinishedEvent.Name = "TasksFinishedEvent"
TasksFinishedEvent.Parent = script

TaskManager.GlobalTasksRequired = 0
TaskManager.GlobalTasksCompleted = 0
TaskManager.PlayerTasks = {} -- Dictionary tracking what tasks each player has

-- Defines the possible tasks that can be assigned (Matched to physical parts in Workspace)
local AVAILABLE_TASKS = {
	"Fix Server Rack",
	"Analyze Fingerprints",
	"Reboot Mainframe",
	"Sort Case Files"
}
local TASKS_PER_PLAYER = 3

function TaskManager.AssignTasks()
	TaskManager.GlobalTasksRequired = 0
	TaskManager.GlobalTasksCompleted = 0
	TaskManager.PlayerTasks = {}

	for _, player in ipairs(Players:GetPlayers()) do
		local role = RoleManager.GetPlayerRole(player)
		if role and role.IsAlive then
			local assigned = {}
			-- Randomly pick tasks for this player
			local pool = table.clone(AVAILABLE_TASKS)
			for i = 1, TASKS_PER_PLAYER do
				if #pool == 0 then break end
				local randomIndex = math.random(1, #pool)
				table.insert(assigned, pool[randomIndex])
				table.remove(pool, randomIndex)
			end

			TaskManager.PlayerTasks[player.Name] = assigned

			-- Only Civilian tasks count towards the global required total
			if role.Team == "Civilian" then
				TaskManager.GlobalTasksRequired += #assigned
			end

			-- Send the task list and global progress to the client
			UpdateTaskUIEvent:FireClient(player, assigned, TaskManager.GlobalTasksCompleted, TaskManager.GlobalTasksRequired)
		end
	end

	print("[TASK MANAGER] Tasks assigned. Global total required: " .. TaskManager.GlobalTasksRequired)
end

function TaskManager.CompleteTask(player, taskName)
	local role = RoleManager.GetPlayerRole(player)
	if not role or not role.IsAlive then return false, "You are dead." end

	local playerTaskList = TaskManager.PlayerTasks[player.Name]
	if not playerTaskList then return false, "No tasks assigned." end

	-- Verify they actually have this task
	local hasTask = false
	local taskIndex = nil
	for i, tName in ipairs(playerTaskList) do
		if tName == taskName then
			hasTask = true
			taskIndex = i
			break
		end
	end

	if not hasTask then return false, "You don't have this task." end

	-- Remove it from their personal list
	table.remove(playerTaskList, taskIndex)

	-- Only increment the global bar if they are a Civilian (Kira's tasks are fake)
	if role.Team == "Civilian" then
		TaskManager.GlobalTasksCompleted += 1
	end

	-- Update ALL clients on the global bar progress, and update this specific player's list
	for _, p in ipairs(Players:GetPlayers()) do
		local pList = TaskManager.PlayerTasks[p.Name] or {}
		UpdateTaskUIEvent:FireClient(p, pList, TaskManager.GlobalTasksCompleted, TaskManager.GlobalTasksRequired)
	end

	print("[TASK MANAGER] " .. player.Name .. " completed " .. taskName)

	-- Check for Civilian Win via tasks
	if TaskManager.GlobalTasksCompleted >= TaskManager.GlobalTasksRequired and TaskManager.GlobalTasksRequired > 0 then
		print("[TASK MANAGER] All global tasks completed! Civilians win.")
		TasksFinishedEvent:Fire()
	end

	return true, "Task completed."
end

return TaskManager