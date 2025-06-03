local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Настройки
local settings = {
    SilentAim = false,
    ESP = true,
    ShowAlive = true,
    ShowDead = false,
}

-- Цвета ролей
local roleColors = {
    ["Murderer"] = Color3.fromRGB(255, 0, 0),    -- Красный
    ["Sheriff"] = Color3.fromRGB(0, 0, 255),     -- Синий
    ["Innocent"] = Color3.fromRGB(0, 255, 0),    -- Зеленый
    ["Dead"] = Color3.fromRGB(128, 128, 128),    -- Серый
}

-- Получить роль игрока (подстрой под твоего клона)
local function getRole(plr)
    local stats = plr:FindFirstChild("leaderstats")
    if stats then
        local role = stats:FindFirstChild("Role")
        if role then
            return role.Value
        end
    end
    return "Innocent"
end

-- Проверка жив ли игрок
local function isAlive(plr)
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            return hum.Health > 0
        end
    end
    return false
end

-- Проверка видимости через Raycast (на голову)
local function canSee(plr)
    if not plr.Character then return false end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return false end

    local origin = camera.CFrame.Position
    local direction = (head.Position - origin).Unit * (head.Position - origin).Magnitude

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(plr.Character)
end

-- ESP создание и обновление
local function createESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    if plr.Character.Head:FindFirstChild("ESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = plr.Character.Head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = plr.Character.Head

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Text = ""
end

local function updateESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end

    local billboard = plr.Character.Head:FindFirstChild("ESP")
    if not billboard then
        createESP(plr)
        billboard = plr.Character.Head:FindFirstChild("ESP")
    end

    local label = billboard:FindFirstChildOfClass("TextLabel")
    if not label then return end

    local alive = isAlive(plr)
    if (alive and not settings.ShowAlive) or (not alive and not settings.ShowDead) then
        billboard.Enabled = false
        return
    end

    billboard.Enabled = settings.ESP

    local role = getRole(plr)
    local color = alive and (roleColors[role] or roleColors["Innocent"]) or roleColors["Dead"]

    label.Text = plr.Name .. " | " .. role
    label.TextColor3 = color
end

local function refreshESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            updateESP(plr)
        end
    end
end

-- Найти ближайшего мардера для шерифа (если видит)
local function findMurderer()
    local minDist = math.huge
    local target = nil
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and getRole(plr) == "Murderer" and isAlive(plr) and canSee(plr) then
            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = plr
            end
        end
    end
    return target
end

-- Найти ближайшего живого для мардера (не себя)
local function findClosestTarget()
    local minDist = math.huge
    local target = nil
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local hrp = char.HumanoidRootPart

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and isAlive(plr) and canSee(plr) then
            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = plr
            end
        end
    end
    return target
end

-- Имитация выстрела/удара - замени под свой клон (пример для RemoteEvent)
local shootEvent = game:GetService("ReplicatedStorage"):WaitForChild("ShootEvent") -- замени название под клон

local function shootAt(target)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Пример - в оригинале MM2 может быть другое событие
    shootEvent:FireServer(hrp.Position)
end

-- Логика Silent Aim по нажатию
local function silentAim()
    local role = getRole(player)
    if role == "Sheriff" then
        local target = findMurderer()
        if target then
            shootAt(target)
        end
    elseif role == "Murderer" then
        local target = findClosestTarget()
        if target then
            shootAt(target)
        end
    end
end

-- Обработка нажатия (мышь или экран)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not settings.SilentAim then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        silentAim()
    end
end)

-- Меню с кнопками
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "MM2CheatMenu"
screenGui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 200, 0, 160)
menuFrame.Position = UDim2.new(0.5, -100, 0, 10)
menuFrame.BackgroundColor3 = Color3.new(0, 0, 0)
menuFrame.BackgroundTransparency = 0.5
menuFrame.BorderSizePixel = 0

local function createToggle(text, settingName, yPos)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(0, 180, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text .. " OFF"

    btn.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        btn.Text = text .. (settings[settingName] and " ON" or " OFF")
    end)
    return btn
end

createToggle("Silent Aim", "SilentAim", 10)
createToggle("ESP", "ESP", 50)
createToggle("Show Alive", "ShowAlive", 90)
createToggle("Show Dead", "ShowDead", 130)

-- Постоянное обновление ESP
RunService.RenderStepped:Connect(function()
    if settings.ESP then
        refreshESP()
    else
        -- Скрыть все ESP
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local esp = plr.Character.Head:FindFirstChild("ESP")
                if esp then esp.Enabled = false end
            end
        end
    end
end)
