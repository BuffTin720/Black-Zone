local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local VRService = game:GetService("VRService")

-- Device detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local isConsole = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local isPC = not isMobile and not isConsole
local isVR = VRService.VREnabled

-- ======== MAIN UI ========
local BlackZoneUI = Instance.new("ScreenGui")
BlackZoneUI.Name = "BlackZoneElite_"..tostring(math.random(100000,999999))
BlackZoneUI.Parent = game:GetService("CoreGui")
BlackZoneUI.ResetOnSpawn = false

-- Circle toggle button
local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 50, 0, 50)
CircleButton.Position = UDim2.new(0.5, -25, 0.1, 0)
CircleButton.Image = "rbxassetid://3570695787" -- Circle image
CircleButton.ScaleType = Enum.ScaleType.Slice
CircleButton.SliceCenter = Rect.new(100, 100, 100, 100)
CircleButton.SliceScale = 0.12
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.BackgroundTransparency = 0.3
CircleButton.Parent = BlackZoneUI

-- Main menu frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 650)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -325)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = BlackZoneUI

-- Responsive design
if isMobile then
    MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
end

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Text = "BLACK ZONE ELITE"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 20
TitleText.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -40, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

-- Navigation tabs
local Tabs = {
    Main = {Frame = nil, Button = nil},
    Combat = {Frame = nil, Button = nil},
    Visuals = {Frame = nil, Button = nil},
    Player = {Frame = nil, Button = nil},
    Automation = {Frame = nil, Button = nil},
    Settings = {Frame = nil, Button = nil}
}

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TabButtonsFrame.BorderSizePixel = 0
TabButtonsFrame.Parent = MainFrame

local TabContentFrame = Instance.new("Frame")
TabContentFrame.Size = UDim2.new(1, 0, 1, -80)
TabContentFrame.Position = UDim2.new(0, 0, 0, 80)
TabContentFrame.BackgroundTransparency = 1
TabContentFrame.Parent = MainFrame

-- Create tabs
for tabName, _ in pairs(Tabs) do
    local tabIndex = table.find(Tabs, tabName)
    local tabWidth = 1/#Tabs
    
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(tabWidth, -2, 1, 0)
    TabButton.Position = UDim2.new((tabIndex-1)*tabWidth, 1, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Text = tabName:upper()
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 14
    TabButton.Parent = TabButtonsFrame
    
    local TabFrame = Instance.new("ScrollingFrame")
    TabFrame.Size = UDim2.new(1, 0, 1, 0)
    TabFrame.BackgroundTransparency = 1
    TabFrame.Visible = false
    TabFrame.ScrollBarThickness = 3
    TabFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    TabFrame.Parent = TabContentFrame
    
    Tabs[tabName].Frame = TabFrame
    Tabs[tabName].Button = TabButton
    
    TabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Frame.Visible = false
        end
        TabFrame.Visible = true
    end)
end

Tabs.Main.Frame.Visible = true

-- ======== UI ELEMENTS ========
local function CreateToggle(parent, text, state, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -20, 0, 35)
    toggle.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 40)
    toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 40, 0, 20)
    indicator.Position = UDim2.new(1, -50, 0.5, -10)
    indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggle
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
        callback(state)
    end)
    
    return {
        SetState = function(self, newState)
            state = newState
            indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
        end
    }
end

local function CreateSlider(parent, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 70)
    slider.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 75)
    slider.BackgroundTransparency = 1
    slider.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    track.BorderSizePixel = 0
    track.Parent = slider
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(0, 60, 0, 20)
    value.Position = UDim2.new(1, -60, 0, 40)
    value.BackgroundTransparency = 1
    value.TextColor3 = Color3.fromRGB(200, 200, 255)
    value.Text = tostring(default)
    value.Font = Enum.Font.GothamBold
    value.TextSize = 14
    value.Parent = slider
    
    local dragging = false
    local function update(input)
        local pos = UDim2.new(math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1), 0, 1, 0)
        fill.Size = pos
        local newValue = math.floor(min + (max-min) * pos.X.Scale)
        value.Text = tostring(newValue)
        callback(newValue)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    return {
        SetValue = function(self, newValue)
            fill.Size = UDim2.new((newValue-min)/(max-min), 0, 1, 0)
            value.Text = tostring(newValue)
        end
    }
end

-- ======== FEATURES CONFIG ========
local Features = {
    Aimbot = {
        SilentAim = false,
        HitChance = 100,
        Prediction = 0.15,
        HitboxExpansion = false,
        HitboxSize = 1.5,
        AutoShoot = false,
        TargetPart = "Head",
        FOV = 120,
        Smoothing = 10,
        Wallbang = false,
        Humanizer = true
    },
    Visuals = {
        ESP = false,
        Boxes = true,
        Names = true,
        Health = true,
        Tracers = false,
        Chams = false,
        MaxDistance = 1000,
        WeaponESP = false,
        Skeleton = false,
        HealthBar = false,
        Radar = false,
        Crosshair = false
    },
    Player = {
        Speed = false,
        SpeedValue = 24,
        JumpPower = false,
        JumpValue = 50,
        Noclip = false,
        Fly = false,
        FlySpeed = 30,
        InfiniteJump = false,
        NoRecoil = false,
        NoSpread = false,
        AntiAim = false,
        AntiGravity = false,
        InstantRespawn = false
    },
    Automation = {
        Autofarm = false,
        Mode = "Normal",
        CollectGuns = true,
        AutoPickup = true,
        KillAll = false,
        AutoReport = false,
        AutoVoteKick = false
    },
    Misc = {
        Fullbright = false,
        FPSBoost = false,
        AntiAFK = false,
        Rejoin = false,
        ChatLogger = false,
        FakeLag = false,
        PingSpoof = false
    }
}

-- ======== UI SETUP ========

-- Main Tab
CreateToggle(Tabs.Main.Frame, "Enable All Features", false, function(state)
    -- Toggle all features
end)

-- Combat Tab
local SilentAimToggle = CreateToggle(Tabs.Combat.Frame, "Silent Aim", Features.Aimbot.SilentAim, function(state)
    Features.Aimbot.SilentAim = state
end)

local HitboxToggle = CreateToggle(Tabs.Combat.Frame, "Hitbox Expansion", Features.Aimbot.HitboxExpansion, function(state)
    Features.Aimbot.HitboxExpansion = state
end)

local HitboxSlider = CreateSlider(Tabs.Combat.Frame, "Hitbox Size", 1, 3, Features.Aimbot.HitboxSize, function(value)
    Features.Aimbot.HitboxSize = value
end)

local KillAllToggle = CreateToggle(Tabs.Combat.Frame, "Kill All Players", Features.Automation.KillAll, function(state)
    Features.Automation.KillAll = state
end)

-- Visuals Tab
local ESPToggle = CreateToggle(Tabs.Visuals.Frame, "ESP", Features.Visuals.ESP, function(state)
    Features.Visuals.ESP = state
end)

local BoxesToggle = CreateToggle(Tabs.Visuals.Frame, "Boxes", Features.Visuals.Boxes, function(state)
    Features.Visuals.Boxes = state
end)

local RadarToggle = CreateToggle(Tabs.Visuals.Frame, "Radar", Features.Visuals.Radar, function(state)
    Features.Visuals.Radar = state
end)

-- Player Tab
local SpeedToggle = CreateToggle(Tabs.Player.Frame, "Speed Hack", Features.Player.Speed, function(state)
    Features.Player.Speed = state
end)

local SpeedSlider = CreateSlider(Tabs.Player.Frame, "Speed Value", 16, 200, Features.Player.SpeedValue, function(value)
    Features.Player.SpeedValue = value
end)

local FlyToggle = CreateToggle(Tabs.Player.Frame, "Fly", Features.Player.Fly, function(state)
    Features.Player.Fly = state
end)

-- Automation Tab
local AutofarmToggle = CreateToggle(Tabs.Automation.Frame, "Autofarm", Features.Automation.Autofarm, function(state)
    Features.Automation.Autofarm = state
end)

local AutoPickupToggle = CreateToggle(Tabs.Automation.Frame, "Auto Pickup Guns", Features.Automation.AutoPickup, function(state)
    Features.Automation.AutoPickup = state
end)

-- Settings Tab
local ThemeToggle = CreateToggle(Tabs.Settings.Frame, "Dark Theme", true, function(state)
    -- Theme toggle logic
end)

-- ======== CORE FUNCTIONS ========

-- Silent Aim
local function SilentAim()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Features.Aimbot.SilentAim and method == "FindPartOnRayWithWhitelist" and math.random(1, 100) <= Features.Aimbot.HitChance then
            local closestPlayer = nil
            local closestDistance = Features.Aimbot.FOV
            local localCharacter = LocalPlayer.Character
            local localHead = localCharacter and localCharacter:FindFirstChild("Head")
            
            if localHead then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local character = player.Character
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        local head = character:FindFirstChild("Head")
                        
                        if humanoid and humanoid.Health > 0 and head then
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
                
                if closestPlayer and closestPlayer.Character then
                    local head = closestPlayer.Character:FindFirstChild("Head")
                    if head then
                        local predictedPosition = head.Position + (head.Velocity * Features.Aimbot.Prediction)
                        args[1] = Ray.new(Workspace.CurrentCamera.CFrame.Position, (predictedPosition - Workspace.CurrentCamera.CFrame.Position).Unit * 1000)
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Hitbox Expansion
local function ExpandHitboxes()
    if not Features.Aimbot.HitboxExpansion then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * Features.Aimbot.HitboxSize
                end
            end
        end
    end
end

-- Speed Hack
local function SpeedHack()
    if Features.Player.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Features.Player.SpeedValue
        end
    end
end

-- Fly
local function Fly()
    if not Features.Player.Fly then return end
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(0, 0, 0)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
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
    
    RunService.Heartbeat:Connect(function()
        if Features.Player.Fly and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            local velocity = root.Velocity
            
            if flyUp then
                velocity = Vector3.new(velocity.X, Features.Player.FlySpeed, velocity.Z)
            elseif flyDown then
                velocity = Vector3.new(velocity.X, -Features.Player.FlySpeed, velocity.Z)
            else
                velocity = Vector3.new(velocity.X, 0, velocity.Z)
            end
            
            root.Velocity = velocity
        end
    end)
end

-- Autofarm
local function Autofarm()
    while Features.Automation.Autofarm do
        -- Autofarm logic
        wait()
    end
end

-- Auto Pickup
local function AutoPickup()
    while Features.Automation.AutoPickup do
        -- Auto pickup logic
        wait(0.5)
    end
end

-- Kill All
local function KillAll()
    if not Features.Automation.KillAll then return end
    
    -- Kill all logic
end

-- ESP
local ESP = {
    Objects = {}
}

function ESP:Add(player)
    if not player.Character then return end
    
    local holder = Instance.new("Folder")
    holder.Name = player.Name
    holder.Parent = BlackZoneUI
    
    local box = Instance.new("Frame")
    box.Visible = false
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255, 50, 50)
    box.ZIndex = 10
    box.Parent = holder
    
    -- Other ESP elements...
    
    self.Objects[player] = {
        Holder = holder,
        Box = box,
        Player = player
    }
end

function ESP:Update()
    if not Features.Visuals.ESP then return end
    
    for player, data in pairs(self.Objects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local character = player.Character
            local head = character.Head
            local humanoid = character.Humanoid
            
            local screenPoint, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            local distance = (LocalPlayer.Character.Head.Position - head.Position).Magnitude
            
            if onScreen and distance <= Features.Visuals.MaxDistance then
                -- Update ESP elements
                if Features.Visuals.Boxes then
                    data.Box.Visible = true
                    -- Position and size box
                else
                    data.Box.Visible = false
                end
            else
                data.Box.Visible = false
            end
        else
            data.Box.Visible = false
        end
    end
end

-- Radar
local function UpdateRadar()
    if not Features.Visuals.Radar then return end
    
    -- Radar update logic
end

-- ======== INITIALIZATION ========

-- Initialize ESP for all players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        ESP:Add(player)
    end
end

-- Add new players to ESP
Players.PlayerAdded:Connect(function(player)
    ESP:Add(player)
end)

-- Remove leaving players from ESP
Players.PlayerRemoving:Connect(function(player)
    if ESP.Objects[player] then
        ESP.Objects[player].Holder:Destroy()
        ESP.Objects[player] = nil
    end
end)

-- Initialize systems
SilentAim()
spawn(Fly)
spawn(Autofarm)
spawn(AutoPickup)

-- ======== MAIN LOOP ========
RunService.Heartbeat:Connect(function()
    ExpandHitboxes()
    SpeedHack()
    KillAll()
    ESP:Update()
    UpdateRadar()
end)

-- ======== UI CONTROLS ========
CircleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Character added event
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to load
    -- Reapply movement hacks
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Features.Misc.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

-- Initial setup
SpeedHack()

print("Black Zone Elite loaded successfully!")
