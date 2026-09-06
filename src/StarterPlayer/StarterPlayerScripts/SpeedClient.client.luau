--!strict
-- Sprint input, momentum HUD bar, and a speed trail on your character.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local sprintEvent = ReplicatedStorage:WaitForChild("SetSprint") :: RemoteEvent
local momentumUpdate = ReplicatedStorage:WaitForChild("MomentumUpdate") :: RemoteEvent

local player = Players.LocalPlayer

-- sprint: hold Left Shift (keyboard) or L3 / left stick click (gamepad)
local function setSprint(on: boolean)
	sprintEvent:FireServer(on)
end
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprint(true)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL3 then
		setSprint(false)
	end
end)

-- HUD
local gui = Instance.new("ScreenGui")
gui.Name = "SpeedHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local holder = Instance.new("Frame")
holder.Size = UDim2.fromOffset(280, 26)
holder.Position = UDim2.new(0.5, -140, 1, -70)
holder.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
holder.BackgroundTransparency = 0.25
holder.BorderSizePixel = 0
holder.Parent = gui
local holderCorner = Instance.new("UICorner")
holderCorner.CornerRadius = UDim.new(0, 6)
holderCorner.Parent = holder

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = Color3.fromRGB(255, 170, 40)
fill.BorderSizePixel = 0
fill.Parent = holder
local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 6)
fillCorner.Parent = fill

local label = Instance.new("TextLabel")
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Text = "MOMENTUM"
label.Parent = holder

momentumUpdate.OnClientEvent:Connect(function(_momentum: number, percent: number)
	-- no cap: the bar sweeps 0 -> full once per 100%, and the colour shifts each lap
	local band = percent / 100
	fill.Size = UDim2.fromScale(band % 1, 1)
	local hue = (0.08 + math.max(0, band - 1) * 0.12) % 1
	fill.BackgroundColor3 = Color3.fromHSV(hue, 0.85, 1)
	label.Text = string.format("MOMENTUM  %d%%", math.floor(percent + 0.5))
end)

-- speed trail
local function addTrail(char: Model)
	local root = char:WaitForChild("HumanoidRootPart")
	local a0 = Instance.new("Attachment")
	a0.Name = "SpeedTrailA"
	a0.Position = Vector3.new(0, 1.5, 0)
	a0.Parent = root
	local a1 = Instance.new("Attachment")
	a1.Name = "SpeedTrailB"
	a1.Position = Vector3.new(0, -1.5, 0)
	a1.Parent = root
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 0.35
	trail.MinLength = 0.1
	trail.LightEmission = 1
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 190, 90), Color3.fromRGB(120, 255, 200))
	trail.Transparency = NumberSequence.new(0.2, 1)
	trail.Parent = root
end
if player.Character then
	addTrail(player.Character)
end
player.CharacterAdded:Connect(addTrail)
