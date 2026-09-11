-- Owns leaderstats creation and persists each player's coins + owned upgrades across sessions.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = require(ReplicatedStorage:WaitForChild("ShopConfig"))

local dataStore = DataStoreService:GetDataStore("CoinGamePlayerData_v1")
local AUTOSAVE_INTERVAL = 120

local upgradeIds = {}
for _, item in ShopConfig.Items do
	if not item.Consumable then
		table.insert(upgradeIds, item.Id)
	end
end

local function loadPlayerData(player)
	local success, data = pcall(function()
		return dataStore:GetAsync("Player_" .. player.UserId)
	end)
	if success and data then
		return data
	end
	return { Coins = 0, Owned = {} }
end

local function savePlayerData(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coins then
		return
	end

	local owned = {}
	for _, id in upgradeIds do
		if player:GetAttribute("Owns" .. id) then
			table.insert(owned, id)
		end
	end

	pcall(function()
		dataStore:SetAsync("Player_" .. player.UserId, { Coins = coins.Value, Owned = owned })
	end)
end

local function setupPlayer(player)
	-- Load before creating leaderstats so no coin pickup can be earned (and then overwritten) mid-load.
	local data = loadPlayerData(player)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.Coins or 0
	coins.Parent = leaderstats

	for _, id in data.Owned or {} do
		player:SetAttribute("Owns" .. id, true)
	end
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(savePlayerData)

task.spawn(function()
	while true do
		task.wait(AUTOSAVE_INTERVAL)
		for _, player in Players:GetPlayers() do
			savePlayerData(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		savePlayerData(player)
	end
end)
