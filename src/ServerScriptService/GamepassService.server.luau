--!strict
-- Grants the "Mega Momentum" perk to owners. Does nothing until Config.GamepassId is set.
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local function refresh(player: Player)
	if Config.GamepassId <= 0 then
		return
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, Config.GamepassId)
	end)
	player:SetAttribute("HasMomentumPass", ok and owns == true)
end

Players.PlayerAdded:Connect(refresh)
for _, player in Players:GetPlayers() do
	task.spawn(refresh, player)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
	if wasPurchased and passId == Config.GamepassId then
		player:SetAttribute("HasMomentumPass", true)
	end
end)
