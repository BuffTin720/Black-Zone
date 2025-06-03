local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Анти-детект (базовый)
local function safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Cheat Error:", result)
        return nil
    end
    return result
end

-- Настройки
local settings = {
    ESP = {
        Enabled = true,
        ShowDead = true,
        Transparency = 0.7,
        Thickness = 1,
        RefreshRate = 1 -- сек
    },
    Aim = {
        Enabled = false,
        Priority = "Murderer", -- Murderer | Sheriff | Innocent
        FOV = 100, -- градусы
        Smoothing = 0.2 -- 0-1
    },
    GUI = {
        Transparency = 0.3,
        Size = UDim2.new(0, 200, 0, 300)
    }
}

-- Логирование
local logHistory = {}
local function logAction(message)
    table.insert(logHistory, os.date("%X") .. ": " .. message)
    if #logHistory > 20 then table.remove(logHistory, 1) end
end

-- GUI
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "CheatUI_" .. math.random(1000,9999)
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = settings.GUI.Transparency
frame.Size = settings.GUI.Size
frame.Position = UDim2.new(0.5, -frame.Size.X.Offset/2, 0, 10)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "MM2 Cheat v2.0"
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40,40,40)
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 16

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
        safeCall(callback, state)
        logAction(name .. (state and " enabled" or " disabled"))
    end)
    safeCall(callback, state)
end

local function createSlider(name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame", frame)
    sliderFrame.Size = UDim2.new(1, -10, 0, 40)
    sliderFrame.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 32)
    sliderFrame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel", sliderFrame)
    label.Text = name .. ": " .. default
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    
    local slider = Instance.new("TextButton", sliderFrame)
    slider.Size = UDim2.new(1, 0, 0, 15)
    slider.Position = UDim2.new(0, 0, 0, 20)
    slider.BackgroundColor3 = Color3.fromRGB(60,60,60)
    slider.Text = ""
    
    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    
    local value = default
    slider.MouseButton1Down:Connect(function(x)
        local percent = math.clamp((x - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        value = math.floor(min + (max - min) * percent)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. value
        safeCall(callback, value)
    end)
    
    safeCall(callback, default)
end

-- ESP
local highlights = {}
local lastRefresh = 0

local roleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 150, 255),
    Innocent = Color3.fromRGB(50, 255, 50),
    Dead = Color3.fromRGB(100, 100, 100),
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
    if player == LocalPlayer or not settings.ESP.Enabled then 
        if highlights[player] then 
            highlights[player]:Destroy()
            highlights[player] = nil
        end
        return 
    end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    if not highlights[player] then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_" .. player.UserId
        hl.Adornee = char
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 1
        hl.OutlineTransparency = settings.ESP.Transparency
        hl.OutlineThickness = settings.ESP.Thickness
        hl.Parent = char
        highlights[player] = hl
    end

    local hl = highlights[player]
    local role = getRole(player)
    local dead = isDead(player)
    
    hl.OutlineColor = roleColors[role] or Color3.new(1, 1, 1)
    hl.OutlineTransparency = dead and (settings.ESP.ShowDead and settings.ESP.Transparency or 1) or settings.ESP.Transparency
end

local function refreshESP()
    if tick() - lastRefresh < settings.ESP.RefreshRate then return end
    lastRefresh = tick()
    
    for _, player in ipairs(Players:GetPlayers()) do
        safeCall(applyESP, player)
    end
end

-- Обработчики событий
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        wait(1)
        safeCall(applyESP, p)
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then 
        highlights[p]:Destroy()
        highlights[p] = nil
    end
end)

RunService.Heartbeat:Connect(function()
    safeCall(refreshESP)
end)

-- Silent Aim
local silentAimTarget = nil
local lastAimUpdate = 0

local function getPriorityValue(role)
    if role == settings.Aim.Priority then return 3 end
    if role == "Murderer" then return 2 end
    if role == "Sheriff" then return 1 end
    return 0
end

local function getBestTarget()
    local bestScore, bestTarget = -math.huge, nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root and not isDead(player) then
                local screenPos, visible = Camera:WorldToViewportPoint(root.Position)
                if visible then
                    local distance = (root.Position - Camera.CFrame.Position).Magnitude
                    local fov = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local fovMagnitude = fov.Magnitude
                    local fovLimit = settings.Aim.FOV * 10
                    
                    if fovMagnitude <= fovLimit then
                        local role = getRole(player)
                        local score = getPriorityValue(role) * 1000 - fovMagnitude - distance / 100
                        
                        if score > bestScore then
                            bestScore = score
                            bestTarget = player
                        end
                    end
                end
            end
        end
    end
    
    return bestTarget
end

local function updateAimTarget()
    if tick() - lastAimUpdate < 0.1 then return end
    lastAimUpdate = tick()
    
    silentAimTarget = settings.Aim.Enabled and getBestTarget() or nil
end

RunService.Heartbeat:Connect(function()
    safeCall(updateAimTarget)
end)

-- Хуки
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if silentAimTarget and silentAimTarget.Character and silentAimTarget.Character:FindFirstChild("HumanoidRootPart") then
        local root = silentAimTarget.Character.HumanoidRootPart
        
        if method == "FireServer" and (tostring(self) == "ShootGun" or tostring(self) == "ThrowKnife") then
            -- Сглаживание прицеливания
            local targetPos = root.Position
            if settings.Aim.Smoothing > 0 then
                local currentPos = args[1]
                targetPos = currentPos + (targetPos - currentPos) * settings.Aim.Smoothing
            end
            
            args[1] = targetPos
            logAction("Aiming at " .. silentAimTarget.Name)
            return oldNamecall(self, unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Создание элементов GUI
createToggle("ESP", settings.ESP.Enabled, function(v) 
    settings.ESP.Enabled = v 
    if not v then
        for _, hl in pairs(highlights) do
            hl:Destroy()
        end
        highlights = {}
    end
end)

createToggle("Show Dead", settings.ESP.ShowDead, function(v) 
    settings.ESP.ShowDead = v 
end)

createToggle("Silent Aim", settings.Aim.Enabled, function(v) 
    settings.Aim.Enabled = v 
end)

createSlider("ESP Transparency", 0, 100, settings.ESP.Transparency * 100, function(v)
    settings.ESP.Transparency = v / 100
end)

createSlider("Aim FOV", 10, 360, settings.Aim.FOV, function(v)
    settings.Aim.FOV = v
end)

createSlider("Aim Smoothing", 0, 100, settings.Aim.Smoothing * 100, function(v)
    settings.Aim.Smoothing = v / 100
end)

-- Выбор приоритета цели
local priorityFrame = Instance.new("Frame", frame)
priorityFrame.Size = UDim2.new(1, -10, 0, 60)
priorityFrame.Position = UDim2.new(0, 5, 0, #frame:GetChildren() * 32)
priorityFrame.BackgroundTransparency = 1

local priorityLabel = Instance.new("TextLabel", priorityFrame)
priorityLabel.Text = "Aim Priority:"
priorityLabel.Size = UDim2.new(1, 0, 0, 20)
priorityLabel.TextColor3 = Color3.new(1,1,1)
priorityLabel.TextSize = 14
priorityLabel.BackgroundTransparency = 1

local priorities = {"Murderer", "Sheriff", "Innocent"}
local currentPriority = 1

local priorityBtn = Instance.new("TextButton", priorityFrame)
priorityBtn.Text = priorities[currentPriority]
priorityBtn.Size = UDim2.new(1, 0, 0, 30)
priorityBtn.Position = UDim2.new(0, 0, 0, 25)
priorityBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
priorityBtn.TextColor3 = Color3.new(1,1,1)

priorityBtn.MouseButton1Click:Connect(function()
    currentPriority = currentPriority % #priorities + 1
    priorityBtn.Text = priorities[currentPriority]
    settings.Aim.Priority = priorities[currentPriority]
    logAction("Aim priority set to " .. priorities[currentPriority])
end)

logAction("Cheat script loaded successfully!")
