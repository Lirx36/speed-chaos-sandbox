--!strict
-- Builds the sandbox map at runtime so the place is playable immediately.
-- Delete this script once you've built your own map in Studio.
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

if Workspace:FindFirstChild("GeneratedMap") then
	return
end

-- Roblox hard-caps a Part at 2048 studs on any axis. Anything "huge" MUST be tiled.
local PART_MAX = 2048

local TILE = 2000 -- floor / wall tile length (kept under PART_MAX)
local GROUND_TILES = 6 -- tiles out from centre in each direction
local WALL_INSET = TILE -- walls sit this far inside the floor edge
local WALL_HALF = TILE * GROUND_TILES - WALL_INSET + TILE / 2 -- ~11000 studs
local WALL_HEIGHT = 250

local CITY_HALF = 3000 -- buildings fill this radius
local CITY_STEP = 600
local LANE_HALF = 300 -- half-width of the clear cross-lanes through the middle

local map = Instance.new("Folder")
map.Name = "GeneratedMap"
map.Parent = Workspace

math.randomseed(1337) -- fixed seed: same city every run

local function part(props: { [string]: any }): BasePart
	local p = Instance.new("Part")
	p.Anchored = true
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props do
		(p :: any)[k] = v
	end
	local s = p.Size
	if s.X > PART_MAX or s.Y > PART_MAX or s.Z > PART_MAX then
		warn(("MapBuilder: '%s' size %s exceeds the %d-stud part limit and will be clamped")
			:format(p.Name, tostring(s), PART_MAX))
	end
	p.Parent = map
	return p
end

local function rand(a: number, b: number): number
	return a + math.random() * (b - a)
end

-- FLOOR: a grid of tiles (one giant part is impossible, see PART_MAX)
for tx = -GROUND_TILES, GROUND_TILES do
	for tz = -GROUND_TILES, GROUND_TILES do
		part({
			Name = "FloorTile",
			Size = Vector3.new(TILE, 4, TILE),
			Position = Vector3.new(tx * TILE, 0, tz * TILE),
			Color = Color3.fromRGB(52, 57, 64),
			Material = Enum.Material.SmoothPlastic,
		})
	end
end
local floorEdge = (GROUND_TILES + 0.5) * TILE -- ~13000 studs from centre to the real edge

-- SPAWN
local spawn = Instance.new("SpawnLocation")
spawn.Name = "Spawn"
spawn.Anchored = true
spawn.Size = Vector3.new(24, 1, 24)
spawn.Position = Vector3.new(0, 3, 0)
spawn.Color = Color3.fromRGB(120, 200, 255)
spawn.Material = Enum.Material.Neon
spawn.Parent = map

-- WALLS: tiled glass segments, set inside the floor edge so ground shows past them
for t = -GROUND_TILES, GROUND_TILES do
	local a = t * TILE
	local segs = {
		{ Vector3.new(a, WALL_HEIGHT / 2, WALL_HALF), Vector3.new(TILE, WALL_HEIGHT, 12) },
		{ Vector3.new(a, WALL_HEIGHT / 2, -WALL_HALF), Vector3.new(TILE, WALL_HEIGHT, 12) },
		{ Vector3.new(WALL_HALF, WALL_HEIGHT / 2, a), Vector3.new(12, WALL_HEIGHT, TILE) },
		{ Vector3.new(-WALL_HALF, WALL_HEIGHT / 2, a), Vector3.new(12, WALL_HEIGHT, TILE) },
	}
	for _, seg in segs do
		part({
			Name = "Wall",
			Position = seg[1],
			Size = seg[2],
			Color = Color3.fromRGB(40, 44, 50),
			Transparency = 0.55,
			Material = Enum.Material.Glass,
		})
	end
end

-- CITY of tiered towers
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
		local h = rand(120, 320)
		part({
			Name = "Building",
			Size = Vector3.new(w, h, d),
			Position = Vector3.new(cx, baseY + h / 2, cz),
			Color = color,
			Material = Enum.Material.Concrete,
		})
		baseY += h
		w = math.max(50, w - rand(24, 64))
		d = math.max(50, d - rand(24, 64))
	end
	part({
		Name = "BuildingCrown",
		Size = Vector3.new(w + 8, 5, d + 8),
		Position = Vector3.new(cx, baseY + 3, cz),
		Color = ACCENTS[math.random(#ACCENTS)],
		Material = Enum.Material.Neon,
	})
end

for gx = -CITY_HALF, CITY_HALF, CITY_STEP do
	for gz = -CITY_HALF, CITY_HALF, CITY_STEP do
		local x = gx + rand(-60, 60)
		local z = gz + rand(-60, 60)
		local clearOfSpawn = Vector2.new(x, z).Magnitude > 520
		local offTheLanes = math.abs(x) > LANE_HALF and math.abs(z) > LANE_HALF
		if clearOfSpawn and offTheLanes then
			tower(x, z)
		end
	end
end

-- RAMPS toward rooftop height
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

-- LAUNCH PADS: 4 around spawn + scattered
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
for _ = 1, 16 do
	launchPad(Vector3.new(rand(-4500, 4500), 3, rand(-4500, 4500)), rand(0, 360))
end

-- BUMPERS scattered wide
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
for _ = 1, 26 do
	local s = rand(24, 46)
	bumper(Vector3.new(rand(-4500, 4500), s / 2 + 4, rand(-4500, 4500)), s)
end

-- SPEED RINGS: long lanes to chain
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
ringLane(Vector3.new(-2000, 28, 0), Vector3.new(360, 0, 0), 12) -- along the X lane
ringLane(Vector3.new(0, 28, -2000), Vector3.new(0, 0, 360), 12) -- along the Z lane
ringLane(Vector3.new(-4500, 28, 3200), Vector3.new(360, 0, 0), 14) -- outskirts straight

-- GAMEPASS BUY PAD near spawn (inert until Config.GamepassId is set)
local buy = part({
	Name = "BuyPassPad",
	Size = Vector3.new(20, 1, 20),
	Position = Vector3.new(60, 3, 0),
	Color = Color3.fromRGB(255, 215, 0),
	Material = Enum.Material.Neon,
})
CollectionService:AddTag(buy, "BuyPassPad")

print(("MapBuilder: built %d parts, floor edge at %d studs, walls at %d")
	:format(#map:GetChildren(), floorEdge, WALL_HALF))
