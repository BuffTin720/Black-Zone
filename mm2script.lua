--[[
Mega Ultra Cheat Script for Murder Mystery 2
This is a comprehensive cheat script designed to test anti-cheat systems in MM2 clones
WARNING: For educational/testing purposes only
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

-- Anti-detection variables
local scriptName = "SystemCore"
local fakeInstance = Instance.new("LocalScript")
fakeInstance.Name = "SystemCore"
fakeInstance.Parent = LocalPlayer:WaitForChild("PlayerScripts")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MegaUltraCheatGUI"
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Mega Ultra Cheat v4.2"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = MainFrame

local TabButtons = {}
local TabFrames = {}

local function CreateTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.33, -2, 0, 30)
    tabButton.Position = UDim2.new(0.33 * (#TabButtons), 1, 0, 30)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabButton.Text = name
    tabButton.Font = Enum.Font.SourceSans
    tabButton.TextSize = 14
    tabButton.Parent = MainFrame
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, -60)
    tabFrame.Position = UDim2.new(0, 0, 0, 60)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Visible = false
    tabFrame.Parent = MainFrame
    
    TabButtons[name] = tabButton
    TabFrames[name] = tabFrame
    
    tabButton.MouseButton1Click:Connect(function()
        for _, frame in pairs(TabFrames) do
            frame.Visible = false
        end
        tabFrame.Visible = true
    end)
    
    return tabFrame
end

-- Create tabs
local AimbotTab = CreateTab("Aimbot")
local VisualsTab = CreateTab("Visuals")
local PlayerTab = CreateTab("Player")
local MiscTab = CreateTab("Misc")

-- Show first tab by default
TabFrames["Aimbot"].Visible = true

-- UI Elements Creator
local function CreateToggle(parent, name, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -10, 0, 30)
    toggleFrame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 35)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 120, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = name
    toggleButton.Font = Enum.Font.SourceSans
    toggleButton.TextSize = 14
    toggleButton.Parent = toggleFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 50, 1, 0)
    statusLabel.Position = UDim2.new(1, -50, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = "OFF"
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 14
    statusLabel.Parent = toggleFrame
    
    local enabled = false
    
    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            statusLabel.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
            statusLabel.Text = "ON"
        else
            statusLabel.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
            statusLabel.Text = "OFF"
        end
        callback(enabled)
    end)
    
    return {
        Set = function(self, value)
            enabled = value
            if enabled then
                statusLabel.BackgroundColor3 = Color3.fromRGB(20, 100, 20)
                statusLabel.Text = "ON"
            else
                statusLabel.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
                statusLabel.Text = "OFF"
            end
            callback(enabled)
        end,
        Get = function(self)
            return enabled
        end
    }
end

local function CreateSlider(parent, name, min, max, default, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -10, 0, 50)
    sliderFrame.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 55)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Text = name
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 0, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0, 15)
    valueLabel.Position = UDim2.new(0, 0, 0, 35)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextSize = 14
    valueLabel.Parent = sliderFrame
    
    local dragging = false
    
    local function updateValue(x)
        local relativeX = math.clamp(x - sliderBar.AbsolutePosition.X, 0, sliderBar.AbsoluteSize.X)
        local ratio = relativeX / sliderBar.AbsoluteSize.X
        local value = math.floor(min + (max - min) * ratio)
        
        sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input.Position.X + sliderBar.AbsolutePosition.X)
        end
    end)
    
    sliderBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    return {
        Set = function(self, value)
            local ratio = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    }
end

-- Cheat Variables
local settings = {
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        VisibleCheck = true,
        FOV = 100,
        Smoothness = 10,
        Keybind = Enum.UserInputType.MouseButton2,
        HitChance = 100,
        SilentAim = false,
        Prediction = 0.1
    },
    Visuals = {
        ESP = false,
        Boxes = true,
        Names = true,
        Health = true,
        Tracers = false,
        Chams = false,
        Glow = false,
        GlowColor = Color3.fromRGB(255, 0, 0),
        MaxDistance = 500
    },
    Player = {
        Speed = false,
        SpeedValue = 20,
        Jump = false,
        JumpValue = 50,
        Noclip = false,
        Fly = false,
        FlySpeed = 25,
        InfiniteJump = false,
        AntiAim = false
    },
    Misc = {
        AutoFarm = false,
        AutoCollectGuns = false,
        AutoWin = false,
        Rejoin = false,
        AntiAFK = false,
        Fullbright = false,
        FPSBoost = false
    }
}

-- Aimbot Tab
CreateToggle(AimbotTab, "Aimbot", function(enabled)
    settings.Aimbot.Enabled = enabled
end)

CreateToggle(AimbotTab, "Team Check", function(enabled)
    settings.Aimbot.TeamCheck = enabled
end)

CreateToggle(AimbotTab, "Visible Check", function(enabled)
    settings.Aimbot.VisibleCheck = enabled
end)

CreateToggle(AimbotTab, "Silent Aim", function(enabled)
    settings.Aimbot.SilentAim = enabled
end)

CreateSlider(AimbotTab, "FOV", 10, 500, 100, function(value)
    settings.Aimbot.FOV = value
end)

CreateSlider(AimbotTab, "Smoothness", 1, 30, 10, function(value)
    settings.Aimbot.Smoothness = value
end)

CreateSlider(AimbotTab, "Hit Chance %", 0, 100, 100, function(value)
    settings.Aimbot.HitChance = value
end)

CreateSlider(AimbotTab, "Prediction", 0, 0.5, 0.1, function(value)
    settings.Aimbot.Prediction = value
end)

-- Visuals Tab
CreateToggle(VisualsTab, "ESP", function(enabled)
    settings.Visuals.ESP = enabled
end)

CreateToggle(VisualsTab, "Boxes", function(enabled)
    settings.Visuals.Boxes = enabled
end)

CreateToggle(VisualsTab, "Names", function(enabled)
    settings.Visuals.Names = enabled
end)

CreateToggle(VisualsTab, "Health", function(enabled)
    settings.Visuals.Health = enabled
end)

CreateToggle(VisualsTab, "Tracers", function(enabled)
    settings.Visuals.Tracers = enabled
end)

CreateToggle(VisualsTab, "Chams", function(enabled)
    settings.Visuals.Chams = enabled
end)

CreateToggle(VisualsTab, "Glow", function(enabled)
    settings.Visuals.Glow = enabled
end)

CreateSlider(VisualsTab, "Max Distance", 50, 2000, 500, function(value)
    settings.Visuals.MaxDistance = value
end)

-- Player Tab
CreateToggle(PlayerTab, "Speed Hack", function(enabled)
    settings.Player.Speed = enabled
end)

CreateSlider(PlayerTab, "Speed Value", 16, 200, 20, function(value)
    settings.Player.SpeedValue = value
end)

CreateToggle(PlayerTab, "High Jump", function(enabled)
    settings.Player.Jump = enabled
end)

CreateSlider(PlayerTab, "Jump Value", 50, 500, 50, function(value)
    settings.Player.JumpValue = value
end)

CreateToggle(PlayerTab, "Noclip", function(enabled)
    settings.Player.Noclip = enabled
end)

CreateToggle(PlayerTab, "Fly", function(enabled)
    settings.Player.Fly = enabled
end)

CreateSlider(PlayerTab, "Fly Speed", 10, 100, 25, function(value)
    settings.Player.FlySpeed = value
end)

CreateToggle(PlayerTab, "Infinite Jump", function(enabled)
    settings.Player.InfiniteJump = enabled
end)

CreateToggle(PlayerTab, "Anti-Aim", function(enabled)
    settings.Player.AntiAim = enabled
end)

-- Misc Tab
CreateToggle(MiscTab, "Auto Farm", function(enabled)
    settings.Misc.AutoFarm = enabled
end)

CreateToggle(MiscTab, "Auto Collect Guns", function(enabled)
    settings.Misc.AutoCollectGuns = enabled
end)

CreateToggle(MiscTab, "Auto Win", function(enabled)
    settings.Misc.AutoWin = enabled
end)

CreateToggle(MiscTab, "Auto Rejoin", function(enabled)
    settings.Misc.Rejoin = enabled
end)

CreateToggle(MiscTab, "Anti-AFK", function(enabled)
    settings.Misc.AntiAFK = enabled
end)

CreateToggle(MiscTab, "Fullbright", function(enabled)
    settings.Misc.Fullbright = enabled
    if enabled then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    else
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
        Lighting.ColorShift_Top = Color3.new(0, 0, 0)
    end
end)

CreateToggle(MiscTab, "FPS Boost", function(enabled)
    settings.Misc.FPSBoost = enabled
    if enabled then
        settings.Misc.OriginalGraphicsQuality = settings.Misc.OriginalGraphicsQuality or settings.Rendering.QualityLevel
        settings.Rendering.QualityLevel = 1
        
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored then
                v.Material = Enum.Material.Plastic
            end
        end
    else
        if settings.Misc.OriginalGraphicsQuality then
            settings.Rendering.QualityLevel = settings.Misc.OriginalGraphicsQuality
        end
    end
end)

-- Anti-Cheat Bypass Functions
local function generateRandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomString = ""
    
    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        randomString = randomString .. string.sub(chars, randomIndex, randomIndex)
    end
    
    return randomString
end

local function spoofInstance(instance)
    -- Change instance properties to avoid detection
    if not instance then return end
    
    local oldName = instance.Name
    local newName = generateRandomString(10)
    
    -- Spoof name temporarily
    instance.Name = newName
    delay(0.1, function()
        instance.Name = oldName
    end)
end

local function hookFunction(object, functionName, newFunction)
    local original = object[functionName]
    
    if original then
        object[functionName] = function(...)
            return newFunction(original, ...)
        end
    end
end

-- Aimbot Functionality
local function getClosestPlayer()
    if not settings.Aimbot.Enabled then return nil end
    
    local closestPlayer = nil
    local closestDistance = settings.Aimbot.FOV
    local localCharacter = LocalPlayer.Character
    local localHead = localCharacter and localCharacter:FindFirstChild("Head")
    
    if not localHead then return nil end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                -- Team check
                if settings.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Visible check
                if settings.Aimbot.VisibleCheck then
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterDescendantsInstances = {localCharacter, character}
                    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    local raycastResult = Workspace:Raycast(localHead.Position, (head.Position - localHead.Position).Unit * 1000, raycastParams)
                    if raycastResult and raycastResult.Instance:FindFirstAncestorOfClass("Model") ~= character then
                        continue
                    end
                end
                
                local screenPoint, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- Silent Aim Hook
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if settings.Aimbot.SilentAim and settings.Aimbot.Enabled and method == "FindPartOnRayWithWhitelist" and math.random(1, 100) <= settings.Aimbot.HitChance then
        local closestPlayer = getClosestPlayer()
        if closestPlayer and closestPlayer.Character then
            local head = closestPlayer.Character:FindFirstChild("Head")
            if head then
                -- Apply prediction
                local prediction = settings.Aimbot.Prediction
                local predictedPosition = head.Position + (head.Velocity * prediction)
                
                args[1] = Ray.new(Workspace.CurrentCamera.CFrame.Position, (predictedPosition - Workspace.CurrentCamera.CFrame.Position).Unit * 1000)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- ESP Functionality
local ESP = {
    Objects = {}
}

function ESP:Add(player)
    if not player.Character then return end
    
    local holder = Instance.new("Folder")
    holder.Name = player.Name
    holder.Parent = ScreenGui
    
    local box = Instance.new("Frame")
    box.Visible = false
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = settings.Visuals.GlowColor
    box.ZIndex = 10
    box.Parent = holder
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Visible = false
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = player.Name
    nameLabel.ZIndex = 10
    nameLabel.Parent = holder
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Visible = false
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.TextSize = 12
    healthLabel.Font = Enum.Font.SourceSans
    healthLabel.ZIndex = 10
    healthLabel.Parent = holder
    
    local tracer = Instance.new("Frame")
    tracer.Visible = false
    tracer.BackgroundColor3 = settings.Visuals.GlowColor
    tracer.BorderSizePixel = 0
    tracer.Size = UDim2.new(0, 1, 0, 1)
    tracer.ZIndex = 10
    tracer.Parent = holder
    
    local cham = Instance.new("BoxHandleAdornment")
    cham.Visible = false
    cham.Adornee = nil
    cham.AlwaysOnTop = true
    cham.ZIndex = 10
    cham.Size = Vector3.new(4, 6, 1)
    cham.Transparency = 0.5
    cham.Color3 = settings.Visuals.GlowColor
    cham.Parent = holder
    
    local glow = Instance.new("BoxHandleAdornment")
    glow.Visible = false
    glow.Adornee = nil
    glow.AlwaysOnTop = false
    glow.ZIndex = 5
    glow.Size = Vector3.new(4.2, 6.2, 1.2)
    glow.Transparency = 0.8
    glow.Color3 = settings.Visuals.GlowColor
    glow.Parent = holder
    
    self.Objects[player] = {
        Holder = holder,
        Box = box,
        NameLabel = nameLabel,
        HealthLabel = healthLabel,
        Tracer = tracer,
        Cham = cham,
        Glow = glow,
        Player = player
    }
end

function ESP:Remove(player)
    local obj = self.Objects[player]
    if obj then
        obj.Holder:Destroy()
        self.Objects[player] = nil
    end
end

function ESP:Update()
    for player, obj in pairs(self.Objects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local character = player.Character
            local head = character.Head
            local humanoid = character.Humanoid
            
            local screenPoint, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            local distance = (LocalPlayer.Character.Head.Position - head.Position).Magnitude
            
            if onScreen and distance <= settings.Visuals.MaxDistance then
                local scale = 1000 / (screenPoint.Z * math.tan(math.rad(Workspace.CurrentCamera.FieldOfView * 0.5)) * 2)
                local width, height = 4 * scale, 6 * scale
                
                -- Box ESP
                if settings.Visuals.ESP and settings.Visuals.Boxes then
                    obj.Box.Size = UDim2.new(0, width, 0, height)
                    obj.Box.Position = UDim2.new(0, screenPoint.X - width * 0.5, 0, screenPoint.Y - height * 0.5)
                    obj.Box.Visible = true
                else
                    obj.Box.Visible = false
                end
                
                -- Name ESP
                if settings.Visuals.ESP and settings.Visuals.Names then
                    obj.NameLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - height * 0.5 - 20)
                    obj.NameLabel.Visible = true
                else
                    obj.NameLabel.Visible = false
                end
                
                -- Health ESP
                if settings.Visuals.ESP and settings.Visuals.Health then
                    obj.HealthLabel.Text = string.format("%d/%d (%.0f%%)", humanoid.Health, humanoid.MaxHealth, (humanoid.Health / humanoid.MaxHealth) * 100)
                    obj.HealthLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y + height * 0.5 + 5)
                    obj.HealthLabel.Visible = true
                else
                    obj.HealthLabel.Visible = false
                end
                
                -- Tracers
                if settings.Visuals.ESP and settings.Visuals.Tracers then
                    obj.Tracer.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y)
                    obj.Tracer.Size = UDim2.new(0, 1, 0, (screenPoint.Y - Workspace.CurrentCamera.ViewportSize.Y * 0.5) * 2)
                    obj.Tracer.Visible = true
                else
                    obj.Tracer.Visible = false
                end
                
                -- Chams
                if settings.Visuals.Chams then
                    obj.Cham.Adornee = character
                    obj.Cham.Visible = true
                else
                    obj.Cham.Visible = false
                end
                
                -- Glow
                if settings.Visuals.Glow then
                    obj.Glow.Adornee = character
                    obj.Glow.Visible = true
                else
                    obj.Glow.Visible = false
                end
            else
                obj.Box.Visible = false
                obj.NameLabel.Visible = false
                obj.HealthLabel.Visible = false
                obj.Tracer.Visible = false
                obj.Cham.Visible = false
                obj.Glow.Visible = false
            end
        else
            obj.Box.Visible = false
            obj.NameLabel.Visible = false
            obj.HealthLabel.Visible = false
            obj.Tracer.Visible = false
            obj.Cham.Visible = false
            obj.Glow.Visible = false
        end
    end
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESP:Add(player)
    end
end

-- Add ESP for new players
Players.PlayerAdded:Connect(function(player)
    ESP:Add(player)
end)

-- Remove ESP for leaving players
Players.PlayerRemoving:Connect(function(player)
    ESP:Remove(player)
end)

-- Player Movement Hacks
local noclipLoop
local flyLoop

local function startNoclip()
    if noclipLoop then noclipLoop:Disconnect() end
    
    noclipLoop = RunService.Stepped:Connect(function()
        if settings.Player.Noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function startFly()
    if flyLoop then flyLoop:Disconnect() end
    
    local flySpeed = settings.Player.FlySpeed
    local flyUp = false
    local flyDown = false
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            flyUp = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyDown = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            flyUp = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyDown = false
        end
    end)
    
    flyLoop = RunService.Heartbeat:Connect(function()
        if settings.Player.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local velocity = root.Velocity
            
            if flyUp then
                velocity = Vector3.new(velocity.X, flySpeed, velocity.Z)
            elseif flyDown then
                velocity = Vector3.new(velocity.X, -flySpeed, velocity.Z)
            else
                velocity = Vector3.new(velocity.X, 0, velocity.Z)
            end
            
            root.Velocity = velocity
        end
    end)
end

-- Speed Hack
local function speedHack()
    if settings.Player.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = settings.Player.SpeedValue
    end
end

-- High Jump
local function highJump()
    if settings.Player.Jump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = settings.Player.JumpValue
    end
end

-- Infinite Jump
local function infiniteJump()
    if settings.Player.InfiniteJump then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- Anti-Aim
local function antiAim()
    if settings.Player.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-180, 180)), 0)
    end
end

-- Auto Farm
local function autoFarm()
    if not settings.Misc.AutoFarm then return end
    
    -- Implementation depends on game specifics
end

-- Auto Collect Guns
local function autoCollectGuns()
    if not settings.Misc.AutoCollectGuns then return end
    
    -- Implementation depends on game specifics
end

-- Auto Win
local function autoWin()
    if not settings.Misc.AutoWin then return end
    
    -- Implementation depends on game specifics
end

-- Anti-AFK
local function antiAFK()
    if settings.Misc.AntiAFK then
        local vu = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            wait(1)
            vu:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end)
    end
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    -- ESP Update
    if settings.Visuals.ESP or settings.Visuals.Chams or settings.Visuals.Glow then
        ESP:Update()
    end
    
    -- Movement Hacks
    speedHack()
    highJump()
    
    -- Other Hacks
    antiAim()
    autoFarm()
    autoCollectGuns()
    autoWin()
end)

-- Start services
startNoclip()
startFly()
antiAFK()

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    infiniteJump()
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    -- Toggle GUI
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Cleanup
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load
    speedHack()
    highJump()
end)

-- Final initialization
speedHack()
highJump()

-- Anti-detection spoofing
while true do
    wait(math.random(5, 15))
    spoofInstance(fakeInstance)
    spoofInstance(ScreenGui)
end