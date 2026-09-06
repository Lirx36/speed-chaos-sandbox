--!strict
-- Handles anything tagged in the world: LaunchPad, Bumper, SpeedRing, BuyPassPad.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local addMomentum = ServerStorage:WaitForChild("AddMomentum") :: BindableEvent

local function getChar(hit: BasePart): (Model?, Humanoid?, BasePart?)
	local model = hit:FindFirstAncestorOfClass("Model")
	if not model then
		return nil, nil, nil
	end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hum and root then
		return model, hum, root
	end
	return nil, nil, nil
end

-- per-character touch debounce (weak keys so respawned characters get cleaned up)
local cooldown: { [Model]: number } = setmetatable({}, { __mode = "k" }) :: any
local function onCooldown(model: Model, seconds: number): boolean
	local now = os.clock()
	if cooldown[model] and now - cooldown[model] < seconds then
		return true
	end
	cooldown[model] = now
	return false
end

local function bindLaunchPad(pad: BasePart)
	pad.Touched:Connect(function(hit)
		local model, _, root = getChar(hit)
		if not model or not root then
			return
		end
		if onCooldown(model, 0.4) then
			return
		end
		local dir = (Vector3.yAxis + pad.CFrame.LookVector * 0.35).Unit
		root.AssemblyLinearVelocity = dir * Config.LaunchPadPower + Vector3.new(0, 20, 0)
	end)
end

local function bindBumper(bumper: BasePart)
	bumper.Touched:Connect(function(hit)
		local model, hum, root = getChar(hit)
		if not model or not hum or not root then
			return
		end
		if onCooldown(model, 0.6) then
			return
		end
		local away = root.Position - bumper.Position
		away = Vector3.new(away.X, 0, away.Z)
		if away.Magnitude < 0.1 then
			away = Vector3.xAxis
		end
		root.AssemblyLinearVelocity = away.Unit * Config.BumperPower + Vector3.new(0, Config.BumperLift, 0)
		root.AssemblyAngularVelocity = Vector3.new(math.random(-20, 20), math.random(-20, 20), math.random(-20, 20))
		hum.PlatformStand = true
		task.delay(Config.BumperTumbleTime, function()
			if hum.Parent then
				hum.PlatformStand = false
			end
		end)
	end)
end

local function bindRing(ring: BasePart)
	ring.CanCollide = false
	ring.Touched:Connect(function(hit)
		local model = getChar(hit)
		local player = model and Players:GetPlayerFromCharacter(model)
		if not model or not player then
			return
		end
		if onCooldown(model, 0.5) then
			return
		end
		addMomentum:Fire(player, Config.RingMomentumFill)
	end)
end

local function bindBuyPad(pad: BasePart)
	pad.Touched:Connect(function(hit)
		if Config.GamepassId <= 0 then
			return
		end
		local model = getChar(hit)
		local player = model and Players:GetPlayerFromCharacter(model)
		if not model or not player then
			return
		end
		if onCooldown(model, 3) then
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, Config.GamepassId)
	end)
end

local binders: { [string]: (BasePart) -> () } = {
	LaunchPad = bindLaunchPad,
	Bumper = bindBumper,
	SpeedRing = bindRing,
	BuyPassPad = bindBuyPad,
}

for tag, fn in binders do
	for _, inst in CollectionService:GetTagged(tag) do
		if inst:IsA("BasePart") then
			fn(inst)
		end
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
		if inst:IsA("BasePart") then
			fn(inst)
		end
	end)
end
