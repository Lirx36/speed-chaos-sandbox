--!strict
-- Shared tuning values. Tweak these numbers freely, no other code changes needed.
local Config = {
	BaseWalkSpeed = 24, -- Roblox default is 16
	SprintBonus = 22, -- extra speed while holding sprint

	MomentumMax = 100, -- how much bonus speed you can build up normally
	MomentumMaxWithPass = 220, -- ...with the Mega Momentum gamepass
	MomentumGainPerSec = 18, -- how fast momentum builds while moving
	MomentumDecayPerSec = 40, -- how fast it drains when you slow down
	MomentumMoveThreshold = 12, -- min horizontal speed (studs/s) before momentum builds

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
