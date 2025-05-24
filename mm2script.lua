local startTime = tick()
local loadTime = math.random(3, 60) -- Random load time between 3-60 seconds
local loaded = false

-- Anti-detection
local SecureMode = true
local ScriptName = "SystemUI_"..tostring(math.random(10000,99999))
local FakeInstance = Instance.new("LocalScript")
FakeInstance.Name = ScriptName
FakeInstance.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts")

-- Services
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

-- Language system
local Languages = {
    English = {
        MainTitle = "BLACK ZONE HUB",
        Loading = "Loading...",
        Autofarm = "Autofarm",
        SilentAim = "Silent Aim",
        HitboxExpansion = "Hitbox Expansion",
        KillAll = "Kill All",
        SpeedHack = "Speed Hack",
        ESP = "ESP",
        AutoPickup = "Auto Pickup",
        AntiAFK = "Anti-AFK",
        Settings = "Settings",
        Language = "Language"
    },
    Russian = {
        MainTitle = "BLACK ZONE HUB",
        Loading = "Загрузка...",
        Autofarm = "Автофарм",
        SilentAim = "Тихий прицел",
        HitboxExpansion = "Расширение хитбокса",
        KillAll = "Убить всех",
        SpeedHack = "Скорость",
        ESP = "ESP",
        AutoPickup = "Автоподбор",
        AntiAFK = "Анти-АФК",
        Settings = "Настройки",
        Language = "Язык"
    }
}

local CurrentLanguage = "English"

-- ======== LOADING SCREEN ========
local LoadingScreen = Instance.new("ScreenGui")
LoadingScreen.Name = "BZH_LoadingScreen"
LoadingScreen.Parent = game:GetService("CoreGui")
LoadingScreen.DisplayOrder = 999

local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Parent = LoadingScreen

local LoadingText = Instance.new("TextLabel")
LoadingText.Size = UDim2.new(1, 0, 0, 50)
LoadingText.Position = UDim2.new(0, 0, 0.5, -25)
LoadingText.BackgroundTransparency = 1
LoadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadingText.Text = Languages[CurrentLanguage].Loading
LoadingText.Font = Enum.Font.GothamBold
LoadingText.TextSize = 24
LoadingText.Parent = LoadingFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0.8, 0, 0, 10)
ProgressBar.Position = UDim2.new(0.1, 0, 0.55, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = LoadingFrame

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBar

-- ======== MAIN GUI ========
local BlackZoneGUI = Instance.new("ScreenGui")
BlackZoneGUI.Name = "BlackZoneHub"
BlackZoneGUI.Parent = game:GetService("CoreGui")
BlackZoneGUI.ResetOnSpawn = false

-- Circle toggle button
local CircleButton = Instance.new("ImageButton")
CircleButton.Size = UDim2.new(0, 50, 0, 50)
CircleButton.Position = UDim2.new(0.5, -25, 0.1, 0)
CircleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CircleButton.BackgroundTransparency = 0.3
CircleButton.Image = "rbxassetid://3570695787"
CircleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
CircleButton.ScaleType = Enum.ScaleType.Slice
CircleButton.SliceCenter = Rect.new(100, 100, 100, 100)
CircleButton.SliceScale = 0.12
CircleButton.Parent = BlackZoneGUI

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = BlackZoneGUI

-- Responsive design
if isMobile then
    MainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
end

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Text = "BLACK ZONE HUB"
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

-- Tabs system
local Tabs = {
    Main = {Frame = nil, Button = nil},
    Combat = {Frame = nil, Button = nil},
    Visuals = {Frame = nil, Button = nil},
    Player = {Frame = nil, Button = nil},
    Misc = {Frame = nil, Button = nil},
    Settings = {Frame = nil, Button = nil}
}

local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 40)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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
    TabButton.Size = UDim2.new(tabWidth, 0, 1, 0)
    TabButton.Position = UDim2.new((tabIndex-1)*tabWidth, 0, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

-- ======== SETTINGS ========
local Settings = {
    Autofarm = {
        Enabled = false,
        Mode = "Normal", -- Normal/Fast/Ultra
        CollectGuns = true,
        AvoidMurderer = true,
        Priority = "Coins" -- Coins/Guns/Both
    },
    Combat = {
        SilentAim = false,
        HitChance = 100,
        Prediction = 0.15,
        HitboxExpansion = false,
        HitboxSize = 1.5,
        AutoShoot = false,
        KillAll = false,
        Wallbang = false,
        Triggerbot = false,
        AutoReload = true
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
        OffscreenArrows = false,
        Radar = false,
        Crosshair = false,
        CrosshairColor = Color3.fromRGB(255, 255, 255),
        CrosshairSize = 10,
        CrosshairGap = 5
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
        InstantRespawn = false,
        NoFallDamage = true,
        AutoStamina = true
    },
    Misc = {
        AutoPickup = true,
        Fullbright = false,
        FPSBoost = false,
        AntiAFK = false,
        Rejoin = false,
        AutoReport = false,
        ChatLogger = false,
        FakeLag = false,
        PingSpoof = false,
        ServerHop = false,
        AutoVoteKick = false,
        SpectatorList = false,
        FreeCam = false,
        FreeCamSpeed = 10
    },
    Settings = {
        Language = "English",
        UITheme = "Dark",
        UISize = "Normal",
        Keybinds = {
            ToggleMenu = Enum.KeyCode.RightShift,
            ToggleESP = Enum.KeyCode.F1,
            ToggleNoclip = Enum.KeyCode.N,
            ToggleFly = Enum.KeyCode.F
        },
        Configs = {
            SaveOnExit = true,
            AutoLoad = true,
            Notifications = true
        }
    }
}

-- ======== UI CREATION FUNCTIONS ========
local function CreateToggle(parent, text, callback, tooltip)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, -20, 0, 35)
    toggleFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 40)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = parent
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 180, 1, 0)
    toggleButton.Position = UDim2.new(0, 0, 0, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Text = text
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 14
    toggleButton.TextXAlignment = Enum.TextXAlignment.Left
    toggleButton.Parent = toggleFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 60, 1, 0)
    statusLabel.Position = UDim2.new(1, -60, 0, 0)
    statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLabel.Text = "OFF"
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14
    statusLabel.Parent = toggleFrame
    
    local enabled = false
    
    toggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            statusLabel.Text = "ON"
        else
            statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            statusLabel.Text = "OFF"
        end
        callback(enabled)
    end)
    
    if tooltip then
        local Tooltip = Instance.new("TextLabel")
        Tooltip.Size = UDim2.new(1, -20, 0, 0)
        Tooltip.Position = UDim2.new(0, 10, 1, 0)
        Tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
        Tooltip.Text = tooltip
        Tooltip.Font = Enum.Font.Gotham
        Tooltip.TextSize = 12
        Tooltip.TextWrapped = true
        Tooltip.Visible = false
        Tooltip.Parent = toggleFrame
        
        toggleButton.MouseEnter:Connect(function()
            Tooltip.Visible = true
            Tooltip.Size = UDim2.new(1, -20, 0, TextService:GetTextSize(tooltip, 12, Enum.Font.Gotham, Vector2.new(parent.AbsoluteSize.X - 40, math.huge)).Y + 10)
        end)
        
        toggleButton.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
    end
    
    return {
        Set = function(self, value)
            enabled = value
            if enabled then
                statusLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
                statusLabel.Text = "ON"
            else
                statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                statusLabel.Text = "OFF"
            end
            callback(enabled)
        end,
        Get = function(self)
            return enabled
        end
    }
end

local function CreateSlider(parent, text, min, max, default, callback, tooltip)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, -20, 0, 60)
    sliderFrame.Position = UDim2.new(0, 10, 0, #parent:GetChildren() * 40)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Text = text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = sliderFrame
    
    local sliderBar = Instance.new("Frame")
    sliderBar.Size = UDim2.new(1, 0, 0, 10)
    sliderBar.Position = UDim2.new(0, 0, 0, 25)
    sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBar.BorderSizePixel = 0
    sliderBar.Parent = sliderFrame
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBar
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 0, 20)
    valueLabel.Position = UDim2.new(0, 0, 0, 35)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.Text = tostring(default)
    valueLabel.Font = Enum.Font.Gotham
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
    
    if tooltip then
        local Tooltip = Instance.new("TextLabel")
        Tooltip.Size = UDim2.new(1, -20, 0, 0)
        Tooltip.Position = UDim2.new(0, 10, 1, 0)
        Tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Tooltip.TextColor3 = Color3.fromRGB(200, 200, 200)
        Tooltip.Text = tooltip
        Tooltip.Font = Enum.Font.Gotham
        Tooltip.TextSize = 12
        Tooltip.TextWrapped = true
        Tooltip.Visible = false
        Tooltip.Parent = sliderFrame
        
        sliderBar.MouseEnter:Connect(function()
            Tooltip.Visible = true
            Tooltip.Size = UDim2.new(1, -20, 0, TextService:GetTextSize(tooltip, 12, Enum.Font.Gotham, Vector2.new(parent.AbsoluteSize.X - 40, math.huge)).Y + 10)
        end)
        
        sliderBar.MouseLeave:Connect(function()
            Tooltip.Visible = false
        end)
    end
    
    return {
        Set = function(self, value)
            local ratio = (value - min) / (max - min)
            sliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    }
end

-- ======== CREATE UI ELEMENTS ========

-- Main Tab
CreateToggle(Tabs.Main.Frame, "Enable All", function(enabled)
    -- Toggle all features
end, "Enable/disable all features at once")

-- Combat Tab
CreateToggle(Tabs.Combat.Frame, "Silent Aim", function(enabled)
    Settings.Combat.SilentAim = enabled
end, "Automatically aims at enemies without moving your camera")

CreateToggle(Tabs.Combat.Frame, "Hitbox Expansion", function(enabled)
    Settings.Combat.HitboxExpansion = enabled
end, "Makes enemy hitboxes larger for easier hits")

CreateSlider(Tabs.Combat.Frame, "Hitbox Size", 1, 3, 1.5, function(value)
    Settings.Combat.HitboxSize = value
end, "Adjust the size of enemy hitboxes")

CreateToggle(Tabs.Combat.Frame, "Kill All", function(enabled)
    Settings.Combat.KillAll = enabled
end, "Automatically kills all players in the game")

-- Visuals Tab
CreateToggle(Tabs.Visuals.Frame, "ESP", function(enabled)
    Settings.Visuals.ESP = enabled
end, "Shows information about other players through walls")

CreateToggle(Tabs.Visuals.Frame, "Boxes", function(enabled)
    Settings.Visuals.Boxes = enabled
end, "Draws boxes around players")

-- Player Tab
CreateToggle(Tabs.Player.Frame, "Speed Hack", function(enabled)
    Settings.Player.Speed = enabled
end, "Increases your movement speed")

CreateSlider(Tabs.Player.Frame, "Speed Value", 16, 200, 24, function(value)
    Settings.Player.SpeedValue = value
end, "Adjust your movement speed")

-- Misc Tab
CreateToggle(Tabs.Misc.Frame, "Auto Pickup Guns", function(enabled)
    Settings.Misc.AutoPickup = enabled
end, "Automatically picks up nearby guns")

-- Settings Tab
local LanguageDropdown = Instance.new("TextButton")
LanguageDropdown.Size = UDim2.new(1, -20, 0, 35)
LanguageDropdown.Position = UDim2.new(0, 10, 0, 10)
LanguageDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LanguageDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
LanguageDropdown.Text = "Language: "..Settings.Settings.Language
LanguageDropdown.Font = Enum.Font.Gotham
LanguageDropdown.TextSize = 14
LanguageDropdown.Parent = Tabs.Settings.Frame

local LanguageOptions = {"English", "Russian"}
local LanguageOpen = false

LanguageDropdown.MouseButton1Click:Connect(function()
    LanguageOpen = not LanguageOpen
    
    if LanguageOpen then
        for i, lang in ipairs(LanguageOptions) do
            local Option = Instance.new("TextButton")
            Option.Size = UDim2.new(1, -30, 0, 30)
            Option.Position = UDim2.new(0, 15, 0, 45 + (i-1)*35)
            Option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Option.TextColor3 = Color3.fromRGB(255, 255, 255)
            Option.Text = lang
            Option.Font = Enum.Font.Gotham
            Option.TextSize = 14
            Option.Parent = Tabs.Settings.Frame
            
            Option.MouseButton1Click:Connect(function()
                Settings.Settings.Language = lang
                LanguageDropdown.Text = "Language: "..lang
                CurrentLanguage = lang
                -- Update all UI text here
                for _, v in pairs(Option.Parent:GetChildren()) do
                    if v ~= Option and v ~= LanguageDropdown then
                        v:Destroy()
                    end
                end
                LanguageOpen = false
            end)
        end
    else
        for _, v in pairs(Tabs.Settings.Frame:GetChildren()) do
            if v ~= LanguageDropdown then
                v:Destroy()
            end
        end
    end
end)

-- ======== CORE FUNCTIONS ========

-- Autofarm system
local function AutoFarm()
    while Settings.Autofarm.Enabled and wait() do
        -- Autofarm logic here
    end
end

-- Silent Aim system
local function SilentAim()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if Settings.Combat.SilentAim and method == "FindPartOnRayWithWhitelist" and math.random(1, 100) <= Settings.Combat.HitChance then
            -- Find closest player logic
            local closestPlayer = nil
            -- ... targeting logic
            
            if closestPlayer and closestPlayer.Character then
                local head = closestPlayer.Character:FindFirstChild("Head")
                if head then
                    local predictedPosition = head.Position + (head.Velocity * Settings.Combat.Prediction)
                    args[1] = Ray.new(Workspace.CurrentCamera.CFrame.Position, (predictedPosition - Workspace.CurrentCamera.CFrame.Position).Unit * 1000)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

-- Hitbox expansion
local function ExpandHitboxes()
    if not Settings.Combat.HitboxExpansion then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Size = part.Size * Settings.Combat.HitboxSize
                end
            end
        end
    end
end

-- Kill all players
local function KillAll()
    if not Settings.Combat.KillAll then return end
    
    -- Kill all logic here
end

-- Speed hack
local function SpeedHack()
    if Settings.Player.Speed and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Settings.Player.SpeedValue
        end
    end
end

-- ESP system
local ESP = {
    Objects = {}
}

function ESP:Add(player)
    -- ESP creation logic
end

function ESP:Update()
    -- ESP update logic
end

-- Auto pickup guns
local function AutoPickup()
    while Settings.Misc.AutoPickup and wait(0.5) do
        -- Auto pickup logic
    end
end

-- ======== MAIN LOOP ========
local function MainLoop()
    -- Loading screen progress
    while tick() - startTime < loadTime do
        local progress = (tick() - startTime) / loadTime
        ProgressFill.Size = UDim2.new(progress, 0, 1, 0)
        LoadingText.Text = Languages[CurrentLanguage].Loading.." "..math.floor(progress * 100).."%"
        RunService.RenderStepped:Wait()
    end
    
    -- Hide loading screen
    LoadingScreen:Destroy()
    loaded = true
    
    -- Initialize systems
    SilentAim()
    spawn(AutoFarm)
    spawn(AutoPickup)
    
    -- Main game loop
    while wait() do
        ExpandHitboxes()
        SpeedHack()
        KillAll()
        
        if Settings.Visuals.ESP then
            ESP:Update()
        end
    end
end

-- ======== EVENT HANDLERS ========
CircleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Settings.Settings.Keybinds.ToggleMenu then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to load
    -- Reapply settings
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if Settings.Misc.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

-- ======== START ========
spawn(MainLoop)
print("Black Zone Hub loaded successfully!")
