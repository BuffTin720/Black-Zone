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
local StarterGui = game:GetService("StarterGui")
local Stats = game:GetService("Stats")

-- Constants
local VERSION = "3.0"
local AUTHOR = "Black Zone Team"
local CONFIG_FOLDER = "BlackZoneElite_Configs"
local DEFAULT_CONFIG = {
    Theme = "Dark",
    MenuKey = Enum.KeyCode.RightShift,
    MenuPosition = {X = 0.8, Y = 0.2},
    MenuSize = {Width = 500, Height = 600}
}

-- Device detection
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local isConsole = UserInputService.GamepadEnabled and not UserInputService.MouseEnabled
local isPC = not isMobile and not isConsole
local isVR = VRService.VREnabled

-- Global variables
local library = {
    Enabled = true,
    Configs = {},
    CurrentConfig = "default",
    Flags = {},
    Connections = {},
    Themes = {
        Dark = {
            Background = Color3.fromRGB(15, 15, 20),
            TabBackground = Color3.fromRGB(25, 25, 30),
            ElementBackground = Color3.fromRGB(30, 30, 40),
            TextColor = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(0, 150, 255),
            ToggleOn = Color3.fromRGB(0, 170, 0),
            ToggleOff = Color3.fromRGB(70, 70, 70)
        },
        Light = {
            Background = Color3.fromRGB(240, 240, 245),
            TabBackground = Color3.fromRGB(220, 220, 225),
            ElementBackground = Color3.fromRGB(200, 200, 210),
            TextColor = Color3.fromRGB(40, 40, 40),
            Accent = Color3.fromRGB(0, 120, 215),
            ToggleOn = Color3.fromRGB(0, 150, 0),
            ToggleOff = Color3.fromRGB(160, 160, 160)
        },
        Purple = {
            Background = Color3.fromRGB(20, 15, 30),
            TabBackground = Color3.fromRGB(30, 20, 45),
            ElementBackground = Color3.fromRGB(40, 30, 60),
            TextColor = Color3.fromRGB(255, 255, 255),
            Accent = Color3.fromRGB(170, 0, 255),
            ToggleOn = Color3.fromRGB(120, 0, 200),
            ToggleOff = Color3.fromRGB(70, 50, 90)
        }
    },
    CurrentTheme = "Dark"
}

-- Utility functions
local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Round(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function Tween(object, properties, duration, ...)
    local tweenInfo = TweenInfo.new(duration, ...)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function SaveConfig(name)
    if not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
    end
    
    local configData = {
        Settings = {
            Theme = library.CurrentTheme,
            MenuKey = DEFAULT_CONFIG.MenuKey,
            MenuPosition = DEFAULT_CONFIG.MenuPosition,
            MenuSize = DEFAULT_CONFIG.MenuSize
        },
        Features = library.Flags
    }
    
    writefile(CONFIG_FOLDER.."/"..name..".json", HttpService:JSONEncode(configData))
    library.Configs[name] = configData
end

local function LoadConfig(name)
    if library.Configs[name] then
        local config = library.Configs[name]
        
        -- Apply settings
        library.CurrentTheme = config.Settings.Theme or library.CurrentTheme
        DEFAULT_CONFIG.MenuKey = config.Settings.MenuKey or DEFAULT_CONFIG.MenuKey
        DEFAULT_CONFIG.MenuPosition = config.Settings.MenuPosition or DEFAULT_CONFIG.MenuPosition
        DEFAULT_CONFIG.MenuSize = config.Settings.MenuSize or DEFAULT_CONFIG.MenuSize
        
        -- Apply features
        for flag, value in pairs(config.Features) do
            if library.Flags[flag] then
                library.Flags[flag]:Set(value)
            end
        end
        
        return true
    end
    return false
end

local function GetConfigs()
    if not isfolder(CONFIG_FOLDER) then
        makefolder(CONFIG_FOLDER)
        return {}
    end
    
    local files = listfiles(CONFIG_FOLDER)
    local configs = {}
    
    for _, file in ipairs(files) do
        local name = file:match(".+/(.+)%..+$")
        if name then
            table.insert(configs, name)
            library.Configs[name] = HttpService:JSONDecode(readfile(file))
        end
    end
    
    return configs
end

-- Feature implementations
local Aimbot = {
    Enabled = false,
    FOV = 100,
    Smoothing = 10,
    Prediction = 0.15,
    HitChance = 100,
    TeamCheck = true,
    VisibleCheck = true,
    TargetPart = "Head",
    Parts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    FOVCircle = nil,
    Target = nil,
    Connections = {}
}

function Aimbot:Init()
    -- Create FOV circle
    self.FOVCircle = Create("Frame", {
        Name = "AimbotFOVCircle",
        Parent = library.Interface.Main,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, self.FOV * 2, 0, self.FOV * 2),
        Position = UDim2.new(0.5, -self.FOV, 0.5, -self.FOV),
        ZIndex = 100
    })
    
    local circle = Create("ImageLabel", {
        Parent = self.FOVCircle,
        Image = "rbxassetid://266543268",
        ImageColor3 = Color3.fromRGB(255, 50, 50),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(128, 128, 128, 128),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    -- Set up connections
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Enabled or not library.Enabled then return end
        
        -- Find target
        local closestPlayer, closestDistance = nil, self.FOV
        local localCharacter = LocalPlayer.Character
        local localHead = localCharacter and localCharacter:FindFirstChild("Head")
        
        if localHead then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local character = player.Character
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local head = character:FindFirstChild("Head")
                    
                    if humanoid and humanoid.Health > 0 and head then
                        -- Team check
                        if self.TeamCheck and player.Team == LocalPlayer.Team then continue end
                        
                        -- Visibility check
                        if self.VisibleCheck then
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            
                            local raycastResult = workspace:Raycast(
                                localHead.Position,
                                (head.Position - localHead.Position).Unit * 1000,
                                raycastParams
                            )
                            
                            if raycastResult and raycastResult.Instance:FindFirstAncestor(player.Name) == nil then
                                continue
                            end
                        end
                        
                        local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                        if onScreen then
                            local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            
                            if distance < closestDistance and math.random(1, 100) <= self.HitChance then
                                closestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
        
        self.Target = closestPlayer
    end))
    
    -- Silent aim hook
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if self.Enabled and method == "FindPartOnRayWithWhitelist" and self.Target and self.Target.Character then
            local targetPart = self.Target.Character:FindFirstChild(self.TargetPart)
            if targetPart then
                local predictedPosition = targetPart.Position + (targetPart.Velocity * self.Prediction)
                args[1] = Ray.new(workspace.CurrentCamera.CFrame.Position, (predictedPosition - workspace.CurrentCamera.CFrame.Position).Unit * 1000)
                return oldNamecall(self, unpack(args))
            end
        end
        
        return oldNamecall(self, ...)
    end)
end

function Aimbot:Update()
    if self.FOVCircle then
        self.FOVCircle.Size = UDim2.new(0, self.FOV * 2, 0, self.FOV * 2)
        self.FOVCircle.Position = UDim2.new(0.5, -self.FOV, 0.5, -self.FOV)
    end
end

local ESP = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = false,
    Chams = false,
    MaxDistance = 1000,
    TeamCheck = true,
    Objects = {},
    Connections = {}
}

function ESP:Add(player)
    if not player.Character then return end
    
    local holder = Create("Folder", {
        Name = player.Name,
        Parent = library.Interface.Main
    })
    
    local box = Create("Frame", {
        Name = "Box",
        Parent = holder,
        BackgroundTransparency = 1,
        BorderSizePixel = 2,
        BorderColor3 = Color3.fromRGB(255, 50, 50),
        ZIndex = 10,
        Visible = false
    })
    
    local nameLabel = Create("TextLabel", {
        Name = "Name",
        Parent = holder,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0.5,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 11,
        Visible = false
    })
    
    local healthBar = Create("Frame", {
        Name = "HealthBar",
        Parent = holder,
        BackgroundColor3 = Color3.fromRGB(50, 50, 50),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        ZIndex = 11,
        Visible = false
    })
    
    local healthFill = Create("Frame", {
        Name = "HealthFill",
        Parent = healthBar,
        BackgroundColor3 = Color3.fromRGB(0, 255, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 12
    })
    
    local distanceLabel = Create("TextLabel", {
        Name = "Distance",
        Parent = holder,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextStrokeTransparency = 0.5,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        ZIndex = 11,
        Visible = false
    })
    
    local tracer = Create("Frame", {
        Name = "Tracer",
        Parent = holder,
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 0, 1000),
        Rotation = 90,
        AnchorPoint = Vector2.new(0.5, 1),
        ZIndex = 9,
        Visible = false
    })
    
    self.Objects[player] = {
        Holder = holder,
        Box = box,
        NameLabel = nameLabel,
        HealthBar = healthBar,
        HealthFill = healthFill,
        DistanceLabel = distanceLabel,
        Tracer = tracer,
        Player = player
    }
end

function ESP:Remove(player)
    if self.Objects[player] then
        self.Objects[player].Holder:Destroy()
        self.Objects[player] = nil
    end
end

function ESP:Update()
    if not self.Enabled or not library.Enabled then
        for _, data in pairs(self.Objects) do
            data.Box.Visible = false
            data.NameLabel.Visible = false
            data.HealthBar.Visible = false
            data.DistanceLabel.Visible = false
            data.Tracer.Visible = false
        end
        return
    end
    
    local localCharacter = LocalPlayer.Character
    local localHead = localCharacter and localCharacter:FindFirstChild("Head")
    
    if not localHead then return end
    
    for player, data in pairs(self.Objects) do
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("Head") then
            local character = player.Character
            local head = character.Head
            local humanoid = character.Humanoid
            
            -- Team check
            if self.TeamCheck and player.Team == LocalPlayer.Team then
                data.Box.Visible = false
                data.NameLabel.Visible = false
                data.HealthBar.Visible = false
                data.DistanceLabel.Visible = false
                data.Tracer.Visible = false
                continue
            end
            
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
            local distance = (localHead.Position - head.Position).Magnitude
            
            if onScreen and distance <= self.MaxDistance then
                -- Calculate box size
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                local size = rootPart and rootPart.Size.Magnitude * 2 or 5
                
                -- Update box
                if self.Boxes then
                    data.Box.Visible = true
                    data.Box.Size = UDim2.new(0, size, 0, size * 1.5)
                    data.Box.Position = UDim2.new(0, screenPoint.X - size/2, 0, screenPoint.Y - size/2)
                else
                    data.Box.Visible = false
                end
                
                -- Update name
                if self.Names then
                    data.NameLabel.Visible = true
                    data.NameLabel.Text = player.Name
                    data.NameLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y - size * 1.5 - 20)
                else
                    data.NameLabel.Visible = false
                end
                
                -- Update health
                if self.Health then
                    data.HealthBar.Visible = true
                    data.HealthBar.Size = UDim2.new(0, size, 0, 3)
                    data.HealthBar.Position = UDim2.new(0, screenPoint.X - size/2, 0, screenPoint.Y + size * 1.5 + 5)
                    
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    data.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)
                    data.HealthFill.BackgroundColor3 = Color3.new(1 - healthPercent, healthPercent, 0)
                else
                    data.HealthBar.Visible = false
                end
                
                -- Update distance
                if self.Distance then
                    data.DistanceLabel.Visible = true
                    data.DistanceLabel.Text = tostring(Round(distance)).."m"
                    data.DistanceLabel.Position = UDim2.new(0, screenPoint.X, 0, screenPoint.Y + size * 1.5 + 10)
                else
                    data.DistanceLabel.Visible = false
                end
                
                -- Update tracer
                if self.Tracers then
                    data.Tracer.Visible = true
                    data.Tracer.Position = UDim2.new(0.5, 0, 1, 0)
                else
                    data.Tracer.Visible = false
                end
            else
                data.Box.Visible = false
                data.NameLabel.Visible = false
                data.HealthBar.Visible = false
                data.DistanceLabel.Visible = false
                data.Tracer.Visible = false
            end
        else
            data.Box.Visible = false
            data.NameLabel.Visible = false
            data.HealthBar.Visible = false
            data.DistanceLabel.Visible = false
            data.Tracer.Visible = false
        end
    end
end

function ESP:Init()
    -- Add existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:Add(player)
        end
    end
    
    -- Add new players
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        self:Add(player)
    end))
    
    -- Remove leaving players
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        self:Remove(player)
    end))
    
    -- Update loop
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:Update()
    end))
end

-- Player modifications
local PlayerMods = {
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
    Connections = {}
}

function PlayerMods:UpdateSpeed()
    if not self.Speed or not library.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = self.SpeedValue
    end
end

function PlayerMods:UpdateJump()
    if not self.JumpPower or not library.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.JumpPower = self.JumpValue
    end
end

function PlayerMods:FlyHandler()
    if not self.Fly or not library.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Create fly controller if it doesn't exist
    if not self.FlyController then
        self.FlyController = Instance.new("BodyVelocity")
        self.FlyController.Name = "FlyController"
        self.FlyController.MaxForce = Vector3.new(0, 0, 0)
        self.FlyController.Velocity = Vector3.new(0, 0, 0)
        self.FlyController.P = 1000
    end
    
    self.FlyController.Parent = root
    
    -- Handle input
    local flyDirection = Vector3.new(0, 0, 0)
    local flyUp = false
    local flyDown = false
    
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            flyUp = true
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyDown = true
        elseif input.KeyCode == Enum.KeyCode.W then
            flyDirection = flyDirection + Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            flyDirection = flyDirection + Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            flyDirection = flyDirection + Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            flyDirection = flyDirection + Vector3.new(1, 0, 0)
        end
    end))
    
    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            flyUp = false
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyDown = false
        elseif input.KeyCode == Enum.KeyCode.W then
            flyDirection = flyDirection - Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            flyDirection = flyDirection - Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            flyDirection = flyDirection - Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            flyDirection = flyDirection - Vector3.new(1, 0, 0)
        end
    end))
    
    -- Update velocity
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        if not self.Fly or not library.Enabled or not character or not root then
            if self.FlyController then
                self.FlyController.Velocity = Vector3.new(0, 0, 0)
            end
            return
        end
        
        local velocity = root.Velocity
        
        if flyUp then
            velocity = Vector3.new(velocity.X, self.FlySpeed, velocity.Z)
        elseif flyDown then
            velocity = Vector3.new(velocity.X, -self.FlySpeed, velocity.Z)
        else
            velocity = Vector3.new(velocity.X, 0, velocity.Z)
        end
        
        -- Apply movement direction
        if flyDirection.Magnitude > 0 then
            local camera = workspace.CurrentCamera
            local forward = camera.CFrame.LookVector
            local right = camera.CFrame.RightVector
            local up = camera.CFrame.UpVector
            
            local moveDirection = (forward * flyDirection.Z) + (right * flyDirection.X) + (up * flyDirection.Y)
            velocity = velocity + (moveDirection.Unit * self.FlySpeed)
        end
        
        self.FlyController.Velocity = velocity
    end))
end

function PlayerMods:NoClipHandler()
    if not self.Noclip or not library.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

function PlayerMods:InfiniteJumpHandler()
    if not self.InfiniteJump or not library.Enabled then return end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    table.insert(self.Connections, UserInputService.JumpRequest:Connect(function()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

function PlayerMods:Init()
    -- Speed and jump power
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:UpdateSpeed()
        self:UpdateJump()
        self:NoClipHandler()
    end))
    
    -- Fly
    self:FlyHandler()
    
    -- Infinite jump
    self:InfiniteJumpHandler()
    
    -- Character added event
    table.insert(self.Connections, LocalPlayer.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to load
        self:UpdateSpeed()
        self:UpdateJump()
    end))
end

-- Visual enhancements
local Visuals = {
    Fullbright = false,
    FPSBoost = false,
    NoFog = false,
    NoShadows = false,
    Chams = false,
    ThirdPerson = false,
    ThirdPersonDistance = 10,
    FOV = 70,
    OriginalFOV = 70,
    Connections = {}
}

function Visuals:UpdateFullbright()
    if not self.Fullbright or not library.Enabled then
        Lighting.Ambient = Color3.fromRGB(100, 100, 100)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        return
    end
    
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
end

function Visuals:UpdateFPSBoost()
    if not self.FPSBoost or not library.Enabled then
        settings().Rendering.QualityLevel = "Automatic"
        return
    end
    
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
end

function Visuals:UpdateNoFog()
    if not self.NoFog or not library.Enabled then
        Lighting.FogEnd = 1000
        return
    end
    
    Lighting.FogEnd = 9e9
end

function Visuals:UpdateNoShadows()
    if not self.NoShadows or not library.Enabled then
        Lighting.GlobalShadows = true
        return
    end
    
    Lighting.GlobalShadows = false
end

function Visuals:UpdateFOV()
    if not library.Enabled then
        workspace.CurrentCamera.FieldOfView = self.OriginalFOV
        return
    end
    
    workspace.CurrentCamera.FieldOfView = self.FOV
end

function Visuals:UpdateThirdPerson()
    if not self.ThirdPerson or not library.Enabled then
        workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
        return
    end
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    workspace.CurrentCamera.CFrame = root.CFrame * CFrame.new(0, 0, self.ThirdPersonDistance)
    workspace.CurrentCamera.Focus = root.CFrame
end

function Visuals:Init()
    -- Save original FOV
    self.OriginalFOV = workspace.CurrentCamera.FieldOfView
    
    -- Set up update loops
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        self:UpdateFullbright()
        self:UpdateFPSBoost()
        self:UpdateNoFog()
        self:UpdateNoShadows()
        self:UpdateFOV()
        self:UpdateThirdPerson()
    end))
end

-- Automation tools
local Automation = {
    Autofarm = false,
    CollectGuns = true,
    AutoPickup = true,
    KillAll = false,
    AutoReport = false,
    AutoVoteKick = false,
    Connections = {}
}

function Automation:AutofarmHandler()
    if not self.Autofarm or not library.Enabled then return end
    
    -- Autofarm logic would go here
    -- This is game-specific so needs to be implemented per-game
end

function Automation:AutoPickupHandler()
    if not self.AutoPickup or not library.Enabled then return end
    
    -- Auto pickup logic would go here
    -- This is game-specific so needs to be implemented per-game
end

function Automation:KillAllHandler()
    if not self.KillAll or not library.Enabled then return end
    
    -- Kill all logic would go here
    -- This is game-specific so needs to be implemented per-game
end

function Automation:Init()
    table.insert(self.Connections, RunService.Heartbeat:Connect(function()
        self:AutofarmHandler()
        self:AutoPickupHandler()
        self:KillAllHandler()
    end))
end

-- UI Library
library.Interface = {
    Main = nil,
    Toggle = nil,
    Tabs = {},
    Elements = {}
}

function library.Interface:CreateWindow()
    -- Main UI
    self.Main = Create("ScreenGui", {
        Name = "BlackZoneElite_"..tostring(math.random(100000,999999)),
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global
    })
    
    -- Toggle button
    self.Toggle = Create("Frame", {
        Name = "Toggle",
        Parent = self.Main,
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(DEFAULT_CONFIG.MenuPosition.X, 0, DEFAULT_CONFIG.MenuPosition.Y, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ZIndex = 100
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0.2, 0),
        Parent = self.Toggle
    })
    
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = self.Toggle,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.8,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 99
    })
    
    local icon = Create("ImageLabel", {
        Name = "Icon",
        Parent = self.Toggle,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(124, 204),
        ImageRectSize = Vector2.new(36, 36),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0.7, 0),
        Position = UDim2.new(0.15, 0, 0.15, 0),
        ZIndex = 101
    })
    
    -- Main frame
    local mainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = self.Main,
        Size = UDim2.new(0, DEFAULT_CONFIG.MenuSize.Width, 0, DEFAULT_CONFIG.MenuSize.Height),
        Position = UDim2.new(0.5, -DEFAULT_CONFIG.MenuSize.Width/2, 0.5, -DEFAULT_CONFIG.MenuSize.Height/2),
        BackgroundColor3 = library.Themes[library.CurrentTheme].Background,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 90
    })
    
    local mainCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = mainFrame
    })
    
    local mainShadow = Create("ImageLabel", {
        Name = "Shadow",
        Parent = mainFrame,
        Image = "rbxassetid://1316045217",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10, 10, 118, 118),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 10, 1, 10),
        Position = UDim2.new(0, -5, 0, -5),
        ZIndex = 89
    })
    
    -- Title bar
    local titleBar = Create("Frame", {
        Name = "TitleBar",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = library.Themes[library.CurrentTheme].TabBackground,
        BorderSizePixel = 0,
        ZIndex = 91
    })
    
    local titleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = titleBar
    })
    
    local titleText = Create("TextLabel", {
        Name = "Title",
        Parent = titleBar,
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = "BLACK ZONE ELITE v"..VERSION,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 92
    })
    
    local closeButton = Create("TextButton", {
        Name = "CloseButton",
        Parent = titleBar,
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -40, 0, 0),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = "X",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        ZIndex = 92
    })
    
    local closeCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = closeButton
    })
    
    -- Tab buttons
    local tabButtons = Create("Frame", {
        Name = "TabButtons",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = library.Themes[library.CurrentTheme].TabBackground,
        BorderSizePixel = 0,
        ZIndex = 91
    })
    
    local tabList = Create("UIListLayout", {
        Parent = tabButtons,
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    -- Tab content
    local tabContent = Create("Frame", {
        Name = "TabContent",
        Parent = mainFrame,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundTransparency = 1,
        ZIndex = 91
    })
    
    -- Create tabs
    self.Tabs = {
        {Name = "Main", Icon = "rbxassetid://3926307971", LayoutOrder = 1},
        {Name = "Combat", Icon = "rbxassetid://3926305904", LayoutOrder = 2},
        {Name = "Visuals", Icon = "rbxassetid://3926309567", LayoutOrder = 3},
        {Name = "Player", Icon = "rbxassetid://3926307971", LayoutOrder = 4},
        {Name = "Automation", Icon = "rbxassetid://3926305733", LayoutOrder = 5},
        {Name = "Settings", Icon = "rbxassetid://3926307971", LayoutOrder = 6}
    }
    
    for _, tab in ipairs(self.Tabs) do
        -- Tab button
        local tabButton = Create("TextButton", {
            Name = tab.Name.."Tab",
            Parent = tabButtons,
            Size = UDim2.new(0, 80, 1, 0),
            BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
            TextColor3 = library.Themes[library.CurrentTheme].TextColor,
            Text = "",
            LayoutOrder = tab.LayoutOrder,
            ZIndex = 92
        })
        
        local tabButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 5),
            Parent = tabButton
        })
        
        local tabIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = tabButton,
            Image = tab.Icon,
            ImageRectOffset = Vector2.new(124, 204),
            ImageRectSize = Vector2.new(36, 36),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.6, 0, 0.6, 0),
            Position = UDim2.new(0.2, 0, 0.2, 0),
            ZIndex = 93
        })
        
        local tabText = Create("TextLabel", {
            Name = "Text",
            Parent = tabButton,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0.8, 0),
            BackgroundTransparency = 1,
            TextColor3 = library.Themes[library.CurrentTheme].TextColor,
            Text = tab.Name:upper(),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            ZIndex = 93
        })
        
        -- Tab content frame
        local tabFrame = Create("ScrollingFrame", {
            Name = tab.Name.."Frame",
            Parent = tabContent,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = library.Themes[library.CurrentTheme].Accent,
            Visible = false,
            ZIndex = 92
        })
        
        local tabLayout = Create("UIListLayout", {
            Parent = tabFrame,
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        tab.Frame = tabFrame
        tab.Button = tabButton
        
        -- Tab button click event
        tabButton.MouseButton1Click:Connect(function()
            for _, otherTab in ipairs(self.Tabs) do
                otherTab.Frame.Visible = false
                otherTab.Button.BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground
            end
            
            tab.Frame.Visible = true
            tab.Button.BackgroundColor3 = library.Themes[library.CurrentTheme].Accent
        end)
    end
    
    -- Set first tab as active
    self.Tabs[1].Frame.Visible = true
    self.Tabs[1].Button.BackgroundColor3 = library.Themes[library.CurrentTheme].Accent
    
    -- UI controls
    self.Toggle.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    -- Keyboard shortcut
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == DEFAULT_CONFIG.MenuKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Make sure the toggle stays on top
    self.Toggle.ZIndex = 100
    shadow.ZIndex = 99
    icon.ZIndex = 101
    
    return mainFrame
end

function library.Interface:CreateTab(tabName)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == tabName then
            return tab.Frame
        end
    end
    return nil
end

function library.Interface:CreateSection(parent, title)
    local section = Create("Frame", {
        Name = "Section",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 40),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = section
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = section,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = title:upper(),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    return section
end

function library.Interface:CreateToggle(parent, text, state, callback)
    local toggle = Create("Frame", {
        Name = "Toggle",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = toggle
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = toggle,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 0)
    })
    
    local toggleFrame = Create("Frame", {
        Name = "ToggleFrame",
        Parent = toggle,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = state and library.Themes[library.CurrentTheme].ToggleOn or library.Themes[library.CurrentTheme].ToggleOff,
        BorderSizePixel = 0
    })
    
    local toggleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = toggleFrame
    })
    
    local toggleCircle = Create("Frame", {
        Name = "ToggleCircle",
        Parent = toggleFrame,
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0
    })
    
    local circleCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = toggleCircle
    })
    
    local btn = Create("TextButton", {
        Name = "Button",
        Parent = toggle,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Tween(toggleFrame, {BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOn}, 0.2)
            Tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
        else
            Tween(toggleFrame, {BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOff}, 0.2)
            Tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
        end
        callback(state)
    end)
    
    local flag = {
        Value = state,
        Set = function(self, value)
            state = value
            if state then
                toggleFrame.BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOn
                toggleCircle.Position = UDim2.new(1, -18, 0.5, -8)
            else
                toggleFrame.BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOff
                toggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            end
            callback(state)
        end
    }
    
    table.insert(library.Flags, flag)
    return flag
end

function library.Interface:CreateSlider(parent, text, min, max, default, callback)
    local slider = Create("Frame", {
        Name = "Slider",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 70),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren()
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = slider,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local track = Create("Frame", {
        Name = "Track",
        Parent = slider,
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOff,
        BorderSizePixel = 0
    })
    
    local trackCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = track
    })
    
    local fill = Create("Frame", {
        Name = "Fill",
        Parent = track,
        Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
        BackgroundColor3 = library.Themes[library.CurrentTheme].Accent,
        BorderSizePixel = 0
    })
    
    local fillCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 3),
        Parent = fill
    })
    
    local value = Create("TextLabel", {
        Name = "Value",
        Parent = slider,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -60, 0, 40),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = tostring(default),
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    
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
    
    local flag = {
        Value = default,
        Set = function(self, newValue)
            fill.Size = UDim2.new((newValue-min)/(max-min), 0, 1, 0)
            value.Text = tostring(newValue)
            callback(newValue)
        end
    }
    
    table.insert(library.Flags, flag)
    return flag
end

function library.Interface:CreateDropdown(parent, text, options, default, callback)
    local dropdown = Create("Frame", {
        Name = "Dropdown",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = dropdown
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = dropdown,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 0)
    })
    
    local current = Create("TextLabel", {
        Name = "Current",
        Parent = dropdown,
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -110, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = options[default] or options[1],
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    local arrow = Create("ImageLabel", {
        Name = "Arrow",
        Parent = dropdown,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(884, 420),
        ImageRectSize = Vector2.new(36, 36),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -25, 0.5, -10),
        Rotation = 90
    })
    
    local btn = Create("TextButton", {
        Name = "Button",
        Parent = dropdown,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    
    local dropdownFrame = Create("Frame", {
        Name = "DropdownFrame",
        Parent = dropdown,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 5),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 100
    })
    
    local dropdownCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = dropdownFrame
    })
    
    local dropdownLayout = Create("UIListLayout", {
        Parent = dropdownFrame,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    local open = false
    local selected = default
    
    local function toggle()
        open = not open
        if open then
            dropdownFrame.Visible = true
            Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, math.min(#options * 30, 150))}, 0.2)
            Tween(arrow, {Rotation = 270}, 0.2)
        else
            Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, function()
                dropdownFrame.Visible = false
            end)
            Tween(arrow, {Rotation = 90}, 0.2)
        end
    end
    
    btn.MouseButton1Click:Connect(toggle)
    
    -- Create options
    for i, option in ipairs(options) do
        local optionBtn = Create("TextButton", {
            Name = option,
            Parent = dropdownFrame,
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            TextColor3 = library.Themes[library.CurrentTheme].TextColor,
            Text = option,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            LayoutOrder = i,
            ZIndex = 101
        })
        
        optionBtn.MouseButton1Click:Connect(function()
            selected = i
            current.Text = option
            callback(i, option)
            toggle()
        end)
    end
    
    local flag = {
        Value = selected,
        Set = function(self, value)
            selected = value
            current.Text = options[value]
            callback(value, options[value])
        end
    }
    
    table.insert(library.Flags, flag)
    return flag
end

function library.Interface:CreateButton(parent, text, callback)
    local button = Create("TextButton", {
        Name = "Button",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        LayoutOrder = #parent:GetChildren()
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = button
    })
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

function library.Interface:CreateLabel(parent, text)
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #parent:GetChildren()
    })
    
    return label
end

function library.Interface:CreateKeybind(parent, text, default, callback)
    local keybind = Create("Frame", {
        Name = "Keybind",
        Parent = parent,
        Size = UDim2.new(1, -20, 0, 35),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ElementBackground,
        BorderSizePixel = 0,
        LayoutOrder = #parent:GetChildren()
    })
    
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = keybind
    })
    
    local label = Create("TextLabel", {
        Name = "Label",
        Parent = keybind,
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 10, 0, 0)
    })
    
    local key = Create("TextButton", {
        Name = "Key",
        Parent = keybind,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOff,
        TextColor3 = library.Themes[library.CurrentTheme].TextColor,
        Text = tostring(default):gsub("Enum.KeyCode.", ""),
        Font = Enum.Font.Gotham,
        TextSize = 12
    })
    
    local keyCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = key
    })
    
    local listening = false
    
    key.MouseButton1Click:Connect(function()
        listening = true
        key.Text = "..."
        key.BackgroundColor3 = library.Themes[library.CurrentTheme].Accent
    end)
    
    table.insert(library.Connections, UserInputService.InputBegan:Connect(function(input)
        if listening then
            local keyCode = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or nil
            
            if keyCode then
                key.Text = tostring(keyCode):gsub("Enum.KeyCode.", "")
                key.BackgroundColor3 = library.Themes[library.CurrentTheme].ToggleOff
                callback(keyCode)
                listening = false
            end
        end
    end))
    
    local flag = {
        Value = default,
        Set = function(self, value)
            key.Text = tostring(value):gsub("Enum.KeyCode.", "")
            callback(value)
        end
    }
    
    table.insert(library.Flags, flag)
    return flag
end

function library:Init()
    -- Create interface
    self.Interface:CreateWindow()
    
    -- Load configs
    GetConfigs()
    
    -- Initialize features
    Aimbot:Init()
    ESP:Init()
    PlayerMods:Init()
    Visuals:Init()
    Automation:Init()
    
    -- Create UI elements
    self:SetupUI()
    
    -- Anti-AFK
    table.insert(self.Connections, LocalPlayer.Idled:Connect(function()
        if library.Flags.AntiAFK and library.Flags.AntiAFK.Value then
            VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        end
    end))
end

function library:SetupUI()
    -- Main Tab
    local mainTab = self.Interface:CreateTab("Main")
    
    local welcomeSection = self.Interface:CreateSection(mainTab, "Welcome")
    self.Interface:CreateLabel(welcomeSection, "Welcome to Black Zone Elite v"..VERSION)
    self.Interface:CreateLabel(welcomeSection, "Created by "..AUTHOR)
    
    local statusSection = self.Interface:CreateSection(mainTab, "Status")
    self.Interface:CreateLabel(statusSection, "FPS: "..math.floor(1/RunService.RenderStepped:Wait()))
    self.Interface:CreateLabel(statusSection, "Ping: "..math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()))
    
    -- Combat Tab
    local combatTab = self.Interface:CreateTab("Combat")
    
    local aimbotSection = self.Interface:CreateSection(combatTab, "Aimbot")
    library.Flags.Aimbot = self.Interface:CreateToggle(aimbotSection, "Enable Aimbot", Aimbot.Enabled, function(state)
        Aimbot.Enabled = state
    end)
    
    library.Flags.AimbotFOV = self.Interface:CreateSlider(aimbotSection, "Aimbot FOV", 10, 360, Aimbot.FOV, function(value)
        Aimbot.FOV = value
        Aimbot:Update()
    end)
    
    library.Flags.AimbotSmoothing = self.Interface:CreateSlider(aimbotSection, "Smoothing", 1, 30, Aimbot.Smoothing, function(value)
        Aimbot.Smoothing = value
    end)
    
    library.Flags.AimbotPrediction = self.Interface:CreateSlider(aimbotSection, "Prediction", 0, 0.5, Aimbot.Prediction, function(value)
        Aimbot.Prediction = value
    end)
    
    library.Flags.AimbotHitChance = self.Interface:CreateSlider(aimbotSection, "Hit Chance", 0, 100, Aimbot.HitChance, function(value)
        Aimbot.HitChance = value
    end)
    
    library.Flags.AimbotTeamCheck = self.Interface:CreateToggle(aimbotSection, "Team Check", Aimbot.TeamCheck, function(state)
        Aimbot.TeamCheck = state
    end)
    
    library.Flags.AimbotVisibleCheck = self.Interface:CreateToggle(aimbotSection, "Visible Check", Aimbot.VisibleCheck, function(state)
        Aimbot.VisibleCheck = state
    end)
    
    library.Flags.AimbotTargetPart = self.Interface:CreateDropdown(aimbotSection, "Target Part", Aimbot.Parts, 1, function(index, value)
        Aimbot.TargetPart = value
    end)
    
    -- Visuals Tab
    local visualsTab = self.Interface:CreateTab("Visuals")
    
    local espSection = self.Interface:CreateSection(visualsTab, "ESP")
    library.Flags.ESP = self.Interface:CreateToggle(espSection, "Enable ESP", ESP.Enabled, function(state)
        ESP.Enabled = state
    end)
    
    library.Flags.ESPBoxes = self.Interface:CreateToggle(espSection, "Boxes", ESP.Boxes, function(state)
        ESP.Boxes = state
    end)
    
    library.Flags.ESPNames = self.Interface:CreateToggle(espSection, "Names", ESP.Names, function(state)
        ESP.Names = state
    end)
    
    library.Flags.ESPHealth = self.Interface:CreateToggle(espSection, "Health", ESP.Health, function(state)
        ESP.Health = state
    end)
    
    library.Flags.ESPDistance = self.Interface:CreateToggle(espSection, "Distance", ESP.Distance, function(state)
        ESP.Distance = state
    end)
    
    library.Flags.ESPTracers = self.Interface:CreateToggle(espSection, "Tracers", ESP.Tracers, function(state)
        ESP.Tracers = state
    end)
    
    library.Flags.ESPTeamCheck = self.Interface:CreateToggle(espSection, "Team Check", ESP.TeamCheck, function(state)
        ESP.TeamCheck = state
    end)
    
    library.Flags.ESPMaxDistance = self.Interface:CreateSlider(espSection, "Max Distance", 0, 5000, ESP.MaxDistance, function(value)
        ESP.MaxDistance = value
    end)
    
    local visualsSection = self.Interface:CreateSection(visualsTab, "Visual Modifications")
    library.Flags.Fullbright = self.Interface:CreateToggle(visualsSection, "Fullbright", Visuals.Fullbright, function(state)
        Visuals.Fullbright = state
    end)
    
    library.Flags.FPSBoost = self.Interface:CreateToggle(visualsSection, "FPS Boost", Visuals.FPSBoost, function(state)
        Visuals.FPSBoost = state
    end)
    
    library.Flags.NoFog = self.Interface:CreateToggle(visualsSection, "No Fog", Visuals.NoFog, function(state)
        Visuals.NoFog = state
    end)
    
    library.Flags.NoShadows = self.Interface:CreateToggle(visualsSection, "No Shadows", Visuals.NoShadows, function(state)
        Visuals.NoShadows = state
    end)
    
    library.Flags.FOV = self.Interface:CreateSlider(visualsSection, "Field of View", 70, 120, Visuals.FOV, function(value)
        Visuals.FOV = value
    end)
    
    -- Player Tab
    local playerTab = self.Interface:CreateTab("Player")
    
    local movementSection = self.Interface:CreateSection(playerTab, "Movement")
    library.Flags.Speed = self.Interface:CreateToggle(movementSection, "Speed Hack", PlayerMods.Speed, function(state)
        PlayerMods.Speed = state
    end)
    
    library.Flags.SpeedValue = self.Interface:CreateSlider(movementSection, "Speed Value", 16, 200, PlayerMods.SpeedValue, function(value)
        PlayerMods.SpeedValue = value
    end)
    
    library.Flags.JumpPower = self.Interface:CreateToggle(movementSection, "Jump Power", PlayerMods.JumpPower, function(state)
        PlayerMods.JumpPower = state
    end)
    
    library.Flags.JumpValue = self.Interface:CreateSlider(movementSection, "Jump Value", 16, 200, PlayerMods.JumpValue, function(value)
        PlayerMods.JumpValue = value
    end)
    
    library.Flags.Fly = self.Interface:CreateToggle(movementSection, "Fly", PlayerMods.Fly, function(state)
        PlayerMods.Fly = state
    end)
    
    library.Flags.FlySpeed = self.Interface:CreateSlider(movementSection, "Fly Speed", 10, 100, PlayerMods.FlySpeed, function(value)
        PlayerMods.FlySpeed = value
    end)
    
    library.Flags.Noclip = self.Interface:CreateToggle(movementSection, "Noclip", PlayerMods.Noclip, function(state)
        PlayerMods.Noclip = state
    end)
    
    library.Flags.InfiniteJump = self.Interface:CreateToggle(movementSection, "Infinite Jump", PlayerMods.InfiniteJump, function(state)
        PlayerMods.InfiniteJump = state
    end)
    
    -- Automation Tab
    local automationTab = self.Interface:CreateTab("Automation")
    
    local farmingSection = self.Interface:CreateSection(automationTab, "Farming")
    library.Flags.Autofarm = self.Interface:CreateToggle(farmingSection, "Autofarm", Automation.Autofarm, function(state)
        Automation.Autofarm = state
    end)
    
    library.Flags.CollectGuns = self.Interface:CreateToggle(farmingSection, "Collect Guns", Automation.CollectGuns, function(state)
        Automation.CollectGuns = state
    end)
    
    library.Flags.AutoPickup = self.Interface:CreateToggle(farmingSection, "Auto Pickup", Automation.AutoPickup, function(state)
        Automation.AutoPickup = state
    end)
    
    library.Flags.KillAll = self.Interface:CreateToggle(farmingSection, "Kill All", Automation.KillAll, function(state)
        Automation.KillAll = state
    end)
    
    -- Settings Tab
    local settingsTab = self.Interface:CreateTab("Settings")
    
    local configSection = self.Interface:CreateSection(settingsTab, "Configurations")
    local configs = GetConfigs()
    self.Interface:CreateDropdown(configSection, "Config", configs, 1, function(index, value)
        library.CurrentConfig = value
    end)
    
    self.Interface:CreateButton(configSection, "Save Config", function()
        SaveConfig(library.CurrentConfig)
    end)
    
    self.Interface:CreateButton(configSection, "Load Config", function()
        LoadConfig(library.CurrentConfig)
    end)
    
    local uiSection = self.Interface:CreateSection(settingsTab, "UI Settings")
    library.Flags.Theme = self.Interface:CreateDropdown(uiSection, "Theme", {"Dark", "Light", "Purple"}, 1, function(index, value)
        library.CurrentTheme = value
        -- Update theme colors
    end)
    
    library.Flags.MenuKey = self.Interface:CreateKeybind(uiSection, "Menu Key", DEFAULT_CONFIG.MenuKey, function(key)
        DEFAULT_CONFIG.MenuKey = key
    end)
    
    local miscSection = self.Interface:CreateSection(settingsTab, "Miscellaneous")
    library.Flags.AntiAFK = self.Interface:CreateToggle(miscSection, "Anti-AFK", false, function(state)
        -- Handled in the idle connection
    end)
    
    self.Interface:CreateButton(miscSection, "Destroy UI", function()
        library:Destroy()
    end)
end

function library:Destroy()
    -- Disable all features
    library.Enabled = false
    
    -- Disconnect all connections
    for _, connection in ipairs(library.Connections) do
        connection:Disconnect()
    end
    
    -- Destroy UI
    if self.Interface.Main then
        self.Interface.Main:Destroy()
    end
    
    -- Clean up
    table.clear(library)
end

-- Initialize the library
library:Init()
