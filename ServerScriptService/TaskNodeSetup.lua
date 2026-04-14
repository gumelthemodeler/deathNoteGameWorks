-- @ScriptType: Script
-- ServerScriptService > TaskNodeSetup (Script)
local TaskManager = require(game.ServerScriptService:WaitForChild("TaskManager"))

local taskNodesFolder = workspace:WaitForChild("TaskNodes")

for _, node in ipairs(taskNodesFolder:GetChildren()) do
	if node:IsA("BasePart") then
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Complete Task"
		prompt.ObjectText = node.Name
		prompt.HoldDuration = 2 -- Takes 2 seconds to do a task
		prompt.RequiresLineOfSight = true
		prompt.MaxActivationDistance = 8
		prompt.Parent = node

		prompt.Triggered:Connect(function(player)
			local success, msg = TaskManager.CompleteTask(player, node.Name)
			if not success then
				-- Optional: Fire a remote to the client to show a tiny error notification
				print(player.Name .. " failed to do task: " .. msg)
			end
		end)
	end
end