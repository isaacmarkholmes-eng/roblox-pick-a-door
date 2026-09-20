--[[
	GameManager.server.lua
	ServerScriptService > PickADoor > GameManager (Script)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("PickADoor"):WaitForChild("Config"))

local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage:WaitForChild("PickADoor")

local statusRemote = Instance.new("RemoteEvent")
statusRemote.Name = "StatusUpdate"
statusRemote.Parent = remotesFolder

local playerState = {}

local function sendStatus(player, text, kind)
	statusRemote:FireClient(player, text, kind or "info")
end

local function getState(player)
	if not playerState[player] then
		playerState[player] = {
			round = 1,
			busy = false,
			room = nil,
			winningDoor = nil,
		}
	end
	return playerState[player]
end

local function createPart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in pairs(props) do
		part[key] = value
	end
	return part
end

local function buildLobby()
	local existing = Workspace:FindFirstChild("PickADoorLobby")
	if existing then
		return existing
	end

	local lobby = Instance.new("Folder")
	lobby.Name = "PickADoorLobby"
	lobby.Parent = Workspace

	local floor = createPart({
		Name = "LobbyFloor",
		Size = Vector3.new(50, 1, 50),
		Position = Config.LOBBY_POSITION + Vector3.new(0, -0.5, 0),
		Color = Color3.fromRGB(60, 60, 70),
		Material = Enum.Material.Concrete,
		Parent = lobby,
	})

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LobbySpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Config.LOBBY_POSITION + Vector3.new(0, 0.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(120, 255, 120)
	spawn.Material = Enum.Material.Neon
	spawn.Parent = lobby

	local sign = createPart({
		Name = "Sign",
		Size = Vector3.new(14, 6, 1),
		Position = Config.LOBBY_POSITION + Vector3.new(0, 5, -18),
		Color = Color3.fromRGB(30, 30, 40),
		Parent = lobby,
	})

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "PICK A DOOR\nStep on the green START pad"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui

	local startPad = createPart({
		Name = "StartPad",
		Size = Vector3.new(8, 1, 8),
		Position = Config.LOBBY_POSITION + Vector3.new(0, 0.5, 10),
		Color = Color3.fromRGB(80, 220, 120),
		Material = Enum.Material.Neon,
		Parent = lobby,
	})

	startPad.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		local state = getState(player)
		if state.busy then
			return
		end
		beginRound(player)
	end)

	return lobby
end

local function clearRoom(state)
	if state.room and state.room.Parent then
		state.room:Destroy()
	end
	state.room = nil
	state.winningDoor = nil
end

local function buildRoom(player, round)
	clearRoom(getState(player))

	local state = getState(player)
	local roomFolder = Instance.new("Folder")
	roomFolder.Name = string.format("%s_Room_R%d", player.Name, round)
	roomFolder.Parent = Workspace

	local origin = Config.LOBBY_POSITION + Config.ROOM_OFFSET * round
	local roomSize = Config.ROOM_SIZE

	local floor = createPart({
		Name = "Floor",
		Size = Vector3.new(roomSize.X, 1, roomSize.Z),
		Position = origin + Vector3.new(0, -0.5, 0),
		Color = Color3.fromRGB(45, 45, 55),
		Material = Enum.Material.Slate,
		Parent = roomFolder,
	})

	local wallHeight = roomSize.Y
	local backWall = createPart({
		Name = "BackWall",
		Size = Vector3.new(roomSize.X, wallHeight, 1),
		Position = origin + Vector3.new(0, wallHeight / 2, -roomSize.Z / 2),
		Color = Color3.fromRGB(35, 35, 45),
		Parent = roomFolder,
	})

	local winningIndex = math.random(1, Config.DOORS_PER_ROUND)
	state.winningDoor = winningIndex
	state.room = roomFolder

	local totalWidth = (Config.DOORS_PER_ROUND - 1) * Config.DOOR_SPACING
	local startX = -totalWidth / 2

	for i = 1, Config.DOORS_PER_ROUND do
		local doorColor = Config.ROOM_COLORS[((round + i - 2) % #Config.ROOM_COLORS) + 1]
		local door = createPart({
			Name = "Door_" .. i,
			Size = Config.DOOR_SIZE,
			Position = origin
				+ Vector3.new(startX + (i - 1) * Config.DOOR_SPACING, Config.DOOR_SIZE.Y / 2, roomSize.Z / 2 - 2),
			Color = doorColor,
			Material = Enum.Material.SmoothPlastic,
			Parent = roomFolder,
		})
		door:SetAttribute("DoorIndex", i)

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Open"
		prompt.ObjectText = "Door " .. i
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.Parent = door

		prompt.Triggered:Connect(function(triggerPlayer)
			if triggerPlayer ~= player then
				return
			end
			handleDoorChoice(player, i)
		end)
	end

	local title = createPart({
		Name = "RoundSign",
		Size = Vector3.new(10, 3, 1),
		Position = origin + Vector3.new(0, wallHeight - 2, -roomSize.Z / 2 + 0.6),
		Color = Color3.fromRGB(25, 25, 30),
		Parent = roomFolder,
	})

	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Front
	surface.Parent = title

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = string.format("Round %d / %d", round, Config.TOTAL_ROUNDS)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Parent = surface

	-- Teleport player into the room
	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(origin + Vector3.new(0, 3, -roomSize.Z / 2 + 8))
		end
	end

	return roomFolder
end

function handleDoorChoice(player, doorIndex)
	local state = getState(player)
	if state.busy or not state.winningDoor then
		return
	end

	state.busy = true

	if doorIndex == state.winningDoor then
		sendStatus(player, Config.MESSAGES.correct, "good")
		task.wait(0.8)

		if state.round >= Config.TOTAL_ROUNDS then
			playerWins(player)
		else
			state.round += 1
			buildRoom(player, state.round)
			sendStatus(player, string.format("Round %d — pick wisely!", state.round), "info")
		end
	else
		sendStatus(player, Config.MESSAGES.wrong, "bad")
		task.wait(0.5)
		resetPlayerToLobby(player)
	end

	state.busy = false
end

function resetPlayerToLobby(player)
	local state = getState(player)
	state.round = 1
	clearRoom(state)

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end

	sendStatus(player, "Round 1 — try again from the START pad.", "info")
end

function playerWins(player)
	local state = getState(player)
	clearRoom(state)
	state.round = 1

	sendStatus(player, Config.MESSAGES.win, "win")

	local winPad = createPart({
		Name = "WinPad_" .. player.UserId,
		Size = Vector3.new(10, 1, 10),
		Position = Config.LOBBY_POSITION + Vector3.new(0, 0.5, -10),
		Color = Color3.fromRGB(255, 215, 0),
		Material = Enum.Material.Neon,
		Parent = Workspace:FindFirstChild("PickADoorLobby") or Workspace,
	})

	task.delay(8, function()
		if winPad.Parent then
			winPad:Destroy()
		end
	end)

	local character = player.Character
	if character then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(Config.LOBBY_POSITION + Vector3.new(0, 3, -10))
		end
	end
end

function beginRound(player)
	local state = getState(player)
	state.round = 1
	state.busy = false
	buildRoom(player, state.round)
	sendStatus(player, string.format("Round %d — one door is correct!", state.round), "info")
end

local function onPlayerAdded(player)
	getState(player)
	player.CharacterAdded:Connect(function()
		sendStatus(player, "Welcome! Step on the green START pad.", "info")
	end)
end

Players.PlayerRemoving:Connect(function(player)
	clearRoom(getState(player))
	playerState[player] = nil
end)

buildLobby()

for _, player in Players:GetPlayers() do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)

print("[PickADoor] Game loaded.")
