--!strict
-- Builds a playable test map at runtime so the place works the moment you press Play.
-- Delete this script once you've built your own map in Studio.
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

if Workspace:FindFirstChild("GeneratedMap") then
	return
end

local map = Instance.new("Folder")
map.Name = "GeneratedMap"
map.Parent = Workspace

local function part(props: { [string]: any }): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	p.Parent = map
	return p
end

-- floor
part({
	Name = "Floor",
	Size = Vector3.new(2048, 4, 2048),
	Position = Vector3.new(0, 0, 0),
	Color = Color3.fromRGB(58, 64, 72),
	Material = Enum.Material.SmoothPlastic,
})

-- spawn
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Anchored = true
spawn.Size = Vector3.new(16, 1, 16)
spawn.Position = Vector3.new(0, 3, 0)
spawn.Color = Color3.fromRGB(120, 200, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = map

-- giant floating TEST sign (live-sync check)
do
	local anchor = part({
		Name = "SignAnchor",
		Size = Vector3.new(1, 1, 1),
		Position = Vector3.new(0, 90, 0),
		Transparency = 1,
		CanCollide = false,
	})
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(60, 20)
	bb.AlwaysOnTop = true
	bb.Parent = anchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBlack
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(255, 80, 200)
	text.Text = "TEST"
	text.Parent = bb
end

-- glass perimeter walls
local dirs = { Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) }
for i, dir in dirs do
	part({
		Name = "Wall" .. i,
		Size = Vector3.new(math.abs(dir.Z) * 2048 + 8, 60, math.abs(dir.X) * 2048 + 8),
		Position = dir * 1024 + Vector3.new(0, 30, 0),
		Color = Color3.fromRGB(40, 44, 50),
		Transparency = 0.5,
		Material = Enum.Material.Glass,
	})
end

-- ramps
local function ramp(pos: Vector3, rot: number, tilt: number)
	part({
		Name = "Ramp",
		Size = Vector3.new(40, 4, 90),
		CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(rot), 0) * CFrame.Angles(math.rad(tilt), 0, 0),
		Color = Color3.fromRGB(90, 100, 110),
		Material = Enum.Material.Metal,
	})
end
ramp(Vector3.new(0, 12, 220), 0, -18)
ramp(Vector3.new(240, 12, -60), 90, -18)
ramp(Vector3.new(-240, 20, -160), 55, -26)

-- launch pads (orange)
local function launchPad(pos: Vector3, facing: number)
	local p = part({
		Name = "LaunchPad",
		Size = Vector3.new(24, 2, 24),
		CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(facing), 0),
		Color = Color3.fromRGB(255, 170, 40),
		Material = Enum.Material.Neon,
	})
	CollectionService:AddTag(p, "LaunchPad")
end
launchPad(Vector3.new(0, 3, 380), 0)
launchPad(Vector3.new(380, 3, 0), -90)
launchPad(Vector3.new(-380, 3, 0), 90)
launchPad(Vector3.new(0, 3, -380), 180)

-- bumpers (pink spheres)
local function bumper(pos: Vector3)
	local p = part({
		Name = "Bumper",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(28, 28, 28),
		Position = pos,
		Color = Color3.fromRGB(255, 70, 120),
		Material = Enum.Material.Neon,
	})
	CollectionService:AddTag(p, "Bumper")
end
bumper(Vector3.new(120, 14, 120))
bumper(Vector3.new(-120, 14, 120))
bumper(Vector3.new(120, 14, -120))
bumper(Vector3.new(-140, 14, -60))

-- speed rings (green) along a lane
for i = 1, 6 do
	local p = part({
		Name = "SpeedRing",
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(2, 40, 40),
		CFrame = CFrame.new(Vector3.new(-520, 22, -400 + i * 120)) * CFrame.Angles(0, 0, math.rad(90)),
		Color = Color3.fromRGB(120, 255, 160),
		Material = Enum.Material.Neon,
		Transparency = 0.35,
		CanCollide = false,
	})
	CollectionService:AddTag(p, "SpeedRing")
end

-- gamepass buy pad (gold) - only prompts once Config.GamepassId is set
local buy = part({
	Name = "BuyPassPad",
	Size = Vector3.new(18, 1, 18),
	Position = Vector3.new(44, 3, 0),
	Color = Color3.fromRGB(255, 215, 0),
	Material = Enum.Material.Neon,
})
CollectionService:AddTag(buy, "BuyPassPad")
