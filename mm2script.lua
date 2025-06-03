-- Roblox LocalScript для клона Murder Mystery 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Настройки меню и функций
local settings = {
    SilentAim = false,
    ESP = true,
    ShowAlive = true,
    ShowDead = false,
}

-- Цвета ролей для ESP
local roleColors = {
    Murderer = Color3.new(1, 0, 0),       -- красный
    Sheriff = Color3.new(0, 0, 1),        -- синий
    Innocent = Color3.new(0, 1, 0),       -- зелёный
    Dead = Color3.new(0.5, 0.5, 0.5),     -- серый
}

-- Функция для получения роли игрока (подкорректируй под свой клон)
local function getRole(plr)
    local stats = plr:FindFirstChild("leaderstats")
    if stats then
        local role = stats:FindFirstChild("Role")
        if role then return role.Value end
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
    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local camera = workspace.CurrentCamera
    local origin = camera.CFrame.Position
    local direction = (hrp.Position - origin).Unit * (hrp.Position - origin).Magnitude

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {player.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, rayParams)
    if not result then return true end
    return result.Instance:IsDescendantOf(plr.Character)
end

-- Создаём ESP для игрока
local function createESP(plr)
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    if plr.Character.Head:FindFirstChild("ESP") then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = plr.Character.Head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 140, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Parent = plr.Character.Head

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 18
    label.TextStrokeTransparency = 0
    label.TextColor3 = Color3.new(1,1,1)
end

-- Обновляем ESP для игрока (текст и цвет)
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

    -- Управление отображением по настройкам живых/мертвых
    if (alive and not settings.ShowAlive) or (not alive and not settings.ShowDead) then
        billboard.Enabled = false
        return
    end

    billboard.Enabled = settings.ESP

    local role = getRole(plr) or "Innocent"
    local color = alive and roleColors[role] or roleColors.Dead

    label.Text = plr.Name .. " | " .. role
    label.TextColor3 = color
end

-- Обновляем ESP для всех игроков кроме себя
local function refreshESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            updateESP(plr)
        end
    end
end

-- Логика для шерифа: найти ближайшего мардера, которого видит
local function findMurdererForSheriff()
    local minDist = math.huge
    local target = nil
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrpPlayer = player.Character.HumanoidRootPart

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and getRole(plr) == "Murderer" and isAlive(plr) and canSee(plr) then
            local dist = (plr.Character.HumanoidRootPart.Position - hrpPlayer.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = plr
            end
        end
    end
    return target
end

-- Логика для мардера: найти ближайшего живого игрока (кроме себя)
local function findClosestTargetForMurderer()
    local minDist = math.huge
    local target = nil
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local hrpPlayer = player.Character.HumanoidRootPart

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and isAlive(plr) and canSee(plr) then
            local dist = (plr.Character.HumanoidRootPart.Position - hrpPlayer.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = plr
            end
        end
    end
    return target
end

-- Имитация выстрела/удара (подставь свои эвенты)
local function shootAt(target)
    if not target or not target.Character then return end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    print("Выстрел по " .. target.Name .. " в позицию " .. tostring(hrp.Position))

    -- Пример вызова события выстрела — подставь своё:
    -- game.ReplicatedStorage.ShootEvent:FireServer(hrp.Position)
end

-- Функция Silent Aim, вызывается при клике/нажатии экрана
local function silentAim()
    local role = getRole(player)
    if role == "Sheriff" then
        local target = findMurdererForSheriff()
        if target then
            shootAt(target)
        end
    elseif role == "Murderer" then
        local target = findClosestTargetForMurderer()
        if target then
            shootAt(target)
        end
    end
end

-- Обработчик нажатия для мобильных и ПК
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not settings.SilentAim then return end

    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        silentAim()
    end
end)

-- Меню — черный полупрозрачный квадрат сверху по центру с кнопками
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CheatMenu"
screenGui.ResetOnSpawn = false

local menuFrame = Instance.new("Frame", screenGui)
menuFrame.Size = UDim2.new(0, 180, 0, 160)
menuFrame.Position = UDim2.new(0.5, -90, 0, 10)
menuFrame.BackgroundColor3 = Color3.new(0,0,0)
menuFrame.BackgroundTransparency = 0.5
menuFrame.BorderSizePixel = 0

local function createToggle(text, settingName, posY)
    local btn = Instance.new("TextButton", menuFrame)
    btn.Size = UDim2.new(0, 160, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1,1,1)
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
        -- Спрятать все ESP если отключено
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local esp = plr.Character.Head:FindFirstChild("ESP")
                if esp then esp.Enabled = false end
            end
        end
    end
end)
