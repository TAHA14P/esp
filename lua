-- esp_bring_noclip.lua
-- LocalScript: StarterPlayer -> StarterPlayerScripts
-- ESP + Bring Players GUI + Noclip (mobile-friendly, client-only)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ============ CONFIG ============
local UPDATE_INTERVAL = 0.12
local SHOW_TEAMMATES = true
local PLAYER_FILL_COLOR = Color3.fromRGB(85, 170, 255) -- blue
local NPC_FILL_COLOR = Color3.fromRGB(120, 255, 120)   -- green
local PLAYER_FILL_TRANSPARENCY = 0.6
local NPC_FILL_TRANSPARENCY = 0.55
local OUTLINE_COLOR = Color3.fromRGB(10,10,10)
local OUTLINE_TRANSPARENCY = 0
local BILLBOARD_SIZE = UDim2.new(0,140,0,28)
local BILLBOARD_OFFSET = Vector3.new(0,2.4,0)
local TEXT_SIZE = 14

-- ============ STATE ============
local espEnabled = true
local tracked = {} -- [model] = {highlight, billboard, label, humanoid, head, isPlayer}
local noclipEnabled = false

-- ================= HELPERS =================
local function isPlayerModel(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

local function makeHighlight(model, isPlayer)
	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.Adornee = model
	highlight.Enabled = espEnabled
	highlight.FillColor = isPlayer and PLAYER_FILL_COLOR or NPC_FILL_COLOR
	highlight.FillTransparency = isPlayer and PLAYER_FILL_TRANSPARENCY or NPC_FILL_TRANSPARENCY
	highlight.OutlineColor = OUTLINE_COLOR
	highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
	highlight.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return highlight
end

local function makeBillboard(head, displayText)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_Billboard"
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.Size = BILLBOARD_SIZE
	billboard.StudsOffset = BILLBOARD_OFFSET
	billboard.MaxDistance = 2000
	billboard.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 0.6
	label.BackgroundColor3 = Color3.fromRGB(0,0,0)
	label.BorderSizePixel = 0
	label.Text = displayText or ""
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextStrokeTransparency = 0.6
	label.TextSize = TEXT_SIZE
	label.Font = Enum.Font.SourceSansSemibold
	label.TextWrapped = false
	label.Parent = billboard

	return billboard, label
end

local function createEntry(model, isPlayer)
	if not model or not model.Parent then return end
	if tracked[model] then return tracked[model] end

	local head = model:FindFirstChild("Head") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart")
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not head or not hum then return end

	local highlight = makeHighlight(model, isPlayer)
	local billboard, label = makeBillboard(head, "")

	tracked[model] = {
		model = model,
		highlight = highlight,
		billboard = billboard,
		label = label,
		humanoid = hum,
		head = head,
		isPlayer = isPlayer,
	}
	return tracked[model]
end

local function cleanupEntry(model)
	local entry = tracked[model]
	if not entry then return end
	if entry.highlight and entry.highlight.Parent then entry.highlight:Destroy() end
	if entry.billboard and entry.billboard.Parent then entry.billboard:Destroy() end
	tracked[model] = nil
end

local function updateEntry(entry)
	if not entry or not entry.model or not entry.model.Parent then
		if entry and entry.model then cleanupEntry(entry.model) end
		return
	end

	if entry.highlight and entry.highlight.Parent then
		entry.highlight.FillColor = entry.isPlayer and PLAYER_FILL_COLOR or NPC_FILL_COLOR
		entry.highlight.FillTransparency = entry.isPlayer and PLAYER_FILL_TRANSPARENCY or NPC_FILL_TRANSPARENCY
		entry.highlight.Enabled = espEnabled
	end

	-- update text
	local nameText = ""
	if entry.isPlayer then
		local pl = Players:GetPlayerFromCharacter(entry.model)
		local hum = entry.humanoid
		if hum then
			local h = math.max(0, math.floor(hum.Health+0.5))
			local mh = math.max(1, math.floor(hum.MaxHealth+0.5))
			nameText = string.format("%s | %d/%d HP", pl.Name, h, mh)
		end
	else
		local hum = entry.humanoid
		if hum then
			nameText = string.format("%s | %d HP", entry.model.Name or "NPC", math.floor(hum.Health+0.5))
		else
			nameText = entry.model.Name or "NPC"
		end
	end

	if entry.label and entry.label.Parent then
		entry.label.Text = nameText
	end
end

local function refreshESP()
	-- players
	for _, p in ipairs(Players:GetPlayers()) do
		local char = p.Character
		if char and char.Parent and p ~= LocalPlayer then
			if SHOW_TEAMMATES == false and p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team then
				cleanupEntry(char)
			else
				createEntry(char, true)
			end
		elseif char then
			cleanupEntry(char)
		end
	end

	-- NPCs
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
			if not Players:GetPlayerFromCharacter(obj) then
				if obj ~= LocalPlayer.Character then
					createEntry(obj, false)
				end
			end
		end
	end

	-- cleanup invalid
	for model, _ in pairs(tracked) do
		if not model or not model.Parent then cleanupEntry(model) end
	end
end

-- ============ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LocalToolsGUI"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,200,0,180)
mainFrame.Position = UDim2.new(0.7,0,0.1,0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local function createButton(text, y)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1,-20,0,28)
	btn.Position = UDim2.new(0,10,0,y)
	btn.Text = text
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
	btn.Parent = mainFrame
	btn.AutoButtonColor = true
	btn.ClipsDescendants = true
	btn.BorderSizePixel = 0
	btn.BackgroundTransparency = 0
	return btn
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Local Tools"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14
title.Parent = mainFrame

local bringBox = Instance.new("TextBox")
bringBox.Size = UDim2.new(1,-20,0,24)
bringBox.Position = UDim2.new(0,10,0,30)
bringBox.PlaceholderText = "Player Name"
bringBox.Text = ""
bringBox.TextColor3 = Color3.fromRGB(255,255,255)
bringBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
bringBox.Font = Enum.Font.SourceSans
bringBox.TextSize = 14
bringBox.Parent = mainFrame

local bringBtn = createButton("Bring",64)
local noclipBtn = createButton("Noclip: OFF", 100)
local closeBtn = createButton("Close", 136)

closeBtn.MouseButton1Click:Connect(function()
	screenGui.Enabled = false
end)

-- Bring Function
bringBtn.MouseButton1Click:Connect(function()
	local name = bringBox.Text
	local target = Players:FindFirstChild(name)
	if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local targetHRP = target.Character.HumanoidRootPart
		local localHRP = LocalPlayer.Character.HumanoidRootPart
		targetHRP.CFrame = localHRP.CFrame + Vector3.new(0,0,3)
	end
end)

-- Noclip Toggle
noclipBtn.MouseButton1Click:Connect(function()
	noclipEnabled = not noclipEnabled
	noclipBtn.Text = "Noclip: " .. (noclipEnabled and "ON" or "OFF")
end)

-- ============ MAIN LOOPS ============
spawn(function()
	while true do
		refreshESP()
		for _, entry in pairs(tracked) do
			pcall(updateEntry, entry)
		end
		wait(UPDATE_INTERVAL)
	end
end)

RunService.Stepped:Connect(function()
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
	end
end)
