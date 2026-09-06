--!strict
-- Shared tuning values. Tweak these numbers freely, no other code changes needed.
local Config = {
	BaseWalkSpeed = 24, -- Roblox default is 16
	SprintBonus = 22, -- extra speed while holding sprint

	-- Momentum has NO cap. You control it with the on-screen buttons / keys 1-2-3:
	-- Gain (speed up), Hold (stay put), Drain (slow down).
	MomentumGainPerSec = 45, -- bonus WalkSpeed added per second while in Gain mode
	MomentumDecayPerSec = 8, -- flat drain per second while in Drain mode
	MomentumDecayFraction = 0.05, -- while draining and momentum is high, also lose this fraction per second
	MomentumPercentReference = 100, -- this much bonus speed reads as "100%" on the HUD
	MomentumHardCap = math.huge, -- keep as math.huge for truly infinite; set a number if physics gets silly
	PassGainMultiplier = 2, -- "Mega Momentum" gamepass: charge this many times faster

	UseJumpPower = true,
	JumpPower = 55,
	DoubleJumpPower = 52,

	LaunchPadPower = 150,
	BumperPower = 230, -- how hard bumpers fling you straight away from their centre
	BumperLift = 70, -- upward kick added on top, so you actually fly
	BumperTumbleTime = 0.7, -- seconds you tumble after a hit (short = recover fast)
	RingMomentumFill = 45, -- momentum granted by flying through a speed ring

	GamepassId = 0, -- put your "Mega Momentum" gamepass id here. 0 = feature disabled.
}

return Config
