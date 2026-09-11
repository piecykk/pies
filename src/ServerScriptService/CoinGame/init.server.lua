-- Coin Collector: spawns coins around the map, tracks each player's score on the leaderboard.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local CONFIG = {
	NumCoins = 15,
	RespawnDelay = 5,
	CoinValue = 1,
	SpawnAreaSize = 90, -- coins spawn within +/- half this size on X and Z
	SpawnHeight = 3,
}

local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "Coins"
coinsFolder.Parent = workspace

local function randomSpawnPosition()
	local half = CONFIG.SpawnAreaSize / 2
	local x = math.random(-half, half)
	local z = math.random(-half, half)
	return Vector3.new(x, CONFIG.SpawnHeight, z)
end

local function showPickupEffect(position, amount)
	local billboardAnchor = Instance.new("Part")
	billboardAnchor.Anchored = true
	billboardAnchor.CanCollide = false
	billboardAnchor.Transparency = 1
	billboardAnchor.Size = Vector3.new(1, 1, 1)
	billboardAnchor.Position = position
	billboardAnchor.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 1, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = billboardAnchor

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Text = "+" .. amount
	label.TextColor3 = Color3.fromRGB(255, 215, 0)
	label.TextStrokeTransparency = 0.5
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	local tween = TweenService:Create(
		billboardAnchor,
		TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Position = position + Vector3.new(0, 4, 0) }
	)
	local fadeTween = TweenService:Create(label, TweenInfo.new(0.8), { TextTransparency = 1, TextStrokeTransparency = 1 })
	tween:Play()
	fadeTween:Play()

	Debris:AddItem(billboardAnchor, 0.9)
end

local function createCoin()
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.4, 2, 2)
	coin.Orientation = Vector3.new(0, 0, 90)
	coin.Anchored = true
	coin.CanCollide = false
	coin.Material = Enum.Material.Neon
	coin.Color = Color3.fromRGB(255, 215, 0)
	coin.Position = randomSpawnPosition()
	coin:SetAttribute("Collected", false)
	coin.Parent = coinsFolder

	local spinConnection
	spinConnection = game:GetService("RunService").Heartbeat:Connect(function(dt)
		if not coin.Parent then
			spinConnection:Disconnect()
			return
		end
		coin.CFrame = coin.CFrame * CFrame.Angles(0, dt * 2, 0)
	end)

	local debounce = false
	coin.Touched:Connect(function(hit)
		if debounce or coin:GetAttribute("Collected") then
			return
		end
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		debounce = true
		coin:SetAttribute("Collected", true)

		local leaderstats = player:WaitForChild("leaderstats", 10)
		local coinsStat = leaderstats and leaderstats:FindFirstChild("Coins")
		local awarded = CONFIG.CoinValue * (player:GetAttribute("CoinMultiplier") or 1)
		if coinsStat then
			coinsStat.Value += awarded
		end

		showPickupEffect(coin.Position, awarded)
		coin.Parent = nil
		spinConnection:Disconnect()

		task.delay(CONFIG.RespawnDelay, createCoin)
	end)

	return coin
end

for _ = 1, CONFIG.NumCoins do
	createCoin()
end
