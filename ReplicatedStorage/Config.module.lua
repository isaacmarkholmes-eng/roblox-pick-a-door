--[[
	Config.module.lua
	ReplicatedStorage > PickADoor > Config (ModuleScript)
]]

local Config = {}

Config.TOTAL_ROUNDS = 5
Config.DOORS_PER_ROUND = 3

Config.LOBBY_POSITION = Vector3.new(0, 3, 0)
Config.ROOM_OFFSET = Vector3.new(120, 0, 0) -- each round built along +X

Config.ROOM_SIZE = Vector3.new(40, 16, 30)
Config.DOOR_SIZE = Vector3.new(4, 10, 1)
Config.DOOR_SPACING = 8

Config.ROOM_COLORS = {
	Color3.fromRGB(85, 170, 255),
	Color3.fromRGB(255, 170, 85),
	Color3.fromRGB(170, 255, 120),
	Color3.fromRGB(255, 120, 200),
	Color3.fromRGB(200, 200, 90),
}

Config.MESSAGES = {
	wrong = "Wrong door! Back to the lobby.",
	correct = "Correct! Next round...",
	win = "You win! All doors conquered.",
}

return Config
