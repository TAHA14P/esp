-- esp.lua
-- Local ESP script: highlights all players so only the local player can see them.

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function createESP(character, player)
	if not character:FindFirstChild("HumanoidRootPart") then return end

	-- Highlight (client-side only)
	local highlight = Instance.new("Highlight")
	highlight.Name = "LocalESP"
	highlight.FillColor = Color3.fromRGB(255, 50, 50)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.75
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character
	
	-- Billboard with name + HP
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameHealth"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = character:WaitForChild("Head")

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0
	text.Font = Enum.Font.SourceSansBold
	text.TextScaled = true
	text.Parent = billboard

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	RunService.RenderStepped:Connect(function()
		if humanoid then
			text.Text = string.format("%s | %d HP", player.Name, math.floor(humanoid.Health))
		end
	end)
end

local function onPlayerAdded(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		char:WaitForChild("Head", 10)
		createESP(char, player)
	end)
	if player.Character then
		createESP(player.Character, player)
	end
end

for _, plr in ipairs(Players:GetPlayers()) do
	onPlayerAdded(plr)
end
Players.PlayerAdded:Connect(onPlayerAdded)
