--[[
	GameUI.client.lua
	StarterPlayer > StarterPlayerScripts > GameUI (LocalScript)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local pickADoor = ReplicatedStorage:WaitForChild("PickADoor")
local statusRemote = pickADoor:WaitForChild("Remotes"):WaitForChild("StatusUpdate")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PickADoorUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "StatusFrame"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 16)
frame.Size = UDim2.new(0, 420, 0, 56)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Name = "StatusLabel"
label.Size = UDim2.new(1, -20, 1, -10)
label.Position = UDim2.new(0, 10, 0, 5)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamMedium
label.TextScaled = true
label.TextColor3 = Color3.fromRGB(235, 235, 245)
label.Text = "Pick a Door"
label.Parent = frame

local colors = {
	info = Color3.fromRGB(235, 235, 245),
	good = Color3.fromRGB(120, 255, 160),
	bad = Color3.fromRGB(255, 120, 120),
	win = Color3.fromRGB(255, 220, 80),
}

statusRemote.OnClientEvent:Connect(function(text, kind)
	label.Text = text
	label.TextColor3 = colors[kind] or colors.info
end)
