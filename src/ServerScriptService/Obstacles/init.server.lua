-- Obstacle course: spinning bars, a lava stretch, and a crusher placed in a line away from the coin field.

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CONFIG = {
	SpinBarDamage = 10,
	SpinBarKnockback = 45,
	SpinBarCooldown = 1,

	LavaDamagePerTick = 15,
	LavaTickInterval = 1,

	CrusherDamage = 50,
	CrusherCooldown = 1,
	CrusherTravelTime = 1.2,
	CrusherTopY = 6,
	CrusherBottomY = 1.5,
}

local obstaclesFolder = Instance.new("Folder")
obstaclesFolder.Name = "Obstacles"
obstaclesFolder.Parent = workspace

local function getHumanoid(hit)
	local character = hit.Parent
	if not character then
		return nil
	end
	return character:FindFirstChildOfClass("Humanoid")
end

local function createSpinBar(position, spinSpeed)
	local pole = Instance.new("Part")
	pole.Name = "SpinBarPole"
	pole.Anchored = true
	pole.CanCollide = false
	pole.Size = Vector3.new(1, 6, 1)
	pole.Position = position
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(80, 80, 80)
	pole.Parent = obstaclesFolder

	local bar = Instance.new("Part")
	bar.Name = "SpinBar"
	bar.Anchored = true
	bar.CanCollide = true
	bar.Size = Vector3.new(16, 1, 1)
	bar.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
	bar.Material = Enum.Material.Neon
	bar.Color = Color3.fromRGB(200, 40, 40)
	bar.Parent = obstaclesFolder

	local lastHit = {}
	local angle = 0

	RunService.Heartbeat:Connect(function(dt)
		if not bar.Parent then
			return
		end
		angle += spinSpeed * dt
		bar.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, angle, 0)
	end)

	bar.Touched:Connect(function(hit)
		local humanoid = getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local now = os.clock()
		if lastHit[humanoid] and now - lastHit[humanoid] < CONFIG.SpinBarCooldown then
			return
		end
		lastHit[humanoid] = now

		humanoid:TakeDamage(CONFIG.SpinBarDamage)

		local rootPart = humanoid.RootPart
		if rootPart then
			local awayDirection = (rootPart.Position - bar.Position) * Vector3.new(1, 0, 1)
			if awayDirection.Magnitude < 0.1 then
				awayDirection = Vector3.new(1, 0, 0)
			end
			awayDirection = awayDirection.Unit
			rootPart.AssemblyLinearVelocity = awayDirection * CONFIG.SpinBarKnockback + Vector3.new(0, 20, 0)
		end
	end)
end

local function createLavaStretch(position, size)
	local lava = Instance.new("Part")
	lava.Name = "Lava"
	lava.Anchored = true
	lava.CanCollide = true
	lava.Size = size
	lava.Position = position
	lava.Material = Enum.Material.Neon
	lava.Color = Color3.fromRGB(255, 90, 0)
	lava.Parent = obstaclesFolder

	local touching = {}

	lava.Touched:Connect(function(hit)
		local humanoid = getHumanoid(hit)
		if humanoid then
			touching[humanoid] = true
		end
	end)

	lava.TouchEnded:Connect(function(hit)
		local humanoid = getHumanoid(hit)
		if humanoid then
			touching[humanoid] = nil
		end
	end)

	task.spawn(function()
		while lava.Parent do
			task.wait(CONFIG.LavaTickInterval)
			for humanoid in pairs(touching) do
				if humanoid.Health > 0 then
					humanoid:TakeDamage(CONFIG.LavaDamagePerTick)
				else
					touching[humanoid] = nil
				end
			end
		end
	end)
end

local function createCrusher(position)
	local frame = Instance.new("Part")
	frame.Name = "CrusherFrame"
	frame.Anchored = true
	frame.CanCollide = false
	frame.Size = Vector3.new(1, 8, 8)
	frame.Position = position + Vector3.new(0, 3, 0)
	frame.Transparency = 0.5
	frame.Material = Enum.Material.Metal
	frame.Color = Color3.fromRGB(60, 60, 60)
	frame.Parent = obstaclesFolder

	local crusher = Instance.new("Part")
	crusher.Name = "Crusher"
	crusher.Anchored = true
	crusher.CanCollide = true
	crusher.Size = Vector3.new(1, 1, 8)
	crusher.Position = position + Vector3.new(0, CONFIG.CrusherTopY, 0)
	crusher.Material = Enum.Material.Metal
	crusher.Color = Color3.fromRGB(150, 20, 20)
	crusher.Parent = obstaclesFolder

	local lastHit = {}
	crusher.Touched:Connect(function(hit)
		local humanoid = getHumanoid(hit)
		if not humanoid or humanoid.Health <= 0 then
			return
		end

		local now = os.clock()
		if lastHit[humanoid] and now - lastHit[humanoid] < CONFIG.CrusherCooldown then
			return
		end
		lastHit[humanoid] = now

		humanoid:TakeDamage(CONFIG.CrusherDamage)
	end)

	task.spawn(function()
		local goingDown = true
		while crusher.Parent do
			local targetY = goingDown and CONFIG.CrusherBottomY or CONFIG.CrusherTopY
			local tween = TweenService:Create(
				crusher,
				TweenInfo.new(CONFIG.CrusherTravelTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ Position = position + Vector3.new(0, targetY, 0) }
			)
			tween:Play()
			tween.Completed:Wait()
			task.wait(0.4)
			goingDown = not goingDown
		end
	end)
end

createSpinBar(Vector3.new(60, 0, 0), 1)
createSpinBar(Vector3.new(80, 0, 0), -1.4)
createLavaStretch(Vector3.new(100, 0.5, 0), Vector3.new(10, 1, 16))
createCrusher(Vector3.new(120, 0, 0))
