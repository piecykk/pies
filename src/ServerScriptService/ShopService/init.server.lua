-- Handles shop purchases, applies permanent/consumable effects, and builds the physical shop stall.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShopConfig = require(ReplicatedStorage:WaitForChild("ShopConfig"))

local itemsById = {}
for _, item in ShopConfig.Items do
	itemsById[item.Id] = item
end

local purchaseItem = Instance.new("RemoteFunction")
purchaseItem.Name = "PurchaseItem"
purchaseItem.Parent = ReplicatedStorage

local BASE_WALK_SPEED = 16
local SONIC_BOOTS_BONUS = 8
local MAGNET_RADIUS = 20
local MAGNET_PULL_SPEED = 40

local coinRushTokens = {}

local function applyWalkSpeed(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = BASE_WALK_SPEED + (player:GetAttribute("OwnsSonicBoots") and SONIC_BOOTS_BONUS or 0)
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.1)
		applyWalkSpeed(player)
	end)
end)

purchaseItem.OnServerInvoke = function(player, itemId)
	local item = itemsById[itemId]
	if not item then
		return { success = false, message = "Unknown item" }
	end

	local ownsAttribute = "Owns" .. item.Id
	if not item.Consumable and player:GetAttribute(ownsAttribute) then
		return { success = false, message = "Already owned" }
	end

	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	if not coins or coins.Value < item.Cost then
		return { success = false, message = "Not enough coins" }
	end

	coins.Value -= item.Cost

	if item.Consumable then
		local token = {}
		coinRushTokens[player] = token
		player:SetAttribute("CoinMultiplier", 2)
		task.delay(item.Duration, function()
			if coinRushTokens[player] == token then
				player:SetAttribute("CoinMultiplier", 1)
				coinRushTokens[player] = nil
			end
		end)
	else
		player:SetAttribute(ownsAttribute, true)
		if item.Id == "SonicBoots" then
			applyWalkSpeed(player)
		end
	end

	return { success = true, owned = not item.Consumable }
end

Players.PlayerRemoving:Connect(function(player)
	coinRushTokens[player] = nil
end)

task.spawn(function()
	while true do
		task.wait(0.1)
		local coinsFolder = workspace:FindFirstChild("Coins")
		if coinsFolder then
			for _, player in Players:GetPlayers() do
				if player:GetAttribute("OwnsCoinMagnet") then
					local character = player.Character
					local rootPart = character and character:FindFirstChild("HumanoidRootPart")
					if rootPart then
						for _, coin in coinsFolder:GetChildren() do
							if coin:IsA("BasePart") and not coin:GetAttribute("Collected") then
								local offset = rootPart.Position - coin.Position
								local distance = offset.Magnitude
								if distance < MAGNET_RADIUS and distance > 2 then
									coin.Position += (offset / distance) * math.min(MAGNET_PULL_SPEED * 0.1, distance)
								end
							end
						end
					end
				end
			end
		end
	end
end)

local stall = Instance.new("Part")
stall.Name = "ShopStall"
stall.Anchored = true
stall.CanCollide = true
stall.Size = Vector3.new(6, 6, 6)
stall.Position = Vector3.new(0, 3, -70)
stall.Material = Enum.Material.Marble
stall.Color = Color3.fromRGB(255, 215, 0)
stall.Parent = workspace

local sign = Instance.new("Part")
sign.Name = "ShopSign"
sign.Anchored = true
sign.CanCollide = false
sign.Transparency = 1
sign.Size = Vector3.new(1, 1, 1)
sign.Position = stall.Position + Vector3.new(0, 5, 0)
sign.Parent = stall

local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 140, 0, 40)
billboard.AlwaysOnTop = true
billboard.Parent = sign

local signLabel = Instance.new("TextLabel")
signLabel.BackgroundTransparency = 1
signLabel.Size = UDim2.new(1, 0, 1, 0)
signLabel.Text = "🛒 SHOP"
signLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
signLabel.TextStrokeTransparency = 0.4
signLabel.TextScaled = true
signLabel.Font = Enum.Font.GothamBlack
signLabel.Parent = billboard

local prompt = Instance.new("ProximityPrompt")
prompt.Name = "ProximityPrompt"
prompt.ActionText = "Shop"
prompt.ObjectText = "Coin Shop"
prompt.HoldDuration = 0.3
prompt.MaxActivationDistance = 10
prompt.Parent = stall
