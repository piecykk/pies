-- Handles activation of purchased abilities (dash, rocket jump, double jump) and their cooldown HUD.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DASH_SPEED = 90
local DASH_COOLDOWN = 4
local ROCKET_POWER = 85
local ROCKET_COOLDOWN = 6
local DOUBLE_JUMP_POWER = 50

local character, humanoid, rootPart
local hasDoubleJumped = false
local cooldownEnds = { Dash = 0, RocketJump = 0 }

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	hasDoubleJumped = false

	humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Landed then
			hasDoubleJumped = false
		end
	end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbilityHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local hudRow = Instance.new("Frame")
hudRow.Name = "AbilityRow"
hudRow.AnchorPoint = Vector2.new(0.5, 1)
hudRow.Position = UDim2.new(0.5, 0, 1, -24)
hudRow.Size = UDim2.new(0, 120, 0, 56)
hudRow.BackgroundTransparency = 1
hudRow.Parent = screenGui

local hudLayout = Instance.new("UIListLayout")
hudLayout.FillDirection = Enum.FillDirection.Horizontal
hudLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
hudLayout.Padding = UDim.new(0, 10)
hudLayout.Parent = hudRow

local hudIcons = {}

local function createHudIcon(id, icon, keyLabel, color)
	local frame = Instance.new("Frame")
	frame.Name = id
	frame.Size = UDim2.fromOffset(52, 52)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
	frame.BackgroundTransparency = 0.2
	frame.Visible = false
	frame.Parent = hudRow

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.Parent = frame

	local iconLabel = Instance.new("TextLabel")
	iconLabel.BackgroundTransparency = 1
	iconLabel.Size = UDim2.fromScale(1, 1)
	iconLabel.Text = icon
	iconLabel.TextSize = 24
	iconLabel.Font = Enum.Font.GothamBold
	iconLabel.ZIndex = 2
	iconLabel.Parent = frame

	local cooldownOverlay = Instance.new("Frame")
	cooldownOverlay.Name = "Cooldown"
	cooldownOverlay.AnchorPoint = Vector2.new(0, 1)
	cooldownOverlay.Position = UDim2.fromScale(0, 1)
	cooldownOverlay.Size = UDim2.fromScale(1, 0)
	cooldownOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	cooldownOverlay.BackgroundTransparency = 0.35
	cooldownOverlay.ZIndex = 3
	cooldownOverlay.Parent = frame

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 12)
	overlayCorner.Parent = cooldownOverlay

	local keyTag = Instance.new("TextLabel")
	keyTag.AnchorPoint = Vector2.new(1, 1)
	keyTag.Position = UDim2.new(1, -2, 1, -2)
	keyTag.Size = UDim2.fromOffset(16, 14)
	keyTag.BackgroundTransparency = 1
	keyTag.Text = keyLabel
	keyTag.Font = Enum.Font.GothamBold
	keyTag.TextSize = 12
	keyTag.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyTag.ZIndex = 4
	keyTag.Parent = frame

	hudIcons[id] = { frame = frame, cooldownOverlay = cooldownOverlay }
end

createHudIcon("Dash", "💨", "Q", Color3.fromRGB(80, 255, 200))
createHudIcon("RocketJump", "🚀", "R", Color3.fromRGB(255, 150, 60))

local function refreshHudVisibility()
	hudIcons.Dash.frame.Visible = player:GetAttribute("OwnsDash") == true
	hudIcons.RocketJump.frame.Visible = player:GetAttribute("OwnsRocketJump") == true
end

refreshHudVisibility()
player.AttributeChanged:Connect(refreshHudVisibility)

local function playCooldown(id, duration)
	local hud = hudIcons[id]
	if not hud then
		return
	end
	hud.cooldownOverlay.Size = UDim2.fromScale(1, 1)
	TweenService:Create(hud.cooldownOverlay, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 0) }):Play()
end

local function tryDash()
	if not (rootPart and humanoid) then
		return
	end
	if not player:GetAttribute("OwnsDash") then
		return
	end
	if os.clock() < cooldownEnds.Dash then
		return
	end
	cooldownEnds.Dash = os.clock() + DASH_COOLDOWN
	playCooldown("Dash", DASH_COOLDOWN)

	local direction = humanoid.MoveDirection
	if direction.Magnitude < 0.1 then
		direction = rootPart.CFrame.LookVector
	end
	direction = Vector3.new(direction.X, 0, direction.Z).Unit
	rootPart.AssemblyLinearVelocity = direction * DASH_SPEED + Vector3.new(0, 8, 0)
end

local function tryRocketJump()
	if not (rootPart and humanoid) then
		return
	end
	if not player:GetAttribute("OwnsRocketJump") then
		return
	end
	if os.clock() < cooldownEnds.RocketJump then
		return
	end
	cooldownEnds.RocketJump = os.clock() + ROCKET_COOLDOWN
	playCooldown("RocketJump", ROCKET_COOLDOWN)

	rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, ROCKET_POWER, rootPart.AssemblyLinearVelocity.Z)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Q then
		tryDash()
	elseif input.KeyCode == Enum.KeyCode.R then
		tryRocketJump()
	end
end)

UserInputService.JumpRequest:Connect(function()
	if not (humanoid and rootPart) then
		return
	end
	if not player:GetAttribute("OwnsDoubleJump") then
		return
	end
	if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
		return
	end
	if hasDoubleJumped then
		return
	end
	hasDoubleJumped = true
	rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, DOUBLE_JUMP_POWER, rootPart.AssemblyLinearVelocity.Z)
end)
