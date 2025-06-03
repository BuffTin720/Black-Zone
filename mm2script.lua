--[[
📌 MM2 Clone Cheat Menu (Delta Mobile Support)
Features:
- ESP by role (Murderer, Sheriff, Innocents, Dead)
- Auto refresh ESP on player join
- Silent Aim: auto target based on role
- Touch-draggable GUI for phones
]]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Size = UDim2.new(0, 180, 0, 250)
frame.Position = UDim2.new(0.5, -90, 0, 10)
frame.Active = true
frame.Draggable = true

local function createToggle(name, default, callback)
	local toggle = Instance.new("TextButton", frame)
	toggle.Size = UDim2.new(1, -10, 0, 30)
	toggle.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 32)
	toggle.Text = name .. ": " .. (default and "ON" or "OFF")
	toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
	toggle.TextColor3 = Color3.new(1, 1, 1)
	toggle.TextSize = 14
	local state = default
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = name .. ": " .. (state and "ON" or "OFF")
		callback(state)
	end)
	callback(state)
end

-- ESP
local enabledESP = true
local showDead = true
local highlights = {}

local roleColors = {
	Murderer = Color3.fromRGB(255, 0, 0),
	Sheriff = Color3.fromRGB(0, 100, 255),
	Innocent = Color3.fromRGB(0, 255, 0),
	Dead = Color3.fromRGB(80, 80, 80),
}

local function getRole(player)
	if player:FindFirstChild("Data") then
		local role = player.Data:FindFirstChild("Role")
		if role then return role.Value end
	end
	return "Innocent"
end

local function isDead(player)
	return player:FindFirstChild("Data") and player.Data:FindFirstChild("Dead") and player.Data.Dead.Value
end

local function applyESP(player)
	if player == LocalPlayer then return end
	if highlights[player] then highlights[player]:Destroy() end

	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	local hl = Instance.new("Highlight")
	hl.Name = "ESP_HL"
	hl.Adornee = char
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.FillTransparency = 1
	hl.OutlineColor = roleColors[getRole(player)] or Color3.new(1, 1, 1)
	hl.OutlineTransparency = isDead(player) and (showDead and 0 or 1) or 0
	hl.Parent = char
	highlights[player] = hl
end

local function refreshESP()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			applyESP(player)
		end
	end
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		wait(1)
		applyESP(p)
	end)
end)

RunService.RenderStepped:Connect(function()
	if not enabledESP then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			applyESP(player)
		end
	end
end)

-- Silent Aim
local silentAimEnabled = false

local function getClosestTarget()
	local minDist, closest = math.huge, nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not isDead(player) then
			local pos, visible = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
			if visible then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)).Magnitude
				if dist < minDist then
					minDist = dist
					closest = player
				end
			end
		end
	end
	return closest
end

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
	local args = {...}
	local method = getnamecallmethod()
	if silentAimEnabled and method == "FireServer" and tostring(self) == "ShootGun" then
		local target = getClosestTarget()
		if target and getRole(target) == "Murderer" then
			args[1] = target.Character and target.Character:FindFirstChild("HumanoidRootPart").Position or args[1]
		end
		return oldNamecall(self, unpack(args))
	elseif silentAimEnabled and method == "FireServer" and tostring(self) == "ThrowKnife" then
		local target = getClosestTarget()
		if target then
			args[1] = target.Character and target.Character:FindFirstChild("HumanoidRootPart").Position or args[1]
		end
		return oldNamecall(self, unpack(args))
	end
	return oldNamecall(self, ...)
end)

-- GUI toggles
createToggle("ESP", true, function(v) enabledESP = v end)
createToggle("Show Dead", true, function(v) showDead = v end)
createToggle("Silent Aim", false, function(v) silentAimEnabled = v end)
