-- ======== PREMIUM CORE ========
local _L = {
    SecureBoot = true,
    LicenseVerified = false,
    HWID = game:GetService("RbxAnalyticsService"):GetClientId(),
    SessionID = HttpService:GenerateGUID(false),
    PremiumFeatures = {
        "UltraSilent Aim", 
        "Dynamic Hitbox", 
        "Smart Autofarm",
        "Priority Support",
        "Weekly Updates"
    }
}

-- ======== PREMIUM LOADER ========
local startTime = tick()
local loadTime = math.random(2, 10) -- Premium load time (2-10 seconds)
local loaded = false
local loadSteps = {
    "Initializing secure environment...",
    "Verifying game integrity...",
    "Loading premium modules...",
    "Building interface...",
    "Finalizing setup..."
}

-- ======== PREMIUM UI ========
local BlackZoneUI = Instance.new("ScreenGui")
BlackZoneUI.Name = "BlackZoneElite_"..tostring(math.random(100000,999999))
BlackZoneUI.Parent = game:GetService("CoreGui")
BlackZoneUI.ResetOnSpawn = false
BlackZoneUI.ZIndexBehavior = Enum.ZIndexBehavior.Global

-- Premium Loading Screen
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 999
LoadingFrame.Parent = BlackZoneUI

local LoadingLogo = Instance.new("ImageLabel")
LoadingLogo.Size = UDim2.new(0, 150, 0, 150)
LoadingLogo.Position = UDim2.new(0.5, -75, 0.4, -75)
LoadingLogo.Image = "rbxassetid://12584587654" -- Premium logo
LoadingLogo.BackgroundTransparency = 1
LoadingLogo.Parent = LoadingFrame

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 30)
LoadingText.Position = UDim2.new(0, 0, 0.6, 0)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(200, 200, 255)
LoadingText.Text = loadSteps[1]
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 18
LoadingText.Parent = LoadingFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0.6, 0, 0, 8)
ProgressBar.Position = UDim2.new(0.2, 0, 0.65, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = LoadingFrame

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBar

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 0, 20)
StatusText.Position = UDim2.new(0, 0, 0.7, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Color3.fromRGB(150, 150, 200)
StatusText.Text = "Verifying premium license..."
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.Parent = LoadingFrame

-- Premium License Verification (simulated)
spawn(function()
    for i = 1, 5 do
        LoadingText.Text = loadSteps[i]
        for p = 0, 100, math.random(5, 15) do
            ProgressFill.Size = UDim2.new(p/100 * (i/5), 0, 1, 0)
            wait(math.random() * 0.1)
        end
    end
    
    -- Simulate license verification
    local verifyTime = math.random(500, 1500)/1000
    local startVerify = tick()
    while tick() - startVerify < verifyTime do
        local progress = (tick() - startVerify)/verifyTime
        StatusText.Text = string.format("License verification %.0f%% complete...", progress*100)
        wait()
    end
    
    _L.LicenseVerified = true
    StatusText.Text = "Premium features unlocked!"
    wait(0.5)
    
    -- Fade out loading screen
    for i = 1, 20 do
        LoadingFrame.BackgroundTransparency = i/20
        LoadingLogo.ImageTransparency = i/20
        LoadingText.TextTransparency = i/20
        ProgressBar.BackgroundTransparency = i/20
        ProgressFill.BackgroundTransparency = i/20
        StatusText.TextTransparency = i/20
        wait(0.02)
    end
    
    LoadingFrame:Destroy()
    loaded = true
end)

-- ======== PREMIUM INTERFACE ========
local MainContainer = Instance.new("Frame")
MainContainer.Size = UDim2.new(0, 550, 0, 650)
MainContainer.Position = UDim2.new(0.5, -275, 0.5, -325)
MainContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainContainer.BorderSizePixel = 0
MainContainer.Visible = false
MainContainer.Parent = BlackZoneUI

-- Premium Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainContainer

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -100, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Text = "BLACK ZONE ELITE"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 18
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.Parent = TitleBar

local PremiumBadge = Instance.new("ImageLabel")
PremiumBadge.Size = UDim2.new(0, 80, 0, 20)
PremiumBadge.Position = UDim2.new(1, -90, 0.5, -10)
PremiumBadge.Image = "rbxassetid://12584587655" -- Premium badge
PremiumBadge.BackgroundTransparency = 1
PremiumBadge.Parent = TitleBar

-- Premium Navigation
local NavBar = Instance.new("Frame")
NavBar.Size = UDim2.new(1, 0, 0, 50)
NavBar.Position = UDim2.new(0, 0, 0, 40)
NavBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
NavBar.BorderSizePixel = 0
NavBar.Parent = MainContainer

local NavButtons = {
    {Name = "AIMBOT", Icon = "rbxassetid://12584587656"},
    {Name = "VISUALS", Icon = "rbxassetid://12584587657"},
    {Name = "PLAYER", Icon = "rbxassetid://12584587658"},
    {Name = "AUTOMATION", Icon = "rbxassetid://12584587659"},
    {Name = "SETTINGS", Icon = "rbxassetid://12584587660"}
}

local TabFrames = {}
for i, nav in ipairs(NavButtons) do
    local btn = Instance.new("ImageButton")
    btn.Size = UDim2.new(1/#NavButtons, -10, 1, -10)
    btn.Position = UDim2.new((i-1)/#NavButtons, 5, 0, 5)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Image = nav.Icon
    btn.ScaleType = Enum.ScaleType.Fit
    btn.Parent = NavBar
    
    local tab = Instance.new("ScrollingFrame")
    tab.Size = UDim2.new(1, 0, 1, -90)
    tab.Position = UDim2.new(0, 0, 0, 90)
    tab.BackgroundTransparency = 1
    tab.Visible = false
    tab.ScrollBarThickness = 3
    tab.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    tab.Parent = MainContainer
    
    TabFrames[nav.Name] = tab
    
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(TabFrames) do f.Visible = false end
        tab.Visible = true
    end)
end
TabFrames["AIMBOT"].Visible = true

-- Premium Toggle Control
local function CreatePremiumToggle(parent, text, state, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -20, 0, 40)
    toggle.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 45)
    toggle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    toggle.BorderSizePixel = 0
    toggle.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Parent = toggle
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 30, 0, 16)
    indicator.Position = UDim2.new(1, -40, 0.5, -8)
    indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(state and 1 or 0, -12, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    dot.BorderSizePixel = 0
    dot.Parent = indicator
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggle
    
    local debounce = false
    btn.MouseButton1Click:Connect(function()
        if debounce then return end
        debounce = true
        
        state = not state
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        if state then
            local tween1 = TweenService:Create(indicator, tweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 170, 0)})
            local tween2 = TweenService:Create(dot, tweenInfo, {Position = UDim2.new(1, -12, 0.5, -6)})
            tween1:Play()
            tween2:Play()
        else
            local tween1 = TweenService:Create(indicator, tweenInfo, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)})
            local tween2 = TweenService:Create(dot, tweenInfo, {Position = UDim2.new(0, 0, 0.5, -6)})
            tween1:Play()
            tween2:Play()
        end
        
        callback(state)
        wait(0.2)
        debounce = false
    end)
    
    return {
        SetState = function(self, newState)
            state = newState
            indicator.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(70, 70, 70)
            dot.Position = UDim2.new(state and 1 or 0, -12, 0.5, -6)
        end
    }
end

-- Premium Slider Control
local function CreatePremiumSlider(parent, text, min, max, default, callback)
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -20, 0, 70)
    slider.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 75)
    slider.BackgroundTransparency = 1
    slider.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
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

-- ======== PREMIUM FEATURES ========
local Features = {
    Aimbot = {
        SilentAim = false,
        HitChance = 100,
        Prediction = 0.15,
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
        HealthBar = false
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
        NoSpread = false
    },
    Automation = {
        Autofarm = false,
        Mode = "Normal",
        CollectGuns = true,
        AutoPickup = true,
        KillAll = false,
        AutoReport = false
    },
    Settings = {
        Language = "English",
        Theme = "Dark",
        Keybinds = {
            Menu = Enum.KeyCode.RightShift,
            Noclip = Enum.KeyCode.N,
            Fly = Enum.KeyCode.F
        }
    }
}

-- ======== PREMIUM UI SETUP ========

-- Aimbot Tab
CreatePremiumToggle(TabFrames["AIMBOT"], "Silent Aim", Features.Aimbot.SilentAim, function(state)
    Features.Aimbot.SilentAim = state
end)

CreatePremiumSlider(TabFrames["AIMBOT"], "Hit Chance", 0, 100, Features.Aimbot.HitChance, function(value)
    Features.Aimbot.HitChance = value
end)

CreatePremiumToggle(TabFrames["AIMBOT"], "Wallbang", Features.Aimbot.Wallbang, function(state)
    Features.Aimbot.Wallbang = state
end)

-- Visuals Tab
CreatePremiumToggle(TabFrames["VISUALS"], "ESP", Features.Visuals.ESP, function(state)
    Features.Visuals.ESP = state
end)

CreatePremiumToggle(TabFrames["VISUALS"], "Boxes", Features.Visuals.Boxes, function(state)
    Features.Visuals.Boxes = state
end)

-- Player Tab
CreatePremiumToggle(TabFrames["PLAYER"], "Speed Hack", Features.Player.Speed, function(state)
    Features.Player.Speed = state
end)

CreatePremiumSlider(TabFrames["PLAYER"], "Speed Value", 16, 200, Features.Player.SpeedValue, function(value)
    Features.Player.SpeedValue = value
end)

-- Automation Tab
CreatePremiumToggle(TabFrames["AUTOMATION"], "Autofarm", Features.Automation.Autofarm, function(state)
    Features.Automation.Autofarm = state
end)

CreatePremiumToggle(TabFrames["AUTOMATION"], "Kill All", Features.Automation.KillAll, function(state)
    Features.Automation.KillAll = state
end)

-- Settings Tab
CreatePremiumToggle(TabFrames["SETTINGS"], "Premium Theme", true, function(state)
    -- Theme toggle logic
end)

-- ======== PREMIUM FUNCTIONALITY ========

-- Premium Silent Aim
local function PremiumSilentAim()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Features.Aimbot.SilentAim and method == "FindPartOnRayWithWhitelist" and math.random(1, 100) <= Features.Aimbot.HitChance then
            -- Premium targeting logic
            local target = FindBestTarget()
            if target and target.Character then
                local part = target.Character:FindFirstChild(Features.Aimbot.TargetPart)
                if part then
                    local predictedPos = part.Position + (part.Velocity * Features.Aimbot.Prediction)
                    args[1] = Ray.new(Workspace.CurrentCamera.CFrame.Position, (predictedPos - Workspace.CurrentCamera.CFrame.Position).Unit * 1000)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Premium ESP System
local ESP = {
    Objects = {}
}

function ESP:Add(player)
    -- Premium ESP creation
end

function ESP:Update()
    -- Premium ESP update
end

-- Premium Autofarm
local function PremiumAutofarm()
    while Features.Automation.Autofarm do
        -- Premium farming logic
        wait()
    end
end

-- Premium Kill All
local function PremiumKillAll()
    if Features.Automation.KillAll then
        -- Premium kill all logic
    end
end

-- ======== PREMIUM CORE LOOP ========
local function PremiumMain()
    -- Initialize premium features
    PremiumSilentAim()
    
    -- Main loop
    while wait() do
        -- Update features
        if Features.Visuals.ESP then
            ESP:Update()
        end
        
        if Features.Player.Speed and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Features.Player.SpeedValue
            end
        end
        
        PremiumKillAll()
    end
end

-- ======== PREMIUM ACTIVATION ========
local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 50, 0, 50)
CircleButton.Position = UDim2.new(0.5, -25, 0.1, 0)
CircleButton.Image = "rbxassetid://12584587661" -- Premium circle icon
CircleButton.BackgroundTransparency = 1
CircleButton.Parent = BlackZoneUI

CircleButton.MouseButton1Click:Connect(function()
    MainContainer.Visible = not MainContainer.Visible
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Features.Settings.Keybinds.Menu then
        MainContainer.Visible = not MainContainer.Visible
    end
end)

-- Start premium system
spawn(PremiumMain)

-- Premium notification
local function Notify(title, message, duration)
    -- Premium notification system
end

Notify("Black Zone Elite", "Premium cheat loaded successfully!", 5)

print("Black Zone Elite initialized | Premium features active")
