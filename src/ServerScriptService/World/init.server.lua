-- Builds the ground and spawn point so the game is self-contained regardless of the starting place template.

local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.CanCollide = true
baseplate.Size = Vector3.new(300, 4, 220)
baseplate.Position = Vector3.new(40, -2, -20)
baseplate.Material = Enum.Material.Grass
baseplate.Color = Color3.fromRGB(80, 170, 90)
baseplate.Parent = workspace

local spawnLocation = Instance.new("SpawnLocation")
spawnLocation.Name = "SpawnLocation"
spawnLocation.Anchored = true
spawnLocation.CanCollide = true
spawnLocation.Size = Vector3.new(8, 1, 8)
spawnLocation.Position = Vector3.new(0, 0.5, 20)
spawnLocation.Material = Enum.Material.SmoothPlastic
spawnLocation.Color = Color3.fromRGB(90, 160, 255)
spawnLocation.Duration = 0
spawnLocation.Parent = workspace
