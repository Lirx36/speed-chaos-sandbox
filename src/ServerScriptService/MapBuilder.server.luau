--!strict
-- Builds a big city sandbox at runtime so the place is playable immediately.
-- Delete this script once you've built your own map in Studio.
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

if Workspace:FindFirstChild("GeneratedMap") then
	return
end

local WORLD_SIZE = 16384 -- distance between the perimeter walls
local FLOOR_OVERHANG = 8000 -- floor extends this far past the walls on every side
local CITY_EXTENT = 3200 -- buildings fill roughly this radius; open ground beyond it
local LANE_HALF = 280 -- half-width of the clear speed lanes through the middle (X and Z)

local map = Instance.new("Folder")
map.Name = "GeneratedMap"
map.Parent = Workspace

math.randomseed(1337) -- fixed seed: the city looks the same every run

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

local function rand(a: number, b: number): number
	return a + math.random() * (b - a)
end

-- floor (bigger than the walled area so you never run out of ground)
local floorSpan = WORLD_SIZE + FLOOR_OVERHANG * 2
part({
	Name = "Floor",
	Size = Vector3.new(floorSpan, 4, floorSpan),
	Position = Vector3.new(0, 0, 0),
	Color = Color3.fromRGB(52, 57, 64),
	Material = Enum.Material.SmoothPlastic,
})

-- spawn
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Anchored = true
spawn.Size = Vector3.new(24, 1, 24)
spawn.Position = Vector3.new(0, 3, 0)
spawn.Color = Color3.fromRGB(120, 200, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = map

-- glass perimeter walls
local halfWorld = WORLD_SIZE / 2
for i, dir in { Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) } do
	part({
		Name = "Wall" .. i,
		Size = Vector3.new(math.abs(dir.Z) * WORLD_SIZE + 12, 240, math.abs(dir.X) * WORLD_SIZE + 12),
		Position = dir * halfWorld + Vector3.new(0, 120, 0),
		Color = Color3.fromRGB(40, 44, 50),
		Transparency = 0.55,
		Material = Enum.Material.Glass,
	})
end

-- city of tiered towers
local PALETTE = {
	Color3.fromRGB(90, 96, 104),
	Color3.fromRGB(120, 110, 100),
	Color3.fromRGB(70, 78, 92),
	Color3.fromRGB(140, 140, 148),
	Color3.fromRGB(96, 84, 78),
}
local ACCENTS = {
	Color3.fromRGB(255, 120, 40),
	Color3.fromRGB(60, 200, 255),
	Color3.fromRGB(120, 255, 160),
	Color3.fromRGB(255, 70, 120),
}

local function tower(cx: number, cz: number)
	local tiers = math.random(1, 3)
	local w, d = rand(130, 250), rand(130, 250)
	local baseY = 2
	local color = PALETTE[math.random(#PALETTE)]
	for _ = 1, tiers do
		local h = rand(120, 340)
		part({
			Name = "Building",
			Size = Vector3.new(w, h, d),
			Position = Vector3.new(cx, baseY + h / 2, cz),
			Color = color,
			Material = Enum.Material.Concrete,
		})
		baseY += h
		w = math.max(46, w - rand(24, 70))
		d = math.max(46, d - rand(24, 70))
	end
	-- glowing crown so tall ones read against the skybox
	part({
		Name = "BuildingCrown",
		Size = Vector3.new(w + 8, 5, d + 8),
		Position = Vector3.new(cx, baseY + 3, cz),
		Color = ACCENTS[math.random(#ACCENTS)],
		Material = Enum.Material.Neon,
	})
end

local STEP = 620
for gx = -CITY_EXTENT, CITY_EXTENT, STEP do
	for gz = -CITY_EXTENT, CITY_EXTENT, STEP do
		local x = gx + rand(-70, 70)
		local z = gz + rand(-70, 70)
		local nearSpawn = Vector2.new(x, z).Magnitude < 560
		local onLane = math.abs(x) < LANE_HALF or math.abs(z) < LANE_HALF -- cross-shaped clear lanes
		if not nearSpawn and not onLane then
			tower(x, z)
		end
	end
end

-- ramps toward the rooftops
local function ramp(pos: Vector3, rot: number, tilt: number, size: Vector3)
	part({
		Name = "Ramp",
		Size = size,
		CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(rot), 0) * CFrame.Angles(math.rad(tilt), 0, 0),
		Color = Color3.fromRGB(95, 105, 115),
		Material = Enum.Material.Metal,
	})
end
ramp(Vector3.new(0, 26, 520), 0, -16, Vector3.new(64, 5, 200))
ramp(Vector3.new(760, 46, 0), 90, -20, Vector3.new(64, 5, 280))
ramp(Vector3.new(-760, 46, 0), 90, -20, Vector3.new(64, 5, 280))
ramp(Vector3.new(0, 64, -940), 0, -24, Vector3.new(84, 6, 360))

-- launch pads: 4 around spawn + scattered across the map
local function launchPad(pos: Vector3, facing: number)
	local p = part({
		Name = "LaunchPad",
		Size = Vector3.new(28, 2, 28),
		CFrame = CFrame.new(pos) * CFrame.Angles(0, math.rad(facing), 0),
		Color = Color3.fromRGB(255, 170, 40),
		Material = Enum.Material.Neon,
	})
	CollectionService:AddTag(p, "LaunchPad")
end
launchPad(Vector3.new(0, 3, 200), 0)
launchPad(Vector3.new(200, 3, 0), -90)
launchPad(Vector3.new(-200, 3, 0), 90)
launchPad(Vector3.new(0, 3, -200), 180)
for _ = 1, 14 do
	launchPad(Vector3.new(rand(-3600, 3600), 3, rand(-3600, 3600)), rand(0, 360))
end

-- bumpers scattered wide
local function bumper(pos: Vector3, sizeN: number)
	local p = part({
		Name = "Bumper",
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(sizeN, sizeN, sizeN),
		Position = pos,
		Color = Color3.fromRGB(255, 70, 120),
		Material = Enum.Material.Neon,
	})
	CollectionService:AddTag(p, "Bumper")
end
for _ = 1, 22 do
	local s = rand(24, 46)
	bumper(Vector3.new(rand(-3600, 3600), s / 2 + 4, rand(-3600, 3600)), s)
end

-- speed rings: long lanes to chain together
local function ringLane(startPos: Vector3, step: Vector3, count: number)
	for i = 1, count do
		local p = part({
			Name = "SpeedRing",
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(2, 48, 48),
			CFrame = CFrame.new(startPos + step * (i - 1)) * CFrame.Angles(0, 0, math.rad(90)),
			Color = Color3.fromRGB(120, 255, 160),
			Material = Enum.Material.Neon,
			Transparency = 0.35,
			CanCollide = false,
		})
		CollectionService:AddTag(p, "SpeedRing")
	end
end
ringLane(Vector3.new(-1900, 28, 0), Vector3.new(340, 0, 0), 12) -- along the X lane
ringLane(Vector3.new(0, 28, -1900), Vector3.new(0, 0, 340), 12) -- along the Z lane
ringLane(Vector3.new(-3600, 28, 2600), Vector3.new(320, 0, 0), 12) -- outskirts straight

-- gamepass buy pad near spawn (inert until Config.GamepassId is set)
local buy = part({
	Name = "BuyPassPad",
	Size = Vector3.new(20, 1, 20),
	Position = Vector3.new(60, 3, 0),
	Color = Color3.fromRGB(255, 215, 0),
	Material = Enum.Material.Neon,
})
CollectionService:AddTag(buy, "BuyPassPad")
