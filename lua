local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ======== SETTINGS ========
local ESP_UPDATE_INTERVAL = 0.12
local espEnabled = true
local tracked = {}
local noclipEnabled = false

-- ======== CREATE GUI ========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LocalToolsGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,220,0,180)
frame.Position = UDim2.new(0.7,0,0.1,0)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local function makeButton(text,y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-20,0,28)
	btn.Position = UDim2.new(0,10,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.Parent = frame
	return btn
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Local Tools"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16
title.Parent = frame

local playerBox = Instance.new("TextBox")
playerBox.Size = UDim2.new(1,-20,0,24)
playerBox.Position = UDim2.new(0,10,0,30)
playerBox.PlaceholderText = "Player Name"
playerBox.Text = ""
playerBox.TextColor3 = Color3.fromRGB(255,255,255)
playerBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
playerBox.Font = Enum.Font.SourceSans
playerBox.TextSize = 14
playerBox.Parent = frame

local bringBtn = makeButton("Bring Player",64)
local noclipBtn = makeButton("Noclip: OFF",100)
local closeBtn = makeButton("Close GUI",136)

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

bringBtn.MouseButton1Click:Connect(function()
	local name = playerBox.Text
	local target = Players:FindFirstChild(name)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		target.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,3)
	end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = "Noclip: "..(noclipEnabled and "ON" or "OFF")
end)

-- ======== Noclip ========
RunService.Stepped:Connect(function()
	if noclipEnabled and LocalPlayer.Character then
		for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)
