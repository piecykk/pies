-- Animated shop panel: opens from a world ProximityPrompt, buys items through the PurchaseItem remote.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ShopConfig = require(ReplicatedStorage:WaitForChild("ShopConfig"))
local purchaseItem = ReplicatedStorage:WaitForChild("PurchaseItem")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function corner(instance, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = radius or UDim.new(0, 12)
	c.Parent = instance
	return c
end

local function stroke(instance, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.new(1, 1, 1)
	s.Thickness = thickness or 1.5
	s.Transparency = transparency or 0.3
	s.Parent = instance
	return s
end

local function gradient(instance, colorSequence, rotation)
	local g = Instance.new("UIGradient")
	g.Color = colorSequence
	g.Rotation = rotation or 0
	g.Parent = instance
	return g
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ShopGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10
screenGui.Enabled = false
screenGui.Parent = playerGui

local dim = Instance.new("TextButton")
dim.Name = "Dim"
dim.AutoButtonColor = false
dim.Text = ""
dim.BackgroundColor3 = Color3.new(0, 0, 0)
dim.BackgroundTransparency = 1
dim.Size = UDim2.fromScale(1, 1)
dim.ZIndex = 1
dim.Parent = screenGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(0, 0)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
panel.ClipsDescendants = true
panel.ZIndex = 2
panel.Parent = screenGui
corner(panel, UDim.new(0, 20))
stroke(panel, Color3.fromRGB(120, 110, 255), 2, 0.2)
gradient(panel, ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(32, 32, 46)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 24)),
}), 45)

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(24, 16)
titleLabel.Size = UDim2.new(1, -100, 0, 36)
titleLabel.Text = "✦ COIN SHOP ✦"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 26
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.ZIndex = 3
titleLabel.Parent = panel

local titleGradient = gradient(titleLabel, ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 210, 90)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 210)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 170, 255)),
}))

local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.Position = UDim2.new(1, -48, 0, 14)
closeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 18
closeButton.ZIndex = 3
closeButton.Parent = panel
corner(closeButton, UDim.new(1, 0))

local balanceLabel = Instance.new("TextLabel")
balanceLabel.Name = "Balance"
balanceLabel.BackgroundTransparency = 1
balanceLabel.Position = UDim2.fromOffset(24, 50)
balanceLabel.Size = UDim2.new(1, -48, 0, 22)
balanceLabel.Text = "🪙 0 coins"
balanceLabel.TextXAlignment = Enum.TextXAlignment.Left
balanceLabel.Font = Enum.Font.GothamMedium
balanceLabel.TextSize = 15
balanceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
balanceLabel.ZIndex = 3
balanceLabel.Parent = panel

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Items"
scroll.Position = UDim2.fromOffset(20, 84)
scroll.Size = UDim2.new(1, -40, 1, -104)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 110, 255)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ZIndex = 3
scroll.Parent = panel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scroll

local buttonsByItemId = {}

local function createItemCard(item, layoutOrder)
	local card = Instance.new("Frame")
	card.Name = item.Id
	card.LayoutOrder = layoutOrder
	card.Size = UDim2.new(1, 0, 0, 76)
	card.BackgroundColor3 = Color3.fromRGB(34, 34, 48)
	card.ZIndex = 3
	card.Parent = scroll
	corner(card, UDim.new(0, 14))
	local cardStroke = stroke(card, item.Color, 1.5, 0.5)

	local iconBg = Instance.new("Frame")
	iconBg.Size = UDim2.fromOffset(52, 52)
	iconBg.Position = UDim2.fromOffset(12, 12)
	iconBg.BackgroundColor3 = item.Color
	iconBg.BackgroundTransparency = 0.75
	iconBg.ZIndex = 3
	iconBg.Parent = card
	corner(iconBg, UDim.new(0, 10))

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Size = UDim2.fromOffset(52, 52)
	icon.Position = UDim2.fromOffset(12, 12)
	icon.Text = item.Icon
	icon.TextSize = 26
	icon.Font = Enum.Font.GothamBold
	icon.ZIndex = 4
	icon.Parent = card

	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(76, 10)
	nameLabel.Size = UDim2.new(1, -180, 0, 20)
	nameLabel.Text = item.Name
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 16
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.ZIndex = 4
	nameLabel.Parent = card

	local descLabel = Instance.new("TextLabel")
	descLabel.BackgroundTransparency = 1
	descLabel.Position = UDim2.fromOffset(76, 32)
	descLabel.Size = UDim2.new(1, -180, 0, 36)
	descLabel.Text = item.Description
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 12
	descLabel.TextColor3 = Color3.fromRGB(190, 190, 200)
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.ZIndex = 4
	descLabel.Parent = card

	local buyButton = Instance.new("TextButton")
	buyButton.Name = "Buy"
	buyButton.Size = UDim2.fromOffset(90, 40)
	buyButton.Position = UDim2.new(1, -102, 0.5, -20)
	buyButton.BackgroundColor3 = item.Color
	buyButton.Text = item.Cost .. " 🪙"
	buyButton.Font = Enum.Font.GothamBold
	buyButton.TextSize = 15
	buyButton.TextColor3 = Color3.fromRGB(20, 20, 20)
	buyButton.ZIndex = 4
	buyButton.Parent = card
	corner(buyButton, UDim.new(0, 10))

	card.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 80) }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.15), { Transparency = 0 }):Play()
	end)
	card.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), { Size = UDim2.new(1, 0, 0, 76) }):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.15), { Transparency = 0.5 }):Play()
	end)

	buyButton.MouseButton1Click:Connect(function()
		if not buyButton.Active then
			return
		end

		TweenService:Create(buyButton, TweenInfo.new(0.08), { Size = UDim2.fromOffset(82, 36) }):Play()
		task.delay(0.08, function()
			if buyButton.Parent and buyButton.Active then
				TweenService:Create(buyButton, TweenInfo.new(0.12), { Size = UDim2.fromOffset(90, 40) }):Play()
			end
		end)

		local ok, result = pcall(function()
			return purchaseItem:InvokeServer(item.Id)
		end)

		if ok and result and result.success then
			TweenService:Create(buyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(80, 255, 120) }):Play()
			task.delay(0.3, function()
				if buyButton.Parent then
					TweenService:Create(buyButton, TweenInfo.new(0.3), { BackgroundColor3 = item.Color }):Play()
				end
			end)

			if result.owned then
				buyButton.Text = "OWNED"
				buyButton.AutoButtonColor = false
				buyButton.Active = false
			end
		else
			local originalPosition = buyButton.Position
			TweenService:Create(
				buyButton,
				TweenInfo.new(0.06, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 5, true),
				{ Position = originalPosition + UDim2.fromOffset(6, 0) }
			):Play()
			TweenService:Create(buyButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(255, 80, 80) }):Play()
			task.delay(0.5, function()
				if buyButton.Parent then
					TweenService:Create(buyButton, TweenInfo.new(0.3), { BackgroundColor3 = item.Color }):Play()
				end
			end)
		end
	end)

	buttonsByItemId[item.Id] = buyButton
end

for index, item in ShopConfig.Items do
	createItemCard(item, index)
end

local function refreshOwnedStates()
	for _, item in ShopConfig.Items do
		if not item.Consumable and player:GetAttribute("Owns" .. item.Id) then
			local button = buttonsByItemId[item.Id]
			button.Text = "OWNED"
			button.AutoButtonColor = false
			button.Active = false
			button.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
		end
	end
end

local function updateBalance()
	local leaderstats = player:FindFirstChild("leaderstats")
	local coins = leaderstats and leaderstats:FindFirstChild("Coins")
	balanceLabel.Text = "🪙 " .. (coins and coins.Value or 0) .. " coins"
end

player.AttributeChanged:Connect(refreshOwnedStates)

task.spawn(function()
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins")
	coins.Changed:Connect(updateBalance)
	updateBalance()
end)

local isOpen = false
local closedPanelSize = UDim2.fromOffset(0, 0)
local openPanelSize = UDim2.fromOffset(560, 460)

local function openShop()
	if isOpen then
		return
	end
	isOpen = true
	refreshOwnedStates()
	updateBalance()
	screenGui.Enabled = true
	panel.Size = closedPanelSize
	dim.BackgroundTransparency = 1
	TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 }):Play()
	TweenService:Create(panel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = openPanelSize }):Play()
end

local function closeShop()
	if not isOpen then
		return
	end
	isOpen = false
	TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
	local closeTween = TweenService:Create(panel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = closedPanelSize })
	closeTween:Play()
	closeTween.Completed:Wait()
	if not isOpen then
		screenGui.Enabled = false
	end
end

closeButton.MouseButton1Click:Connect(closeShop)
dim.MouseButton1Click:Connect(closeShop)

task.spawn(function()
	while true do
		task.wait(0.03)
		if screenGui.Enabled then
			titleGradient.Rotation = (titleGradient.Rotation + 2) % 360
		end
	end
end)

local shopStall = workspace:WaitForChild("ShopStall")
local prompt = shopStall:WaitForChild("ProximityPrompt")
prompt.Triggered:Connect(function()
	if isOpen then
		closeShop()
	else
		openShop()
	end
end)
