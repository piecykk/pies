-- Single source of truth for shop items, shared by the server (purchases) and client (UI + abilities).

local ShopConfig = {}

ShopConfig.Items = {
	{
		Id = "SonicBoots",
		Name = "Sonic Boots",
		Description = "Permanently boosts your walk speed.",
		Icon = "👟",
		Cost = 30,
		Category = "Upgrade",
		Color = Color3.fromRGB(80, 170, 255),
	},
	{
		Id = "DoubleJump",
		Name = "Double Jump",
		Description = "Jump again while airborne.",
		Icon = "🦘",
		Cost = 50,
		Category = "Upgrade",
		Color = Color3.fromRGB(170, 100, 255),
	},
	{
		Id = "CoinMagnet",
		Name = "Coin Magnet",
		Description = "Nearby coins fly straight to you.",
		Icon = "🧲",
		Cost = 40,
		Category = "Upgrade",
		Color = Color3.fromRGB(255, 100, 180),
	},
	{
		Id = "Dash",
		Name = "Phase Dash",
		Description = "Press Q to burst forward. 4s cooldown.",
		Icon = "💨",
		Cost = 60,
		Category = "Ability",
		Color = Color3.fromRGB(80, 255, 200),
		Cooldown = 4,
	},
	{
		Id = "RocketJump",
		Name = "Rocket Jump",
		Description = "Press R to launch skyward. 6s cooldown.",
		Icon = "🚀",
		Cost = 55,
		Category = "Ability",
		Color = Color3.fromRGB(255, 150, 60),
		Cooldown = 6,
	},
	{
		Id = "CoinRush",
		Name = "Coin Rush",
		Description = "Double coin value for 60 seconds.",
		Icon = "⚡",
		Cost = 25,
		Category = "Boost",
		Color = Color3.fromRGB(255, 220, 60),
		Duration = 60,
		Consumable = true,
	},
}

return ShopConfig
