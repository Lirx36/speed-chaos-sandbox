--!strict
-- One extra mid-air jump. Runs once per character (StarterCharacterScripts).
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local char = script.Parent
local hum = char:WaitForChild("Humanoid") :: Humanoid
local root = char:WaitForChild("HumanoidRootPart") :: BasePart

local canDoubleJump = false
local usedDoubleJump = false

hum.StateChanged:Connect(function(_, newState)
	if newState == Enum.HumanoidStateType.Landed or newState == Enum.HumanoidStateType.Running then
		canDoubleJump = false
		usedDoubleJump = false
	elseif newState == Enum.HumanoidStateType.Freefall then
		canDoubleJump = true
	end
end)

UserInputService.JumpRequest:Connect(function()
	if canDoubleJump and not usedDoubleJump and hum:GetState() == Enum.HumanoidStateType.Freefall then
		usedDoubleJump = true
		local v = root.AssemblyLinearVelocity
		root.AssemblyLinearVelocity = Vector3.new(v.X, Config.DoubleJumpPower, v.Z)
	end
end)
