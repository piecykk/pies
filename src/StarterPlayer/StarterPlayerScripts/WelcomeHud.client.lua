-- A one-time onboarding panel explaining the game loop, which collapses into a reopenable "?" button.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WelcomeHud"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Position = UDim2.fromOffset(20, 20)
panel.Size = UDim2.fromOffset(300, 190)
panel.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
panel.BackgroundTransparency = 1
panel.ClipsDescendants = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 16)
panelCorner.Parent = panel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(120, 110, 255)
panelStroke.Thickness = 2
panelStroke.Transparency = 1
panelStroke.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.new(1, -32, 0, 26)
title.Text = "👋 Welcome!"
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTransparency = 1
title.Parent = panel

local body = Instance.new("TextLabel")
body.BackgroundTransparency = 1
body.Position = UDim2.fromOffset(16, 44)
body.Size = UDim2.new(1, -32, 0, 130)
body.Text = "🪙 Collect coins scattered around\n🏃 Clear the obstacle course (east) for a bonus\n🛒 Visit the shop (south) for upgrades\n💨 Q and 🚀 R activate abilities you own"
body.Font = Enum.Font.Gotham
body.TextSize = 14
body.TextColor3 = Color3.fromRGB(210, 210, 220)
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.TextTransparency = 1
body.Parent = panel

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "Reopen"
reopenButton.Position = UDim2.fromOffset(20, 20)
reopenButton.Size = UDim2.fromOffset(40, 40)
reopenButton.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
reopenButton.Text = "?"
reopenButton.Font = Enum.Font.GothamBlack
reopenButton.TextSize = 20
reopenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
reopenButton.Visible = false
reopenButton.Parent = screenGui

local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(1, 0)
reopenCorner.Parent = reopenButton

local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(120, 110, 255)
reopenStroke.Thickness = 2
reopenStroke.Parent = reopenButton

local function fadeInPanel()
	panel.Visible = true
	reopenButton.Visible = false
	TweenService:Create(panel, TweenInfo.new(0.35), { BackgroundTransparency = 0.15 }):Play()
	TweenService:Create(panelStroke, TweenInfo.new(0.35), { Transparency = 0.2 }):Play()
	TweenService:Create(title, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
	TweenService:Create(body, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
end

local function collapsePanel()
	TweenService:Create(panel, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(panelStroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
	TweenService:Create(title, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
	local bodyFade = TweenService:Create(body, TweenInfo.new(0.3), { TextTransparency = 1 })
	bodyFade:Play()
	bodyFade.Completed:Wait()
	panel.Visible = false
	reopenButton.Visible = true
end

fadeInPanel()
task.delay(12, collapsePanel)

reopenButton.MouseButton1Click:Connect(fadeInPanel)
