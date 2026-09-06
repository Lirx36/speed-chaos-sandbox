--!strict
-- Core movement: builds "momentum" while you keep moving and turns it into raw WalkSpeed.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- remotes / bindables other scripts and the HUD use
local momentumUpdate = Instance.new("RemoteEvent")
momentumUpdate.Name = "MomentumUpdate" -- server -> client, for the HUD bar
momentumUpdate.Parent = ReplicatedStorage

local sprintEvent = Instance.new("RemoteEvent")
sprintEvent.Name = "SetSprint" -- client -> server, hold-to-sprint
sprintEvent.Parent = ReplicatedStorage

local modeEvent = Instance.new("RemoteEvent")
modeEvent.Name = "SetMomentumMode" -- client -> server: "Gain" | "Hold" | "Drain"
modeEvent.Parent = ReplicatedStorage

local addMomentum = Instance.new("BindableEvent")
addMomentum.Name = "AddMomentum" -- other server scripts fire this (e.g. speed rings)
addMomentum.Parent = ServerStorage

type State = { momentum: number, sprinting: boolean, mode: string }
local states: { [Player]: State } = {}

local VALID_MODES = { Gain = true, Hold = true, Drain = true }
local DEFAULT_MODE = "Gain"

local function gainMultiplier(player: Player): number
	return player:GetAttribute("HasMomentumPass") and Config.PassGainMultiplier or 1
end

local function onCharacter(player: Player, char: Model)
	local hum = char:WaitForChild("Humanoid") :: Humanoid
	hum.UseJumpPower = Config.UseJumpPower
	hum.JumpPower = Config.JumpPower
	hum.WalkSpeed = Config.BaseWalkSpeed
	local st = states[player]
	if st then
		st.momentum = 0
	end
end

Players.PlayerAdded:Connect(function(player)
	states[player] = { momentum = 0, sprinting = false, mode = DEFAULT_MODE }
	player.CharacterAdded:Connect(function(char)
		onCharacter(player, char)
	end)
	if player.Character then
		onCharacter(player, player.Character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

sprintEvent.OnServerEvent:Connect(function(player, wantSprint)
	local st = states[player]
	if st then
		st.sprinting = wantSprint == true
	end
end)

modeEvent.OnServerEvent:Connect(function(player, mode)
	local st = states[player]
	if st and VALID_MODES[mode] then
		st.mode = mode
	end
end)

addMomentum.Event:Connect(function(player: Player, amount: number)
	local st = states[player]
	if st then
		st.momentum = math.clamp(st.momentum + amount, 0, Config.MomentumHardCap)
	end
end)

local broadcastAccum = 0
RunService.Heartbeat:Connect(function(dt)
	for player, st in states do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			continue
		end

		-- momentum only changes according to the player's chosen mode
		if st.mode == "Gain" then
			st.momentum += Config.MomentumGainPerSec * gainMultiplier(player) * dt
		elseif st.mode == "Drain" then
			local drain = math.max(Config.MomentumDecayPerSec, st.momentum * Config.MomentumDecayFraction)
			st.momentum -= drain * dt
		end
		-- "Hold" leaves momentum exactly where it is
		st.momentum = math.clamp(st.momentum, 0, Config.MomentumHardCap)

		local target = Config.BaseWalkSpeed + st.momentum
		if st.sprinting then
			target += Config.SprintBonus
		end
		hum.WalkSpeed = target
	end

	broadcastAccum += dt
	if broadcastAccum >= 0.1 then
		broadcastAccum = 0
		for player, st in states do
			local percent = st.momentum / Config.MomentumPercentReference * 100
			momentumUpdate:FireClient(player, st.momentum, percent, st.mode)
		end
	end
end)
