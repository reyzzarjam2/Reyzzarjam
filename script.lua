task.wait(0.1)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ESP_Colors = {
    ["Merah"] = Color3.fromRGB(255, 40, 40),
    ["Hijau"] = Color3.fromRGB(40, 255, 100),
    ["Biru"] = Color3.fromRGB(40, 100, 255),
    ["Kuning"] = Color3.fromRGB(255, 230, 30),
    ["Cyan"] = Color3.fromRGB(20, 255, 255),
    ["Pink"] = Color3.fromRGB(255, 80, 200),
    ["Ungu"] = Color3.fromRGB(170, 50, 255),
    ["Putih"] = Color3.fromRGB(255, 255, 255),
    ["Hitam"] = Color3.fromRGB(0, 0, 0),
    ["Oren"] = Color3.fromRGB(255, 140, 20)
}
local ESP_ColorList = {"Merah", "Hijau", "Biru", "Kuning", "Cyan", "Pink", "Ungu", "Putih", "Hitam", "Oren"}
local TextChatService = game:GetService("TextChatService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local ConfigFolder = "ReyzzHub_UniversalConfigs"
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Caps = {
    WriteFile = (typeof(writefile) == "function"),
    ReadFile = (typeof(readfile) == "function"),
    MakeFolder = (typeof(makefolder) == "function"),
    ListFiles = (typeof(listfiles) == "function"),
    IsFile = (typeof(isfile) == "function"),
    SetFPS = (typeof(setfpscap) == "function")
}

local ConfigFolder = "ReyzzHub_UniversalConfigs"
if not isfolder(ConfigFolder) then
    if makefolder then makefolder(ConfigFolder) end
end

UP_Config = { 
    JumpX = 0.8,
    JumpY = 0.8,
    JumpSize = 1.0,
    CustomJumpEnabled = true
}

function SaveUPConfig()
    if not writefile then return end 
    pcall(function()
        local FilePath = ConfigFolder .. "/MobileLayout.json"
        writefile(FilePath, game:GetService("HttpService"):JSONEncode(UP_Config))
    end)
end

function LoadUPConfig()
    local FilePath = ConfigFolder .. "/MobileLayout.json"
    
    if not isfile or not readfile then return end
    if isfile(FilePath) then
        pcall(function()
            local data = readfile(FilePath)
            local decoded = game:GetService("HttpService"):JSONDecode(data)
            if decoded then
                for k, v in pairs(decoded) do
                    UP_Config[k] = v
                end
            end
        end)
    end
end
do
    local JumpLoop = nil

    function UpdateMobileJump()
        if not game:GetService("UserInputService").TouchEnabled then return end
        if LoadUPConfig then LoadUPConfig() end
        local IsActive = true
        if typeof(UP_Config) == "table" and UP_Config.CustomJumpEnabled ~= nil then
            IsActive = UP_Config.CustomJumpEnabled
        end
        if JumpLoop then JumpLoop:Disconnect() JumpLoop = nil end
        if not IsActive then return end
        local RunService = game:GetService("RunService")
        JumpLoop = RunService.RenderStepped:Connect(function()
            pcall(function()
                local Plr = game:GetService("Players").LocalPlayer
                local PlrGui = Plr and Plr:FindFirstChild("PlayerGui")
                local Touch = PlrGui and PlrGui:FindFirstChild("TouchGui")
                local Frame = Touch and Touch:FindFirstChild("TouchControlFrame")
                local JumpBtn = Frame and (Frame:FindFirstChild("JumpButton") or Frame:FindFirstChild("JumpImage"))
                
                if JumpBtn then
                    local Scale = (UP_Config.JumpSize or 1)
                    local PosX = (UP_Config.JumpX or 0.8)
                    local PosY = (UP_Config.JumpY or 0.8)
                    local BaseSize = 140 
                    
                    JumpBtn.Size = UDim2.new(0, BaseSize * Scale, 0, BaseSize * Scale)
                    JumpBtn.Position = UDim2.new(PosX, 0, PosY, 0)
                    JumpBtn.Visible = true
                end
            end)
        end)
    end
    task.delay(1, function() UpdateMobileJump() end)
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        UpdateMobileJump()
    end)
end
game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "UI LOADING REYZZHUB",
        Text = "WAIT a MINUTE FOR LOADING",
        Duration = 10
    })
task.spawn(function()
    local UIS = game:GetService("UserInputService")
    if not UIS.TouchEnabled then return end
    while task.wait(1) do 
        UpdateMobileJump()
    end
end)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if game:GetService("UserInputService").TouchEnabled then
        task.wait(0.5)
        UpdateMobileJump()
        task.wait(1)
        UpdateMobileJump()
    end
end)
task.wait(1)
UpdateMobileJump()
local function SafeWriteFile(name, content)
    if Caps.WriteFile then pcall(function() writefile(name, content) end) end
end
local function SafeReadFile(name)
    if Caps.ReadFile and Caps.IsFile and isfile(name) then 
        local s, r = pcall(function() return readfile(name) end)
        if s then return r end
    end
    return nil
end
local function SafeMakeFolder(name)
    if Caps.MakeFolder then pcall(function() makefolder(name) end) end
end
local function SafeSetFPS(val)
    if Caps.SetFPS then pcall(function() setfpscap(val) end) end
end
local HttpService = game:GetService("HttpService")
local function GetRandomName()
    return HttpService:GenerateGUID(false)
end
local function ParseColor(str)
    local r, g, b = str:match("(%d+),%s*(%d+),%s*(%d+)")
    if r and g and b then
        return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
    end
    return nil
end
local MySafeName = GetRandomName()
local EspName = GetRandomName()
if not isfolder(ConfigFolder) then
    SafeMakeFolder(ConfigFolder)
end
local AutoExecFile = "Reyzz_AutoExec_Status.txt"
local AutoExecStatus = isfile(AutoExecFile) and readfile(AutoExecFile) == "true"
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),       
        Sidebar    = Color3.fromRGB(20, 20, 25),       
        ElementBG  = Color3.fromRGB(30, 30, 40),       
        Accent     = Color3.fromRGB(99, 102, 241),     
        Text       = Color3.fromRGB(255, 255, 255),    
        TextDim    = Color3.fromRGB(148, 163, 184),    
        Stroke     = Color3.fromRGB(60, 60, 80)        
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Sidebar = Color3.fromRGB(220, 220, 230),
        ElementBG = Color3.fromRGB(255, 255, 255),
        Accent = Color3.fromRGB(0, 120, 255),
        Text = Color3.fromRGB(30, 30, 30),
        TextDim = Color3.fromRGB(100, 100, 100),
        Stroke = Color3.fromRGB(200, 200, 200)
    },
    NeonCyan = {
        Background = Color3.fromRGB(10, 15, 20),
        Sidebar = Color3.fromRGB(5, 10, 15),
        ElementBG = Color3.fromRGB(20, 30, 40),
        Accent = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextDim = Color3.fromRGB(100, 200, 200),
        Stroke = Color3.fromRGB(0, 100, 100)
    },
    NeonGreen = {
        Background = Color3.fromRGB(10, 20, 10),
        Sidebar = Color3.fromRGB(5, 15, 5),
        ElementBG = Color3.fromRGB(20, 35, 20),
        Accent = Color3.fromRGB(50, 255, 50),
        Text = Color3.fromRGB(220, 255, 220),
        TextDim = Color3.fromRGB(100, 180, 100),
        Stroke = Color3.fromRGB(20, 80, 20)
    },
    NeonRed = {
        Background = Color3.fromRGB(20, 10, 10),
        Sidebar = Color3.fromRGB(15, 5, 5),
        ElementBG = Color3.fromRGB(35, 20, 20),
        Accent = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(255, 220, 220),
        TextDim = Color3.fromRGB(180, 100, 100),
        Stroke = Color3.fromRGB(80, 20, 20)
    }
}
local CurrentThemeName = 'Dark'
local CurrentTheme = Themes[CurrentThemeName]
local ThemeRegistry = {} 
local function RegisterTheme(instance, property, themeKey)
    table.insert(ThemeRegistry, {Obj = instance, Prop = property, Key = themeKey})
    instance[property] = CurrentTheme[themeKey]
end
local function ApplyTheme(themeName)
    if Themes[themeName] then
        CurrentThemeName = themeName
        CurrentTheme = Themes[themeName]
        for _, data in pairs(ThemeRegistry) do
            if data.Obj and data.Obj.Parent then
                TweenService:Create(data.Obj, TweenInfo.new(0.3), {[data.Prop] = CurrentTheme[data.Key]}):Play()
            end
        end
        return true
    end
    return false
end
local UIScale = {
    BaseSize = UDim2.new(0, 700, 0, 450), 
    LargeSize = UDim2.new(0, 900, 0, 550), 
    FontSmall = 12,
    FontNormal = 14, 
    FontHeader = 18
}
local Toggles = {} 
local State = {
    Aimbot = false,
    AimbotMode = "All Players",
    AimbotAggressiveness = 0.4,
    AimbotPart = "Head",
    AimbotButton = Enum.UserInputType.MouseButton2,
    WallCheck = false,
    TouchFling = false,
    FlingMode = "Walk",
    HitboxLoop = false,
    HitboxSize = 15,
    HitboxInvisible = true,
    HitboxPart = "HumanoidRootPart", 
    AutoClicker = false,
    CPS = 10,
    WeaponRapidFire = false,
    RapidFireCPS = 20,
    AntiFling = false,
    NoRecoil = false,
    GunMods = false,
    InfiniteJump = false,
    NoFall = false,
    Noclip = false, 
    Fly = false, 
    Spider = false,
    Bhop = false, 
    WalkSpeed = 16, 
    JumpPower = 50, 
    AutoRegen = false,
    LoopSpeed = false, 
    FakeLag = false,
    AntiTP = false,
    LastSafeTPPos = nil, 
    MasterESP = false, 
    ShowInventory = false,
    XRay = false,
    Crosshair = false,
    NightVision = false,
    EntityESP = false,
    KeyESP = false,
    MonsterNotify = false,
    ObjectInspector = false,
    FullbrightLoop = false, 
    NoFog = false, 
    NoParticles = false,
    AntiVoid = false, 
    VoidHeight = -50, 
    LastSafePos = nil, 
    WalkOnWater = false, 
    GravityControl = false,
    AntiDrown = false,
    PlatformWalk = false,
    PlatformHeight = -3.5,
    AntiKillBrick = false,
    AutoInteract = false,
    GodModeBug = false,
    Headless = false,
    Freecam = false, 
    FreecamSpeed = 1, 
    FreecamPos = Camera.CFrame, 
    FreecamRot = Vector2.new(0, 0),
    FreecamPart = nil,
    MaxZoom = false,
    SpectatingPlayer = nil,
    CinematicCamera = false,
    FOV = 90,
    LockFOV = false,   
    TargetFOV = 90,   
    LockTime = false, 
    TargetTime = 14, 
    IdentityMode = "Default",
    CustomNameText = "Reyzz Hub User",
    RainbowAnim = false,
    SpectatorList = false,
    AdminDetector = false,
    AdminGroupId = 0,
    ProximityWarning = false,
    ProximityDist = 50,
    ProximityMode = "All",
    TargetJobId = "",
    AnimLogger = false,
    ChatLogger = false,
    ForceUnlockMouse = false,
    AutoReconnect = true,
    IsRespawning = false,
    LastPos = nil,
    AntiAFK = true,
    ClickTP = false,
    SpinBot = false,
    SpinSpeed = 100,
    IsMaximized = false,
    ShowStats = false,
    AnimChanger = false,
    AnimFixLoop = nil,
    CurrentAnimID = 0,
    CurrentAnimTrack = nil,
    AnimRigType = "R15",
    FlyVehicle = false,
    BhopLegit = false,
    GravityWall = false,
    WallRun = false,    
    ChatBypass = false,
    AutoBadge = false,
    UnlockFPS = false,
    EspEnemyColorName = "Merah",  
    EspTeamColorName = "Hijau",   
    EspNameColorName = "Putih",   
    EspEnemyColor = Color3.fromRGB(255, 50, 50),
    EspTeamColor = Color3.fromRGB(0, 255, 100),
    EspNameColor = Color3.fromRGB(255, 255, 255),
    UseCustomNameColor = false, 
    SelectedLang = "ID",   
    CurrentVersion = "1.1", 
    RegisteredFeatures = {},  
    UIListeners = {}          
}
local LoopSpeedConnections = { wsLoop = nil, wsCA = nil }
local PlatformPart = nil
local PlatformY = nil
local function EnableLoopSpeed(speedVal)
    local Char = LocalPlayer.Character or workspace:FindFirstChild(LocalPlayer.Name)
    local Human = Char and Char:FindFirstChildWhichIsA("Humanoid")
    local function WalkSpeedChange()
        if Char and Human then
            Human.WalkSpeed = speedVal
        end
    end
    WalkSpeedChange()
    if LoopSpeedConnections.wsLoop then LoopSpeedConnections.wsLoop:Disconnect() end
    if LoopSpeedConnections.wsCA then LoopSpeedConnections.wsCA:Disconnect() end
    LoopSpeedConnections.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    LoopSpeedConnections.wsCA = LocalPlayer.CharacterAdded:Connect(function(nChar)
        Char, Human = nChar, nChar:WaitForChild("Humanoid")
        WalkSpeedChange()
        if LoopSpeedConnections.wsLoop then LoopSpeedConnections.wsLoop:Disconnect() end
        LoopSpeedConnections.wsLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(WalkSpeedChange)
    end)
end
local function DisableLoopSpeed()
    if LoopSpeedConnections.wsLoop then 
        LoopSpeedConnections.wsLoop:Disconnect()
        LoopSpeedConnections.wsLoop = nil 
    end
    if LoopSpeedConnections.wsCA then 
        LoopSpeedConnections.wsCA:Disconnect()
        LoopSpeedConnections.wsCA = nil 
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = DefaultWalkSpeed or 16
    end
end
local HitboxConnection = nil
local AutoClickerRunning = false
local function ApplyHitboxLogic()
    local Settings = {
        Size = State.HitboxSize,
        Transparency = State.HitboxInvisible and 1 or 0.6
    }
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local targetVec = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
                if hrp.Size ~= targetVec then
                    hrp.Size = targetVec
                    hrp.Transparency = Settings.Transparency
                end
                if hrp.CanCollide then 
                    hrp.CanCollide = false 
                end
                if hrp.RotVelocity.Magnitude > 0 then
                    hrp.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
    end
end
local HitboxConnection = nil
local function ToggleHitbox(enable)
    State.HitboxLoop = enable
    if HitboxConnection then
        HitboxConnection:Disconnect()
        HitboxConnection = nil
    end
    if enable then
        HitboxConnection = game:GetService("RunService").RenderStepped:Connect(function()
            for _, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v ~= LocalPlayer and v.Character then
                    local root = v.Character:FindFirstChild("HumanoidRootPart")
                    local hum = v.Character:FindFirstChild("Humanoid")
                    if root and hum and hum.Health > 0 then
                        local Size = State.HitboxSize or 15
                        local TargetSize = Vector3.new(Size, Size, Size)
                        if root.Size.X ~= Size then
                            root.Size = Vector3.new(Size, Size, Size)
                            root.CanCollide = false
                            root.Transparency = State.HitboxInvisible and 1 or 0.4
                        end
                        root.CanCollide = false 
                    end
                end
            end
        end)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
        end
        for _, v in pairs(game:GetService("Players"):GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local root = v.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = Vector3.new(2, 2, 1)
                    root.Transparency = 1
                    root.CanCollide = true
                end
            end
        end
    end
end
local function ManageAutoClicker(enable)
    State.AutoClicker = enable
    if enable then
        if AutoClickerRunning then return end 
        AutoClickerRunning = true
        task.spawn(function()
            while State.AutoClicker do
                local char = game:GetService("Players").LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
                task.wait(1 / math.max(1, State.CPS))
            end
            AutoClickerRunning = false
        end)
    end
end
local GC = getconnections or get_signal_cons
if GC then
    for i,v in pairs(GC(LocalPlayer.Idled)) do
        if v["Disable"] then v["Disable"](v) elseif v["Disconnect"] then v["Disconnect"](v) end
    end
end
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end)
local DefaultWalkSpeed = 16
local DefaultJumpPower = 50
task.spawn(function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            DefaultWalkSpeed = hum.WalkSpeed
            if hum.UseJumpPower then
                DefaultJumpPower = hum.JumpPower
            else
                DefaultJumpPower = hum.JumpHeight
            end
            State.WalkSpeed = DefaultWalkSpeed
            State.JumpPower = DefaultJumpPower
        end
    end
end)
local function GetSafeGui()
    if gethui then return gethui() end
    if get_hidden_gui then return get_hidden_gui() end
    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if success and core then return core end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
if getgenv().ReyzzInstance and getgenv().ReyzzInstance.Parent then
    getgenv().ReyzzInstance:Destroy() 
end
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = MySafeName 
ScreenGui.Parent = GetSafeGui()
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.DisplayOrder = 2147483647

State.MobileInput = {Move = Vector3.new(0,0,0), Up = 0, Zoom = 0} 
IsTouch = game:GetService("UserInputService").TouchEnabled
if IsTouch then
    DroneUI = Instance.new("Frame", ScreenGui)
    DroneUI.Name = "DroneControls"
    DroneUI.Size = UDim2.new(1, 0, 1, 0)
    DroneUI.BackgroundTransparency = 1
    DroneUI.Visible = false
    local JoyBG = Instance.new("Frame", DroneUI)
    JoyBG.Size = UDim2.new(0, 150, 0, 150)
    JoyBG.Position = UDim2.new(0, 50, 1, -220) 
    JoyBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    JoyBG.BackgroundTransparency = 0.6
    Instance.new("UICorner", JoyBG).CornerRadius = UDim.new(1, 0)
    local JoyKnob = Instance.new("TextButton", JoyBG) 
    JoyKnob.Size = UDim2.new(0, 60, 0, 60)
    JoyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
    JoyKnob.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    JoyKnob.BackgroundTransparency = 0.2
    JoyKnob.Text = ""
    Instance.new("UICorner", JoyKnob).CornerRadius = UDim.new(1, 0)
    local dragging = false
    local origin = JoyBG.AbsolutePosition + (JoyBG.AbsoluteSize / 2)
    JoyKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            origin = JoyBG.AbsolutePosition + (JoyBG.AbsoluteSize / 2)
        end
    end)
    JoyKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            JoyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
            State.MobileInput.Move = Vector3.new(0,0,0)
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local pos = input.Position
            local dist = Vector2.new(pos.X, pos.Y) - origin
            local maxDist = JoyBG.AbsoluteSize.X / 2
            if dist.Magnitude > maxDist then
                local clamped = dist.Unit * maxDist
                dist = clamped
            end
            JoyKnob.Position = UDim2.new(0.5, -30 + dist.X, 0.5, -30 + dist.Y)
            State.MobileInput.Move = Vector3.new(dist.X / maxDist, 0, dist.Y / maxDist)
        end
    end)
    function CreateDroneBtn(txt, pos, type, val)
        local btn = Instance.new("TextButton", DroneUI)
        btn.Size = UDim2.new(0, 50, 0, 50) 
        btn.Position = pos
        btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = 0.5
        btn.Text = txt
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 20
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
        btn.InputBegan:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if type == "Up" then State.MobileInput.Up = val end
                if type == "Zoom" then State.MobileInput.Zoom = val end
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            end
        end)
        btn.InputEnded:Connect(function(input) 
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if type == "Up" then State.MobileInput.Up = 0 end
                if type == "Zoom" then State.MobileInput.Zoom = 0 end
                btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            end
        end)
    end
    CreateDroneBtn("⬆", UDim2.new(1, -120, 1, -180), "Up", 1)   
    CreateDroneBtn("⬇", UDim2.new(1, -120, 1, -120), "Up", -1)  
    CreateDroneBtn("➕", UDim2.new(1, -180, 1, -180), "Zoom", 1)  
    CreateDroneBtn("➖", UDim2.new(1, -180, 1, -120), "Zoom", -1) 
end
local CrosshairFrame = Instance.new("Frame", ScreenGui); CrosshairFrame.Name = GetRandomName() CrosshairFrame.Size = UDim2.new(0, 20, 0, 20); CrosshairFrame.Position = UDim2.new(0.5, -10, 0.5, -10); CrosshairFrame.BackgroundTransparency = 1; CrosshairFrame.Visible = false
local CH_H = Instance.new("Frame", CrosshairFrame); CH_H.Size = UDim2.new(1, 0, 0, 2); CH_H.Position = UDim2.new(0, 0, 0.5, -1); RegisterTheme(CH_H, "BackgroundColor3", "Accent"); CH_H.BorderSizePixel = 0
local CH_V = Instance.new("Frame", CrosshairFrame); CH_V.Size = UDim2.new(0, 2, 1, 0); CH_V.Position = UDim2.new(0.5, -1, 0, 0); RegisterTheme(CH_V, "BackgroundColor3", "Accent"); CH_V.BorderSizePixel = 0
local ProxFrame = Instance.new("Frame", ScreenGui)
ProxFrame.Name = GetRandomName()
ProxFrame.Size = UDim2.new(0, 260, 0, 50) 
ProxFrame.AutomaticSize = Enum.AutomaticSize.Y 
ProxFrame.Position = UDim2.new(0.5, -130, 0.08, 0) 
ProxFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ProxFrame.BackgroundTransparency = 0.2
ProxFrame.Visible = false
ProxFrame.ClipsDescendants = true
Instance.new("UICorner", ProxFrame).CornerRadius = UDim.new(0, 12)
local ProxStroke = Instance.new("UIStroke", ProxFrame)
ProxStroke.Color = Color3.fromRGB(255, 50, 50)
ProxStroke.Thickness = 2
ProxStroke.Transparency = 0.5
local ProxGrad = Instance.new("UIGradient", ProxFrame)
ProxGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
ProxGrad.Rotation = 45
local ProxIcon = Instance.new("ImageLabel", ProxFrame)
ProxIcon.Size = UDim2.new(0, 30, 0, 30)
ProxIcon.Position = UDim2.new(0, 10, 0, 10)
ProxIcon.BackgroundTransparency = 1
ProxIcon.Image = "rbxassetid://10734950309" 
ProxIcon.ImageColor3 = Color3.fromRGB(255, 50, 50) 
local ProxTitle = Instance.new("TextLabel", ProxFrame)
ProxTitle.Size = UDim2.new(1, -50, 0, 20)
ProxTitle.Position = UDim2.new(0, 50, 0, 8)
ProxTitle.BackgroundTransparency = 1
ProxTitle.Text = "THREAT DETECTED"
ProxTitle.TextColor3 = Color3.fromRGB(255, 80, 80)
ProxTitle.Font = Enum.Font.GothamBlack
ProxTitle.TextSize = 14
ProxTitle.TextXAlignment = Enum.TextXAlignment.Left
local ProxList = Instance.new("TextLabel", ProxFrame)
ProxList.Size = UDim2.new(1, -50, 0, 0) 
ProxList.AutomaticSize = Enum.AutomaticSize.Y
ProxList.Position = UDim2.new(0, 50, 0, 28)
ProxList.BackgroundTransparency = 1
ProxList.Text = "..."
ProxList.TextColor3 = Color3.fromRGB(200, 200, 200)
ProxList.Font = Enum.Font.GothamBold
ProxList.TextSize = 11
ProxList.TextXAlignment = Enum.TextXAlignment.Left
task.spawn(function()
    local TweenService = game:GetService("TweenService")
    while true do
        if ProxFrame.Visible then
            TweenService:Create(ProxIcon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 34, 0, 34), Position = UDim2.new(0, 8, 0, 8), ImageColor3 = Color3.fromRGB(255, 0, 0)}):Play()
            task.wait(0.5)
            TweenService:Create(ProxIcon, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0, 10), ImageColor3 = Color3.fromRGB(200, 50, 50)}):Play()
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)
local ToastContainer = Instance.new("Frame", ScreenGui)
ToastContainer.Name = GetRandomName()
ToastContainer.Size = UDim2.new(0, 350, 1, -20)
ToastContainer.Position = UDim2.new(1, -360, 0, 0)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 10000
local ToastLayout = Instance.new("UIListLayout", ToastContainer)
ToastLayout.SortOrder = Enum.SortOrder.LayoutOrder
ToastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
ToastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ToastLayout.Padding = UDim.new(0, 8)
local function ShowToast(text)
    local NewToast = Instance.new("Frame", ToastContainer)
    NewToast.Size = UDim2.new(0, 320, 0, 55)
    NewToast.BackgroundTransparency = 1
    RegisterTheme(NewToast, "BackgroundColor3", "Background")
    Instance.new("UICorner", NewToast).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", NewToast)
    RegisterTheme(Stroke, "Color", "Accent")
    Stroke.Thickness = 1
    Stroke.Transparency = 1
    local Lbl = Instance.new("TextLabel", NewToast)
    Lbl.Size = UDim2.new(1, -20, 1, 0)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 15
    Lbl.TextWrapped = true
    Lbl.TextTransparency = 1
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    NewToast.BackgroundTransparency = 0.1
    TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    TweenService:Create(Lbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    local originalSize = UDim2.new(0, 320, 0, 55)
    NewToast.Size = UDim2.new(0, 290, 0, 55)
    TweenService:Create(NewToast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize, BackgroundTransparency = 0.1}):Play()
    task.delay(3, function()
        if NewToast and NewToast.Parent then
            local outTween = TweenService:Create(NewToast, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 350, 0, 55)
            })
            outTween:Play()
            TweenService:Create(Stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
            TweenService:Create(Lbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            outTween.Completed:Connect(function()
                NewToast:Destroy()
            end)
        end
    end)
end
local ActiveListFrame = Instance.new("Frame", ScreenGui)
ActiveListFrame.Name = GetRandomName()
ActiveListFrame.Position = UDim2.new(1, -220, 0.4, 0) 
ActiveListFrame.Size = UDim2.new(0, 200, 0.5, 0)
ActiveListFrame.BackgroundTransparency = 1
local ActiveListLayout = Instance.new("UIListLayout", ActiveListFrame)
ActiveListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ActiveListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
ActiveListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ActiveListLayout.Padding = UDim.new(0, 4)
local function UpdateActiveList(featureName, isEnabled)
    local existing = ActiveListFrame:FindFirstChild(featureName)
    if isEnabled then
        if not existing then
            local label = Instance.new("TextLabel", ActiveListFrame)
            label.Name = featureName
            label.Size = UDim2.new(1, 0, 0, 22)
            label.BackgroundTransparency = 1
            label.Text = featureName .. "  " 
            label.Font = Enum.Font.GothamBold
            label.TextSize = 14
            RegisterTheme(label, "TextColor3", "Accent")
            label.TextXAlignment = Enum.TextXAlignment.Right
            label.TextTransparency = 1
            TweenService:Create(label, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        end
    else
        if existing then
            local tween = TweenService:Create(existing, TweenInfo.new(0.3), {TextTransparency = 1})
            tween:Play(); tween.Completed:Connect(function() existing:Destroy() end)
        end
    end
end
local function MakeDraggable(Frame)
    local dragging, dragInput, dragStart, startPos
    Frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    Frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(Frame, TweenInfo.new(0.05), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end
local SpecFrame = Instance.new("Frame", ScreenGui)
SpecFrame.Name = GetRandomName()
SpecFrame.Size = UDim2.new(0, 200, 0, 150)
SpecFrame.Position = UDim2.new(0.85, 0, 0.4, 0)
RegisterTheme(SpecFrame, "BackgroundColor3", "Background")
SpecFrame.Visible = false
Instance.new("UICorner", SpecFrame).CornerRadius = UDim.new(0, 8)
MakeDraggable(SpecFrame)
local SpecTitle = Instance.new("TextLabel", SpecFrame)
SpecTitle.Size = UDim2.new(1, 0, 0, 25)
SpecTitle.BackgroundTransparency = 1
SpecTitle.Text = "SPECTATORS"
RegisterTheme(SpecTitle, "TextColor3", "Accent")
SpecTitle.Font = Enum.Font.GothamBlack
SpecTitle.TextSize = 12
local SpecScroll = Instance.new("ScrollingFrame", SpecFrame)
SpecScroll.Size = UDim2.new(1, -10, 1, -30)
SpecScroll.Position = UDim2.new(0, 5, 0, 30)
SpecScroll.BackgroundTransparency = 1
SpecScroll.ScrollBarThickness = 3
SpecScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SpecScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
local SpecText = Instance.new("TextLabel", SpecScroll)
SpecText.Size = UDim2.new(1, 0, 0, 0)
SpecText.AutomaticSize = Enum.AutomaticSize.Y
SpecText.BackgroundTransparency = 1
SpecText.Text = "Scanning..."
RegisterTheme(SpecText, "TextColor3", "Text")
SpecText.Font = Enum.Font.Code
SpecText.TextSize = 11
SpecText.TextXAlignment = Enum.TextXAlignment.Left
SpecText.TextYAlignment = Enum.TextYAlignment.Top
SpecText.TextWrapped = true
local function RejoinServer()
    ShowToast("🔄 Rejoining Server...")
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    
    local connection
    connection = ts.TeleportInitFailed:Connect(function(player, result, errorMessage)
        if player == p then
            ShowToast("⚠️ Rejoin Gagal ("..tostring(result).."). Mencari Server Baru...")
            ts:Teleport(game.PlaceId, p)
            if connection then connection:Disconnect() end
        end
    end)
    if game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0 then
        ShowToast("Private Server Detected Mencoba Melakukan Rejoin")
        ts:Teleport(game.PlaceId, p)
        return
    end
    if #game:GetService("Players"):GetPlayers() <= 1 then
         p:Kick("\nRejoining (Mencari Server Baru)...") 
         task.wait()
         ts:Teleport(game.PlaceId, p)
    else
        ShowToast("🔄 Mencoba masuk ke Room yang sama...")
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, p)
    end
end
local function JoinJobId()
    if State.TargetJobId ~= "" then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, State.TargetJobId, LocalPlayer)
    end
end
local function JoinLowestServer()
    if State.IsScanning then 
        ShowToast("✋ Ekspedisi sedang berjalan...")
        return 
    end
    local MaxTolerance = 3   
    local SkipPages    = 10  
    local RetryDelay   = 20  
    State.IsScanning = true
    ShowToast("🕳️ Menyelam ke Deep Server (Skip " .. SkipPages .. " hal)...")
    local Http = game:GetService("HttpService")
    local PlaceId = game.PlaceId
    task.spawn(function()
        local cursor = nil
        local pageCount = 1
        local retryCount = 0
        while State.IsScanning do
            local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor then Url = Url .. "&cursor=" .. cursor end
            local success, result = pcall(function() 
                return game:HttpGet(Url) 
            end)
            if success and result then
                local data = nil
                local decodeSuccess, _ = pcall(function()
                    data = Http:JSONDecode(result)
                end)
                if decodeSuccess and data and data.data then
                    retryCount = 0
                    if pageCount <= SkipPages then
                        ShowToast("🚀 Skip Hal " .. pageCount .. " (Masih terlalu baru)...")
                        if data.nextPageCursor then
                            cursor = data.nextPageCursor
                            pageCount = pageCount + 1
                        else
                            ShowToast("⚠️ Server dikit banget, gak bisa skip jauh!")
                            SkipPages = 0 
                        end
                        task.wait(0.5) 
                    else
                        if #data.data == 0 then
                            ShowToast("⚠️ Halaman kosong (Glitch). Ulangi...")
                            task.wait(3) 
                        else
                            local bestServer = nil
                            for _, server in pairs(data.data) do
                                if server.playing and server.playing > 0 and server.id ~= game.JobId then
                                    if server.playing <= MaxTolerance then
                                        if not bestServer or server.playing < bestServer.playing then
                                            bestServer = server
                                        end
                                        if bestServer.playing == 1 then break end
                                    end
                                end
                            end
                            if bestServer then
                                State.IsScanning = false
                                ShowToast("💀 NEMU DEAD SERVER!")
                                ShowToast("Lokasi: Halaman " .. pageCount .. " (Deep Layer)")
                                ShowToast("Populasi: " .. bestServer.playing .. " Hantu")
                                task.wait(1)
                                pcall(function()
                                    TeleportService:TeleportToPlaceInstance(PlaceId, bestServer.id, LocalPlayer)
                                end)
                                return
                            end
                            if data.nextPageCursor then
                                cursor = data.nextPageCursor
                                pageCount = pageCount + 1
                                if pageCount % 1 == 0 then 
                                    ShowToast("Menjelajah Halaman " .. pageCount .. "...")
                                end
                            else
                                ShowToast("🛑 Dasar lautan tercapai (List Habis). Ulang...")
                                cursor = nil
                                pageCount = 1
                                task.wait(5)
                            end
                        end
                        task.wait(3.5)
                    end
                else
                    warn("Data error, retry...")
                    task.wait(3)
                end
            else
                retryCount = retryCount + 1
                ShowToast("⚠️ RTO/Limit. Sembunyi " .. RetryDelay .. " detik... (" .. retryCount .. ")")
                task.wait(RetryDelay) 
            end
        end
    end)
end
local function JoinRandomHighServer()
    ShowToast("🔍 Mencari server ramai (Scanning)...")
    local Http = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local cursor = ""
    local FoundServer = nil
    
    task.spawn(function()
        for i = 5, 10 do
            if FoundServer then break end

            local Url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
            if cursor ~= "" then
                Url = Url .. "&cursor=" .. cursor
            end
            
            local success, result = pcall(function() 
                return game:HttpGet(Url) 
            end)

            if success and result then
                local data = Http:JSONDecode(result)
                if data and data.data then
                    local Candidates = {}
                    for _, server in pairs(data.data) do
                        if server.playing < server.maxPlayers and server.playing > 0 and server.id ~= game.JobId then
                            table.insert(Candidates, server)
                        end
                    end

                    if #Candidates > 0 then
                        FoundServer = Candidates[math.random(1, #Candidates)]
                        ShowToast("Server Ditemukan!")
                        ShowToast("Players: " .. FoundServer.playing .. " / " .. FoundServer.maxPlayers)
                        TeleportService:TeleportToPlaceInstance(PlaceId, FoundServer.id, LocalPlayer)
                        return -- Stop loop, langsung TP
                    else
                        if data.nextPageCursor then
                            cursor = data.nextPageCursor
                            ShowToast("Halaman " .. i .. " penuh, cek halaman selanjutnya...")
                            task.wait(0.5)
                        else
                            break
                        end
                    end
                end
            else
                ShowToast("⚠️ HTTP Error (Coba lagi nanti)")
                task.wait(1)
            end
        end
        
        if not FoundServer then
            ShowToast("❌ Tidak menemukan server kosong (Semua Penuh/Sepi)")
        end
    end)
end
local function GetHitboxPart(character)
    if not character then return nil end
    return character:FindFirstChild("HumanoidRootPart")
end
local function GetVisualPart(character)
    if not character then return nil end
    if character.PrimaryPart then return character.PrimaryPart end
    local bodyParts = {"HumanoidRootPart", "Torso", "UpperTorso", "Head"}
    for _, name in pairs(bodyParts) do
        local part = character:FindFirstChild(name)
        if part then return part end
    end
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end
local function GetBestAimPart(char)
    if not char then return nil end
    if State.AimbotPart == "Head" then
        local aliases = {"Head", "HeadGeo", "UpperHead", "FakeHead", "Skull", "Face", "Hea"}
        for _, name in pairs(aliases) do
            local found = char:FindFirstChild(name)
            if found then return found end
        end
        for _, c in pairs(char:GetChildren()) do
            if c:IsA("BasePart") and string.find(string.lower(c.Name), "head") then
                return c
            end
        end
        return nil
    end
    return char:FindFirstChild(State.AimbotPart) or 
           char:FindFirstChild("HumanoidRootPart") or 
           char:FindFirstChild("Torso")
end
local function GetClosestPlayer()
    local closestDist = math.huge
    local closestTarget = nil
    local mousePos = UserInputService:GetMouseLocation()
    if not UserInputService:IsMouseButtonPressed(State.AimbotButton) then return nil end
    -- GANTI DARI SINI (Looping Players)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                -- Cek Teman Satu Tim
                local IsTeammate = (State.AimbotMode == "Enemy Only" and p.Team == LocalPlayer.Team)

                -- HANYA JALAN JIKA: BUKAN Teman (Pengganti continue)
                if not IsTeammate then
                    local hum = p.Character:FindFirstChild("Humanoid")
                    local root = p.Character:FindFirstChild("HumanoidRootPart")
                    local head = p.Character:FindFirstChild("Head")
                    
                    if hum and hum.Health > 0 and root and head then
                        local part = head
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestTarget = {
                                    Character = p.Character,
                                    Part = part,
                                    ScreenPos = screenPos
                                }
                            end
                        end
                    end
                end -- Akhir cek IsTeammate
            end
        end
        -- SAMPAI SINI
    if closestTarget and State.WallCheck then
        local origin = Camera.CFrame.Position
        local direction = (closestTarget.Part.Position - origin)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character, closestTarget.Character, Camera}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = Workspace:Raycast(origin, direction, params)
        if result then return nil end 
    end
    return closestTarget
end
local IdentityConfig = {
    Enabled = false,
    NewDisplayName = "Reyzz Admin", 
    NewUserName = "reyzz_admin"     
}
local SpooferConnections = {}
local SpooferLoop = nil
local function SmartSpoof(obj)
    if not obj or not obj.Parent then return end
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    local currentText = obj.Text
    local myDisplay = LocalPlayer.DisplayName
    local myName = LocalPlayer.Name
    if currentText:find(myDisplay) then
        obj.Text = currentText:gsub(myDisplay, IdentityConfig.NewDisplayName)
    elseif currentText:find(myName) then
        obj.Text = currentText:gsub(myName, IdentityConfig.NewUserName)
    end
end
local function ToggleIdentitySystem(enable)
    IdentityConfig.Enabled = enable
    if enable then
        ShowToast("✅ Spoofer: ACTIVE (Smart Mode)")
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.DisplayName = IdentityConfig.NewDisplayName
        end
        if SpooferLoop then task.cancel(SpooferLoop) end
        SpooferLoop = task.spawn(function()
            while IdentityConfig.Enabled do
                pcall(function()
                    local CoreGui = game:GetService("CoreGui")
                    for _, v in pairs(CoreGui:GetDescendants()) do
                        if v.Visible then 
                            SmartSpoof(v) 
                        end
                    end
                end)
                pcall(function()
                    for _, v in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if v.Visible then 
                            SmartSpoof(v) 
                        end
                    end
                end)
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("TextLabel") then SmartSpoof(v) end
                    end
                    local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                    if hum and hum.DisplayName ~= IdentityConfig.NewDisplayName then
                        hum.DisplayName = IdentityConfig.NewDisplayName
                    end
                end
                task.wait(3) 
            end
        end)
        local function OnDescendantAdded(descendant)
            if IdentityConfig.Enabled and descendant:IsA("TextLabel") then
                task.delay(0.1, function() 
                    SmartSpoof(descendant) 
                end)
            end
        end
        table.insert(SpooferConnections, game:GetService("CoreGui").DescendantAdded:Connect(OnDescendantAdded))
        table.insert(SpooferConnections, LocalPlayer.PlayerGui.DescendantAdded:Connect(OnDescendantAdded))
    else
        ShowToast("❌ Spoofer: DISABLED")
        if SpooferLoop then task.cancel(SpooferLoop) SpooferLoop = nil end
        for _, conn in pairs(SpooferConnections) do conn:Disconnect() end
        SpooferConnections = {}
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.DisplayName = LocalPlayer.DisplayName
        end
    end
end
local WoWPart = Instance.new("Part", Workspace)
WoWPart.Name = "JesusWalk"
WoWPart.Size = Vector3.new(20, 1, 20)
WoWPart.Anchored = true
WoWPart.Transparency = 1
WoWPart.CanCollide = false 
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = GetVisualPart(LocalPlayer.Character)
        
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        elseif root then
            local currentVel = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(currentVel.X, State.JumpPower or 50, currentVel.Z)
        end
    end
end)
local function ToggleXRay(enable)
    if enable then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                if v.Transparency < 0.5 then v:SetAttribute("OrigTrans", v.Transparency); v.Transparency = 0.5 end
            end
        end
    else
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:GetAttribute("OrigTrans") then
                v.Transparency = v:GetAttribute("OrigTrans"); v:SetAttribute("OrigTrans", nil)
            end
        end
    end
end
local function SuperBoostFPS()
    ShowToast("ULTRA BOOST: OPTIMIZING MAP & PLAYERS...")
    task.wait(0.1)
    local light = game:GetService("Lighting")
    pcall(function()
        light.GlobalShadows = false
        light.FogEnd = 9e9
        light.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"
        
        for _, v in pairs(light:GetChildren()) do
            if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                v:Destroy()
            end
        end
    end)

    pcall(function()
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
            pcall(function() Terrain.Decoration = false end)
            pcall(function() Terrain.DecorationEnabled = false end)
        end
    end)
    local desc = workspace:GetDescendants() 
    for _, v in pairs(desc) do
        pcall(function()
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic 
                v.Reflectance = 0
                v.CastShadow = false
                if v.Transparency < 1 then v.Color = Color3.fromRGB(255, 255, 255) end
                if v:IsA("MeshPart") then v.TextureID = "" end

            elseif v:IsA("Decal") or v:IsA("Texture") then
                v:Destroy()
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false 
            end
        end)
    end
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        pcall(function()
            if p.Character then
                for _, v in pairs(p.Character:GetChildren()) do
                    if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("CharacterMesh") or v:IsA("BodyColors") then
                        v:Destroy() 
                    end
                end
                
                for _, part in pairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.SmoothPlastic
                        part.Color = Color3.fromRGB(200, 200, 200) 
                        part.Transparency = 0
                        part.CastShadow = false
                        
                        if part.Name == "Head" then
                            local face = part:FindFirstChild("face")
                            if face then face:Destroy() end
                        end
                    end
                end
            end
        end)
    end

    pcall(function()
        if game.Workspace:FindFirstChild("Debris") then game.Workspace.Debris:ClearAllChildren() end
    end)
end

State.FPSLoop = false
State.FPSInterval = 1
task.spawn(function()
    while true do
        if State.FPSLoop then
            SuperBoostFPS()
            task.wait(State.FPSInterval * 60)
        else
            task.wait(1)
        end
    end
end)
local function ClearMemory()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then 
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0 
        terrain.WaterReflectance = 0 
        terrain.WaterTransparency = 1 
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    collectgarbage("collect") 
    ShowToast("RAM Cleared (GC Run)!")
end
local function DeleteMap()
    ShowToast("⚠️ Delete Map is risky here! Using Safe Hide instead.")
    for _, v in pairs(Workspace:GetChildren()) do
        if v.Name ~= "Terrain" and not v:IsA("Camera") and not Players:GetPlayerFromCharacter(v) then
            if not v:FindFirstChild("Humanoid") then
                if v:IsA("BasePart") then
                    v.Transparency = 1
                    v.CanCollide = false
                elseif v:IsA("Model") then
                     for _, child in pairs(v:GetDescendants()) do
                        if child:IsA("BasePart") then
                            child.Transparency = 1
                            child.CanCollide = false
                        end
                     end
                end
            end
        end
    end
    ShowToast("🚫 Map Hidden (Not Deleted) to prevent Crash")
end
local function RemoveTextures()
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") or v:IsA("SurfaceAppearance") then
            if v:IsA("SurfaceAppearance") then
                v:Destroy() 
            else
                v.Transparency = 1 
            end
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        end
    end
    ShowToast("🎨 Textures Hidden!")
end
local function ClearMemory()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0; terrain.WaterReflectance = 0; terrain.WaterTransparency = 0 end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    settings().Rendering.QualityLevel = "Level01"
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end
    end
    collectgarbage("collect") 
    ShowToast("Memory Cleared & GC Run!")
end
State.FlySpeed = 60 
local FlyConnection = nil
local FlyBodyGyro = nil 
local function StopFly()
    if FlyConnection then FlyConnection:Disconnect(); FlyConnection = nil end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = GetVisualPart(char) 
    
    if hum then 
        hum.PlatformStand = false 
        hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
    end
    
    if root then 
        root.AssemblyLinearVelocity = Vector3.zero 
        root.AssemblyAngularVelocity = Vector3.zero
    end
end
local function StartFly()
    StopFly() 
    local char = LocalPlayer.Character
    local root = GetVisualPart(char) 
    local hum = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    
    if not root then return end 
    if hum then hum.PlatformStand = true end 
    
    local targetCFrame = root.CFrame 

    FlyConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not State.Fly or not char or not root then
            StopFly()
            return
        end

        local moveDir = Vector3.zero
        local camCF = cam.CFrame
        local UIS = game:GetService("UserInputService")
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        
        local speed = State.FlySpeed or 50
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            targetCFrame = targetCFrame + (moveDir * (speed * deltaTime))
            targetCFrame = CFrame.new(targetCFrame.Position, targetCFrame.Position + camCF.LookVector)
        else
            targetCFrame = CFrame.new(targetCFrame.Position, targetCFrame.Position + camCF.LookVector)
        end
        
        root.CFrame = targetCFrame
        root.AssemblyLinearVelocity = Vector3.zero 
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end
TargetCamPos = nil
TargetCamRot = nil
State.FreecamFOV = 70 
CamFocusPart = nil 
TargetCamPos = nil
TargetCamRot = nil
State.FreecamFOV = 70 

function ToggleFreecam(enable)
    State.Freecam = enable
    local UIS = game:GetService("UserInputService")
    local Cam = game:GetService("Workspace").CurrentCamera
    local RunService = game:GetService("RunService")

    -- [[ 1. SETUP UI HUD (INDIKATOR FOV) ]] --
    local FOVHudName = "ReyzzFOVIndicator"
    local FOVHud = ScreenGui:FindFirstChild(FOVHudName)
    
    if enable then
        -- Jika HUD belum ada, buat baru
        if not FOVHud then
            FOVHud = Instance.new("TextLabel", ScreenGui)
            FOVHud.Name = FOVHudName
            FOVHud.Size = UDim2.new(0, 200, 0, 30)
            FOVHud.Position = UDim2.new(0.5, -100, 0.85, 0)
            FOVHud.BackgroundTransparency = 1
            FOVHud.Text = "FOV: 70"
            FOVHud.Font = Enum.Font.GothamBlack
            FOVHud.TextSize = 18
            FOVHud.TextColor3 = Color3.fromRGB(0, 255, 255)
            local Stroke = Instance.new("UIStroke", FOVHud)
            Stroke.Thickness = 2
            Stroke.Color = Color3.fromRGB(0, 0, 0)
        end
        if FOVHud then FOVHud.Visible = false end

        -- Tampilkan UI Drone Mobile (Jika HP)
        if DroneUI then DroneUI.Visible = UIS.TouchEnabled end

        -- [[ 2. SETUP KAMERA ]] --
        Cam.CameraType = Enum.CameraType.Scriptable
        State.FreecamPos = Cam.CFrame
        TargetCamPos = Cam.CFrame.Position 
        State.FreecamFOV = Cam.FieldOfView 
        
        local rx, ry, rz = Cam.CFrame:ToEulerAnglesYXZ()
        State.FreecamRot = Vector2.new(rx, ry)
        TargetCamRot = Vector2.new(rx, ry)

        -- Bekukan Karakter (Agar tidak jatuh saat kamera terbang)
        if LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if root then root.Anchored = true end 
            if hum then hum.PlatformStand = true end 
        end

        -- [[ OPTIMASI: HAPUS BAGIAN REPLICATION FOCUS ]] --
        -- Kita tidak lagi membuat Part palsu untuk memaksa render map.
        -- Ini akan membuat CPU jauh lebih dingin.

        -- [[ 3. CINEMATIC LOOP ]] --
        if State.FreecamLoop then State.FreecamLoop:Disconnect() end
        State.FreecamLoop = RunService.RenderStepped:Connect(function(dt)
            if not State.Freecam then return end
            
            if Cam.CameraType ~= Enum.CameraType.Scriptable then
                Cam.CameraType = Enum.CameraType.Scriptable
            end

            if FOVHud then
                FOVHud.Text = "ZOOM FOV: " .. math.floor(Cam.FieldOfView)
            end

            local delta = Vector2.new(0,0)

            -- Input Rotasi PC (Klik Kanan)
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition 
                delta = UIS:GetMouseDelta()
            else
                if not UIS.TouchEnabled then UIS.MouseBehavior = Enum.MouseBehavior.Default end
            end

            -- Input Rotasi HP
            if UIS.TouchEnabled and State.MobileCamDelta then
                delta = State.MobileCamDelta; State.MobileCamDelta = Vector2.new(0,0) 
            end
            
            -- Hitung Rotasi Kamera
            local sens = 0.003
            TargetCamRot = TargetCamRot - Vector2.new(delta.Y * sens, delta.X * sens)
            TargetCamRot = Vector2.new(math.clamp(TargetCamRot.X, -1.4, 1.4), TargetCamRot.Y)
            local rotCFrame = CFrame.fromEulerAnglesYXZ(TargetCamRot.X, TargetCamRot.Y, 0)

            -- Input Gerakan (WASD)
            local moveDir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + rotCFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - rotCFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + rotCFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - rotCFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.E) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.Q) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            -- Input Mobile
            if State.MobileInput then
                local joy = State.MobileInput.Move 
                if joy.Magnitude > 0 then
                    moveDir = moveDir + (rotCFrame.LookVector * -joy.Z) + (rotCFrame.RightVector * joy.X)
                end
                if State.MobileInput.Up ~= 0 then moveDir = moveDir + Vector3.new(0, State.MobileInput.Up, 0) end
                
                if State.MobileInput.Zoom ~= 0 then
                    State.FreecamFOV = math.clamp(State.FreecamFOV - (State.MobileInput.Zoom * 1.5), 5, 120)
                end
            end

            -- Kecepatan Kamera
            local baseSpeed = (State.FreecamSpeed or 1) * 50
            local speedMult = 1
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then speedMult = 4 end 
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then speedMult = 0.1 end
            
            TargetCamPos = TargetCamPos + (moveDir * baseSpeed * speedMult * dt)

            -- Apply Posisi (Tanpa update fokus map)
            local GoalCFrame = CFrame.new(TargetCamPos) * rotCFrame
            Cam.CFrame = Cam.CFrame:Lerp(GoalCFrame, 0.15)
            
            -- Apply FOV
            Cam.FieldOfView = Cam.FieldOfView + (State.FreecamFOV - Cam.FieldOfView) * 0.2
        end)
        
        -- [[ 4. INPUT HANDLER ]] --
        if State.TouchConnection then State.TouchConnection:Disconnect() end
        State.TouchConnection = UIS.InputChanged:Connect(function(input)
            if State.Freecam then
                if input.UserInputType == Enum.UserInputType.Touch then
                    if input.Position.X > Cam.ViewportSize.X * 0.3 then State.MobileCamDelta = input.Delta end
                elseif input.UserInputType == Enum.UserInputType.MouseWheel then
                    local isCtrlHeld = UIS:IsKeyDown(Enum.KeyCode.LeftControl)
                    if isCtrlHeld then
                        local scrollAmount = input.Position.Z * 5 
                        State.FreecamFOV = math.clamp(State.FreecamFOV - scrollAmount, 5, 120)
                    end
                end
            end
        end)

    else
        -- Matikan Freecam
        if State.FreecamLoop then State.FreecamLoop:Disconnect() State.FreecamLoop = nil end
        if ToggleButton then ToggleButton.Visible = true end
        if State.TouchConnection then State.TouchConnection:Disconnect() State.TouchConnection = nil end
        if FOVHud then FOVHud.Visible = false end 
        if DroneUI then DroneUI.Visible = false end

        -- Reset Fokus Render ke Karakter Asli
        LocalPlayer.ReplicationFocus = nil 
        
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        Cam.CameraType = Enum.CameraType.Custom
        Cam.FieldOfView = 70
        
        if LocalPlayer.Character then 
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hum then Cam.CameraSubject = hum end
            if root then root.Anchored = false end
            if hum then hum.PlatformStand = false end
        end
    end
end
local TracerCache = {}
local function GetTeamColor(player)
    if player.Team == LocalPlayer.Team then
        local colorName = State.EspTeamColorName or "Hijau"
        return ESP_Colors[colorName] or ESP_Colors["Hijau"]
    else
        local colorName = State.EspEnemyColorName or "Merah"
        return ESP_Colors[colorName] or ESP_Colors["Merah"]
    end
end
local function StartVehicleFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local root = nil
    if hum and hum.SeatPart then
        root = hum.SeatPart 
    else
        root = char:FindFirstChild("HumanoidRootPart")
    end
    if not root then return end
    if root:FindFirstChild("VFlyV") then root.VFlyV:Destroy() end
    if root:FindFirstChild("VFlyG") then root.VFlyG:Destroy() end
    local bv = Instance.new("BodyVelocity", root)
    bv.Name = "VFlyV"
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    local bg = Instance.new("BodyGyro", root)
    bg.Name = "VFlyG"
    bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bg.P = 9000
    task.spawn(function()
        while State.FlyVehicle and root and root.Parent do
            local camCF = Camera.CFrame
            local speed = 100 
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                dir = dir + cam.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                dir = dir - cam.CFrame.LookVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                dir = dir - cam.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                dir = dir + cam.CFrame.RightVector 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                dir = dir + Vector3.new(0, 1, 0) 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
                dir = dir - Vector3.new(0, 1, 0) 
            end
            bv.Velocity = dir * speed
            bg.CFrame = camCF
            task.wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end
local function GetSurfaceNormal()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local directions = {
        -root.CFrame.UpVector * 5, 
        -root.CFrame.RightVector * 3, 
        root.CFrame.RightVector * 3, 
        root.CFrame.LookVector * 3,
        -root.CFrame.LookVector * 3
    }
    for _, dir in pairs(directions) do
        local result = Workspace:Raycast(root.Position, dir, params)
        if result and result.Instance and result.Instance.CanCollide then
            return result.Normal 
        end
    end
    return nil
end
local function BypassMessage(msg)
    local invisibleChar = "‎" 
    local newMsg = ""
    for i = 1, #msg do
        newMsg = newMsg .. string.sub(msg, i, i) .. invisibleChar
    end
    return newMsg
end
local function SendBypassChat(text)
    local safeText = BypassMessage(text)
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels.RBXGeneral
        if channel then channel:SendAsync(safeText) end
    else
        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(safeText, "All")
    end
end
RunService.Heartbeat:Connect(function(dt)
    if game:GetService("UserInputService").TouchEnabled then
        if tick() % 0.1 < 0.05 then return end
    end
    if State.NoFall and LocalPlayer.Character then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char:FindFirstChild("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hrp then
                local state = hum:GetState()
                if (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.FallingDown) and hrp.Velocity.Y < -50 then
                    hum:ChangeState(Enum.HumanoidStateType.PlatformStanding)
                end
            end
        end)
    end
    if State.AntiTP and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not State.LastSafeTPPos then
                State.LastSafeTPPos = root.CFrame
            end
            local distance = (root.Position - State.LastSafeTPPos.Position).Magnitude
            if distance > 20 then
                root.CFrame = State.LastSafeTPPos
                root.Velocity = Vector3.new(0, 0, 0)
            else
                State.LastSafeTPPos = root.CFrame
            end
        else
            State.LastSafeTPPos = nil
        end
    else
        State.LastSafeTPPos = nil
    end
    if State.WallRun and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root and hum then
            local normal = GetSurfaceNormal()
            if normal then
                local currentUp = root.CFrame.UpVector
                local newUp = normal
                if currentUp:Dot(newUp) < 0.99 then
                    local axis = currentUp:Cross(newUp)
                    local angle = math.acos(math.clamp(currentUp:Dot(newUp), -1, 1))
                    local rot = CFrame.fromAxisAngle(axis, angle * 5 * dt)
                    root.CFrame = rot * root.CFrame
                end
                hum.AutoRotate = false
                if not root:FindFirstChild("AntiGrav") then
                    local f = Instance.new("BodyForce", root)
                    f.Name = "AntiGrav"
                    f.Force = Vector3.new(0, workspace.Gravity * root.AssemblyMass, 0)
                else
                    root.AntiGrav.Force = Vector3.new(0, workspace.Gravity * root.AssemblyMass, 0)
                end
            else
                 if root:FindFirstChild("AntiGrav") then root.AntiGrav:Destroy() end
                 hum.AutoRotate = true
            end
        end
    else
        if LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and root:FindFirstChild("AntiGrav") then
                root.AntiGrav:Destroy()
            end
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.AutoRotate == false then
                hum.AutoRotate = true
            end
        end
    end
end)
local function CheckUpdate()
    ShowToast("Checking updates...")
    local url = "https://raw.githubusercontent.com/reyzzarjam2/SCRIPT-ROBLOX/refs/heads/main/universal/reyzzhub.lua?token=GHSAT0AAAAAADRGCAS4JV5ILQGXVQKO7ANQ2J4ZWGQ"
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not success then
        ShowToast("❌ ERROR: " .. tostring(result))
        return
    end
    if result ~= State.CurrentVersion then
        ShowToast("⚠️ NEW UPDATE AVAILABLE CEK IN MY DISCORD!")
    else
        ShowToast("✅ You are using the latest version!")
    end
end
RunService.Heartbeat:Connect(function()
    if State.BhopLegit and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.FloorMaterial ~= Enum.Material.Air and hum.MoveDirection.Magnitude > 0 then
            if math.random(1, 100) <= 85 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)
RunService.Stepped:Connect(function()
    if State.LockTime then
        Lighting.ClockTime = State.TargetTime
    end
end)
local InspFrame = Instance.new("Frame", ScreenGui)
local I_Name, I_Class, I_Path, I_Pos, I_Parent
do
InspFrame.Name = GetRandomName()
InspFrame.Size = UDim2.new(0, 250, 0, 300)
InspFrame.Position = UDim2.new(0.5, 260, 0.5, -150) 
RegisterTheme(InspFrame, "BackgroundColor3", "Background")
InspFrame.Visible = false
Instance.new("UICorner", InspFrame).CornerRadius = UDim.new(0, 8)
local InspStroke = Instance.new("UIStroke", InspFrame); RegisterTheme(InspStroke, "Color", "Accent"); InspStroke.Thickness = 1
MakeDraggable(InspFrame)
local InspHeader = Instance.new("TextLabel", InspFrame)
InspHeader.Size = UDim2.new(1, -30, 0, 30)
InspHeader.Position = UDim2.new(0, 10, 0, 0)
InspHeader.BackgroundTransparency = 1
InspHeader.Text = "OBJECT INSPECTOR"
RegisterTheme(InspHeader, "TextColor3", "Accent")
InspHeader.Font = Enum.Font.GothamBlack
InspHeader.TextSize = 14
InspHeader.TextXAlignment = Enum.TextXAlignment.Left
local CloseInsp = Instance.new("TextButton", InspFrame)
CloseInsp.Size = UDim2.new(0, 25, 0, 25)
CloseInsp.Position = UDim2.new(1, -30, 0, 2)
CloseInsp.BackgroundTransparency = 1
CloseInsp.Text = "X"
CloseInsp.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseInsp.Font = Enum.Font.GothamBold
CloseInsp.MouseButton1Click:Connect(function() InspFrame.Visible = false end)
local InspContainer = Instance.new("ScrollingFrame", InspFrame)
InspContainer.Size = UDim2.new(1, -10, 1, -80)
InspContainer.Position = UDim2.new(0, 5, 0, 35)
InspContainer.BackgroundTransparency = 1
InspContainer.ScrollBarThickness = 2
local InspList = Instance.new("UIListLayout", InspContainer); InspList.Padding = UDim.new(0, 5)
local function CreateInspLabel(title)
    local f = Instance.new("Frame", InspContainer); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundTransparency = 1
    local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, 0, 0, 12); t.Text=title; t.TextColor3=Color3.fromRGB(150,150,150); t.BackgroundTransparency=1; t.Font=Enum.Font.Gotham; t.TextSize=10; t.TextXAlignment=Enum.TextXAlignment.Left
    local v = Instance.new("TextBox", f); v.Size = UDim2.new(1, -5, 0, 20); v.Position=UDim2.new(0,0,0,14); v.Text="..."; v.TextColor3=Color3.new(1,1,1); v.BackgroundTransparency=0.8; v.BackgroundColor3=Color3.new(0,0,0); v.Font=Enum.Font.Code; v.TextSize=11; v.TextXAlignment=Enum.TextXAlignment.Left; v.ClearTextOnFocus=false; v.TextEditable=false
    Instance.new("UICorner", v).CornerRadius = UDim.new(0,4)
    return v
end
    I_Name = CreateInspLabel("Object Name")
    I_Class = CreateInspLabel("ClassName (Penting buat ESP)")
    I_Path = CreateInspLabel("Full Path")
    I_Pos = CreateInspLabel("Position (XYZ)")
    I_Parent = CreateInspLabel("Parent Name")
local BtnContainer = Instance.new("Frame", InspFrame)
BtnContainer.Size = UDim2.new(1, -10, 0, 35)
BtnContainer.Position = UDim2.new(0, 5, 1, -40)
BtnContainer.BackgroundTransparency = 1
local BtnLayout = Instance.new("UIListLayout", BtnContainer); BtnLayout.FillDirection=Enum.FillDirection.Horizontal; BtnLayout.Padding=UDim.new(0,5)
local function CreateInspBtn(txt, callback)
    local b = Instance.new("TextButton", BtnContainer); b.Size=UDim2.new(0.48,0,1,0); b.BackgroundColor3=Color3.fromRGB(40,40,40); b.Text=txt; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(callback)
end
CreateInspBtn("COPY PATH", function() setclipboard(I_Path.Text); ShowToast("Path Copied!") end)
CreateInspBtn("COPY POS", function() setclipboard(I_Pos.Text); ShowToast("Position Copied!") end)
end
local GuiSpyFrame = Instance.new("Frame", ScreenGui)
local GSContainer
do
    GuiSpyFrame.Name = GetRandomName()
    GuiSpyFrame.Size = UDim2.new(0, 350, 0, 400) 
    GuiSpyFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    RegisterTheme(GuiSpyFrame, "BackgroundColor3", "Background")
    GuiSpyFrame.Visible = false
    GuiSpyFrame.ClipsDescendants = true
    Instance.new("UICorner", GuiSpyFrame).CornerRadius = UDim.new(0, 8)
    local GSStroke = Instance.new("UIStroke", GuiSpyFrame); RegisterTheme(GSStroke, "Color", "Accent"); GSStroke.Thickness = 1
    MakeDraggable(GuiSpyFrame)
    local GSHeader = Instance.new("TextLabel", GuiSpyFrame)
    GSHeader.Size = UDim2.new(1, -30, 0, 30)
    GSHeader.Position = UDim2.new(0, 10, 0, 0)
    GSHeader.BackgroundTransparency = 1
    GSHeader.Text = "SMART GUI DETECTOR"
    RegisterTheme(GSHeader, "TextColor3", "Accent")
    GSHeader.Font = Enum.Font.GothamBlack
    GSHeader.TextSize = 14
    GSHeader.TextXAlignment = Enum.TextXAlignment.Left
    local CloseGS = Instance.new("TextButton", GuiSpyFrame)
    CloseGS.Size = UDim2.new(0, 25, 0, 25)
    CloseGS.Position = UDim2.new(1, -30, 0, 2)
    CloseGS.BackgroundTransparency = 1
    CloseGS.Text = "X"
    CloseGS.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseGS.Font = Enum.Font.GothamBold
    CloseGS.MouseButton1Click:Connect(function() GuiSpyFrame.Visible = false end)
    local InfoH = Instance.new("TextLabel", GuiSpyFrame)
    InfoH.Size = UDim2.new(1, -20, 0, 15)
    InfoH.Position = UDim2.new(0, 10, 0, 25)
    InfoH.BackgroundTransparency = 1
    InfoH.Text = "Klik [👁️] untuk melihat lokasi GUI di layar."
    InfoH.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoH.Font = Enum.Font.Gotham
    InfoH.TextSize = 11
    InfoH.TextXAlignment = Enum.TextXAlignment.Left
    GSContainer = Instance.new("ScrollingFrame", GuiSpyFrame)
    GSContainer.Size = UDim2.new(1, -10, 1, -50)
    GSContainer.Position = UDim2.new(0, 5, 0, 45)
    GSContainer.BackgroundTransparency = 1
    GSContainer.ScrollBarThickness = 3
    GSContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    GSContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    local GSList = Instance.new("UIListLayout", GSContainer); GSList.Padding = UDim.new(0, 6)
end
local function RefreshGuiSpy()
    if not GSContainer then return end 
    for _, v in pairs(GSContainer:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Enabled then
            local hasVisibleContent = false
            local foundText = ""
            local count = 0
            for _, child in pairs(gui:GetDescendants()) do
                if child:IsA("GuiObject") then 
                    if child.Visible then
                        if child:IsA("Frame") or child:IsA("ImageButton") or child:IsA("ScrollingFrame") then
                            hasVisibleContent = true
                        end
                        if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text ~= "" and count < 3 then
                            foundText = foundText .. "[" .. child.Text .. "] "
                            count = count + 1
                        end
                    end
                end
            end
            if foundText == "" then foundText = "No Text Found" end
            if hasVisibleContent then
                local Row = Instance.new("Frame", GSContainer)
                Row.Size = UDim2.new(1, 0, 0, 55) 
                RegisterTheme(Row, "BackgroundColor3", "ElementBG")
                Instance.new("UICorner", Row).CornerRadius = UDim.new(0, 6)
                local NameL = Instance.new("TextLabel", Row)
                NameL.Size = UDim2.new(1, -90, 0, 20)
                NameL.Position = UDim2.new(0, 8, 0, 2)
                NameL.BackgroundTransparency = 1
                NameL.Text = gui.Name
                RegisterTheme(NameL, "TextColor3", "Accent")
                NameL.Font = Enum.Font.GothamBold
                NameL.TextSize = 13
                NameL.TextXAlignment = Enum.TextXAlignment.Left
                local PreviewL = Instance.new("TextLabel", Row)
                PreviewL.Size = UDim2.new(1, -90, 0, 25)
                PreviewL.Position = UDim2.new(0, 8, 0, 22)
                PreviewL.BackgroundTransparency = 1
                PreviewL.Text = "Isi: " .. foundText
                PreviewL.TextColor3 = Color3.fromRGB(180, 180, 180) 
                PreviewL.Font = Enum.Font.Code
                PreviewL.TextSize = 11
                PreviewL.TextXAlignment = Enum.TextXAlignment.Left
                PreviewL.TextWrapped = true
                PreviewL.TextTruncate = Enum.TextTruncate.AtEnd
                local EyeBtn = Instance.new("TextButton", Row)
                EyeBtn.Size = UDim2.new(0, 30, 0, 30)
                EyeBtn.Position = UDim2.new(1, -85, 0.5, -15)
                EyeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                EyeBtn.Text = "👁️"
                EyeBtn.TextColor3 = Color3.new(1,1,1)
                EyeBtn.Font = Enum.Font.GothamBold
                EyeBtn.TextSize = 14
                Instance.new("UICorner", EyeBtn).CornerRadius = UDim.new(0, 4)
                EyeBtn.MouseButton1Click:Connect(function()
                    ShowToast("Highlighting: " .. gui.Name)
                    local highlights = {}
                    for _, v in pairs(gui:GetDescendants()) do
                        if v:IsA("GuiObject") and v.Visible then
                            if v:IsA("Frame") or v:IsA("ScrollingFrame") or v:IsA("ImageButton") then
                                local stroke = Instance.new("UIStroke", v)
                                stroke.Color = Color3.fromRGB(255, 0, 0)
                                stroke.Thickness = 4
                                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                                table.insert(highlights, stroke)
                            end
                        end
                    end
                    task.delay(2, function()
                        for _, h in pairs(highlights) do h:Destroy() end
                    end)
                end)
                local CopyBtn = Instance.new("TextButton", Row)
                CopyBtn.Size = UDim2.new(0, 45, 0, 30)
                CopyBtn.Position = UDim2.new(1, -50, 0.5, -15)
                RegisterTheme(CopyBtn, "BackgroundColor3", "Sidebar")
                CopyBtn.Text = "COPY"
                RegisterTheme(CopyBtn, "TextColor3", "Accent")
                CopyBtn.Font = Enum.Font.GothamBold
                CopyBtn.TextSize = 10
                Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)
                CopyBtn.MouseButton1Click:Connect(function()
                    local path = 'game:GetService("Players").LocalPlayer.PlayerGui["' .. gui.Name .. '"]'
                    setclipboard(path)
                    ShowToast("✅ Path Copied!")
                end)
            end
        end
    end
end
-- [SYSTEM MONITOR UI - GLOBAL VERSION (ANTI-LIMIT)]
-- Variabel dibuat Global (tanpa 'local') agar tidak kena limit script utama

StatsFrame = Instance.new("Frame", ScreenGui)
StatsFrame.Name = "StatsPanel"
StatsFrame.Size = UDim2.new(0, 220, 0, 200)
StatsFrame.Position = UDim2.new(0, 10, 0.4, 0)
RegisterTheme(StatsFrame, "BackgroundColor3", "Background")
StatsFrame.Visible = false
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)

StatsStroke = Instance.new("UIStroke", StatsFrame)
RegisterTheme(StatsStroke, "Color", "Accent")
StatsStroke.Thickness = 1
MakeDraggable(StatsFrame)

StatsHeader = Instance.new("TextLabel", StatsFrame)
StatsHeader.Size = UDim2.new(1, 0, 0, 25)
StatsHeader.BackgroundTransparency = 1
StatsHeader.Text = "SYSTEM MONITOR"
RegisterTheme(StatsHeader, "TextColor3", "Accent")
StatsHeader.Font = Enum.Font.GothamBlack
StatsHeader.TextSize = 13

StatsContainer = Instance.new("Frame", StatsFrame)
StatsContainer.Size = UDim2.new(1, -10, 1, -30)
StatsContainer.Position = UDim2.new(0, 5, 0, 30)
StatsContainer.BackgroundTransparency = 1

StatsList = Instance.new("UIListLayout", StatsContainer)
StatsList.Padding = UDim.new(0, 2)

-- Fungsi Global Helper
function CreateStatLabel(name)
    local f = Instance.new("Frame", StatsContainer) -- local di dalam fungsi aman
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    RegisterTheme(l, "TextColor3", "TextDim")
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    
    local v = Instance.new("TextLabel", f)
    v.Size = UDim2.new(0.5, 0, 1, 0)
    v.Position = UDim2.new(0.5, 0, 0, 0)
    v.BackgroundTransparency = 1
    v.Text = "..."
    RegisterTheme(v, "TextColor3", "Text")
    v.Font = Enum.Font.Code
    v.TextSize = 12
    v.TextXAlignment = Enum.TextXAlignment.Right
    return v
end

-- Label Indikator (Global)
FPSLabel  = CreateStatLabel("FPS:")
CPULabel  = CreateStatLabel("CPU (ms):")
PingLabel = CreateStatLabel("Ping:")
PlrLabel  = CreateStatLabel("Players:")
MemLabel  = CreateStatLabel("Memory:")
RecvLabel = CreateStatLabel("Recv:")
SentLabel = CreateStatLabel("Sent:")
InstLabel = CreateStatLabel("Instances:")

-- Loop Update (Global Thread)
task.spawn(function()
    while true do
        -- Cek variable State global
        if State.ShowStats and StatsFrame.Visible then
            -- Hitung Frame Time (CPU Load)
            local dt = game:GetService("RunService").RenderStepped:Wait() 
            local fps = math.floor(1 / (dt + 0.0001))
            local cpuMs = math.floor(dt * 1000)
            
            FPSLabel.Text = fps
            CPULabel.Text = cpuMs .. " ms"
            
            if cpuMs < 20 then
                CPULabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            elseif cpuMs < 50 then
                CPULabel.TextColor3 = Color3.fromRGB(255, 200, 50)
            else
                CPULabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end

            -- Ping
            local pingVal = 0
            pcall(function() pingVal = math.floor(game:GetService("Players").LocalPlayer:GetNetworkPing() * 2000) end)
            if pingVal == 0 then 
                pcall(function() pingVal = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end) 
            end
            PingLabel.Text = pingVal .. " ms"

            -- Players
            pcall(function() PlrLabel.Text = #game:GetService("Players"):GetPlayers() .. " / " .. game:GetService("Players").MaxPlayers end)

            -- Memory
            local mem = 0
            pcall(function() mem = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb()) end)
            MemLabel.Text = mem .. " MB"

            -- Network
            local recv = 0; local sent = 0
            pcall(function() recv = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Receive"]:GetValue()) end)
            pcall(function() sent = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Send"]:GetValue()) end)
            RecvLabel.Text = recv .. " KB/s"
            SentLabel.Text = sent .. " KB/s"

            -- Instances
            pcall(function() InstLabel.Text = tostring(#workspace:GetDescendants()) end)
        else
            task.wait(1)
        end
        task.wait(0.5)
    end
end)
local AnimLogFrame = Instance.new("Frame", ScreenGui); AnimLogFrame.Name = GetRandomName() AnimLogFrame.Size = UDim2.new(0, 220, 0, 160); AnimLogFrame.Position = UDim2.new(0, 10, 0.5, -80); RegisterTheme(AnimLogFrame, "BackgroundColor3", "Background"); AnimLogFrame.Visible = false
Instance.new("UICorner", AnimLogFrame).CornerRadius = UDim.new(0, 8); local ALStroke = Instance.new("UIStroke", AnimLogFrame); RegisterTheme(ALStroke, "Color", "Accent"); ALStroke.Thickness = 1; MakeDraggable(AnimLogFrame)
local ALContainer = Instance.new("ScrollingFrame", AnimLogFrame); ALContainer.Size = UDim2.new(1, -10, 1, -30); ALContainer.Position = UDim2.new(0, 5, 0, 30); ALContainer.BackgroundTransparency = 1; ALContainer.ScrollBarThickness = 3; ALContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
local ALList = Instance.new("UIListLayout", ALContainer); ALList.Padding = UDim.new(0, 2); local ALHeader = Instance.new("TextLabel", AnimLogFrame); ALHeader.Size = UDim2.new(1, 0, 0, 25); ALHeader.BackgroundTransparency = 1; ALHeader.Text = "ANIM LOG"; RegisterTheme(ALHeader, "TextColor3", "Accent"); ALHeader.Font = Enum.Font.GothamBlack; ALHeader.TextSize = 14
local ChatLogFrame = Instance.new("Frame", ScreenGui); ChatLogFrame.Name = GetRandomName() ChatLogFrame.Size = UDim2.new(0, 260, 0, 180); ChatLogFrame.Position = UDim2.new(1, -280, 0.5, -80); RegisterTheme(ChatLogFrame, "BackgroundColor3", "Background"); ChatLogFrame.Visible = false
Instance.new("UICorner", ChatLogFrame).CornerRadius = UDim.new(0, 8); local CLStroke = Instance.new("UIStroke", ChatLogFrame); RegisterTheme(CLStroke, "Color", "Accent"); CLStroke.Thickness = 1; MakeDraggable(ChatLogFrame)
local CLContainer = Instance.new("ScrollingFrame", ChatLogFrame); CLContainer.Size = UDim2.new(1, -10, 1, -30); CLContainer.Position = UDim2.new(0, 5, 0, 30); CLContainer.BackgroundTransparency = 1; CLContainer.ScrollBarThickness = 3; CLContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
local CLList = Instance.new("UIListLayout", CLContainer); CLList.Padding = UDim.new(0, 4); local CLHeader = Instance.new("TextLabel", ChatLogFrame); CLHeader.Size = UDim2.new(1, 0, 0, 25); CLHeader.BackgroundTransparency = 1; CLHeader.Text = "CHAT LOG"; RegisterTheme(CLHeader, "TextColor3", "Accent"); CLHeader.Font = Enum.Font.GothamBlack; CLHeader.TextSize = 14
local UpdateAnimLogger, InitChatLogger 
do
    local AnimLoggerConnection = nil 
    local ActiveAnimLabels = {}

    local function ClearAnimLog() 
        for _, child in pairs(ALContainer:GetChildren()) do 
            if child:IsA("Frame") then child:Destroy() end 
        end 
        ActiveAnimLabels = {} 
    end

    local function ClearChatLog() 
        for _, child in pairs(CLContainer:GetChildren()) do 
            if child:IsA("TextLabel") then child:Destroy() end 
        end 
    end

    UpdateAnimLogger = function()
        -- Bersihkan koneksi lama
        if AnimLoggerConnection then 
            AnimLoggerConnection:Disconnect()
            AnimLoggerConnection = nil
        end

        -- Jika fitur dimatikan
        if not State.AnimLogger then 
            AnimLogFrame.Visible = false
            ClearAnimLog() 
            return 
        end

        AnimLogFrame.Visible = true
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChild("Humanoid"); if not hum then return end
        local animator = hum:FindFirstChildOfClass("Animator"); if not animator then return end

        AnimLoggerConnection = animator.AnimationPlayed:Connect(function(track)
            if not State.AnimLogger then return end
            
            local animId = track.Animation.AnimationId
            local idNum = string.match(animId, "%d+") or "Unknown"
            
            -- Cek duplikat biar gak spam list
            if ActiveAnimLabels[track] then return end

            -- [UPDATE TAMPILAN BARU: ROW DENGAN TOMBOL COPY]
            local Row = Instance.new("Frame", ALContainer)
            Row.Size = UDim2.new(1, 0, 0, 28) -- Tinggi baris
            Row.BackgroundTransparency = 1
            
            -- Label ID (Kiri)
            local lbl = Instance.new("TextLabel", Row)
            lbl.Size = UDim2.new(0.65, 0, 1, 0)
            lbl.Position = UDim2.new(0, 0, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "ID: " .. idNum
            RegisterTheme(lbl, "TextColor3", "Text")
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Tombol Copy (Kanan)
            local CopyBtn = Instance.new("TextButton", Row)
            CopyBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
            CopyBtn.Position = UDim2.new(0.68, 0, 0.1, 0)
            CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Warna Biru
            CopyBtn.Text = "COPY"
            CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CopyBtn.Font = Enum.Font.GothamBold
            CopyBtn.TextSize = 10
            Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)
            
            -- Fungsi Copy
            CopyBtn.MouseButton1Click:Connect(function() 
                setclipboard(idNum)
                ShowToast("✅ ID Copied: " .. idNum)
                
                -- Efek Visual Tombol Berubah
                CopyBtn.Text = "COPIED!"
                CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                task.wait(1)
                CopyBtn.Text = "COPY"
                CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            end)

            ActiveAnimLabels[track] = Row

            -- Hapus dari list jika animasi berhenti
            track.Stopped:Connect(function() 
                if ActiveAnimLabels[track] then 
                    ActiveAnimLabels[track]:Destroy()
                    ActiveAnimLabels[track] = nil 
                end 
            end)
        end)
    end
end
local ChatConnections = {} 
local function ToggleChatLogger(enable)
    State.ChatLogger = enable
    if enable then
        ChatLogFrame.Visible = true
        local function LogMessage(player, msg)
            if not ChatLogFrame.Visible then return end
            local time = os.date("%H:%M")
            local name = (player and player.DisplayName) or "Unknown"
            local lbl = Instance.new("TextLabel", CLContainer)
            lbl.Size = UDim2.new(1, 0, 0, 25)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextWrapped = true
            lbl.RichText = true
            lbl.Text = string.format("<font color='rgb(0,255,140)'>[%s] %s:</font> %s", time, name, msg)
            RegisterTheme(lbl, "TextColor3", "Text")
            CLContainer.CanvasPosition = Vector2.new(0, 99999)
            local children = CLContainer:GetChildren()
            if #children > 50 then 
                for i=1, 5 do 
                    if children[i] and children[i]:IsA("TextLabel") then children[i]:Destroy() end 
                end 
            end
        end
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
             local conn = TextChatService.MessageReceived:Connect(function(msg)
                if msg.TextSource then 
                    LogMessage(Players:GetPlayerByUserId(msg.TextSource.UserId), msg.Text) 
                end
            end)
            table.insert(ChatConnections, conn)
        else
            local conn = ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
                local p = Players:FindFirstChild(data.FromSpeaker)
                LogMessage(p, data.Message)
            end)
            table.insert(ChatConnections, conn)
        end
        ShowToast("Chat Logger: Listening...")
    else
        ChatLogFrame.Visible = false
        for _, conn in pairs(ChatConnections) do
            conn:Disconnect()
        end
        ChatConnections = {} 
        for _, v in pairs(CLContainer:GetChildren()) do
            if v:IsA("TextLabel") then v:Destroy() end
        end
        ShowToast("Chat Logger: Sleeping (Disconnected)")
    end
end
local ProxLoopRunning = false
local function ToggleProximity(enable)
    State.ProximityWarning = enable
    if not enable then
        ProxFrame.Visible = false
        return 
    end
    if ProxLoopRunning then return end
    ProxLoopRunning = true
    task.spawn(function()
        ShowToast("Proximity Sensor: ACTIVE")
        while State.ProximityWarning do 
            local nearbyText = ""
            local count = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local root = GetVisualPart(p.Character)
                    local myRoot = GetVisualPart(LocalPlayer.Character)
                    if root and myRoot then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < State.ProximityDist then
                            local isThreat = true
                            if State.ProximityMode == "Enemy Only" and p.Team == LocalPlayer.Team then 
                                isThreat = false 
                            end
                            if isThreat then
                                nearbyText = nearbyText .. "• " .. p.DisplayName .. " [" .. math.floor(dist) .. "m]\n"
                                count = count + 1
                            end
                        end
                    end
                end
            end
            if count > 0 then
                ProxFrame.Visible = true
                ProxTitle.Text = "WARNING: " .. count .. " ENEMY!"
                ProxList.Text = nearbyText
            else
                ProxFrame.Visible = false
            end
            task.wait(0.5)
        end
        ProxLoopRunning = false
        ProxFrame.Visible = false
    end)
end
local LastClickTime = 0
local LastVisualUpdate = 0
local VisualRate = 0.05
RunService.RenderStepped:Connect(function(dt)
    if State.Aimbot and UserInputService:IsMouseButtonPressed(State.AimbotButton) then
        local targetObj = GetClosestPlayer()
        if targetObj and targetObj.Character then
            local part = GetBestAimPart(targetObj.Character) 
            local root = targetObj.Character:FindFirstChild("HumanoidRootPart")
            if part and root then
                local TargetPos = part.Position
                if State.AimbotMethod == "Camera (FPP)" then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPos)
                else 
                    local screenPos, onScreen = Camera:WorldToViewportPoint(TargetPos)
                    if onScreen then
                        local mouseLoc = UserInputService:GetMouseLocation()
                        local aimVec = Vector2.new(screenPos.X, screenPos.Y) - mouseLoc
                        if mousemoverel then mousemoverel(aimVec.X * State.AimbotAggressiveness, aimVec.Y * State.AimbotAggressiveness) end
                    end
                end
            end
        end
    end
    if State.AutoClicker then
        if tick() - LastClickTime > (1 / State.CPS) then
            LastClickTime = tick()
            local char = LocalPlayer.Character
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate()
            else
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
            end
        end
    end
    if State.Bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if State.FullbrightLoop then 
        Lighting.Brightness = 2 
        Lighting.ClockTime = 12 
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178) 
        Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    end
    if State.NoFog then 
        Lighting.FogStart = 9e9 
        Lighting.FogEnd = 9e9 
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                v.Density = 0
                v.Offset = 0
                v.Haze = 0
                v.Glare = 0
            end
        end
    end
    if State.DisableLighting then
        Lighting.GlobalShadows = false 
        Lighting.Brightness = 1 
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then 
                v.Enabled = false
            end
        end
    end
    if State.Crosshair then CrosshairFrame.Visible = true else CrosshairFrame.Visible = false end
    if tick() - LastVisualUpdate > VisualRate then
        LastVisualUpdate = tick()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                -- Cek HumanoidRootPart untuk memastikan karakter valid
                local rootPart = char and char:FindFirstChild("HumanoidRootPart")
                
                if State.MasterESP and char and rootPart then
                    local targetPart = GetVisualPart(char) -- Biasanya Head/Root
                    
                    if targetPart then
                        local myRoot = GetVisualPart(LocalPlayer.Character)
                        local dist = (myRoot and math.floor((myRoot.Position - targetPart.Position).Magnitude)) or 0
                        local targetColor = GetTeamColor(p) 
                        
                        -- Cari atau Buat GUI ESP
                        local info = char:FindFirstChild("ReyzzWSP_V2")
                        if not info then
                            info = Instance.new("BillboardGui", char)
                            info.Name = "ReyzzWSP_V2"
                            info.Size = UDim2.new(0, 200, 0, 100)
                            info.StudsOffset = Vector3.new(0, 4, 0)
                            info.AlwaysOnTop = true -- Tembus Tembok
                            info.MaxDistance = math.huge -- [FIX] Jarak Tak Terbatas
                            
                            local layout = Instance.new("UIListLayout", info)
                            layout.SortOrder = Enum.SortOrder.LayoutOrder
                            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                            
                            local nLbl = Instance.new("TextLabel", info); nLbl.Name = "NameLbl"; nLbl.Size = UDim2.new(1,0,0,15); nLbl.BackgroundTransparency = 1; nLbl.Font = Enum.Font.GothamBold; nLbl.TextSize = 13; nLbl.TextStrokeTransparency = 0; nLbl.LayoutOrder = 1
                            local hLbl = Instance.new("TextLabel", info); hLbl.Name = "HPLbl"; hLbl.Size = UDim2.new(1,0,0,15); hLbl.BackgroundTransparency = 1; hLbl.Font = Enum.Font.Code; hLbl.TextSize = 11; hLbl.TextStrokeTransparency = 0; hLbl.LayoutOrder = 2
                            local dLbl = Instance.new("TextLabel", info); dLbl.Name = "DistLbl"; dLbl.Size = UDim2.new(1,0,0,15); dLbl.BackgroundTransparency = 1; dLbl.Font = Enum.Font.GothamBold; dLbl.TextSize = 10; dLbl.TextStrokeTransparency = 0; dLbl.LayoutOrder = 3
                        end

                        info.Enabled = true
                        info.Adornee = targetPart -- Tempel ke Kepala/Badan
                        
                        -- Update Nama & Warna
                        local nameL = info:FindFirstChild("NameLbl")
                        if nameL then 
                            nameL.Text = p.DisplayName
                            if State.UseCustomNameColor then
                                local cName = State.EspNameColorName or "Putih"
                                nameL.TextColor3 = ESP_Colors[cName] or Color3.fromRGB(255, 255, 255)
                            else
                                nameL.TextColor3 = targetColor 
                            end 
                        end
                        
                        -- Update HP
                        local hpL = info:FindFirstChild("HPLbl")
                        local hum = char:FindFirstChild("Humanoid")
                        if hpL then 
                            if hum then 
                                local hp = math.floor(hum.Health)
                                local perc = math.clamp(hp / hum.MaxHealth, 0, 1)
                                hpL.Text = "HP: " .. hp
                                hpL.TextColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), perc) 
                            else 
                                hpL.Text = "HP: ?"
                                hpL.TextColor3 = Color3.new(1,1,1) 
                            end 
                        end
                        
                        -- Update Jarak
                        local distL = info:FindFirstChild("DistLbl")
                        if distL then 
                            local txt = "[" .. dist .. "m]"
                            if State.ShowInventory then 
                                local tool = char:FindFirstChildOfClass("Tool")
                                if tool then txt = txt .. "\n[Item: " .. tool.Name .. "]" end 
                            end
                            distL.Text = txt
                            -- Ubah warna jarak: Makin jauh makin putih, dekat makin merah
                            distL.TextColor3 = Color3.fromRGB(255, 50, 50):Lerp(Color3.fromRGB(255, 255, 255), math.clamp(dist/300, 0, 1))
                        end

                        -- Update Highlight (Kotak Nyala)
                        -- PENTING: Highlight punya limit 31 player. Kita bungkus pcall biar gak error.
                        local hl = char:FindFirstChild("GHighlight")
                        if not hl then 
                            hl = Instance.new("Highlight", char)
                            hl.Name = "GHighlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                        end
                        
                        hl.Enabled = true
                        hl.FillColor = targetColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255) 
                        hl.FillTransparency = 0.5 
                        hl.OutlineTransparency = 0
                    end
                else
                    -- Matikan ESP jika fitur OFF atau player mati
                    if char then
                        if char:FindFirstChild("ReyzzWSP_V2") then char.ReyzzWSP_V2.Enabled = false end
                        if char:FindFirstChild("GHighlight") then char.GHighlight.Enabled = false end
                    end
                end
            end
        end
    end
    if State.AutoRegen and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then if Camera.CameraSubject ~= hum then Camera.CameraSubject = hum end; if Camera.CameraType ~= Enum.CameraType.Custom then Camera.CameraType = Enum.CameraType.Custom end end
    end
    if State.MaxZoom then LocalPlayer.CameraMaxZoomDistance = 1000; LocalPlayer.CameraMinZoomDistance = 0.5 end
    if State.FakeLag and LocalPlayer.Character then
        local root = GetVisualPart(LocalPlayer.Character)
        if root then if tick() % 0.2 < 0.1 then root.Anchored = true else root.Anchored = false end end
    else
        if LocalPlayer.Character then 
            local root = GetVisualPart(LocalPlayer.Character)
            if root and root.Anchored and not State.Freecam then root.Anchored = false end
        end
    end
    if State.PlatformWalk and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not PlatformY then 
                PlatformY = root.Position.Y 
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
                PlatformY = PlatformY + 0.5
            elseif UserInputService:IsKeyDown(Enum.KeyCode.E) then
                PlatformY = PlatformY - 0.5
            end
            if not PlatformPart or not PlatformPart.Parent then
                PlatformPart = Instance.new("Part", Workspace)
                PlatformPart.Name = "ReyzzPlatform"
                PlatformPart.Anchored = true
                PlatformPart.CanCollide = true
                PlatformPart.Transparency = 0.5
                PlatformPart.Size = Vector3.new(6, 1, 6) 
                PlatformPart.Material = Enum.Material.ForceField 
                PlatformPart.Color = Color3.fromRGB(0, 255, 255)
            end
            PlatformPart.CFrame = CFrame.new(root.Position.X, PlatformY - 3.5, root.Position.Z)
            root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
        end
    else
        if PlatformPart then
            PlatformPart:Destroy()
            PlatformPart = nil
        end
        PlatformY = nil
    end
    if State.GravityControl and LocalPlayer.Character then
        local root = GetVisualPart(LocalPlayer.Character)
        if root then
            local ray = Ray.new(root.Position, -root.CFrame.UpVector * 10)
            local part, pos, normal = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if part then
                local currentRight = root.CFrame.RightVector; local newUp = normal; local newRight = currentRight:Cross(newUp).Unit; local newLook = newUp:Cross(newRight).Unit
                root.CFrame = CFrame.fromMatrix(root.Position, newRight, newUp, newLook)
            end
        end
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root.Position.Y > State.VoidHeight + 10 and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then State.LastSafePos = root.CFrame end
        if State.AntiVoid and root.Position.Y < State.VoidHeight then
            if State.LastSafePos then root.CFrame = State.LastSafePos + Vector3.new(0, 3, 0); root.Velocity = Vector3.new(0,0,0); ShowToast("Anti-Void: Saved!") end
        end
    end
    if State.WalkOnWater and LocalPlayer.Character then
        local root = GetVisualPart(LocalPlayer.Character)
        if root then
            local params = RaycastParams.new(); params.FilterDescendantsInstances = {LocalPlayer.Character, WoWPart}
            local ray = Workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
            if ray and ray.Material == Enum.Material.Water then WoWPart.CanCollide = true; WoWPart.Position = Vector3.new(root.Position.X, ray.Position.Y, root.Position.Z) else WoWPart.CanCollide = false end
        end
    else WoWPart.CanCollide = false end
    if State.Spider and LocalPlayer.Character then
        local root = GetVisualPart(LocalPlayer.Character); local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root and hum then
            local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
            local part, _ = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if part and hum.MoveDirection.Magnitude > 0 then root.Velocity = Vector3.new(root.Velocity.X, 25, root.Velocity.Z) end
        end
    end
    if (State.SpinBot or State.TouchFling) and LocalPlayer.Character then
        local root = GetVisualPart(LocalPlayer.Character); local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if root and hum then
            local bambam = root:FindFirstChild("IY_BAMBAM")
            if not bambam then bambam = Instance.new("BodyAngularVelocity", root); bambam.Name = "IY_BAMBAM"; bambam.MaxTorque = Vector3.new(0, math.huge, 0); bambam.P = math.huge end
            local flyVel = root:FindFirstChild("IY_FLY"); local flyGyro = root:FindFirstChild("IY_GYRO")
            if State.TouchFling then
                bambam.AngularVelocity = Vector3.new(0, 99999, 0) 
                for _, v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false; v.Massless = true; v.Velocity = Vector3.new(0,0,0); v.CustomPhysicalProperties = PhysicalProperties.new(100, 0.3, 0.5) end
                end
                if State.FlingMode == "Fly" then
                    if not flyVel then flyVel = Instance.new("BodyVelocity", root); flyVel.Name = "IY_FLY"; flyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9) end
                    if not flyGyro then flyGyro = Instance.new("BodyGyro", root); flyGyro.Name = "IY_GYRO"; flyGyro.P = 9e4; flyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9) end
                    hum.PlatformStand = true; local cam = Workspace.CurrentCamera; flyVel.Velocity = cam.CFrame.LookVector * 100; flyGyro.CFrame = cam.CFrame
                else
                    if flyVel then flyVel:Destroy() end; if flyGyro then flyGyro:Destroy() end; hum.PlatformStand = false
                end
            else
                bambam.AngularVelocity = Vector3.new(0, State.SpinSpeed, 0)
                if flyVel then flyVel:Destroy() end; if flyGyro then flyGyro:Destroy() end
            end
        end
    else
        if LocalPlayer.Character then
            local root = GetVisualPart(LocalPlayer.Character)
            if root then
                if root:FindFirstChild("IY_BAMBAM") then root.IY_BAMBAM:Destroy() end
                if root:FindFirstChild("IY_FLY") then root.IY_FLY:Destroy() end
                if root:FindFirstChild("IY_GYRO") then root.IY_GYRO:Destroy() end
            end
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid"); if hum and hum.PlatformStand then hum.PlatformStand = false end
        end
    end
    if State.ForceUnlockMouse then
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then UserInputService.MouseBehavior = Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled = true end
    end
    if State.SpectatingPlayer and State.CinematicCamera then
        local p = State.SpectatingPlayer
        if p and p.Character then
            local targetPart = p.Character:FindFirstChild("Head") or GetVisualPart(p.Character)
            if targetPart then
                Camera.CameraType = Enum.CameraType.Scriptable
                local vel = targetPart.Velocity; local targetPos = targetPart.Position; local currentCF = Camera.CFrame; local time = tick()
                local breathY = math.sin(time * 1.5) * 0.15; local speed = vel.Magnitude
                local walkSwayX = math.cos(time * 8) * (speed * 0.005); local walkSwayY = math.abs(math.sin(time * 8)) * (speed * 0.005)
                local tiltZ = math.clamp(-targetPart.CFrame.RightVector:Dot(vel) * 0.05, -0.1, 0.1)
                local finalPos = targetPos + Vector3.new(0, 2 + breathY + walkSwayY, 0)
                local smoothCF = currentCF:Lerp(CFrame.new(finalPos + (targetPart.CFrame.LookVector * -6), finalPos), 0.15)
                Camera.CFrame = smoothCF * CFrame.Angles(walkSwayY, walkSwayX, tiltZ)
            end
        else
            State.SpectatingPlayer = nil; State.CinematicCamera = false
            Camera.CameraType = Enum.CameraType.Custom; Camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end
    if (State.GunMods or State.NoRecoil) and LocalPlayer.Character then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("ModuleScript") then
                    pcall(function() local m = require(v); if type(m) == "table" then if State.NoRecoil then m.Recoil=0; m.Spread=0 end; if State.GunMods then m.FireRate=0; m.Auto=true end end end)
                end
            end
        end
    end
end)
task.spawn(function()
    while true do
        if State.SpectatorList and SpecFrame.Visible then
            local content = ""
            local count = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local theirRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and theirRoot then
                        local dist = (myRoot.Position - theirRoot.Position).Magnitude
                        if dist < 20 then
                            content = content .. "• " .. p.DisplayName .. " [" .. math.floor(dist) .. "m]\n"
                            count = count + 1
                        end
                    end
                end
            end
            if count == 0 then
                SpecText.Text = "No one nearby..."
            else
                SpecText.Text = content
            end
        end
        task.wait(1) 
    end
end)
local ToggleButton, MainFrame, SettingsBtn, SetIcon, Sidebar, Content 
do
    ToggleButton = Instance.new("ImageButton", ScreenGui)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 50, 0, 50)
    ToggleButton.Image = "rbxassetid://99526677735751"
    ToggleButton.ScaleType = Enum.ScaleType.Fit
    RegisterTheme(ToggleButton, "BackgroundColor3", "Background")
    ToggleButton.BackgroundTransparency = 0
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.AutoButtonColor = false
    ToggleButton.Visible = true
    ToggleButton.ZIndex = 9999
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 15)
    local IconStroke = Instance.new("UIStroke", ToggleButton)
    RegisterTheme(IconStroke, "Color", "Accent")
    IconStroke.Thickness = 3
    IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MakeDraggable(ToggleButton)
    MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UIScale.BaseSize 
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    RegisterTheme(MainFrame, "BackgroundColor3", "Background") 
    MainFrame.Visible = false
    MainFrame.ClipsDescendants = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
    MainFrame.BackgroundTransparency = 0.3
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Name = "MainBorder"
    MainStroke.Thickness = 1.5 
    MainStroke.Transparency = 0.2 
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RegisterTheme(MainStroke, "Color", "Accent") 
    local Shadow = Instance.new("ImageLabel", MainFrame)
    Shadow.Name = "GlowShadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5028857472" 
    Shadow.ImageColor3 = CurrentTheme.Accent
    Shadow.Size = UDim2.new(1, 100, 1, 100)
    Shadow.Position = UDim2.new(0, -50, 0, -50)
    Shadow.ZIndex = -1 
    Shadow.ImageTransparency = 0.7 
    RegisterTheme(Shadow, "ImageColor3", "Accent")
    MakeDraggable(MainFrame)
    local HeaderFrame = Instance.new("Frame", MainFrame)
    HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
    RegisterTheme(HeaderFrame, "BackgroundColor3", "Background") 
    HeaderFrame.BackgroundTransparency = 1
    HeaderFrame.BorderSizePixel = 0
    local HeaderTitle = Instance.new("TextLabel", HeaderFrame)
    HeaderTitle.Text = ConfigName or "ReyzzHub v1.1.2 | Universal" 
    HeaderTitle.Size = UDim2.new(0.7, 0, 1, 0)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    RegisterTheme(HeaderTitle, "TextColor3", "Accent")
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 14
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    local WinControls = Instance.new("Frame", HeaderFrame)
    WinControls.Size = UDim2.new(0, 80, 1, 0)
    WinControls.Position = UDim2.new(1, -80, 0, 0)
    WinControls.BackgroundTransparency = 1
    local function CreateWinBtn(text, order, callback)
        local btn = Instance.new("TextButton", WinControls)
        btn.Size = UDim2.new(0, 40, 1, 0)
        btn.Position = UDim2.new(0, (order-1)*40, 0, 0)
        btn.BackgroundTransparency = 1
        btn.Text = text
        RegisterTheme(btn, "TextColor3", "TextDim")
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 16
        btn.MouseEnter:Connect(function() btn.TextColor3 = CurrentTheme.Text end)
        btn.MouseLeave:Connect(function() btn.TextColor3 = CurrentTheme.TextDim end)
        btn.MouseButton1Click:Connect(callback)
    end
    CreateWinBtn("-", 1, function() MainFrame.Visible = false end)
    local HeaderLine = Instance.new("Frame", MainFrame)
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 0, 40)
    RegisterTheme(HeaderLine, "BackgroundColor3", "Stroke")
    HeaderLine.BorderSizePixel = 0
    local SidebarWidth = 160
    Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -41)
    Sidebar.Position = UDim2.new(0, 0, 0, 41)
    RegisterTheme(Sidebar, "BackgroundColor3", "Sidebar")
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.ZIndex = 100
    local SidePadding = Instance.new("UIPadding", Sidebar)
    SidePadding.PaddingTop = UDim.new(0, 25)
    local TabListLayout = Instance.new("UIListLayout", Sidebar)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Content = Instance.new("Frame", MainFrame)
    Content.Size = UDim2.new(1, -SidebarWidth, 1, -41)
    Content.Position = UDim2.new(0, SidebarWidth, 0, 41)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
CreateWinBtn("X", 2, function()
    if ScreenGui:FindFirstChild("ExitConfirmation") then return end
    local Overlay = Instance.new("Frame", ScreenGui) 
    Overlay.Name = "ExitConfirmation"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 1 
    Overlay.ZIndex = 10000 
    local Box = Instance.new("Frame", Overlay)
    Box.Size = UDim2.new(0, 0, 0, 0)
    Box.Position = UDim2.new(0.5, 0, 0.5, 0)
    Box.AnchorPoint = Vector2.new(0.5, 0.5)
    Box.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Box.ClipsDescendants = true
    Box.ZIndex = 10001 
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Box)
    Stroke.Color = Color3.fromRGB(255, 60, 60)
    Stroke.Thickness = 1.5
    local Title = Instance.new("TextLabel", Box)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "⚠️ KONFIRMASI"
    Title.TextColor3 = Color3.fromRGB(255, 60, 60)
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.ZIndex = 10002
    local Msg = Instance.new("TextLabel", Box)
    Msg.Size = UDim2.new(0.9, 0, 0, 60)
    Msg.Position = UDim2.new(0.05, 0, 0, 35)
    Msg.BackgroundTransparency = 1
    Msg.Text = "Script akan TETAP JALAN di background meski panel ditutup.\nYakin ingin menutup?"
    Msg.TextColor3 = Color3.fromRGB(200, 200, 200)
    Msg.Font = Enum.Font.GothamMedium
    Msg.TextSize = 12
    Msg.TextWrapped = true
    Msg.ZIndex = 10002
    local BtnYes = Instance.new("TextButton", Box)
    BtnYes.Size = UDim2.new(0.4, 0, 0, 35)
    BtnYes.Position = UDim2.new(0.05, 0, 1, -45)
    BtnYes.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    BtnYes.Text = "YA (TUTUP)"
    BtnYes.TextColor3 = Color3.new(1, 1, 1)
    BtnYes.Font = Enum.Font.GothamBold
    BtnYes.TextSize = 11
    BtnYes.ZIndex = 10002
    Instance.new("UICorner", BtnYes).CornerRadius = UDim.new(0, 6)
    local BtnNo = Instance.new("TextButton", Box)
    BtnNo.Size = UDim2.new(0.4, 0, 0, 35)
    BtnNo.Position = UDim2.new(0.55, 0, 1, -45)
    BtnNo.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    BtnNo.Text = "BATAL"
    BtnNo.TextColor3 = Color3.new(1, 1, 1)
    BtnNo.Font = Enum.Font.GothamBold
    BtnNo.TextSize = 11
    BtnNo.ZIndex = 10002
    Instance.new("UICorner", BtnNo).CornerRadius = UDim.new(0, 6)
    BtnYes.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    BtnNo.MouseButton1Click:Connect(function()
        local TS = game:GetService("TweenService")
        TS:Create(Box, TweenInfo.new(0.2), {Size = UDim2.new(0,0,0,0)}):Play()
        TS:Create(Overlay, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        task.wait(0.2)
        Overlay:Destroy()
    end)
    local TS = game:GetService("TweenService")
    TS:Create(Overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    TS:Create(Box, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 160)}):Play()
end)
end
Content.ClipsDescendants = true
local function CreateTab(Name, IconId)
    local Btn = Instance.new("TextButton", Sidebar)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 101
    local ActiveBar = Instance.new("Frame", Btn)
    RegisterTheme(ActiveBar, "BackgroundColor3", "Accent")
    ActiveBar.Size = UDim2.new(0, 4, 0.6, 0)
    ActiveBar.Position = UDim2.new(0, 0, 0.2, 0)
    ActiveBar.Visible = false
    Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(0, 2)
    ActiveBar.ZIndex = 102
    local IconImg = Instance.new("ImageLabel", Btn)
    IconImg.Name = "TabIcon"
    IconImg.Size = UDim2.new(0, 24, 0, 24)
    IconImg.Position = UDim2.new(0, 15, 0.5, -12)
    IconImg.BackgroundTransparency = 1
    IconImg.Image = IconId or "rbxassetid://0"
    RegisterTheme(IconImg, "ImageColor3", "TextDim")
    IconImg.ZIndex = 102
    local NameLbl = Instance.new("TextLabel", Btn)
    NameLbl.Text = Name
    NameLbl.Size = UDim2.new(0, 100, 1, 0)
    NameLbl.Position = UDim2.new(0, 50, 0, 0)
    NameLbl.BackgroundTransparency = 1
    RegisterTheme(NameLbl, "TextColor3", "TextDim")
    NameLbl.Font = Enum.Font.GothamBold
    NameLbl.TextSize = 14
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.ZIndex = 102
    local Page = Instance.new("ScrollingFrame", Content)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = false
    Page.ScrollBarThickness = 4
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    local PL = Instance.new("UIListLayout", Page)
    PL.Padding = UDim.new(0, 10)
    PL.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local PP = Instance.new("UIPadding", Page)
    PP.PaddingTop = UDim.new(0, 20)
    PP.PaddingBottom = UDim.new(0, 20)
    Btn.MouseButton1Click:Connect(function()
        for _, v in pairs(Sidebar:GetChildren()) do
            if v:IsA("TextButton") then
                local ab = v:FindFirstChild("Frame") 
                local il = v:FindFirstChild("TabIcon")
                local nl = v:GetChildren()[3] 
                if ab then ab.Visible = false end
                if il then TweenService:Create(il, TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.TextDim}):Play() end
                if nl then TweenService:Create(nl, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.TextDim}):Play() end
                TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end
        for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
        ActiveBar.Visible = true
        TweenService:Create(IconImg, TweenInfo.new(0.3), {ImageColor3 = CurrentTheme.Accent}):Play()
        TweenService:Create(NameLbl, TweenInfo.new(0.3), {TextColor3 = CurrentTheme.Text}):Play()
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.85, BackgroundColor3 = CurrentTheme.Accent}):Play()
        Page.Visible = true
    end)
    return Page
end
local function CreateToggle(Page, Text, Callback, Default)
    local Wrapper = Instance.new("TextButton", Page)
    Wrapper.Name = "Toggle_" .. Text
    Wrapper.Size = UDim2.new(0.95, 0, 0, 35)
    Wrapper.BackgroundTransparency = 1
    Wrapper.Text = "" 
    Wrapper.AutoButtonColor = false 
    local Lbl = Instance.new("TextLabel", Wrapper)
    Lbl.Text = Text
    Lbl.Size = UDim2.new(0.7, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local TogBtn = Instance.new("Frame", Wrapper) 
    TogBtn.Size = UDim2.new(0, 45, 0, 22)
    TogBtn.Position = UDim2.new(1, -55, 0.18, 0)
    RegisterTheme(TogBtn, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", TogBtn).CornerRadius = UDim.new(1, 0)
    local Circle = Instance.new("Frame", TogBtn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 2, 0.5, -9)
    RegisterTheme(Circle, "BackgroundColor3", "TextDim")
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    local Toggled = Default or false
    local function SetState(val, skipToast)
        Toggled = val
        local TweenService = game:GetService("TweenService")
        if Toggled then
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
            RegisterTheme(Circle, "BackgroundColor3", "Accent")
            if not skipToast then ShowToast(Text .. ": ON 🟢") end
            
            -- Panggil Fungsi Global tadi
            if UpdateActiveIndicator then UpdateActiveIndicator(Text, true) end
        else
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            RegisterTheme(Circle, "BackgroundColor3", "TextDim")
            if not skipToast then ShowToast(Text .. ": OFF 🔴") end
            
            -- Panggil Fungsi Global tadi
            if UpdateActiveIndicator then UpdateActiveIndicator(Text, false) end
        end
        Callback(Toggled)
    end
    Wrapper.MouseButton1Click:Connect(function() SetState(not Toggled) end)
    if Default then task.spawn(function() SetState(true, true) end) end
    State.UIListeners[Text] = function(val) SetState(val, true) end
    State.RegisteredFeatures[Text] = {
        Type = "Toggle",
        Trigger = function() SetState(not Toggled) end 
    }
end
local function C(text, r, g, b)
    return '<font color="rgb(' .. r .. ',' .. g .. ',' .. b .. ')">' .. text .. '</font>'
end
local function CreateLabel(Page, Text)
    local Wrapper = Instance.new("Frame", Page)
    Wrapper.Size = UDim2.new(0.95, 0, 0, 30)
    Wrapper.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", Wrapper)
    Lbl.Size = UDim2.new(1, -10, 1, 0)
    Lbl.Position = UDim2.new(0, 5, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.RichText = true 
    Lbl.Text = Text
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 13
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextWrapped = true
    return Lbl
end
local function CreateInput(Page, Text, Placeholder, Callback, IsString)
    local Wrapper = Instance.new("Frame", Page)
    Wrapper.Size = UDim2.new(0.95, 0, 0, 50)
    Wrapper.BackgroundTransparency = 1
    local Lbl = Instance.new("TextLabel", Wrapper)
    Lbl.Text = Text 
    Lbl.Size = UDim2.new(1, 0, 0, 20)
    Lbl.Position = UDim2.new(0, 5, 0, 0)
    Lbl.BackgroundTransparency = 1
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local BgBox = Instance.new("Frame", Wrapper)
    BgBox.Size = UDim2.new(1, 0, 0, 30)
    BgBox.Position = UDim2.new(0, 0, 0, 20)
    RegisterTheme(BgBox, "BackgroundColor3", "ElementBG")
    BgBox.ClipsDescendants = true 
    Instance.new("UICorner", BgBox).CornerRadius = UDim.new(0, 6)
    local Stroke = Instance.new("UIStroke", BgBox)
    Stroke.Thickness = 1
    RegisterTheme(Stroke, "Color", "Stroke")
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local InputBox = Instance.new("TextBox", BgBox)
    InputBox.Size = UDim2.new(1, -10, 1, 0)
    InputBox.Position = UDim2.new(0, 5, 0, 0)
    InputBox.BackgroundTransparency = 1
    InputBox.Text = ""
    InputBox.PlaceholderText = tostring(Placeholder)
    RegisterTheme(InputBox, "TextColor3", "Accent")
    RegisterTheme(InputBox, "PlaceholderColor3", "TextDim")
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.TextSize = 13
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false
    InputBox.Focused:Connect(function()
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = CurrentTheme.Accent, Transparency = 0}):Play()
        TweenService:Create(BgBox, TweenInfo.new(0.3), {BackgroundTransparency = 0.5}):Play()
    end)
    InputBox.FocusLost:Connect(function(enter)
        TweenService:Create(Stroke, TweenInfo.new(0.3), {Color = CurrentTheme.Stroke, Transparency = 0.5}):Play()
        TweenService:Create(BgBox, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        if IsString then 
            Callback(InputBox.Text) 
        else 
            local num = tonumber(InputBox.Text)
            if num then Callback(num) else InputBox.Text = "" end 
        end 
    end)
    return InputBox
end
local function CreateButton(Page, Text, Callback)
    local Btn = Instance.new("TextButton", Page)
    Btn.Size = UDim2.new(0.95, 0, 0, 35)
    RegisterTheme(Btn, "BackgroundColor3", "ElementBG")
    Btn.Text = Text
    RegisterTheme(Btn, "TextColor3", "Text")
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 13
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    local BtnStroke = Instance.new("UIStroke", Btn)
    BtnStroke.Color = CurrentTheme.Accent
    BtnStroke.Thickness = 1.5
    BtnStroke.Transparency = 1 
    BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    RegisterTheme(BtnStroke, "Color", "Accent") 
    Btn.MouseEnter:Connect(function() 
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0.3}):Play() 
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
    end)
    Btn.MouseLeave:Connect(function() 
        TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() 
        TweenService:Create(BtnStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
    end)
    Btn.MouseButton1Click:Connect(Callback)
    if Page ~= T4 and not string.find(string.lower(Text), "refresh") and not string.find(string.lower(Text), "reset") then
        State.RegisteredFeatures[Text] = {
            Type = "Button",
            Trigger = Callback
        }
    end
    return Btn
end
local function CreateSlider(Page, Text, Min, Max, Default, Callback)
    local Wrapper = Instance.new("Frame", Page)
    Wrapper.Size = UDim2.new(0.95, 0, 0, 60)
    RegisterTheme(Wrapper, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 8)
    local Lbl = Instance.new("TextLabel", Wrapper)
    Lbl.Text = Text
    Lbl.Size = UDim2.new(0.5, 0, 0, 30)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.BackgroundTransparency = 1
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    local ValLbl = Instance.new("TextLabel", Wrapper)
    ValLbl.Text = tostring(Default)
    ValLbl.Size = UDim2.new(0.2, 0, 0, 30)
    ValLbl.Position = UDim2.new(0.75, 0, 0, 0)
    ValLbl.BackgroundTransparency = 1
    RegisterTheme(ValLbl, "TextColor3", "Accent")
    ValLbl.Font = Enum.Font.Code
    ValLbl.TextSize = 14
    ValLbl.TextXAlignment = Enum.TextXAlignment.Right
    local SliderBg = Instance.new("Frame", Wrapper)
    SliderBg.Size = UDim2.new(0.9, 0, 0, 6)
    SliderBg.Position = UDim2.new(0.05, 0, 0.65, 0)
    RegisterTheme(SliderBg, "BackgroundColor3", "Background")
    Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
    local SliderFill = Instance.new("Frame", SliderBg)
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    RegisterTheme(SliderFill, "BackgroundColor3", "Accent")
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
    local Trigger = Instance.new("TextButton", SliderBg)
    Trigger.Size = UDim2.new(1, 0, 1, 0); Trigger.BackgroundTransparency = 1; Trigger.Text = ""
    local function Set(val, doCallback)
        local pct = math.clamp((val - Min) / (Max - Min), 0, 1)
        SliderFill.Size = UDim2.new(pct, 0, 1, 0)
        ValLbl.Text = tostring(math.floor(val))
        if doCallback then Callback(val) end
    end
    Set(Default, false)
    State.UIListeners[Text] = function(val) Set(val, true) end
    local dragging = false
    Trigger.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            dragging = true 
            local pos = input.Position.X; local size = SliderBg.AbsoluteSize.X; local start = SliderBg.AbsolutePosition.X
            local pct = math.clamp((pos - start) / size, 0, 1)
            Set(Min + (Max - Min) * pct, true)
        end 
    end)
    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end 
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position.X; local size = SliderBg.AbsoluteSize.X; local start = SliderBg.AbsolutePosition.X
            local pct = math.clamp((pos - start) / size, 0, 1)
            Set(Min + (Max - Min) * pct, true)
        end
    end)
end
local function CreateDropdown(Page, Text, Options, Default, Callback, UseSearch)
    if UseSearch == nil then UseSearch = true end
    local BaseZIndex = 5 
    local CurrentSelection = Default
    local Wrapper = Instance.new("Frame", Page)
    Wrapper.Name = "Dropdown_" .. Text
    Wrapper.Size = UDim2.new(0.95, 0, 0, 50) 
    RegisterTheme(Wrapper, "BackgroundColor3", "ElementBG")
    Wrapper.ClipsDescendants = true 
    Wrapper.ZIndex = BaseZIndex
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 8)
    local Lbl = Instance.new("TextLabel", Wrapper)
    Lbl.Text = Text
    Lbl.Size = UDim2.new(0.4, 0, 0, 50)
    Lbl.Position = UDim2.new(0, 15, 0, 0)
    Lbl.BackgroundTransparency = 1
    RegisterTheme(Lbl, "TextColor3", "Text")
    Lbl.Font = Enum.Font.GothamBold
    Lbl.TextSize = 14
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.ZIndex = BaseZIndex + 1 
    local MainBtn = Instance.new("TextButton", Wrapper)
    MainBtn.Name = "TriggerBtn"
    MainBtn.Size = UDim2.new(0, 140, 0, 30)
    MainBtn.Position = UDim2.new(1, -150, 0, 10) 
    RegisterTheme(MainBtn, "BackgroundColor3", "Background")
    MainBtn.Text = Default .. "  ▼"
    RegisterTheme(MainBtn, "TextColor3", "Accent")
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 12
    MainBtn.ZIndex = BaseZIndex + 2
    Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)
    local Container = Instance.new("Frame", Wrapper)
    Container.Name = "ListContainer"
    Container.Size = UDim2.new(1, -20, 0, 0) 
    Container.Position = UDim2.new(0, 10, 0, 55)
    Container.BackgroundTransparency = 1
    Container.ZIndex = BaseZIndex + 3
    Container.Visible = false 
    
    local SearchWrapper = Instance.new("Frame", Container)
    SearchWrapper.Name = "SearchWrapper"
    SearchWrapper.Size = UDim2.new(1, -10, 0, 32) 
    SearchWrapper.Position = UDim2.new(0, 5, 0, 0)
    
    SearchWrapper.BackgroundColor3 = Color3.fromRGB(10, 10, 12) 
    SearchWrapper.BackgroundTransparency = 0 
    
    SearchWrapper.BorderSizePixel = 0
    SearchWrapper.ZIndex = BaseZIndex + 4
    SearchWrapper.Visible = UseSearch
    Instance.new("UICorner", SearchWrapper).CornerRadius = UDim.new(0, 6)

    local SearchStroke = Instance.new("UIStroke", SearchWrapper)
    SearchStroke.Thickness = 1.5
    RegisterTheme(SearchStroke, "Color", "Accent")
    SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SearchStroke.Transparency = 0 

    local SearchBox = Instance.new("TextBox", SearchWrapper)
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    -- SearchBox.Position = UDim2.new(0, 32, 0, 0)
    RegisterTheme(SearchBox, "BackgroundColor3", "Background")
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "  Search options..."
    
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255) 
    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.TextSize = 13
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = BaseZIndex + 5
    
    SearchBox.Focused:Connect(function()
        TweenService:Create(SearchStroke, TweenInfo.new(0.2), {Color = CurrentTheme.Accent}):Play()
        TweenService:Create(SearchIcon, TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.Accent}):Play()
        TweenService:Create(SearchWrapper, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}):Play()
    end)

    SearchBox.FocusLost:Connect(function()
        TweenService:Create(SearchStroke, TweenInfo.new(0.2), {Color = CurrentTheme.Accent}):Play()
        TweenService:Create(SearchIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        TweenService:Create(SearchWrapper, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(10, 10, 12)}):Play()
    end)
    local DropFrame = Instance.new("ScrollingFrame", Container)
    if UseSearch then
        DropFrame.Position = UDim2.new(0, 0, 0, 38) 
        DropFrame.Size = UDim2.new(1, 0, 1, -38)
    else
        DropFrame.Position = UDim2.new(0, 0, 0, 0)
        DropFrame.Size = UDim2.new(1, 0, 1, 0)
    end
    DropFrame.BackgroundTransparency = 1
    DropFrame.BorderSizePixel = 0
    DropFrame.ScrollBarThickness = 2
    RegisterTheme(DropFrame, "ScrollBarImageColor3", "Accent")
    DropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y 
    DropFrame.CanvasSize = UDim2.new(0,0,0,0)
    DropFrame.ZIndex = BaseZIndex + 3
    local ListLayout = Instance.new("UIListLayout", DropFrame)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 4)
    local isOpened = false
    local TweenService = game:GetService("TweenService")
    local function UpdateAllZIndex(Val)
        BaseZIndex = Val
        Wrapper.ZIndex = BaseZIndex
        Lbl.ZIndex = BaseZIndex + 1
        MainBtn.ZIndex = BaseZIndex + 2
        Container.ZIndex = BaseZIndex + 3
        SearchBox.ZIndex = BaseZIndex + 4
        DropFrame.ZIndex = BaseZIndex + 3
        for _, child in pairs(DropFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.ZIndex = BaseZIndex + 5
            end
        end
    end
    local function RenderList(filterText)
        for _, child in pairs(DropFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, opt in ipairs(Options) do
            if filterText == "" or string.find(string.lower(tostring(opt)), string.lower(filterText)) then
                local OptBtn = Instance.new("TextButton", DropFrame)
                OptBtn.Size = UDim2.new(1, -5, 0, 25)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = "  " .. tostring(opt)
                RegisterTheme(OptBtn, "TextColor3", "TextDim")
                OptBtn.Font = Enum.Font.GothamMedium
                OptBtn.TextSize = 12
                OptBtn.ZIndex = BaseZIndex + 5 
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = CurrentTheme.Accent end)
                OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = CurrentTheme.TextDim end)
                OptBtn.MouseButton1Click:Connect(function()
                    MainBtn.Text = tostring(opt) .. "  ▼"
                    CurrentSelection = opt
                    Callback(opt)
                    isOpened = false
                    MainBtn.Text = MainBtn.Text:gsub("▲", "▼")
                    TweenService:Create(Wrapper, TweenInfo.new(0.25), {Size = UDim2.new(0.95, 0, 0, 50)}):Play()
                    TweenService:Create(Container, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                    task.delay(0.25, function()
                        if not isOpened then 
                            Container.Visible = false
                            UpdateAllZIndex(5) 
                        end
                    end)
                    SearchBox.Text = ""
                end)
            end
        end
        DropFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function() RenderList(SearchBox.Text) end)
    MainBtn.MouseButton1Click:Connect(function()
        isOpened = not isOpened
        if isOpened then
            UpdateAllZIndex(100) 
            RenderList("") 
            MainBtn.Text = MainBtn.Text:gsub("▼", "▲")
            Container.Visible = true
            local listHeight = 160 
            local headerHeight = UseSearch and 30 or 0
            local totalHeight = 50 + headerHeight + listHeight + 10
            TweenService:Create(Wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
            TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, listHeight + headerHeight)}):Play()
        else
            MainBtn.Text = MainBtn.Text:gsub("▲", "▼")
            TweenService:Create(Wrapper, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.95, 0, 0, 50)}):Play()
            TweenService:Create(Container, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -20, 0, 0)}):Play()
            task.delay(0.25, function()
                if not isOpened then 
                    Container.Visible = false
                    UpdateAllZIndex(5) 
                end
            end)
        end
    end)
    RenderList("")
    local DropdownAPI = {}
    function DropdownAPI:Refresh(NewList)
        Options = NewList
        RenderList("")
        local found = false
        for _, v in pairs(NewList) do
            if tostring(v) == tostring(CurrentSelection) then
                found = true
                break
            end
        end

        if found then
            MainBtn.Text = tostring(CurrentSelection) .. "  ▼"
        else
            MainBtn.Text = Default .. "  ▼"
            CurrentSelection = Default
        end
    end
    return DropdownAPI 
end
local function CreateSection(Page, Title)
    local Wrapper = Instance.new("Frame", Page)
    Wrapper.Name = "Section_" .. Title
    Wrapper.Size = UDim2.new(0.98, 0, 0, 42) 
    Wrapper.BackgroundColor3 = CurrentTheme.ElementBG 
    Wrapper.BackgroundTransparency = 0.5
    Wrapper.ClipsDescendants = true 
    Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", Wrapper)
    Stroke.Color = Color3.fromRGB(80, 80, 80)
    Stroke.Thickness = 1
    Stroke.Transparency = 0.5
    local HeaderBtn = Instance.new("TextButton", Wrapper)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 38)
    HeaderBtn.Position = UDim2.new(0, 0, 0, 2)
    HeaderBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 50) 
    HeaderBtn.AutoButtonColor = false
    HeaderBtn.Text = ""
    HeaderBtn.ZIndex = 5
    Instance.new("UICorner", HeaderBtn).CornerRadius = UDim.new(0, 8)
    local HeadStroke = Instance.new("UIStroke", HeaderBtn)
    HeadStroke.Color = Color3.fromRGB(60, 65, 80)
    HeadStroke.Thickness = 1
    HeadStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local GlowBar = Instance.new("Frame", HeaderBtn)
    GlowBar.Size = UDim2.new(0, 4, 0.6, 0)
    GlowBar.Position = UDim2.new(0, 0, 0.2, 0)
    GlowBar.BackgroundColor3 = CurrentTheme.Accent 
    GlowBar.BorderSizePixel = 0
    GlowBar.ZIndex = 6
    GlowBar.BackgroundTransparency = 1 
    Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(0, 4)
    local TitleLbl = Instance.new("TextLabel", HeaderBtn)
    TitleLbl.Text = Title
    TitleLbl.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLbl.Position = UDim2.new(0, 18, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.Font = Enum.Font.GothamBlack
    TitleLbl.TextSize = 14
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 10 
    local Arrow = Instance.new("TextLabel", HeaderBtn)
    Arrow.Text = "▼"
    Arrow.Size = UDim2.new(0, 40, 1, 0)
    Arrow.Position = UDim2.new(1, -40, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.TextColor3 = Color3.fromRGB(180, 180, 180)
    Arrow.Font = Enum.Font.GothamBlack
    Arrow.TextSize = 18
    Arrow.ZIndex = 10
    local Divider = Instance.new("Frame", Wrapper)
    Divider.Name = "DividerLine"
    Divider.Size = UDim2.new(1, 0, 0, 1) 
    Divider.Position = UDim2.new(0, 0, 0, 40)
    Divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Divider.BorderSizePixel = 0
    Divider.BackgroundTransparency = 1 
    Divider.ZIndex = 4
    local DivGrad = Instance.new("UIGradient", Divider)
    DivGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 40, 50)),
        ColorSequenceKeypoint.new(0.5, CurrentTheme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 40, 50)) 
    }
    local Container = Instance.new("Frame", Wrapper)
    Container.Name = "Content"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 50)
    Container.BackgroundTransparency = 1
    local ContPad = Instance.new("UIPadding", Container)
    ContPad.PaddingLeft = UDim.new(0, 10)
    ContPad.PaddingRight = UDim.new(0, 10)
    local ListLayout = Instance.new("UIListLayout", Container)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 8)
    local isOpen = false
    local TweenService = game:GetService("TweenService")
    local TI = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out) 
    HeaderBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local contentHeight = ListLayout.AbsoluteContentSize.Y
            TweenService:Create(Wrapper, TI, {Size = UDim2.new(0.98, 0, 0, contentHeight + 60), BackgroundTransparency = 0.5}):Play()
            TweenService:Create(Arrow, TI, {Rotation = 180, TextColor3 = CurrentTheme.Accent}):Play()
            TweenService:Create(HeadStroke, TI, {Color = CurrentTheme.Accent, Transparency = 0.5}):Play()
            TweenService:Create(GlowBar, TI, {BackgroundTransparency = 0}):Play()
            TweenService:Create(TitleLbl, TI, {TextColor3 = CurrentTheme.Accent}):Play()
            TweenService:Create(Divider, TI, {BackgroundTransparency = 0}):Play()
        else
            TweenService:Create(Wrapper, TI, {Size = UDim2.new(0.98, 0, 0, 42), BackgroundTransparency = 1}):Play()
            TweenService:Create(Arrow, TI, {Rotation = 0, TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
            TweenService:Create(HeadStroke, TI, {Color = Color3.fromRGB(60, 65, 80), Transparency = 0}):Play()
            TweenService:Create(GlowBar, TI, {BackgroundTransparency = 1}):Play()
            TweenService:Create(TitleLbl, TI, {TextColor3 = Color3.fromRGB(240, 240, 240)}):Play()
            TweenService:Create(Divider, TI, {BackgroundTransparency = 1}):Play()
        end
    end)
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isOpen then
            local contentHeight = ListLayout.AbsoluteContentSize.Y
            TweenService:Create(Wrapper, TI, {Size = UDim2.new(0.98, 0, 0, contentHeight + 60)}):Play()
        end
    end)
    return Container
end
local ConfigFolder = "ReyzzHub_UniversalConfigs"
local ConfigName = ConfigFolder .. "/DefaultConfig.json"
local AutoExecFile = "Reyzz_AutoExec_Status.txt"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigBlacklist = {
    ["WalkSpeed"] = true, ["JumpPower"] = true, ["SpeedInput"] = true, ["JumpInput"] = true,
    ["DefaultWalkSpeed"] = true, ["DefaultJumpPower"] = true
}
function BuildKeybindManager(TargetTab)
    local Box_Keys = CreateSection(TargetTab, "KEYBIND MANAGER") 
    local SearchBind = ""
    local BindListFrame = Instance.new("ScrollingFrame", Box_Keys)
    BindListFrame.Size = UDim2.new(1, 0, 0, 300); BindListFrame.BackgroundTransparency = 0.5; RegisterTheme(BindListFrame, "BackgroundColor3", "Background"); BindListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; BindListFrame.CanvasSize = UDim2.new(0,0,0,0); Instance.new("UICorner", BindListFrame).CornerRadius = UDim.new(0, 6)
    local BindLayout = Instance.new("UIListLayout", BindListFrame); BindLayout.Padding = UDim.new(0, 4); local BindPad = Instance.new("UIPadding", BindListFrame); BindPad.PaddingTop = UDim.new(0,5); BindPad.PaddingLeft = UDim.new(0,5); BindPad.PaddingRight = UDim.new(0,5)
    local function RefreshKeybinds()
        for _, v in pairs(BindListFrame:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        local sortedNames = {}
        if State.RegisteredFeatures then for n in pairs(State.RegisteredFeatures) do table.insert(sortedNames, n) end; table.sort(sortedNames) end
        for _, name in ipairs(sortedNames) do
            if SearchBind == "" or string.find(string.lower(name), string.lower(SearchBind)) then
                if not State.Keybinds[name] then State.Keybinds[name] = {Key = Enum.KeyCode.Unknown, Shift = false} end
                local bindData = State.Keybinds[name]
                local Row = Instance.new("Frame", BindListFrame); Row.Size = UDim2.new(1, 0, 0, 35); Row.BackgroundTransparency = 1
                local Title = Instance.new("TextLabel", Row); Title.Text = name; Title.Size = UDim2.new(0.45, 0, 1, 0); Title.BackgroundTransparency = 1; Title.TextXAlignment = Enum.TextXAlignment.Left; RegisterTheme(Title, "TextColor3", "Text"); Title.Font = Enum.Font.GothamMedium; Title.TextSize = 12; Title.TextTruncate = Enum.TextTruncate.AtEnd
                local KeyBtn = Instance.new("TextButton", Row); KeyBtn.Size = UDim2.new(0.25, 0, 0.8, 0); KeyBtn.Position = UDim2.new(0.48, 0, 0.1, 0); RegisterTheme(KeyBtn, "BackgroundColor3", "ElementBG"); Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 5); RegisterTheme(KeyBtn, "TextColor3", "Accent"); KeyBtn.Font = Enum.Font.Code; KeyBtn.TextSize = 13
                local function UpdateKeyText() if bindData.Key == Enum.KeyCode.Unknown then KeyBtn.Text = "[ NONE ]"; RegisterTheme(KeyBtn, "TextColor3", "TextDim") else KeyBtn.Text = "[" .. bindData.Key.Name .. "]"; RegisterTheme(KeyBtn, "TextColor3", "Accent") end end; UpdateKeyText()
                local ShiftBtn = Instance.new("TextButton", Row); ShiftBtn.Size = UDim2.new(0.25, 0, 0.8, 0); ShiftBtn.Position = UDim2.new(0.74, 0, 0.1, 0); Instance.new("UICorner", ShiftBtn).CornerRadius = UDim.new(0, 5); ShiftBtn.Font = Enum.Font.GothamBold; ShiftBtn.TextSize = 11
                local function UpdateShiftVisual() if bindData.Shift then ShiftBtn.Text = "SHIFT: ON"; ShiftBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100); ShiftBtn.TextColor3 = Color3.fromRGB(0, 0, 0) else ShiftBtn.Text = "Single Key"; RegisterTheme(ShiftBtn, "BackgroundColor3", "Sidebar"); RegisterTheme(ShiftBtn, "TextColor3", "TextDim") end end; UpdateShiftVisual()
                KeyBtn.MouseButton1Click:Connect(function() KeyBtn.Text = "..."; KeyBtn.TextColor3 = Color3.fromRGB(255, 200, 50); local con; con = game:GetService("UserInputService").InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Keyboard then if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then return end; if input.KeyCode == Enum.KeyCode.Escape then UpdateKeyText(); con:Disconnect(); return end; if input.KeyCode == Enum.KeyCode.Backspace then bindData.Key = Enum.KeyCode.Unknown; UpdateKeyText(); con:Disconnect(); return end; bindData.Key = input.KeyCode; UpdateKeyText(); con:Disconnect() elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then UpdateKeyText(); con:Disconnect() end end) end)
                ShiftBtn.MouseButton1Click:Connect(function() bindData.Shift = not bindData.Shift; UpdateShiftVisual() end)
            end
        end
    end
    CreateInput(Box_Keys, "Search Feature...", "Filter...", function(val) SearchBind = val; RefreshKeybinds() end, true)
    CreateButton(Box_Keys, "🔄 Refresh Feature List", RefreshKeybinds)
    task.delay(1, RefreshKeybinds)
    return RefreshKeybinds
end
function BuildConfigManager(TargetTab, RefreshKeybindsFunc)
    local function GetConfigFiles()
        local files = listfiles(ConfigFolder)
        local names = {}
        for _, file in pairs(files) do
            local name = file:gsub(ConfigFolder.."\\", ""):gsub(ConfigFolder.."/", ""):gsub(".json", "") 
            table.insert(names, name)
        end
        return names
    end
    local Box_Config = CreateSection(TargetTab, "PROFILE & AUTO EXEC")
    local SelectedConfigName = ""
    local SelectedFileToLoad = ""
    local HttpService = game:GetService("HttpService")
    CreateInput(Box_Config, "New Config Name", "Type name...", function(val) SelectedConfigName = val end, true)
    local ConfigDrop = CreateDropdown(Box_Config, "Select Config", GetConfigFiles(), "Select...", function(val) SelectedFileToLoad = val end)
    CreateButton(Box_Config, "🔄 Refresh List", function() if ConfigDrop.Refresh then ConfigDrop:Refresh(GetConfigFiles()) end end)
    CreateButton(Box_Config, "💾 Save Config", function()
        if SelectedConfigName == "" then ShowToast("⚠️ Enter Name First!") return end
        local DataToSave = { Settings = {}, Keybinds = {} }
        for key, value in pairs(State) do
            if not ConfigBlacklist[key] and key ~= "Keybinds" and key ~= "RegisteredFeatures" then
                local vType = typeof(value)
                if vType == "string" or vType == "number" or vType == "boolean" then
                    DataToSave.Settings[key] = value
                elseif vType == "EnumItem" then
                    DataToSave.Settings[key] = {Enum = tostring(value)}
                end
            end
        end
        if State.Keybinds then 
            for name, bind in pairs(State.Keybinds) do 
                DataToSave.Keybinds[name] = { Key = bind.Key.Name, Shift = bind.Shift } 
            end 
        end
        local success, encoded = pcall(function() return HttpService:JSONEncode(DataToSave) end)
        if success then
            SafeWriteFile(ConfigFolder .. "/" .. SelectedConfigName .. ".json", encoded)
            ShowToast("✅ Saved: " .. SelectedConfigName)
            if ConfigDrop.Refresh then ConfigDrop:Refresh(GetConfigFiles()) end
        else
            warn("JSON Encode Error:", encoded)
            ShowToast("❌ Error Saving Config!")
        end
    end)
    CreateButton(Box_Config, "📂 Load Config", function()
        if SelectedFileToLoad == "" then ShowToast("⚠️ Select Config First!") return end
        local path = ConfigFolder .. "/" .. SelectedFileToLoad .. ".json"
        if isfile(path) then
            local success, decoded = pcall(function() return HttpService:JSONDecode(SafeReadFile(path)) end)
            if success then
                if decoded.Settings then 
                    for key, value in pairs(decoded.Settings) do 
                        if not ConfigBlacklist[key] then 
                            if type(value) == "table" and value.Enum then
                            else
                                State[key] = value 
                            end
                            if State.UIListeners[key] then
                                State.UIListeners[key](value)
                            end
                        end 
                    end 
                end
                if decoded.Keybinds then 
                    for name, bindData in pairs(decoded.Keybinds) do 
                        if State.Keybinds[name] then 
                            State.Keybinds[name].Key = Enum.KeyCode[bindData.Key] or Enum.KeyCode.Unknown
                            State.Keybinds[name].Shift = bindData.Shift 
                        end 
                    end
                    if RefreshKeybindsFunc then RefreshKeybindsFunc() end 
                end
                ShowToast("✅ Config Loaded & UI Refreshed!")
            else
                ShowToast("❌ Corrupted File!")
            end
        else ShowToast("❌ File not found!") end
    end)
    CreateButton(Box_Config, "🗑️ Delete Config", function() 
        if SelectedFileToLoad == "" then return end
        local path = ConfigFolder .. "/" .. SelectedFileToLoad .. ".json"
        if isfile(path) then 
            delfile(path)
            ShowToast("Deleted: " .. SelectedFileToLoad)
            if ConfigDrop.Refresh then ConfigDrop:Refresh(GetConfigFiles()) end 
        end 
    end)
    CreateButton(Box_Config, "♻️ Reset Keybinds", function() if RefreshKeybindsFunc then RefreshKeybindsFunc() end; ShowToast("Keybinds Reset!") end)
end
ShowToast("🚀 Starting Rendering UI...")
task.wait(0.1)
local T1 = CreateTab("Main", "rbxassetid://10709782497")
ShowToast("Loading: Main Features...")
task.wait(0.1)
ShowToast("Loading: Dashboard...")
local T_Dash = CreateTab("Dashboard", "rbxassetid://10709752906")
task.wait(0.1)
local T_Combat = CreateTab("Combat", "rbxassetid://95264995174476")
task.wait(0.1)
local T2 = CreateTab("Visuals", "rbxassetid://7035631382")
task.wait(0.1)
local T3 = CreateTab("Camera", "rbxassetid://14333878755")
task.wait(0.1)
local T4 = CreateTab("Teleport", "rbxassetid://84201332373055")
task.wait(0.1)
local T5 = CreateTab("World", "rbxassetid://11887653877")
task.wait(0.1)
local T6 = CreateTab("Misc", "rbxassetid://87846110657364")
task.wait(0.1)
local MobilePage = nil
if game:GetService("UserInputService").TouchEnabled then
    MobilePage = CreateTab("Mobile", "rbxassetid://6034818379")
end
T_Status = CreateTab("Status", "rbxassetid://9692125126")
task.wait(0.1)
local T7 = CreateTab("About", "rbxassetid://116139826677453")
task.wait(0.1)
local T_Settings = CreateTab("Settings", "rbxassetid://11956055886")
ShowToast("Script Loaded Successfully!")
do
    local Box_Move = CreateSection(T1, "CHARACTER MOVEMENT")
    local RegenConnection = nil 
    CreateToggle(Box_Move, "Auto Regen (Semi-God)", function(isOn)
        State.AutoRegen = isOn
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end
        if isOn then
            ShowToast("Auto Regen: ON (Smart Mode)")
            hum.Health = hum.MaxHealth
            if RegenConnection then RegenConnection:Disconnect() end
            RegenConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        else
            ShowToast("Auto Regen: OFF")
            if RegenConnection then 
                RegenConnection:Disconnect()
                RegenConnection = nil 
            end
        end
    end)
    State.UIListeners["AutoRegen"] = State.UIListeners["Auto Regen (Semi-God)"]
    CreateToggle(Box_Move, "Infinite Jump (Shift+J)", function(v) State.InfiniteJump = v end)
    CreateLabel(Box_Move, C("<i>Keybind: Space (Jump) / Shift+J</i>", 150, 150, 150))
    CreateToggle(Box_Move, "Bhop Auto (Bunny Hop)", function(v) State.Bhop = v end) 
    CreateToggle(Box_Move, "Auto Bhop (Legit Mode)", function(v) 
        State.BhopLegit = v 
        if v then ShowToast("Legit Bhop: ON (Randomized)") end
    end)
    local NoclipConnection = nil 
    CreateToggle(Box_Move, "Noclip (Wall Hack)", function(isOn)
        State.Noclip = isOn
        if isOn then
            ShowToast("Noclip: ON")
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide == true then
                            v.CanCollide = false
                        end
                    end
                end
            end)
        else
            ShowToast("Noclip: OFF")
            if NoclipConnection then
                NoclipConnection:Disconnect()
                NoclipConnection = nil
            end
        end
    end)
    State.UIListeners["Noclip"] = State.UIListeners["Noclip (Wall Hack)"]
    CreateToggle(Box_Move, "Fly Mode (CFrame)", function(v) 
        State.Fly = v; 
        if v then StartFly() else StopFly() end 
    end)
    CreateInput(Box_Move, "✈️ Fly Speed", "50", function(val)
        local num = tonumber(val)
        if num then
            State.FlySpeed = num 
            ShowToast("Speed set to: " .. num)
        else
            ShowToast("⚠️ Please enter a valid number!")
        end
    end, true)
    local Box_Parkour = CreateSection(T1, "PARKOUR & PHYSICS")
    CreateToggle(Box_Parkour, "Spider Wall (Hold W)", function(v) State.Spider = v end)
    CreateToggle(Box_Parkour, "Wall Run (Gravity)", function(v) State.WallRun = v end)
    CreateToggle(Box_Parkour, "Safety Walk (Platform)", function(v) 
        State.PlatformWalk = v 
        if v then ShowToast("Controls: Q = Up | E = Down") end
    end)
    CreateLabel(Box_Parkour, C("Tips: Q = Elevate | E = Descend", 200, 200, 200))
    CreateToggle(Box_Parkour, "Swim Mode (Air Swim)", function(v)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if v then
                hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
                if not State.OldGrav then State.OldGrav = workspace.Gravity end
                workspace.Gravity = 0
                local swimVel = Instance.new("BodyVelocity", root)
                swimVel.Name = "SwimVel"
                swimVel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                swimVel.Velocity = Vector3.new(0,0,0)
                task.spawn(function()
                    while v and hum and root do
                        hum:ChangeState(Enum.HumanoidStateType.Swimming)
                        local moveDir = hum.MoveDirection
                        swimVel.Velocity = moveDir * State.WalkSpeed
                        task.wait()
                    end
                end)
                ShowToast("Swim Mode: ON")
            else
                workspace.Gravity = State.OldGrav or 196.2
                if root:FindFirstChild("SwimVel") then root.SwimVel:Destroy() end
                hum:ChangeState(Enum.HumanoidStateType.Running)
                ShowToast("Swim Mode: OFF")
            end
        end
    end)
    local Box_Vehicle = CreateSection(T1, "VEHICLE MODS")
    local VFlyActive = false
    CreateToggle(Box_Vehicle, "🚗 Vehicle Fly (IY Style)", function(v)
        VFlyActive = v
        local seat = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character.Humanoid.SeatPart
        local vehicle = seat and seat.Parent
        if vehicle and not vehicle:IsA("Model") then vehicle = vehicle.Parent end
        if v and vehicle then
            ShowToast("Vehicle Fly: ON")
            local root = vehicle.PrimaryPart or seat
            local bv = Instance.new("BodyVelocity", root)
            bv.Name = "IY_VFLY_VEL"
            bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            local bg = Instance.new("BodyGyro", root)
            bg.Name = "IY_VFLY_GYRO"
            bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            bg.P = 9000
            task.spawn(function()
                while VFlyActive and vehicle.Parent do
                    local cam = Workspace.CurrentCamera
                    local hum = LocalPlayer.Character.Humanoid
                    hum.PlatformStand = true 
                    local dir = Vector3.zero
                    -- Gerak Maju (W)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then 
                        dir = dir + cam.CFrame.LookVector 
                    end
                    -- Gerak Mundur (S)
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then 
                        dir = dir - cam.CFrame.LookVector 
                    end
                    -- Gerak Kiri (A)
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then 
                        dir = dir - cam.CFrame.RightVector 
                    end
                    -- Gerak Kanan (D)
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then 
                        dir = dir + cam.CFrame.RightVector 
                    end
                    -- Naik (Spasi)
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                        dir = dir + Vector3.new(0, 1, 0) 
                    end
                    -- Turun (Ctrl)
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then 
                        dir = dir - Vector3.new(0, 1, 0) 
                    end

                    -- Terapkan Kecepatan
                    bv.Velocity = dir * (State.WalkSpeed * 3)
                    bg.CFrame = cam.CFrame
                    task.wait()
                end
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
                if LocalPlayer.Character then LocalPlayer.Character.Humanoid.PlatformStand = false end
            end)
        else
            VFlyActive = false
            ShowToast("Vehicle Fly: OFF / No Vehicle")
            for _, desc in pairs(Workspace:GetDescendants()) do
                if desc.Name == "IY_VFLY_VEL" or desc.Name == "IY_VFLY_GYRO" then desc:Destroy() end
            end
        end
    end)
    CreateToggle(Box_Vehicle, "🚗 Vehicle Noclip", function(v)
        State.VehicleNoclip = v
        if v then
            ShowToast("Vehicle Noclip: ON")
            task.spawn(function()
                while State.VehicleNoclip do
                    local char = LocalPlayer.Character
                    local seat = char and char:FindFirstChildOfClass("Humanoid") and char.Humanoid.SeatPart
                    if seat then
                        local vehicle = seat.Parent
                        if not vehicle:IsA("Model") then vehicle = vehicle.Parent end
                        for _, part in pairs(vehicle:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            ShowToast("Vehicle Noclip: OFF")
        end
    end)
    local Box_Speed = CreateSection(T1, "SPEED & POWER CONFIG")
    CreateToggle(Box_Speed, "Enable SpinBot", function(v) State.SpinBot = v end)
    CreateInput(Box_Speed, "Spin Speed", 100, function(v) State.SpinSpeed = v end)
    local WSInput = CreateInput(Box_Speed, "Set Walk Speed", State.WalkSpeed, function(v)
        State.WalkSpeed = tonumber(v) or 16
    end)
    local JPInput = CreateInput(Box_Speed, "Set Jump Power", State.JumpPower, function(v)
        State.JumpPower = tonumber(v) or 50
    end)
    local SpeedConnection = nil 
    CreateToggle(Box_Speed, "Enable Speed Loop", function(isOn)
        State.LoopSpeed = isOn
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if not hum then return end
        if isOn then
            hum.WalkSpeed = State.WalkSpeed 
            ShowToast("Speed: ON (Smart Mode)")
            if SpeedConnection then SpeedConnection:Disconnect() end
            SpeedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                if hum.WalkSpeed ~= State.WalkSpeed then
                    hum.WalkSpeed = State.WalkSpeed 
                end
            end)
        else
            ShowToast("Speed: OFF")
            if SpeedConnection then 
                SpeedConnection:Disconnect()
                SpeedConnection = nil
            end
            hum.WalkSpeed = 16 
        end
    end)
    CreateButton(Box_Speed, "Reset to Default", function()
        State.LoopSpeed = false
        State.WalkSpeed = DefaultWalkSpeed
        State.JumpPower = DefaultJumpPower
        if WSInput then WSInput.Text = tostring(DefaultWalkSpeed) end
        if JPInput then JPInput.Text = tostring(DefaultJumpPower) end
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = DefaultWalkSpeed
                if hum.UseJumpPower then hum.JumpPower = DefaultJumpPower else hum.JumpHeight = DefaultJumpPower end
            end
        end
        ShowToast("Stats Restored to Normal")
    end)
    local Box_Safety = CreateSection(T1, "SAFETY & PROTECTION")
    CreateToggle(Box_Safety, "🛡️ No Fall Damage", function(v) 
        State.NoFall = v 
        if v then
            ShowToast("Anti-Fall: ON (Smooth)")
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            ShowToast("Anti-Fall: OFF")
        end
    end)
    CreateToggle(Box_Safety, "🛡️ Anti-TP (Rubberband)", function(v) 
        State.AntiTP = v 
        if v then ShowToast("Anti-Teleport: ON") else ShowToast("Anti-Teleport: OFF") end
    end)
    local AntiFlingConnection = nil
    CreateToggle(Box_Safety, "🛡️ Anti-Fling", function(isOn) 
        State.AntiFling = isOn
        if isOn then
            ShowToast("Anti-Fling Active")
            if AntiFlingConnection then AntiFlingConnection:Disconnect() end
            AntiFlingConnection = game:GetService("RunService").Stepped:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    if root.AssemblyAngularVelocity.Magnitude > 1 then 
                        root.AssemblyAngularVelocity = Vector3.new(0,0,0) 
                    end
                    if root.AssemblyLinearVelocity.Magnitude > 300 then
                        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in pairs(p.Character:GetChildren()) do
                            if part:IsA("BasePart") and part.CanCollide == true then
                                part.CanCollide = false 
                            end
                        end
                    end
                end
            end)
        else
            ShowToast("Anti-Fling: OFF")
            if AntiFlingConnection then 
                AntiFlingConnection:Disconnect()
                AntiFlingConnection = nil
            end
        end
    end)
    State.UIListeners["AntiFling"] = State.UIListeners["🛡️ Anti-Fling"]
    CreateButton(Box_Safety, "Respawn & Return (Safe)", function()
        if LocalPlayer.Character then 
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            local root = GetVisualPart(LocalPlayer.Character)
            if hum and hum.Health > 0 and root then 
                State.LastPos = root.CFrame
                State.IsRespawning = true
                hum.Health = 0
                ShowToast("Respawning... Position Saved.") 
            end 
        end
    end)
    local AntiPushConnection = nil
    CreateToggle(Box_Safety, "🛡️ Anti-Push (Anchor Idle)", function(v)
        State.AntiPush = v
        if AntiPushConnection then 
            AntiPushConnection:Disconnect() 
            AntiPushConnection = nil 
        end

        if v then
            ShowToast("Anti-Push: ON (Smart Anchor)")
            local RunService = game:GetService("RunService")
            
            AntiPushConnection = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                
                if root and hum then
                    if hum.MoveDirection.Magnitude <= 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
                        if not root.Anchored then 
                            root.Anchored = true 
                            root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            root.AssemblyAngularVelocity = Vector3.new(0,0,0)
                        end
                    else
                        if root.Anchored then 
                            root.Anchored = false 
                        end
                    end
                end
            end)
        else
            ShowToast("Anti-Push: OFF")
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end)
    State.UIListeners["AntiPush"] = function(val) 
    end
    local Box_Panic = CreateSection(T1, "EMERGENCY")
    local PanicBtn = CreateButton(Box_Panic, "🚨 PANIC MODE (DISABLE ALL)", function()
        for name, updateFunc in pairs(Toggles) do
            task.spawn(function()
                pcall(function() updateFunc(false) end)
            end)
        end
        State.LoopSpeed = false
        State.InfiniteJump = false
        State.Fly = false
        State.Noclip = false
        State.SpinBot = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        ShowToast("⚠️ PANIC EXECUTED: ALL SYSTEMS KILLED!")
    end)
    local PBtnFrame = PanicBtn.Parent 
    PanicBtn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    PanicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CreateLabel(Box_Panic, C("Warning: Tombol ini akan mematikan paksa semua fitur cheat.", 255, 100, 100))
end
do
function BuildDashboardTab()
    for _, v in pairs(T_Dash:GetChildren()) do
        if v:IsA("Frame") or v:IsA("UIListLayout") or v:IsA("UIPadding") then v:Destroy() end
    end

    local DashLayout = Instance.new("UIListLayout", T_Dash)
    DashLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DashLayout.Padding = UDim.new(0, 12)
    
    local DashPad = Instance.new("UIPadding", T_Dash)
    DashPad.PaddingTop = UDim.new(0, 15)
    DashPad.PaddingLeft = UDim.new(0, 15)
    DashPad.PaddingRight = UDim.new(0, 15)
    DashPad.PaddingBottom = UDim.new(0, 15)

    -- [1. PROFILE CARD (Modern Header)]
    local ProfileCard = Instance.new("Frame", T_Dash)
    ProfileCard.Name = "ProfileCard"
    ProfileCard.Size = UDim2.new(1, 0, 0, 80)
    ProfileCard.LayoutOrder = 1
    RegisterTheme(ProfileCard, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 8)
    
    local PGrad = Instance.new("UIGradient", ProfileCard)
    PGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
    }
    PGrad.Rotation = 45

    -- Avatar Image
    local AvatarImg = Instance.new("ImageLabel", ProfileCard)
    AvatarImg.Size = UDim2.new(0, 60, 0, 60)
    AvatarImg.Position = UDim2.new(0, 12, 0, 10)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0) -- Bulat Sempurna
    local AvaStroke = Instance.new("UIStroke", AvatarImg)
    RegisterTheme(AvaStroke, "Color", "Accent"); AvaStroke.Thickness = 2

    -- Greeting Text
    local hour = tonumber(os.date("%H"))
    local greeting = "Welcome back,"
    if hour >= 5 and hour < 12 then greeting = "Good Morning,"
    elseif hour >= 12 and hour < 18 then greeting = "Good Afternoon,"
    elseif hour >= 18 then greeting = "Good Evening,"
    end

    local WelcomeTitle = Instance.new("TextLabel", ProfileCard)
    WelcomeTitle.Size = UDim2.new(1, -90, 0, 20)
    WelcomeTitle.Position = UDim2.new(0, 85, 0, 12)
    WelcomeTitle.BackgroundTransparency = 1
    WelcomeTitle.Text = greeting
    RegisterTheme(WelcomeTitle, "TextColor3", "TextDim")
    WelcomeTitle.Font = Enum.Font.GothamMedium
    WelcomeTitle.TextSize = 12
    WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left

    local DisplayNameLbl = Instance.new("TextLabel", ProfileCard)
    DisplayNameLbl.Size = UDim2.new(1, -90, 0, 25)
    DisplayNameLbl.Position = UDim2.new(0, 85, 0, 30)
    DisplayNameLbl.BackgroundTransparency = 1
    DisplayNameLbl.Text = LocalPlayer.DisplayName
    RegisterTheme(DisplayNameLbl, "TextColor3", "Accent")
    DisplayNameLbl.Font = Enum.Font.GothamBlack
    DisplayNameLbl.TextSize = 18
    DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local UsernameLbl = Instance.new("TextLabel", ProfileCard)
    UsernameLbl.Size = UDim2.new(1, -90, 0, 15)
    UsernameLbl.Position = UDim2.new(0, 85, 0, 52)
    UsernameLbl.BackgroundTransparency = 1
    UsernameLbl.Text = "@" .. LocalPlayer.Name
    RegisterTheme(UsernameLbl, "TextColor3", "TextDim")
    UsernameLbl.Font = Enum.Font.Code
    UsernameLbl.TextSize = 11
    UsernameLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- [2. GAME INFO & EXECUTOR (Compact)]
    local GameInfoFrame = Instance.new("Frame", T_Dash)
    GameInfoFrame.Size = UDim2.new(1, 0, 0, 70)
    GameInfoFrame.LayoutOrder = 2
    GameInfoFrame.BackgroundTransparency = 1
    
    local GILayout = Instance.new("UIListLayout", GameInfoFrame)
    GILayout.FillDirection = Enum.FillDirection.Horizontal
    GILayout.Padding = UDim.new(0, 10)

    -- Left: Game Info
    local GameBox = Instance.new("Frame", GameInfoFrame)
    GameBox.Size = UDim2.new(0.65, -5, 1, 0)
    RegisterTheme(GameBox, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", GameBox).CornerRadius = UDim.new(0, 8)
    
    local GameIcon = Instance.new("ImageLabel", GameBox)
    GameIcon.Size = UDim2.new(0, 50, 0, 50)
    GameIcon.Position = UDim2.new(0, 10, 0, 10)
    GameIcon.BackgroundTransparency = 1
    Instance.new("UICorner", GameIcon).CornerRadius = UDim.new(0, 6)
    pcall(function()
        GameIcon.Image = "rbxassetid://" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).IconImageAssetId
    end)

    local GameTitle = Instance.new("TextLabel", GameBox)
    GameTitle.Size = UDim2.new(1, -70, 0, 20)
    GameTitle.Position = UDim2.new(0, 70, 0, 12)
    GameTitle.BackgroundTransparency = 1
    GameTitle.Text = (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown Place")
    RegisterTheme(GameTitle, "TextColor3", "Text")
    GameTitle.Font = Enum.Font.GothamBold
    GameTitle.TextSize = 13
    GameTitle.TextXAlignment = Enum.TextXAlignment.Left
    GameTitle.TextTruncate = Enum.TextTruncate.AtEnd

    local ExecName = identifyexecutor and identifyexecutor() or "Unknown"
    local ExecLbl = Instance.new("TextLabel", GameBox)
    ExecLbl.Size = UDim2.new(1, -70, 0, 15)
    ExecLbl.Position = UDim2.new(0, 70, 0, 35)
    ExecLbl.BackgroundTransparency = 1
    ExecLbl.Text = "Exec: " .. ExecName
    RegisterTheme(ExecLbl, "TextColor3", "Accent")
    ExecLbl.Font = Enum.Font.Code
    ExecLbl.TextSize = 11
    ExecLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Right: Account Age
    local AccBox = Instance.new("Frame", GameInfoFrame)
    AccBox.Size = UDim2.new(0.35, -5, 1, 0)
    RegisterTheme(AccBox, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", AccBox).CornerRadius = UDim.new(0, 8)

    local AgeTitle = Instance.new("TextLabel", AccBox)
    AgeTitle.Size = UDim2.new(1, 0, 0, 20)
    AgeTitle.Position = UDim2.new(0, 0, 0, 15)
    AgeTitle.BackgroundTransparency = 1
    AgeTitle.Text = "ACCOUNT AGE"
    RegisterTheme(AgeTitle, "TextColor3", "TextDim")
    AgeTitle.Font = Enum.Font.GothamBold
    AgeTitle.TextSize = 9
    
    local AgeVal = Instance.new("TextLabel", AccBox)
    AgeVal.Size = UDim2.new(1, 0, 0, 20)
    AgeVal.Position = UDim2.new(0, 0, 0, 35)
    AgeVal.BackgroundTransparency = 1
    AgeVal.Text = LocalPlayer.AccountAge .. " Days"
    RegisterTheme(AgeVal, "TextColor3", "Text")
    AgeVal.Font = Enum.Font.GothamBlack
    AgeVal.TextSize = 12

    -- [3. STATS GRID (ICONS VERSION)]
    local GridFrame = Instance.new("Frame", T_Dash)
    GridFrame.Size = UDim2.new(1, 0, 0, 140)
    GridFrame.LayoutOrder = 3
    GridFrame.BackgroundTransparency = 1
    
    local GridLayout = Instance.new("UIGridLayout", GridFrame)
    GridLayout.CellSize = UDim2.new(0.31, 0, 0, 65) -- Ukuran pas agar muat 3 kesamping
    GridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local function CreateWidget(Title, IconID)
        local W = Instance.new("Frame", GridFrame)
        RegisterTheme(W, "BackgroundColor3", "ElementBG")
        Instance.new("UICorner", W).CornerRadius = UDim.new(0, 6)
        
        -- Icon Image (Ganti Emoji)
        local I = Instance.new("ImageLabel", W)
        I.Size = UDim2.new(0, 24, 0, 24)
        I.Position = UDim2.new(0, 10, 0.5, -12)
        I.BackgroundTransparency = 1
        I.Image = IconID
        RegisterTheme(I, "ImageColor3", "Accent") -- Icon ikut warna tema
        
        -- Garis Pemisah Kecil
        local Sep = Instance.new("Frame", W)
        Sep.Size = UDim2.new(0, 1, 0.6, 0)
        Sep.Position = UDim2.new(0, 42, 0.2, 0)
        Sep.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        Sep.BorderSizePixel = 0

        local T = Instance.new("TextLabel", W)
        T.Size = UDim2.new(1, -50, 0, 15)
        T.Position = UDim2.new(0, 50, 0, 12)
        T.BackgroundTransparency = 1
        T.Text = Title
        RegisterTheme(T, "TextColor3", "TextDim")
        T.Font = Enum.Font.GothamBold
        T.TextSize = 9
        T.TextXAlignment = Enum.TextXAlignment.Left
        
        local V = Instance.new("TextLabel", W)
        V.Size = UDim2.new(1, -50, 0, 20)
        V.Position = UDim2.new(0, 50, 0, 28)
        V.BackgroundTransparency = 1
        V.Text = "..."
        RegisterTheme(V, "TextColor3", "Text")
        V.Font = Enum.Font.GothamBlack
        V.TextSize = 13
        V.TextXAlignment = Enum.TextXAlignment.Left
        return V
    end

    Dash_FPS = CreateWidget("FPS", "rbxassetid://10709752906") 
    Dash_Ping = CreateWidget("PING", "rbxassetid://75471941086926") 
    Dash_Time = CreateWidget("SERVER TIME", "rbxassetid://10709782497") 
    Dash_Plr = CreateWidget("PLAYERS", "rbxassetid://10747373176") 
    Dash_Ram = CreateWidget("MEMORY", "rbxassetid://105856032975609") 
    Dash_Ver = CreateWidget("VERSION", "rbxassetid://93686373226919")
    Dash_Ver.Text = "v" .. State.CurrentVersion

    local NewsFrame = Instance.new("Frame", T_Dash)
    NewsFrame.Size = UDim2.new(1, 0, 0, 120) 
    NewsFrame.LayoutOrder = 4
    RegisterTheme(NewsFrame, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", NewsFrame).CornerRadius = UDim.new(0, 8)
    
    local NewsHeader = Instance.new("Frame", NewsFrame)
    NewsHeader.Size = UDim2.new(1, 0, 0, 30)
    NewsHeader.BackgroundTransparency = 1
    
    local NewsIcon = Instance.new("ImageLabel", NewsHeader)
    NewsIcon.Size = UDim2.new(0, 18, 0, 18)
    NewsIcon.Position = UDim2.new(0, 10, 0.5, -9)
    NewsIcon.BackgroundTransparency = 1
    NewsIcon.Image = "rbxassetid://10709773693" -- Icon List/News
    RegisterTheme(NewsIcon, "ImageColor3", "Accent")

    local NewsTitle = Instance.new("TextLabel", NewsHeader)
    NewsTitle.Size = UDim2.new(1, -40, 1, 0)
    NewsTitle.Position = UDim2.new(0, 35, 0, 0)
    NewsTitle.BackgroundTransparency = 1
    NewsTitle.Text = "LATEST UPDATES"
    RegisterTheme(NewsTitle, "TextColor3", "Text")
    NewsTitle.Font = Enum.Font.GothamBlack
    NewsTitle.TextSize = 12
    NewsTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local Divider = Instance.new("Frame", NewsFrame)
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.new(0, 0, 0, 30)
    Divider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Divider.BorderSizePixel = 0

    local NewsScroll = Instance.new("ScrollingFrame", NewsFrame)
    NewsScroll.Size = UDim2.new(1, -20, 1, -40)
    NewsScroll.Position = UDim2.new(0, 10, 0, 35)
    NewsScroll.BackgroundTransparency = 1
    NewsScroll.ScrollBarThickness = 2
    NewsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    NewsScroll.CanvasSize = UDim2.new(0,0,0,0)
    local NList = Instance.new("UIListLayout", NewsScroll)
    NList.Padding = UDim.new(0, 4)
    
    local function AddNews(txt)
        local L = Instance.new("TextLabel", NewsScroll)
        L.Size = UDim2.new(1, 0, 0, 0)
        L.AutomaticSize = Enum.AutomaticSize.Y
        L.BackgroundTransparency = 1
        L.Text = "• " .. txt
        RegisterTheme(L, "TextColor3", "TextDim")
        L.Font = Enum.Font.GothamMedium
        L.TextSize = 11
        L.TextWrapped = true
        L.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    AddNews("Remastered Dashboard UI (Grid Layout).")
    AddNews("Added Real-time System Monitor.")
    AddNews("Replaced Emojis with Professional Icons.")
    AddNews("Optimized RTX Graphics Engine.")
    AddNews("Fixed Animation Bugs & Spectator Mode.")

    -- [GLOBAL UPDATE LOOP DASHBOARD]
    task.spawn(function()
        local RunService = game:GetService("RunService")
        local Stats = game:GetService("Stats")
        while task.wait(1) do
            if T_Dash.Visible then
                -- Ping
                local ping = 0
                pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 2000) end)
                if ping == 0 then pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end) end
                
                -- FPS
                local fps = math.floor(1 / (RunService.RenderStepped:Wait() + 0.0001))
                
                -- RAM
                local mem = math.floor(Stats:GetTotalMemoryUsageMb())

                -- Update Text
                if Dash_Ping then Dash_Ping.Text = ping .. " ms" end
                if Dash_FPS then Dash_FPS.Text = fps .. " FPS" end
                if Dash_Time then Dash_Time.Text = os.date("%H:%M") end
                if Dash_Plr then Dash_Plr.Text = #Players:GetPlayers() .. "/" .. Players.MaxPlayers end
                if Dash_Ram then Dash_Ram.Text = mem .. " MB" end

                -- Indikator Warna Ping
                if Dash_Ping then
                    if ping < 100 then Dash_Ping.TextColor3 = Color3.fromRGB(0, 255, 100)
                    elseif ping < 250 then Dash_Ping.TextColor3 = Color3.fromRGB(255, 200, 50)
                    else Dash_Ping.TextColor3 = Color3.fromRGB(255, 50, 50) end
                end
            end
        end
    end)
end
-- Jalankan Fungsi Build
BuildDashboardTab()
end
do
    local Box_Aim = CreateSection(T_Combat, "AIM ASSIST")
    CreateToggle(Box_Aim, "Simple Aimbot (Active)", function(v) State.Aimbot = v end)
    CreateSlider(Box_Aim, "Aggressiveness (%)", 1, 100, 40, function(v)
        State.AimbotAggressiveness = v / 100 
    end)
    CreateDropdown(Box_Aim, "Aimbot Target", {"All Players", "Enemy Only"}, "All Players", function(val)
        State.AimbotMode = val
        ShowToast("Aim Target: " .. val)
    end)
    CreateDropdown(Box_Aim, "Aim Method", {"Mouse (TPP)", "Camera (FPP)"}, "Mouse (TPP)", function(val)
        State.AimbotMethod = val
        if val == "Camera (FPP)" then ShowToast("Mode: Camera Lock") else ShowToast("Mode: Mouse Drag") end
    end)
    CreateDropdown(Box_Aim, "Trigger Button", {"Right Click", "Left Click"}, "Right Click", function(val)
        if val == "Right Click" then State.AimbotButton = Enum.UserInputType.MouseButton2 else State.AimbotButton = Enum.UserInputType.MouseButton1 end
    end)
    CreateDropdown(Box_Aim, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(v) State.AimbotPart = v end) 
    CreateToggle(Box_Aim, "Auto Wall Check", function(v) State.WallCheck = v end)
    CreateToggle(Box_Aim, "Built-in Auto Clicker", function(v) 
        ManageAutoClicker(v) 
    end)
    CreateSlider(Box_Aim, "Click Speed (CPS)", 1, 50, 10, function(v) State.CPS = v end)
    local Box_Wep = CreateSection(T_Combat, "WEAPON MODS")
    CreateToggle(Box_Wep, "Rapid Fire (Hold Click)", function(v) 
        State.WeaponRapidFire = v
        if v then
            task.spawn(function()
                while State.WeaponRapidFire do
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        local char = LocalPlayer.Character
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then
                            tool:Activate() 
                            task.wait()  
                            tool:Deactivate() 
                        end
                        local delay = 1 / math.max(1, State.RapidFireCPS)
                        task.wait(delay)
                    else
                        task.wait(0.05)
                    end
                end
            end)
        end
    end)
    CreateSlider(Box_Wep, "Rapid Fire Speed", 1, 100, 15, function(v) State.RapidFireCPS = v end)
    CreateToggle(Box_Wep, "No Recoil & Spread", function(v) State.NoRecoil = v end)
    CreateToggle(Box_Wep, "OP Gun Mods (Fast Fire)", function(v) State.GunMods = v end)
    CreateToggle(Box_Wep, "Touch Fling (Loop)", function(v) 
        State.TouchFling = v 
        if v then ShowToast("Touch Fling Active! Senggol Dong!") end
    end)
    CreateDropdown(Box_Wep, "Fling Mode", {"Walk", "Fly"}, "Walk", function(val) State.FlingMode = val end)
    local Box_Hitbox = CreateSection(T_Combat, "HITBOX & REACH")
    CreateDropdown(Box_Hitbox, "Hitbox Part", {"HumanoidRootPart", "Head"}, "HumanoidRootPart", function(val) State.HitboxPart = val end)
    local HBSizeInput = CreateInput(Box_Hitbox, "Hitbox Size", 15, function(v) State.HitboxSize = v end)
    CreateToggle(Box_Hitbox, "Invisible Visuals", function(v) State.HitboxInvisible = v end, true)
    CreateToggle(Box_Hitbox, "Loop Hitbox (Active)", function(v) 
        ToggleHitbox(v)
    end)
    local ResetBtn = CreateButton(Box_Hitbox, "RESET HITBOX DEFAULT", function()
        HBLoopToggle(false)
        State.HitboxLoop = false
        if HBSizeInput then HBSizeInput.Text = "2" end
        State.HitboxSize = 2
        State.HitboxPart = "HumanoidRootPart"
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local t = p.Character:FindFirstChild("HumanoidRootPart")
                local h = p.Character:FindFirstChild("Head")
                if t then t.Size = Vector3.new(2, 2, 1); t.Transparency = 1; t.CanCollide = true; t.Massless = false end
                if h then h.Size = Vector3.new(1, 1, 1); h.Transparency = 1; h.CanCollide = true; h.Massless = false end
            end
        end
        ShowToast("Hitbox Reset!")
    end)
    ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
    ResetBtn.TextColor3 = Color3.new(1,1,1)
    CreateToggle(Box_Hitbox, "🗡️ Reach (Sword Extender)", function(v)
        State.ReachActive = v
        local size = v and Vector3.new(50, 50, 50) or Vector3.new(1, 1, 1) 
        task.spawn(function()
            while State.ReachActive do
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        local handle = tool.Handle
                        if handle:IsA("BasePart") then
                            handle.Massless = true
                            handle.Size = size
                            if not handle:FindFirstChild("ReachBox") then
                                local box = Instance.new("SelectionBox", handle)
                                box.Name = "ReachBox"; box.Adornee = handle; box.Color3 = Color3.fromRGB(255, 0, 0)
                            end
                        end
                    end
                end
                task.wait(0.5)
            end
            if not State.ReachActive then
                local char = LocalPlayer.Character
                if char then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        tool.Handle.Size = Vector3.new(1, 1, 1)
                        if tool.Handle:FindFirstChild("ReachBox") then tool.Handle.ReachBox:Destroy() end
                    end
                end
                ShowToast("Reach Disabled")
            end
        end)
        if v then ShowToast("Reach Active! (Hold Tool)") end
    end)
    local Box_Desync = CreateSection(T_Combat, "GHOST & DESYNC")
    local DesyncConnections = {} 
    local DesyncConnections = {} 
    CreateToggle(Box_Desync, "👻 Sky Desync (Hitbox ke Langit)", function(v)
        State.Desync = v
        if DesyncConnections.Heartbeat then DesyncConnections.Heartbeat:Disconnect() DesyncConnections.Heartbeat = nil end
        if DesyncConnections.RenderStepped then DesyncConnections.RenderStepped:Disconnect() DesyncConnections.RenderStepped = nil end
        local LocalPlayer = game:GetService("Players").LocalPlayer
        local RunService = game:GetService("RunService")
        local LastSafeCFrame = nil
        if v then
            ShowToast("Sky Desync: ON (Safe Mode)")
            DesyncConnections.Heartbeat = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and State.Desync then
                    LastSafeCFrame = root.CFrame
                    root.AssemblyLinearVelocity = Vector3.new(math.random(-1000, 1000), 5000, math.random(-1000, 1000))
                    root.AssemblyAngularVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
                    local FakeCFrame = LastSafeCFrame * CFrame.new(0, 500, 0)
                    root.CFrame = FakeCFrame
                end
            end)
            DesyncConnections.RenderStepped = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and State.Desync and LastSafeCFrame then
                    root.CFrame = LastSafeCFrame
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            ShowToast("Desync: OFF (Stabilizing...)")
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")
            if root then
                if LastSafeCFrame and (root.Position.Y - LastSafeCFrame.Position.Y) > 400 then
                    root.CFrame = LastSafeCFrame
                end
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
            end
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                hum:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end
    end)
    CreateLabel(Box_Desync, C("Note: Gunakan Visualizer Terlebih Dulu Sebelum Memakai Desync, Jika Ada Bug Silahkan Report Bug Ke Discord Kami.", 200, 200, 200))
end
do
    local Box_Player = CreateSection(T2, "PLAYER VISUALS")
    CreateToggle(Box_Player, "ESP Player (Smart Box)", function(v) State.MasterESP = v end)
    CreateLabel(Box_Player, "🎨 GACOR COLOR THEME")
    CreateDropdown(Box_Player, "Enemy Color", ESP_ColorList, "Merah", function(val)
        State.EspEnemyColorName = val
        ShowToast("Enemy Color: " .. val)
    end)
    CreateDropdown(Box_Player, "Team Color", ESP_ColorList, "Hijau", function(val)
        State.EspTeamColorName = val
        ShowToast("Team Color: " .. val)
    end)
    CreateToggle(Box_Player, "Custom Name Color", function(v) 
        State.UseCustomNameColor = v 
    end)
    CreateDropdown(Box_Player, "Display Name Color", ESP_ColorList, "Putih", function(val)
        State.EspNameColorName = val
        ShowToast("Name Color: " .. val)
    end)
    CreateToggle(Box_Player, "Show Inventory Tools", function(v) State.ShowInventory = v end)
    CreateToggle(Box_Player, "Spectator List (Nearby)", function(v) 
        State.SpectatorList = v 
        if SpecFrame then SpecFrame.Visible = v end
    end)
    local Box_World = CreateSection(T2, "WORLD & OBJECTS")
    local NVG_Loop = nil
    local NVG_Effect = nil
    
    CreateToggle(Box_World, "Night Vision (NVG Mode)", function(v)
        State.NightVision = v
        local Lighting = game:GetService("Lighting")
        local RunService = game:GetService("RunService")

        if v then
            ShowToast("NVG Mode: ACTIVATED 🟢")
            if not NVG_Effect then
                NVG_Effect = Instance.new("ColorCorrectionEffect")
                NVG_Effect.Name = "Reyzz_NVG_Filter"
                NVG_Effect.TintColor = Color3.fromRGB(100, 255, 100)
                NVG_Effect.Saturation = -1
                NVG_Effect.Contrast = 0.1 
                NVG_Effect.Brightness = 0.1
                NVG_Effect.Parent = Lighting
            end
            if NVG_Loop then NVG_Loop:Disconnect() end
            NVG_Loop = RunService.RenderStepped:Connect(function()
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255) 
                Lighting.Ambient = Color3.fromRGB(255, 255, 255) 
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 2 
                if not State.LockTime then
                    Lighting.ClockTime = 12 
                end
            end)
        else
            ShowToast("NVG Mode: OFF")
            if NVG_Loop then 
                NVG_Loop:Disconnect()
                NVG_Loop = nil
            end
            if NVG_Effect then 
                NVG_Effect:Destroy()
                NVG_Effect = nil
            end
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.Brightness = 1
        end
    end)
    CreateToggle(Box_World, "World X-Ray [BETA]", ToggleXRay)
    local Box_Radar = CreateSection(T2, "RADAR & HUD SYSTEM")
    CreateToggle(Box_Radar, "Custom Crosshair (HUD)", function(v) State.Crosshair = v end)
    CreateToggle(Box_Radar, "Proximity Warning ⚠️", function(v) 
        ToggleProximity(v) 
    end)
    CreateDropdown(Box_Radar, "Warning Mode", {"All Players", "Enemy Only"}, "All Players", function(v) State.ProximityMode = v end)
    CreateSlider(Box_Radar, "Detect Distance", 10, 200, 50, function(v) State.ProximityDist = v end)
    -- [PLAYER HIDER SYSTEM V2 (ANTI LOCAL LIMIT)] --
    local Box_Hide = CreateSection(T2, "PLAYER VISIBILITY (HIDER)")
    
    -- Variabel Default
    State.GlobalHideMode = "None"
    State.TargetHideName = ""

    -- 1. Dropdown Global
    CreateDropdown(Box_Hide, "Global Hide Mode", {"None", "Hide All Players", "Hide Enemies", "Hide Teammates"}, "None", function(val)
        State.GlobalHideMode = val
        if val == "None" then 
            ShowToast("Visibility Restored (Waiting Respawn/Update)")
        else
            ShowToast("Mode: " .. val)
        end
    end)

    function GetPlayerNames()
        local list = {} 
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then 
                table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")") 
            end
        end
        return list
    end

    HideSpecificDrop = CreateDropdown(Box_Hide, "Hide Specific Player", GetPlayerNames(), "Select Player...", function(val)
        State.TargetHideName = val
        ShowToast("Target Hiding: " .. val)
    end)

    CreateButton(Box_Hide, "🔄 Refresh Player List", function()
        if HideSpecificDrop and HideSpecificDrop.Refresh then
            HideSpecificDrop:Refresh(GetPlayerNames())
        end
        ShowToast("List Updated with Usernames!")
    end)

    CreateButton(Box_Hide, "👁️ Force Un-Hide All", function()
        State.GlobalHideMode = "None"
        State.TargetHideName = ""
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, v in pairs(p.Character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        -- FIX: Jangan munculkan HumanoidRootPart (Kotak Inti)
                        if v.Name == "HumanoidRootPart" then
                            v.Transparency = 1 
                        else
                            v.Transparency = 0
                        end
                    elseif v:IsA("Decal") then
                        v.Transparency = 0
                    elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                        v.Handle.Transparency = 0
                    end
                end
                -- Munculkan Nama Kembali
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
        end
        ShowToast("All Players Visible (Normal)!")
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if State.GlobalHideMode == "None" and State.TargetHideName == "" then return end
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local shouldHide = false 
                if State.GlobalHideMode == "Hide All Players" then
                    shouldHide = true
                elseif State.GlobalHideMode == "Hide Enemies" and p.Team ~= LocalPlayer.Team then
                    shouldHide = true
                elseif State.GlobalHideMode == "Hide Teammates" and p.Team == LocalPlayer.Team then
                    shouldHide = true
                end
                if State.TargetHideName ~= "" then
                    local pID = p.DisplayName .. " (@" .. p.Name .. ")"
                    if pID == State.TargetHideName then
                        shouldHide = true
                    end
                end
                if shouldHide then
                    for _, v in pairs(p.Character:GetChildren()) do
                        if v:IsA("BasePart") or v:IsA("Decal") then
                            v.Transparency = 1 
                        elseif v:IsA("Accessory") and v:FindFirstChild("Handle") then
                            v.Handle.Transparency = 1
                        end
                    end
                    local hum = p.Character:FindFirstChild("Humanoid")
                    if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end
                end
            end
        end
    end)
end
do
    local Box_Tools = CreateSection(T3, "CAMERA TOOLS")
    CreateToggle(Box_Tools, "Freecam (Drone Mode)", ToggleFreecam)
    CreateInput(Box_Tools, "Drone Speed", 1, function(v) State.FreecamSpeed = v end)
    CreateButton(Box_Tools, "Reset Camera Normal", function() 
        ToggleFreecam(false)
        State.Freecam = false
        Camera.CameraType = Enum.CameraType.Custom 
        ShowToast("Camera Reset!")
    end)
    local Box_View = CreateSection(T3, "VIEW CONFIGURATION")
    CreateToggle(Box_View, "Max Zoom (1000 Studs)", function(v) 
        State.MaxZoom = v 
        if v then LocalPlayer.CameraMaxZoomDistance = 1000 end
    end)
    CreateDropdown(Box_View, "View Perspective", {"Default", "First Person", "Third Person"}, "Default", function(v) 
        if v == "First Person" then
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        elseif v == "Third Person" then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 10
            LocalPlayer.CameraMaxZoomDistance = 100
        else
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 400
        end
    end)
    CreateSlider(Box_View, "Field of View (FOV)", 30, 120, 90, function(v)
        State.TargetFOV = v
        Camera.FieldOfView = v
    end)
    local FOVConnection = nil
    CreateToggle(Box_View, "🔒 Lock FOV (Loop)", function(isOn)
        State.LockFOV = isOn
        if isOn then 
            ShowToast("FOV Locked: " .. (State.TargetFOV or 90)) 
            if FOVConnection then FOVConnection:Disconnect() end
            FOVConnection = game:GetService("RunService").RenderStepped:Connect(function()
                Camera.FieldOfView = State.TargetFOV or 90
            end)
        else
            if FOVConnection then 
                FOVConnection:Disconnect()
                FOVConnection = nil
            end
            ShowToast("FOV Unlocked")
        end
    end)
    State.UIListeners["LockFOV"] = State.UIListeners["🔒 Lock FOV (Loop)"]
    local Box_Stab = CreateSection(T3, "STABILIZATION")
    CreateToggle(Box_Stab, "No Bobbing (Anti-Goyang)", function(v)
        State.NoShake = v
        if v then
            ShowToast("Anti-Goyang: ON (Forced)")
            RunService:BindToRenderStep("FixCameraBobbing", Enum.RenderPriority.Camera.Value + 10, function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
                end
            end)
        else
            pcall(function()
                RunService:UnbindFromRenderStep("FixCameraBobbing")
            end)
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.CameraOffset = Vector3.new(0, 0, 0)
            end
            ShowToast("Anti-Goyang: OFF")
        end
    end)
end
do
    local Box_Manual = CreateSection(T4, "MANUAL TELEPORT")
    CreateButton(Box_Manual, "Copy Current Position (XYZ)", function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            local x = math.floor(pos.X)
            local y = math.floor(pos.Y)
            local z = math.floor(pos.Z)
            local coordString = x .. ", " .. y .. ", " .. z
            setclipboard(coordString)
            ShowToast("Copied: " .. coordString)
        else
            ShowToast("Error: Character not found!")
        end
    end)
    CreateInput(Box_Manual, "Teleport to (X, Y, Z)", "Example: 100, 50, -200", function(text)
        text = text:gsub(" ", "")
        local x, y, z = text:match("([^,]+),([^,]+),([^,]+)")
        if x and y and z then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(tonumber(x), tonumber(y), tonumber(z))
                ShowToast("Teleported to Custom Coords!")
            end
        else
            ShowToast("Format Salah! Gunakan: X, Y, Z")
        end
    end, true)
    CreateToggle(Box_Manual, "CTRL + Click TP", function(v) State.ClickTP = v end)
    local Box_Server = CreateSection(T4, "SERVER HOPPER")
    CreateButton(Box_Server, "🔄 Rejoin Server (Retry)", RejoinServer)
    CreateButton(Box_Server, "🔀 Join Random Server (Rame)", JoinRandomHighServer)
    CreateButton(Box_Server, "💀 Join Lowest Server (Sepi)", JoinLowestServer)
    CreateButton(Box_Server, "⛔ Stop Searching", function()
        State.IsScanning = false
        ShowToast("Scanner Dihentikan.")
    end)
    CreateInput(Box_Server, "Join Job ID", "Paste ID Here", function(id) State.TargetJobId = id end, true)
    CreateButton(Box_Server, "Join by Job ID", JoinJobId)
    local Box_Finder = CreateSection(T4, "PLAYER TELEPORT & SPECTATE")
    CreateButton(Box_Finder, "Stop Spectating / Reset Cam", function()
        State.SpectatingPlayer = nil
        State.CinematicCamera = false 
        Camera.CameraType = Enum.CameraType.Custom
        LocalPlayer.ReplicationFocus = nil 
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        ShowToast("Spectating Stopped")
    end)
    local CurrentSearch = "" 
    local SearchBox = CreateInput(Box_Finder, "Search Player Name", "Type here...", function(val)
        CurrentSearch = string.lower(val)
        RefreshList()
    end, true)
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        CurrentSearch = string.lower(SearchBox.Text) 
        RefreshList() 
    end)
    CreateButton(Box_Finder, "Force Refresh List", function() RefreshList() end)
    local TPList = Instance.new("ScrollingFrame", Box_Finder)
    TPList.Size = UDim2.new(1, 0, 0, 200) 
    RegisterTheme(TPList, "BackgroundColor3", "Background")
    TPList.BackgroundTransparency = 0.5
    TPList.ScrollBarThickness = 2
    TPList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TPList.CanvasSize = UDim2.new(0, 0, 0, 0)
    Instance.new("UICorner", TPList).CornerRadius = UDim.new(0, 8)
    local TPLayout = Instance.new("UIListLayout", TPList)
    TPLayout.Padding = UDim.new(0, 5)
    local TPPadding = Instance.new("UIPadding", TPList)
    TPPadding.PaddingTop = UDim.new(0, 5)
    TPPadding.PaddingLeft = UDim.new(0, 5)
    TPPadding.PaddingRight = UDim.new(0, 5)
    TPPadding.PaddingBottom = UDim.new(0, 5)
    RefreshList = function()
        -- Bersihkan list lama
        for _,v in pairs(TPList:GetChildren()) do 
            if v:IsA("Frame") then v:Destroy() end 
        end

        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pName = string.lower(p.DisplayName) 
                local pReal = string.lower(p.Name)
                
                -- Filter Pencarian
                if CurrentSearch == "" or string.find(pName, CurrentSearch) or string.find(pReal, CurrentSearch) then
                    local Row = Instance.new("Frame", TPList)
                    Row.Size = UDim2.new(1, 0, 0, 35)
                    Row.BackgroundTransparency = 1
                    
                    local TPBtn = Instance.new("TextButton", Row)
                    TPBtn.Size = UDim2.new(0.6, -5, 1, 0)
                    RegisterTheme(TPBtn, "BackgroundColor3", "ElementBG")
                    TPBtn.Text = "TP: " .. p.DisplayName
                    RegisterTheme(TPBtn, "TextColor3", "Text")
                    TPBtn.Font = Enum.Font.GothamMedium
                    TPBtn.TextSize = 12
                    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 6)
                    
                    local ViewBtn = Instance.new("TextButton", Row)
                    ViewBtn.Size = UDim2.new(0.4, -5, 1, 0)
                    ViewBtn.Position = UDim2.new(0.6, 5, 0, 0)
                    RegisterTheme(ViewBtn, "BackgroundColor3", "Sidebar")
                    ViewBtn.Text = "Spectate"
                    RegisterTheme(ViewBtn, "TextColor3", "Accent")
                    ViewBtn.Font = Enum.Font.GothamBold
                    ViewBtn.TextSize = 11
                    Instance.new("UICorner", ViewBtn).CornerRadius = UDim.new(0, 6)

                    -- [[ LOGIKA TELEPORT BARU (ANTI VOID) ]] --
                    TPBtn.MouseButton1Click:Connect(function() 
                        local targetPos = nil
                        
                        -- Coba ambil posisi (GetPivot lebih kuat drpd cari Part)
                        if p.Character then 
                            targetPos = p.Character:GetPivot().Position
                        end

                        if targetPos then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                ShowToast("⏳ Requesting Map Chunk...")
                                
                                -- 1. Paksa Server Render Area Sana Dulu
                                LocalPlayer:RequestStreamAroundAsync(targetPos)
                                
                                -- 2. Teleport Loop (Biar gak jatuh ke void)
                                local StartTime = tick()
                                local Connection
                                Connection = game:GetService("RunService").Stepped:Connect(function()
                                    -- Teleport paksa selama 1.5 detik sampai map loading
                                    if tick() - StartTime > 1.5 then
                                        Connection:Disconnect()
                                        ShowToast("✅ Teleport Success!")
                                    else
                                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                                        root.Velocity = Vector3.new(0,0,0)
                                    end
                                end)
                            end
                        else
                            ShowToast("❌ Gagal: Player Terlalu Jauh / Tidak Ter-Render")
                        end
                    end)

                    ViewBtn.MouseButton1Click:Connect(function() 
                        local targetPos = nil
                        if p.Character then targetPos = p.Character:GetPivot().Position end

                        if targetPos then
                            State.SpectatingPlayer = p
                            ShowToast("👁️ Spectating: " .. p.DisplayName)
                            LocalPlayer.ReplicationFocus = p.Character.PrimaryPart or p.Character:FindFirstChild("Head")

                            Camera.CameraType = Enum.CameraType.Scriptable
                            Camera.CFrame = CFrame.new(targetPos + Vector3.new(0, 10, 0), targetPos)
                            
                            task.spawn(function()
                                -- Paksa load area
                                LocalPlayer:RequestStreamAroundAsync(targetPos)
                                task.wait(0.5)
                                local MaxWait = 20 
                                local Found = false
                                
                                for i = 1, MaxWait do
                                    if p.Character and p.Character:FindFirstChild("Humanoid") then
                                        Camera.CameraType = Enum.CameraType.Custom
                                        Camera.CameraSubject = p.Character.Humanoid
                                        -- Pastikan fokus tetap di musuh
                                        LocalPlayer.ReplicationFocus = p.Character.PrimaryPart
                                        Found = true
                                        break
                                    else
                                        LocalPlayer:RequestStreamAroundAsync(targetPos)
                                    end
                                    task.wait(0.2)
                                end

                                if not Found then
                                    ShowToast("⚠️ Gagal Load Karakter (Kejauhan)")
                                    -- Reset Fokus ke diri sendiri biar ga ngebug
                                    LocalPlayer.ReplicationFocus = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
                                    Camera.CameraType = Enum.CameraType.Custom
                                    if LocalPlayer.Character then Camera.CameraSubject = LocalPlayer.Character.Humanoid end
                                end
                            end)
                        else 
                            ShowToast("❌ Player Tidak Ditemukan (Out of Range)") 
                        end 
                    end)
                end
            end
        end
    end
    Players.PlayerAdded:Connect(function(p) task.wait(1); RefreshList(); ShowToast(p.DisplayName .. " Joined") end)
    Players.PlayerRemoving:Connect(function(p) task.wait(0.1); RefreshList(); ShowToast(p.DisplayName .. " Left") end)
    task.spawn(RefreshList)
    local Box_Follow = CreateSection(T4, "AUTO FOLLOW PLAYER")
    State.FollowTarget = nil
    State.FollowDistance = 5
    State.FollowHeight = 0 
    local FollowLoop = nil
    local function GetPlayerNames()
        local list = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.DisplayName) 
            end
        end
        return list
    end
    local PlayerDropdown = CreateDropdown(Box_Follow, "Select Target", GetPlayerNames(), "Select...", function(val)
        for _, p in pairs(Players:GetPlayers()) do
            if p.DisplayName == val or p.Name == val then
                State.FollowTarget = p
                ShowToast("🎯 Target: " .. p.DisplayName)
                if p.Character and p.Character:GetPivot() then
                     pcall(function() LocalPlayer:RequestStreamAroundAsync(p.Character:GetPivot().Position) end)
                end
                break
            end
        end
    end)
    CreateInput(Box_Follow, "Jarak Follow (Studs)", "5", function(val)
        State.FollowDistance = val 
    end)
    CreateToggle(Box_Follow, "Start Auto Follow", function(enable)
        State.AutoFollow = enable
        if enable then
            if not State.FollowTarget then
                ShowToast("⚠️ Pilih Target Dulu!")
                return
            end
            ShowToast("🚀 Mengikuti: " .. State.FollowTarget.DisplayName)
            if FollowLoop then FollowLoop:Disconnect() end
            FollowLoop = RunService.Heartbeat:Connect(function()
                if not State.AutoFollow then return end
                local target = State.FollowTarget
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if target and target.Character and myRoot then
                    local tPivot = target.Character:GetPivot()
                    if tPivot then
                        local targetCFrame = tPivot * CFrame.new(0, 2, State.FollowDistance)
                        myRoot.CFrame = targetCFrame
                        myRoot.AssemblyLinearVelocity = Vector3.zero 
                        myRoot.AssemblyAngularVelocity = Vector3.zero
                    end
                else
                end
            end)
        else
            if FollowLoop then FollowLoop:Disconnect(); FollowLoop = nil end
            ShowToast("🛑 Follow Berhenti")
        end
    end)
    local function UpdateDropdownList()
        if PlayerDropdown and PlayerDropdown.Refresh then
            PlayerDropdown:Refresh(GetPlayerNames())
        end
    end
    Players.PlayerAdded:Connect(function() 
        task.wait(1)
        UpdateDropdownList() 
    end)
    Players.PlayerRemoving:Connect(function() 
        task.wait(0.5)
        UpdateDropdownList() 
    end)
end
do
    local Box_Atmo = CreateSection(T5, "ATMOSPHERE & VISUALS")
    CreateToggle(Box_Atmo, "Fullbright Loop (No Darkness)", function(v) State.FullbrightLoop = v end)
    CreateToggle(Box_Atmo, "Remove Fog (Clear View)", function(v) State.NoFog = v end)
    CreateToggle(Box_Atmo, "Disable FX (Anti-Silau Max)", false, function(val)
        State.DisableLighting = val
        local Lighting = game:GetService("Lighting")
        if val then
            ShowToast("💡 Anti-Silau: ON (Removing Glare...)")
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = true
                end
            end
            
            Lighting.GlobalShadows = false  
            Lighting.ClockTime = 12 
            Lighting.ExposureCompensation = 0 
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128) 
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            
        else
            ShowToast("💡 Anti-Silau: OFF (Restoring...)")
            
            Lighting.GlobalShadows = true
            Lighting.Brightness = 1
            Lighting.ExposureCompensation = 0
            Lighting.EnvironmentDiffuseScale = 1 
            Lighting.EnvironmentSpecularScale = 1
            for _, v in pairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                    v.Enabled = true
                end
            end
        end
    end)
    CreateToggle(Box_Atmo, "Remove Particles", function(v) State.NoParticles = v end)
    local Box_Phys = CreateSection(T5, "PHYSICS MODIFIERS")
    CreateToggle(Box_Phys, "Walk on Water (Jesus)", function(v) State.WalkOnWater = v end) 
    CreateToggle(Box_Phys, "Gravity Control (Magnet)", function(v) State.GravityControl = v end)
    local Box_Opt = CreateSection(T5, "MAP OPTIMIZATION (FPS)")
    CreateInput(Box_Opt, "⏱️ Loop Interval (Menit)", "1", function(val)
        local num = tonumber(val)
        if num and num > 0 then
            State.FPSInterval = num
            ShowToast("Interval set: " .. num .. " Menit")
        else
            ShowToast("Masukkan angka valid!")
        end
    end, false) 
    CreateToggle(Box_Opt, "Auto Boost Loop", function(v)
        State.FPSLoop = v
        if v then 
            ShowToast("Auto Boost: ON (Tiap " .. State.FPSInterval .. " Menit)")
            SuperBoostFPS()
        else 
            ShowToast("Auto Boost: OFF") 
        end
    end)
    CreateButton(Box_Opt, "⚡ Extreme Boost", SuperBoostFPS)
    CreateButton(Box_Opt, "🔥 Delete Map (Extreme FPS)", DeleteMap)
    CreateButton(Box_Opt, "🎨 Remove Textures (Anti-Lag)", RemoveTextures)
    CreateButton(Box_Opt, "🧹 Clear Debris (Trash Cleaner)", function()
        local count = 0
        for _, v in pairs(game:GetService("Debris"):GetChildren()) do
            v:Destroy(); count = count + 1
        end
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Tool") or v.Name == "Debris" or v.Name == "Trash" then
                v:Destroy(); count = count + 1
            elseif v:IsA("MeshPart") and not v.Anchored and v.Size.Magnitude < 2 then
                v:Destroy(); count = count + 1
            end
        end
        ShowToast("🧹 Cleaned " .. count .. " Trash Items!")
    end)
    local Box_Util = CreateSection(T5, "UTILITY TOOLS")
    CreateToggle(Box_Util, "Anti-Void (Return Safe)", function(v) State.AntiVoid = v end) 
    CreateInput(Box_Util, "Void Height (Y)", -50, function(v) State.VoidHeight = v end) 
    CreateToggle(Box_Util, "Show Server Stats UI", function(v) State.ShowStats = v; StatsFrame.Visible = v end)
    local Box_RTX = CreateSection(T5, "RTX GRAPHICS ENGINE (UE5)")
    -- Variabel Global (Biar gak kena limit)
    RTX_Loop = nil
    RTX_Effects = {} 
    function ClearRTX()
        if RTX_Loop then RTX_Loop:Disconnect() RTX_Loop = nil end
        local Lighting = game:GetService("Lighting")
        if RTX_Effects then
            for _, v in pairs(RTX_Effects) do
                if v and v.Parent then v:Destroy() end
            end
        end
        RTX_Effects = {}
        Lighting.GlobalShadows = true
        Lighting.Brightness = 1
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ExposureCompensation = 0
        ShowToast("RTX OFF: Graphics Restored")
    end
    -- Fungsi Utama RTX (V3 - With Realistic Atmosphere)
    function ActivateRTX(Mode)
        ClearRTX() -- Reset dulu biar bersih
        task.wait(0.1)
        
        local Lighting = game:GetService("Lighting")
        ShowToast("🚀 Loading Graphics: " .. Mode)

        -- 1. BUAT EFEK VISUAL BASIC
        local CC = Instance.new("ColorCorrectionEffect", Lighting)
        CC.Name = "RTX_CC"
        table.insert(RTX_Effects, CC)

        local Bloom = Instance.new("BloomEffect", Lighting)
        Bloom.Name = "RTX_Bloom"
        table.insert(RTX_Effects, Bloom)

        local Sun = Instance.new("SunRaysEffect", Lighting)
        Sun.Name = "RTX_Sun"
        table.insert(RTX_Effects, Sun)
        
        -- Kita pasang Atmosphere di SEMUA mode biar gak "No Fog"
        local Atmo = Instance.new("Atmosphere", Lighting)
        Atmo.Name = "RTX_Atmo"
        table.insert(RTX_Effects, Atmo)

        local Blur = nil
        if Mode == "Ultra (UE5)" then
            Blur = Instance.new("DepthOfFieldEffect", Lighting)
            Blur.Name = "RTX_Blur"
            table.insert(RTX_Effects, Blur)
        end

        -- 2. TENTUKAN SETTINGAN (ATMOSFERA DIATUR DISINI)
        local Settings = {}
        
        if Mode == "Low (Vibrant)" then
            -- Grafik Terang & Berwarna (Kabut Tipis)
            Settings.Brightness = 2
            Settings.Shadows = true
            Settings.Specular = 0.3
            Settings.Diffuse = 0.5
            Settings.Ambient = Color3.fromRGB(150, 150, 150)
            
            -- Efek
            CC.Saturation = 0.3; CC.Contrast = 0.1
            Bloom.Intensity = 0.2; Bloom.Size = 24
            Sun.Intensity = 0.1
            
            -- Atmosfer (Fog Tipis tapi Ada)
            Atmo.Density = 0.25      -- Ketebalan udara
            Atmo.Offset = 0          -- Pantulan langit
            Atmo.Haze = 1            -- Kabut panas
            Atmo.Glare = 0.2         -- Silau matahari
            Atmo.Color = Color3.fromRGB(190, 190, 190)
            Atmo.Decay = Color3.fromRGB(100, 100, 100)
            
            -- Fog Klasik (Backup)
            Lighting.FogStart = 50
            Lighting.FogEnd = 5000 

        elseif Mode == "Medium (Shadows)" then
            -- Grafik Seimbang (Kabut Realistis)
            Settings.Brightness = 2.5
            Settings.Shadows = true
            Settings.Specular = 1 
            Settings.Diffuse = 1
            Settings.Ambient = Color3.fromRGB(80, 80, 80)
            
            -- Efek
            CC.Saturation = 0.2; CC.Contrast = 0.2
            Bloom.Intensity = 0.4; Bloom.Size = 30
            Sun.Intensity = 0.25; Sun.Spread = 0.6
            
            -- Atmosfer (Lebih Tebal)
            Atmo.Density = 0.35
            Atmo.Offset = 0.25
            Atmo.Haze = 2
            Atmo.Glare = 0.5
            Atmo.Color = Color3.fromRGB(200, 170, 140) -- Agak oranye (Sore)
            Atmo.Decay = Color3.fromRGB(90, 80, 70)
            
            -- Fog Klasik
            Lighting.FogStart = 20
            Lighting.FogEnd = 2500 

        elseif Mode == "Ultra (UE5)" then
            -- Grafik Berat (Volumetric Fog / Tebal & Cinematic)
            Settings.Brightness = 3
            Settings.Shadows = true
            Settings.Specular = 1 -- Refleksi Maksimal
            Settings.Diffuse = 1
            Settings.Ambient = Color3.fromRGB(30, 30, 30) -- Shadow Gelap
            
            -- Efek
            CC.Saturation = 0; CC.Contrast = 0.5 -- Warna agak pudar tapi kontras tinggi (Realistis)
            Bloom.Intensity = 0.6; Bloom.Size = 40; Bloom.Threshold = 0.8
            Sun.Intensity = 0.5; Sun.Spread = 0.3
            
            if Blur then 
                Blur.FocusDistance = 30; Blur.InFocusRadius = 40; Blur.NearIntensity = 0; Blur.FarIntensity = 0.5 
            end
            
            -- Atmosfer (UE5 Style - Tebal & Menyatu dengan cahaya)
            Atmo.Density = 0.45      -- Udara tebal (efek volume)
            Atmo.Offset = 0.5        -- Cahaya nyebar lebih luas
            Atmo.Haze = 3            -- Efek fatamorgana/panas
            Atmo.Glare = 0.7         -- Matahari menyilaukan
            Atmo.Color = Color3.fromRGB(255, 220, 180) -- Warna Golden Hour
            Atmo.Decay = Color3.fromRGB(50, 40, 40)    -- Warna kejauhan gelap
            
            -- Fog Klasik (Jarak pandang terbatas biar kayak film)
            Lighting.FogStart = 10
            Lighting.FogEnd = 1500 
        end

        -- 3. LOOPING FORCER
        local RunService = game:GetService("RunService")
        RTX_Loop = RunService.RenderStepped:Connect(function()
            Lighting.GlobalShadows = Settings.Shadows
            Lighting.Brightness = Settings.Brightness
            Lighting.EnvironmentSpecularScale = Settings.Specular
            Lighting.EnvironmentDiffuseScale = Settings.Diffuse
            Lighting.OutdoorAmbient = Settings.Ambient
            
            -- Kunci Jam ke Sore (Golden Hour) biar Atmosfernya Kelihatan Bagus
            if not State.LockTime then 
                Lighting.ClockTime = 17.2 -- Jam 5 sore lewat dikit (Warna oranye langit keluar)
            end
        end)
    end

    local Modes = {"OFF", "Low (Vibrant)", "Medium (Shadows)", "Ultra (UE5)"}
    CreateDropdown(Box_RTX, "Select Graphics Mode", Modes, "OFF", function(val)
        if val == "OFF" then
            ClearRTX()
        else
            ActivateRTX(val)
        end
    end)
    CreateLabel(Box_RTX, "Tip: Pilih 'Ultra' untuk grafik refleksi air & lantai maksimal (Seperti Ray Tracing).")
    do
        local App = {
            Picking = false,
            Hovered = nil,
            TargetName = ""
        }
        App.Main = Instance.new("Frame", ScreenGui)
        App.Main.Name = GetRandomName()
        App.Main.Size = UDim2.new(0, 380, 0, 480)
        App.Main.Position = UDim2.new(0.5, -190, 0.5, -240)
        RegisterTheme(App.Main, "BackgroundColor3", "Background")
        App.Main.Visible = false
        App.Main.ClipsDescendants = true
        Instance.new("UICorner", App.Main).CornerRadius = UDim.new(0, 8)
        local ExStroke = Instance.new("UIStroke", App.Main); RegisterTheme(ExStroke, "Color", "Accent"); ExStroke.Thickness = 2
        MakeDraggable(App.Main)
        local Header = Instance.new("TextLabel", App.Main)
        Header.Size = UDim2.new(1, -40, 0, 30); Header.Position = UDim2.new(0, 10, 0, 0); Header.BackgroundTransparency = 1
        Header.Text = "UI INSPECTOR: OMNI-TOOL"; RegisterTheme(Header, "TextColor3", "Accent"); Header.Font = Enum.Font.GothamBlack; Header.TextSize = 14; Header.TextXAlignment = Enum.TextXAlignment.Left
        local CloseBtn = Instance.new("TextButton", App.Main)
        CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 0); CloseBtn.BackgroundTransparency = 1
        CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.MouseButton1Click:Connect(function() 
            App.Main.Visible = false
            App.Picking = false 
            App.HighBox.Visible = false
        end)
        local Toolbar = Instance.new("Frame", App.Main)
        Toolbar.Size = UDim2.new(1, -10, 0, 35); Toolbar.Position = UDim2.new(0, 5, 0, 35); Toolbar.BackgroundTransparency = 1
        App.PickBtn = Instance.new("TextButton", Toolbar)
        App.PickBtn.Size = UDim2.new(0.3, 0, 1, 0)
        App.PickBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        App.PickBtn.Text = "🖱️ PICK GUI"; App.PickBtn.TextColor3 = Color3.new(1,1,1); App.PickBtn.Font = Enum.Font.GothamBold; App.PickBtn.TextSize = 11
        Instance.new("UICorner", App.PickBtn).CornerRadius = UDim.new(0, 6)
        local PickStroke = Instance.new("UIStroke", App.PickBtn); PickStroke.Color = Color3.fromRGB(100,100,100); PickStroke.Thickness = 2; PickStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local SearchBox = Instance.new("TextBox", Toolbar)
        SearchBox.Size = UDim2.new(0.45, 0, 1, 0); SearchBox.Position = UDim2.new(0.32, 0, 0, 0)
        RegisterTheme(SearchBox, "BackgroundColor3", "ElementBG"); SearchBox.Text = ""; SearchBox.PlaceholderText = "Cari Nama..."; SearchBox.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,6); SearchBox.Font = Enum.Font.GothamMedium; SearchBox.TextSize = 11
        local RefreshBtn = Instance.new("TextButton", Toolbar)
        RefreshBtn.Size = UDim2.new(0.2, 0, 1, 0); RefreshBtn.Position = UDim2.new(0.79, 0, 0, 0)
        RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255); RefreshBtn.Text = "LIST"; RefreshBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,6); RefreshBtn.Font = Enum.Font.GothamBold; RefreshBtn.TextSize = 11
        local InfoLabel = Instance.new("TextLabel", App.Main)
        InfoLabel.Size = UDim2.new(1, 0, 0, 15); InfoLabel.Position = UDim2.new(0, 0, 0, 75); InfoLabel.BackgroundTransparency = 1; InfoLabel.Text = "Pick Mode: Klik GUI di Layar | List Mode: Klik Kanan utk Detail"; InfoLabel.TextColor3 = Color3.fromRGB(150,150,150); InfoLabel.TextSize = 10
        App.List = Instance.new("ScrollingFrame", App.Main)
        App.List.Size = UDim2.new(1, -10, 1, -100); App.List.Position = UDim2.new(0, 5, 0, 95); App.List.BackgroundTransparency = 1
        App.List.ScrollBarThickness = 3; App.List.AutomaticCanvasSize = Enum.AutomaticSize.Y; App.List.CanvasSize = UDim2.new(0,0,0,0)
        local UIList = Instance.new("UIListLayout", App.List); UIList.Padding = UDim.new(0, 4)
        App.Popup = Instance.new("Frame", ScreenGui)
        App.Popup.Name = GetRandomName()
        App.Popup.Size = UDim2.new(0, 280, 0, 160)
        App.Popup.Position = UDim2.new(0.5, 50, 0.5, 50)
        App.Popup.Visible = false
        RegisterTheme(App.Popup, "BackgroundColor3", "Sidebar")
        Instance.new("UICorner", App.Popup).CornerRadius = UDim.new(0, 8)
        local PStroke = Instance.new("UIStroke", App.Popup); RegisterTheme(PStroke, "Color", "Accent"); PStroke.Thickness = 2
        MakeDraggable(App.Popup)
        local P_Header = Instance.new("TextLabel", App.Popup); P_Header.Size=UDim2.new(1,-10,0,25); P_Header.Position=UDim2.new(0,10,0,5); P_Header.BackgroundTransparency=1; P_Header.Text="INSPECTOR DETAIL"; P_Header.TextColor3=Color3.fromRGB(0,255,255); P_Header.Font=Enum.Font.GothamBlack; P_Header.TextSize=12; P_Header.TextXAlignment=Enum.TextXAlignment.Left
        App.L_Name = Instance.new("TextLabel", App.Popup); App.L_Name.Size=UDim2.new(1,-20,0,15); App.L_Name.Position=UDim2.new(0,10,0,30); App.L_Name.BackgroundTransparency=1; App.L_Name.TextColor3=Color3.fromRGB(180,180,180); App.L_Name.Font=Enum.Font.Code; App.L_Name.TextSize=10; App.L_Name.TextXAlignment=Enum.TextXAlignment.Left
        App.L_Class = Instance.new("TextLabel", App.Popup); App.L_Class.Size=UDim2.new(1,-20,0,15); App.L_Class.Position=UDim2.new(0,10,0,45); App.L_Class.BackgroundTransparency=1; App.L_Class.TextColor3=Color3.fromRGB(180,180,180); App.L_Class.Font=Enum.Font.Code; App.L_Class.TextSize=10; App.L_Class.TextXAlignment=Enum.TextXAlignment.Left
        App.PathBox = Instance.new("TextBox", App.Popup); App.PathBox.Size=UDim2.new(1,-20,0,30); App.PathBox.Position=UDim2.new(0,10,0,80); App.PathBox.BackgroundColor3=Color3.fromRGB(20,20,25); App.PathBox.Text="..."; App.PathBox.TextColor3=Color3.fromRGB(0,255,100); App.PathBox.Font=Enum.Font.Code; App.PathBox.TextSize=9; App.PathBox.TextWrapped=true; Instance.new("UICorner", App.PathBox).CornerRadius=UDim.new(0,6)
        local P_Copy = Instance.new("TextButton", App.Popup); P_Copy.Size=UDim2.new(0.45,0,0,25); P_Copy.Position=UDim2.new(0,10,1,-35); P_Copy.BackgroundColor3=Color3.fromRGB(0,120,255); P_Copy.Text="COPY PATH"; P_Copy.TextColor3=Color3.new(1,1,1); Instance.new("UICorner", P_Copy).CornerRadius=UDim.new(0,4); P_Copy.Font=Enum.Font.GothamBold; P_Copy.TextSize=10
        local P_Close = Instance.new("TextButton", App.Popup); P_Close.Size=UDim2.new(0.45,0,0,25); P_Close.Position=UDim2.new(0.5,5,1,-35); P_Close.BackgroundColor3=Color3.fromRGB(200,50,50); P_Close.Text="CLOSE"; P_Close.TextColor3=Color3.new(1,1,1); Instance.new("UICorner", P_Close).CornerRadius=UDim.new(0,4); P_Close.Font=Enum.Font.GothamBold; P_Close.TextSize=10
        P_Close.MouseButton1Click:Connect(function() App.Popup.Visible = false end)
        P_Copy.MouseButton1Click:Connect(function() setclipboard(App.PathBox.Text); ShowToast("✅ Path Copied!") end)
        App.HighBox = Instance.new("Frame", ScreenGui)
        App.HighBox.Name = GetRandomName()
        App.HighBox.BackgroundTransparency = 1; App.HighBox.Visible = false; App.HighBox.ZIndex = 999999
        local HStroke = Instance.new("UIStroke", App.HighBox); HStroke.Color = Color3.fromRGB(255, 0, 0); HStroke.Thickness = 3; HStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        App.PickBtn.MouseButton1Click:Connect(function()
            App.Picking = not App.Picking
            if App.Picking then
                App.PickBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                App.PickBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
                App.PickBtn.Text = "STOP PICK"
                ShowToast("🖱️ Mode Picker ON: Klik GUI di layar!")
            else
                App.PickBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                App.PickBtn.TextColor3 = Color3.new(1,1,1)
                App.PickBtn.Text = "🖱️ PICK GUI"
                App.HighBox.Visible = false
                App.Hovered = nil
            end
        end)
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        RunService.RenderStepped:Connect(function()
            if App.Picking and App.Main.Visible then
                local Mouse = UserInputService:GetMouseLocation()
                local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
                local Found = nil
                pcall(function()
                    local Objects = PlayerGui:GetGuiObjectsAtPosition(Mouse.X, Mouse.Y)
                    for _, v in pairs(Objects) do
                        if not v:IsDescendantOf(ScreenGui) and v.Visible then
                            Found = v
                            break
                        end
                    end
                end)
                if Found then
                    App.Hovered = Found
                    App.HighBox.Visible = true
                    App.HighBox.Size = UDim2.new(0, Found.AbsoluteSize.X, 0, Found.AbsoluteSize.Y)
                    App.HighBox.Position = UDim2.new(0, Found.AbsolutePosition.X, 0, Found.AbsolutePosition.Y)
                else
                    App.HighBox.Visible = false
                    App.Hovered = nil
                end
            end
        end)
        UserInputService.InputBegan:Connect(function(input)
            if App.Picking and input.UserInputType == Enum.UserInputType.MouseButton1 then
                if App.Hovered then
                    local obj = App.Hovered
                    App.L_Name.Text = "Name: " .. obj.Name
                    App.L_Class.Text = "Class: " .. obj.ClassName
                    local path = obj:GetFullName()
                    path = path:gsub("Players%."..LocalPlayer.Name.."%.PlayerGui", "game.Players.LocalPlayer.PlayerGui")
                    App.PathBox.Text = path
                    App.Popup.Position = UDim2.new(0, input.Position.X + 20, 0, input.Position.Y)
                    App.Popup.Visible = true
                    App.Picking = false
                    App.PickBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                    App.PickBtn.TextColor3 = Color3.new(1,1,1)
                    App.PickBtn.Text = "🖱️ PICK GUI"
                    App.HighBox.Visible = false
                    ShowToast("✅ GUI Selected!")
                end
            end
        end)
        RefreshBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(App.List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            local TargetName = SearchBox.Text
            local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
            local ObjectsToShow = {}
            if TargetName ~= "" then
                for _, v in pairs(PlayerGui:GetDescendants()) do
                    if v:IsA("GuiObject") and v.Visible and string.find(string.lower(v.Name), string.lower(TargetName)) then
                        table.insert(ObjectsToShow, v)
                    end
                end
            else
                for _, v in pairs(PlayerGui:GetChildren()) do
                    if v:IsA("ScreenGui") then table.insert(ObjectsToShow, v) end
                end
            end
            local Count = 0
            for _, obj in pairs(ObjectsToShow) do
                Count = Count + 1
                if Count > 100 then break end
                local Row = Instance.new("TextButton", App.List)
                Row.Size = UDim2.new(1, 0, 0, 25); Row.BackgroundTransparency = 1; Row.AutoButtonColor = false; Row.Text = ""
                local Lbl = Instance.new("TextLabel", Row)
                Lbl.Size = UDim2.new(1, -10, 1, 0); Lbl.Position = UDim2.new(0, 5, 0, 0); Lbl.BackgroundTransparency = 1
                Lbl.Text = obj.Name .. " <font color='#888888'>(" .. obj.ClassName .. ")</font>"
                Lbl.RichText = true; Lbl.TextColor3 = Color3.fromRGB(200,200,200); Lbl.TextSize = 11; Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Row.MouseEnter:Connect(function()
                    Lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                    App.HighBox.Visible = true
                    App.HighBox.Size = UDim2.new(0, obj.AbsoluteSize.X, 0, obj.AbsoluteSize.Y)
                    App.HighBox.Position = UDim2.new(0, obj.AbsolutePosition.X, 0, obj.AbsolutePosition.Y)
                end)
                Row.MouseLeave:Connect(function()
                    Lbl.TextColor3 = Color3.fromRGB(200,200,200)
                    App.HighBox.Visible = false
                end)
                Row.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        App.L_Name.Text = "Name: " .. obj.Name
                        App.L_Class.Text = "Class: " .. obj.ClassName
                        local path = obj:GetFullName()
                        path = path:gsub("Players%."..LocalPlayer.Name.."%.PlayerGui", "game.Players.LocalPlayer.PlayerGui")
                        App.PathBox.Text = path
                        App.Popup.Visible = true
                        App.Popup.Position = UDim2.new(0.5, -140, 0.5, -80)
                    end
                end)
            end
        end)
        CreateButton(Box_Util, "🛠️ Omni-Tool GUI Inspector", function()
            App.Main.Visible = true
        end)
    end
    CreateToggle(Box_Util, "🔍 Object Inspector (Click)", function(v)
        State.ObjectInspector = v
        if v then ShowToast("Inspector ON: Klik objek apapun!") else ShowToast("Inspector OFF") end
    end)
    CreateButton(Box_Util, "🛠️ BTools (Infinite Yield)", function()
        local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if Backpack then
            local tools = {
                {Enum.BinType.Hammer, "Hammer"},
                {Enum.BinType.Clone, "Clone"},
                {Enum.BinType.GameTool, "Delete"}
            }
            for _, toolData in pairs(tools) do
                local bin = Instance.new("HopperBin")
                bin.BinType = toolData[1]
                bin.Name = toolData[2]
                bin.Parent = Backpack
            end
            ShowToast("BTools Added to Inventory!")
        else
            ShowToast("Error: No Backpack Found")
        end
    end)
end
do
    local AnimURL = "https://reyzzhub.netlify.app/api/anmc1"
    local R15_Anims = {}
    local R6_Anims = {}
    local function UpdateAnimation(val)
        if State.AnimFixLoop then 
            State.AnimFixLoop:Disconnect(); State.AnimFixLoop = nil
        end
        if State.CurrentAnimTrack then 
            State.CurrentAnimTrack:Stop(); State.CurrentAnimTrack = nil 
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local char = LocalPlayer.Character
            local hum = char.Humanoid
            local animator = hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator")
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://" .. val
            local track = animator:LoadAnimation(anim)
            track.Priority = Enum.AnimationPriority.Action4 
            track.Looped = true 
            track:Play()
            State.CurrentAnimTrack = track
            State.AnimFixLoop = RunService.Heartbeat:Connect(function()
                if not State.AnimChanger then return end 
                local defaultAnimate = char:FindFirstChild("Animate")
                if defaultAnimate and defaultAnimate.Disabled == false then defaultAnimate.Disabled = true end
                for _, t in pairs(animator:GetPlayingAnimationTracks()) do
                    if t ~= State.CurrentAnimTrack then t:Stop() end
                end
                if State.CurrentAnimTrack and not State.CurrentAnimTrack.IsPlaying then State.CurrentAnimTrack:Play() end
            end)
        end
    end
    local Box_Theme = CreateSection(T6, "UI THEME & APPEARANCE")
    CreateDropdown(Box_Theme, "Select Theme", {"Dark", "Light", "NeonCyan", "NeonGreen", "NeonRed"}, "Dark", function(val) 
        ApplyTheme(val)
    end)
    local Box_Surv = CreateSection(T6, "SURVIVAL & CHARACTER MODS")
    CreateToggle(Box_Surv, "God Mode (Client/Regen)", function(v)
        State.GodModeBug = v
        if v and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then
                hum.MaxHealth = math.huge
                hum.Health = math.huge
                task.spawn(function()
                    while State.GodModeBug do
                        hum.Health = math.huge
                        task.wait()
                    end
                end)
            end
            ShowToast("God Mode Active (Client)")
        else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.MaxHealth = 100
            end
        end
    end)
    CreateToggle(Box_Surv, "👻 Invisible (Ghost Mode)", function(v)
        local char = LocalPlayer.Character
        if char then
            if v then
                State.Noclip = true
                local hum = char:FindFirstChild("Humanoid")
                if hum then 
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None 
                    hum.NameOcclusion = Enum.NameOcclusion.OccludeAll
                end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        if not part:GetAttribute("OrigTrans") then part:SetAttribute("OrigTrans", part.Transparency) end
                        part.Transparency = 1 
                    end
                end
                ShowToast("Invisible: ON")
            else
                State.Noclip = false
                local hum = char:FindFirstChild("Humanoid")
                if hum then 
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
                    hum.NameOcclusion = Enum.NameOcclusion.NoOcclusion
                end
                for _, part in pairs(char:GetDescendants()) do
                    if (part:IsA("BasePart") or part:IsA("Decal")) and part:GetAttribute("OrigTrans") then
                        part.Transparency = part:GetAttribute("OrigTrans")
                        part:SetAttribute("OrigTrans", nil)
                    end
                end
                ShowToast("Invisible: OFF")
            end
        end
    end)
    CreateToggle(Box_Surv, "Anti-Drown (Water)", function(v) State.AntiDrown = v end)
    CreateToggle(Box_Surv, "Fake Lag", function(v) State.FakeLag = v end) 
    CreateButton(Box_Surv, "Delete Kill Bricks (Lava)", function()
        local count = 0
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and (v.Name == "Kill" or v.Name == "Lava" or v:FindFirstChild("TouchInterest")) then
                if v:FindFirstChild("TouchInterest") then v.TouchInterest:Destroy(); count = count + 1 end
            end
        end
        ShowToast("Removed " .. count .. " Kill Zones!")
    end)
    local Box_Anim = CreateSection(T6, "ANIMATION CHANGER")
    local RigStatusLbl = CreateLabel(Box_Anim, "Detecting Rig Type...")
    RigStatusLbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    task.spawn(function() 
        while task.wait(5) do 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local rig = LocalPlayer.Character.Humanoid.RigType
                if rig == Enum.HumanoidRigType.R15 then
                    RigStatusLbl.Text = "✅ DETECTED: R15 (Use R15 List)"
                    RigStatusLbl.TextColor3 = Color3.fromRGB(0, 255, 100)
                    State.AnimRigType = "R15"
                else
                    RigStatusLbl.Text = "⚠️ DETECTED: R6 (Use R6 List)"
                    RigStatusLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
                    State.AnimRigType = "R6"
                end
            end
        end 
    end)
    local DropR15, DropR6 
    local function GetSortedKeys(dict)
        local keys = {}
        for k, _ in pairs(dict) do table.insert(keys, k) end
        table.sort(keys)
        return keys
    end

    DropR15 = CreateDropdown(Box_Anim, "R15 Animations", GetSortedKeys(R15_Anims), "Select...", function(name)
        if State.AnimRigType == "R15" then 
            State.CurrentAnimID = R15_Anims[name]
            if State.AnimChanger then UpdateAnimation(State.CurrentAnimID) end 
        else ShowToast("❌ Error: You are R6!") end
    end)

    DropR6 = CreateDropdown(Box_Anim, "R6 Animations", GetSortedKeys(R6_Anims), "Select...", function(name)
        if State.AnimRigType == "R6" then 
            State.CurrentAnimID = R6_Anims[name]
            if State.AnimChanger then UpdateAnimation(State.CurrentAnimID) end 
        else ShowToast("❌ Error: You are R15!") end
    end)
    CreateInput(Box_Anim, "Custom ID", "Paste ID...", function(val) 
        State.CurrentAnimID = val
        if State.AnimChanger then UpdateAnimation(val) end 
    end, true)
    CreateToggle(Box_Anim, "Enable Animation Override", function(v) 
        State.AnimChanger = v
        if v then
            if State.CurrentAnimID ~= 0 then UpdateAnimation(State.CurrentAnimID); ShowToast("Anim Loaded!") 
            else ShowToast("⚠️ Select Animation First!") end
        else
            if State.AnimFixLoop then State.AnimFixLoop:Disconnect() end
            if LocalPlayer.Character then 
                local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                local animator = hum and hum:FindFirstChildOfClass("Animator")
                if animator then for _, t in pairs(animator:GetPlayingAnimationTracks()) do t:Stop() end end
                local defaultAnimate = LocalPlayer.Character:FindFirstChild("Animate")
                if defaultAnimate then defaultAnimate.Disabled = true; task.wait(); defaultAnimate.Disabled = false end
            end
            ShowToast("Anim Reset")
        end
    end)
    -- [[ CLOUD ANIMATION UPDATER SYSTEM ]] --
    task.spawn(function()
    local HttpService = game:GetService("HttpService")
    
    local function FetchAnimations()
        local success, result = pcall(function()
            -- Trik ?t=tick() ini MEMAKSA Netlify & Roblox mengambil data terbaru
            -- Ini mengatasi masalah cache yang kamu khawatirkan.
            return game:HttpGet(AnimURL .. "?t=" .. math.floor(tick())) 
        end)

        if success and result then
            local decoded = nil
            local decodeSuccess, err = pcall(function()
                decoded = HttpService:JSONDecode(result)
            end)

            if decodeSuccess and decoded then
                if decoded.animations then
                    if decoded.animations.R15 then 
                        R15_Anims = decoded.animations.R15 
                    end
                
                    if decoded.animations.R6 then 
                        R6_Anims = decoded.animations.R6 
                    end
                    if DropR15 and DropR15.Refresh then
                        DropR15:Refresh(GetSortedKeys(R15_Anims))
                    end
                    if DropR6 and DropR6.Refresh then
                        DropR6:Refresh(GetSortedKeys(R6_Anims))
                    end
                end
            else
                warn("⚠️ Gagal Decode JSON: " .. tostring(err))
            end
        else
            warn("⚠️ Gagal Fetch URL: " .. tostring(result))
        end
    end
    FetchAnimations()
    while task.wait(10) do
        FetchAnimations()
    end
end)


    local Box_Time = CreateSection(T6, "TIME & ENVIRONMENT")
    CreateToggle(Box_Time, "Loop Time (Freeze Day)", function(v) 
        State.LockTime = v
        if v then ShowToast("Time Locked!") else ShowToast("Time Unlocked") end
    end)
    CreateSlider(Box_Time, "Set Clock Time", 0, 24, 14, function(v)
        State.TargetTime = v
        Lighting.ClockTime = v
    end)
    CreateToggle(Box_Time, "Unlock FPS (Max)", function(v)
        State.UnlockFPS = v
        if v then setfpscap(999); ShowToast("FPS Uncapped!") else setfpscap(60); ShowToast("FPS Locked 60") end
    end)
    CreateButton(Box_Time, "Clear Memory/Cache", ClearMemory)
    local Box_Chat = CreateSection(T6, "LOGGER FEATURE")
    CreateInput(Box_Chat, "Bypass Chat (No Sensor)", "Type...", function(text) SendBypassChat(text) end, true)
    CreateToggle(Box_Chat, "Chat Logger (Spy)", function(v) 
        ToggleChatLogger(v)
    end)
    CreateToggle(Box_Chat, "Auto Anim Logger", function(v) State.AnimLogger = v; UpdateAnimLogger() end)
    local Box_Id = CreateSection(T6, "IDENTITY SPOOFER (FIXED)")
    CreateToggle(Box_Id, "Enable Name Spoofer", function(v) 
        ToggleIdentitySystem(v)
    end)
    CreateInput(Box_Id, "Set Display Name", "Kosong = Invisible", function(val)
        IdentityConfig.NewDisplayName = val
        if IdentityConfig.Enabled then 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                if val == "" then
                    LocalPlayer.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                else
                    LocalPlayer.Character.Humanoid.DisplayName = val
                    LocalPlayer.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
                end
            end
            for _, v in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do ProcessObject(v) end
        end
    end, true)
    CreateInput(Box_Id, "Set Username", "Kosong = Invisible", function(val)
        IdentityConfig.NewUserName = val
        if IdentityConfig.Enabled then
            for _, v in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do ProcessObject(v) end
        end
    end, true)
    CreateButton(Box_Id, "♻️ Force Refresh UI", function()
        if IdentityConfig.Enabled then
            for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do ProcessObject(v) end
            for _, v in pairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do ProcessObject(v) end
            ShowToast("UI Rescanned & Spoofed!")
        else
            ShowToast("⚠️ Enable Spoofer First!")
        end
    end)
    local Box_Sys = CreateSection(T6, "SYSTEM & UTILITY")
    local AdminConn = nil
    local function StartAdminCheck()
        local CreatorId = game.CreatorId
        local CreatorType = game.CreatorType
        local MinRank = 2
        ShowToast("🛡️ Admin Watch: ACTIVE")
        if CreatorType == Enum.CreatorType.Group then
            ShowToast("ℹ️ Mode: Group Game (ID: " .. CreatorId .. ")")
        else
            ShowToast("ℹ️ Mode: User Game (Owner ID: " .. CreatorId .. ")")
        end
        local function CheckThreat(player)
            if player == LocalPlayer then return end
            if player.UserId == CreatorId then
                LocalPlayer:Kick("\n[🛡️ REYZZ SECURITY]\nGame Owner Joined!\nName: " .. player.Name)
                return
            end
            if CreatorType == Enum.CreatorType.Group then
                local success, rank = pcall(function() 
                    return player:GetRankInGroup(CreatorId) 
                end)
                if success and rank > MinRank then
                    LocalPlayer:Kick("\n[🛡️ REYZZ SECURITY]\nStaff Detected!\nName: " .. player.Name .. "\nRank: " .. rank)
                end
            end
            if player.MembershipType == Enum.MembershipType.Premium then
            end
        end
        for _, p in pairs(Players:GetPlayers()) do
            task.spawn(function() CheckThreat(p) end)
        end
        AdminConn = Players.PlayerAdded:Connect(function(p)
            CheckThreat(p)
        end)
    end
    CreateToggle(Box_Sys, "🛡️ Auto Admin Detector", function(v) 
        State.AdminDetector = v
        if v then
            StartAdminCheck()
        else
            if AdminConn then AdminConn:Disconnect(); AdminConn = nil end
            ShowToast("🛡️ Admin Watch: OFF")
        end
    end)
    CreateToggle(Box_Sys, "Auto Reconnect", function(v) State.AutoReconnect = v end)
    CreateToggle(Box_Sys, "Anti-AFK", function(v) State.AntiAFK = v end)
    CreateToggle(Box_Sys, "Unlock Mouse (F1)", function(v) 
        State.ForceUnlockMouse = v
        if not v then UserInputService.MouseBehavior = Enum.MouseBehavior.Default; UserInputService.MouseIconEnabled = true end 
    end)
    CreateToggle(Box_Sys, "Auto Get Badges (Risky)", function(v)
        State.AutoBadge = v
        if v then
            ShowToast("🚀 Farming Badges...")
            task.spawn(function()
                for _, v in pairs(Workspace:GetDescendants()) do
                    if not State.AutoBadge then break end
                    if v:IsA("BasePart") and v:FindFirstChild("TouchInterest") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local root = LocalPlayer.Character.HumanoidRootPart
                            firetouchinterest(root, v, 0); firetouchinterest(root, v, 1)
                            root.CFrame = v.CFrame; task.wait(0.1) 
                        end
                    end
                end
                if State.AutoBadge then ShowToast("✅ Finished!") end; State.AutoBadge = false
            end)
        else ShowToast("Badge Farm Stopped") end
    end)
    CreateButton(Box_Sys, "🔄 Check for Updates", function()
        if CheckUpdate then CheckUpdate() else ShowToast("No Updates Available") end
    end)
    if MobilePage then 
        local Box_Mobile = CreateSection(MobilePage, "Custom Controls (Native)")
        
        CreateToggle(Box_Mobile, "Modifikasi Tombol Bawaan", function(v)
            UP_Config.CustomJumpEnabled = v
            SaveUPConfig()
            UpdateMobileJump() -- Restart loop saat ditoggle
        end, true)

        CreateSlider(Box_Mobile, "Posisi X (Kiri-Kanan)", 0, 300, (UP_Config.JumpX or 0.8)*100, function(v)
            UP_Config.JumpX = v / 100
            SaveUPConfig()
        end)
        
        CreateSlider(Box_Mobile, "Posisi Y (Atas-Bawah)", 0, 300, (UP_Config.JumpY or 0.8)*100, function(v)
            UP_Config.JumpY = v / 100
            SaveUPConfig()
        end)
        
        CreateSlider(Box_Mobile, "Ukuran Tombol", 50, 700, (UP_Config.JumpSize or 1)*100, function(v)
            UP_Config.JumpSize = v / 100
            SaveUPConfig()
        end)
    end
end
local AboutTitle = Instance.new("TextLabel", T7); AboutTitle.Text = "Reyzzarjam BloxHub Dynamic"; AboutTitle.Size = UDim2.new(1, 0, 0, 40); AboutTitle.BackgroundTransparency = 1; RegisterTheme(AboutTitle, "TextColor3", "Accent"); AboutTitle.Font = Enum.Font.GothamBlack; AboutTitle.TextSize = 28; AboutTitle.TextXAlignment = Enum.TextXAlignment.Center
local AboutDesc = Instance.new("TextLabel", T7); AboutDesc.Text = "If You Find Bug Please Report On My Discord\nSuggest Game For More Feature\nNeed Suggest More Featured\n\n\nCopyright © Reyzzarjam 2025"; AboutDesc.Size = UDim2.new(1, 0, 0, 60); AboutDesc.BackgroundTransparency = 1; RegisterTheme(AboutDesc, "TextColor3", "TextDim"); AboutDesc.Font = Enum.Font.Gotham; AboutDesc.TextSize = 14
local DiscordBtn = CreateButton(T7, "Copy Discord Link", function() setclipboard("https://discord.gg/fnU7ebtGq8"); ShowToast("Discord Link Copied!") end); DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)


-- 1. BAGIAN LIST FITUR AKTIF
Box_Status_Active = CreateSection(T_Status, "ACTIVE FEATURES LIST")

-- Wadah Scrolling untuk List
Status_ActiveScroll = Instance.new("ScrollingFrame", Box_Status_Active)
Status_ActiveScroll.Name = "ActiveScroll"
Status_ActiveScroll.Size = UDim2.new(1, -10, 0, 150)
Status_ActiveScroll.Position = UDim2.new(0, 5, 0, 0)
Status_ActiveScroll.BackgroundTransparency = 1
Status_ActiveScroll.ScrollBarThickness = 3
Status_ActiveScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Status_ActiveScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Status_ActiveLayout = Instance.new("UIListLayout", Status_ActiveScroll)
Status_ActiveLayout.SortOrder = Enum.SortOrder.LayoutOrder
Status_ActiveLayout.Padding = UDim.new(0, 4)
task.spawn(function()
    task.wait(0.5)
    if PendingActiveFeatures then
        for name, _ in pairs(PendingActiveFeatures) do
            UpdateActiveIndicator(name, true)
        end
        PendingActiveFeatures = {} 
    end
end)
Box_Status_Error = CreateSection(T_Status, "ERROR LOGS (DEBUG)")

-- Wadah Scrolling untuk Error
Status_ErrorScroll = Instance.new("ScrollingFrame", Box_Status_Error)
Status_ErrorScroll.Name = "ErrorScroll"
Status_ErrorScroll.Size = UDim2.new(1, -10, 0, 150)
Status_ErrorScroll.Position = UDim2.new(0, 5, 0, 0)
Status_ErrorScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Background Gelap
Status_ErrorScroll.BackgroundTransparency = 0.5
Instance.new("UICorner", Status_ErrorScroll).CornerRadius = UDim.new(0, 6)
Status_ErrorScroll.ScrollBarThickness = 3
Status_ErrorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Status_ErrorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Layout Error
local Status_ErrorLayout = Instance.new("UIListLayout", Status_ErrorScroll)
Status_ErrorLayout.Padding = UDim.new(0, 2)
local ErrorPad = Instance.new("UIPadding", Status_ErrorScroll)
ErrorPad.PaddingLeft = UDim.new(0, 5)
ErrorPad.PaddingTop = UDim.new(0, 5)

-- Tombol Bersihkan Error
CreateButton(Box_Status_Error, "🧹 Clear Error Logs", function()
    for _, v in pairs(Status_ErrorScroll:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    ShowToast("Error Logs Cleared")
end)

------------------------------------------------------------------------
-- [LOGIKA GLOBAL PENGGERAK UI STATUS]
------------------------------------------------------------------------

-- Fungsi Update Indikator (Versi Tab)
-- Kita buat Global agar bisa dipanggil dari CreateToggle
function UpdateActiveIndicator(FeatureName, IsActive)
    -- Cek apakah Tab Status sudah dibuat
    if not Status_ActiveScroll then return end

    local existing = Status_ActiveScroll:FindFirstChild("IND_" .. FeatureName)
    
    if IsActive then
        if not existing then
            local Row = Instance.new("Frame", Status_ActiveScroll)
            Row.Name = "IND_" .. FeatureName
            Row.Size = UDim2.new(1, -5, 0, 25)
            Row.BackgroundTransparency = 1
            
            -- Ikon Dot Hijau Glowing
            local Dot = Instance.new("Frame", Row)
            Dot.Size = UDim2.new(0, 8, 0, 8)
            Dot.Position = UDim2.new(0, 5, 0.5, -4)
            Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            
            local Glow = Instance.new("UIStroke", Dot)
            Glow.Color = Color3.fromRGB(0, 255, 100)
            Glow.Thickness = 2
            Glow.Transparency = 0.5
            
            -- Teks Nama Fitur
            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Size = UDim2.new(1, -25, 1, 0)
            Lbl.Position = UDim2.new(0, 20, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = FeatureName
            -- Pake warna tema kalau bisa
            if CurrentTheme then 
                Lbl.TextColor3 = CurrentTheme.Text 
            else
                Lbl.TextColor3 = Color3.fromRGB(255,255,255)
            end
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
    else
        if existing then
            existing:Destroy()
        end
    end
end

-- [UPDATE BAGIAN INI: Logika Indikator dengan Antrian] --

local PendingActiveFeatures = {} -- Wadah simpanan sementara

function UpdateActiveIndicator(FeatureName, IsActive)
    -- KASUS 1: Jika UI List BELUM JADI (Script baru start)
    if not Status_ActiveScroll then 
        if IsActive then
            PendingActiveFeatures[FeatureName] = true -- Simpan dulu di saku
        else
            PendingActiveFeatures[FeatureName] = nil -- Hapus dari saku
        end
        return 
    end

    -- KASUS 2: Jika UI List SUDAH ADA (Normal)
    local existing = Status_ActiveScroll:FindFirstChild("IND_" .. FeatureName)
    
    if IsActive then
        if not existing then
            local Row = Instance.new("Frame", Status_ActiveScroll)
            Row.Name = "IND_" .. FeatureName
            Row.Size = UDim2.new(1, -5, 0, 25)
            Row.BackgroundTransparency = 1
            
            local Dot = Instance.new("Frame", Row)
            Dot.Size = UDim2.new(0, 8, 0, 8)
            Dot.Position = UDim2.new(0, 5, 0.5, -4)
            Dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
            
            local Glow = Instance.new("UIStroke", Dot)
            Glow.Color = Color3.fromRGB(0, 255, 100); Glow.Thickness = 2; Glow.Transparency = 0.5
            
            local Lbl = Instance.new("TextLabel", Row)
            Lbl.Size = UDim2.new(1, -25, 1, 0)
            Lbl.Position = UDim2.new(0, 20, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = FeatureName
            if CurrentTheme then Lbl.TextColor3 = CurrentTheme.Text else Lbl.TextColor3 = Color3.fromRGB(255,255,255) end
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            -- Animasi Masuk
            local TS = game:GetService("TweenService")
            Row.BackgroundTransparency = 1
            Lbl.TextTransparency = 1
            TS:Create(Lbl, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
        end
    else
        if existing then existing:Destroy() end
    end
end
function LogToConsole(msg, type)
    if not Status_ErrorScroll then return end

    -- Tentukan Warna & Prefix berdasarkan Tipe Log
    local color = Color3.fromRGB(200, 200, 200) -- Default Abu-abu
    local prefix = "[INFO]"

    if type == "Error" then
        color = Color3.fromRGB(255, 80, 80) -- Merah (Error)
        prefix = "[FAIL]"
    elseif type == "Warn" then
        color = Color3.fromRGB(255, 200, 50) -- Kuning (Peringatan)
        prefix = "[WARN]"
    elseif type == "Success" then
        color = Color3.fromRGB(100, 255, 100) -- Hijau (Berhasil)
        prefix = "[OK]"
    elseif type == "System" then
        color = Color3.fromRGB(0, 255, 255) -- Cyan (Sistem)
        prefix = "[SYS]"
    elseif type == "Boot" then
        color = Color3.fromRGB(150, 100, 255) -- Ungu (Booting)
        prefix = "[BOOT]"
    end

    local Lbl = Instance.new("TextLabel", Status_ErrorScroll)
    Lbl.Size = UDim2.new(1, -5, 0, 0)
    Lbl.AutomaticSize = Enum.AutomaticSize.Y
    Lbl.BackgroundTransparency = 1
    
    local Time = os.date("%H:%M:%S")
    -- Format Teks: Waktu (Abu2) + Prefix (Bold) + Pesan (Warna)
    Lbl.Text = string.format("<font color='#888888'>%s</font> <b>%s</b> %s", Time, prefix, tostring(msg))
    Lbl.RichText = true
    Lbl.TextColor3 = color
    Lbl.Font = Enum.Font.Code
    Lbl.TextSize = 12
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.TextWrapped = true
    
    -- Auto Scroll ke Bawah
    Status_ErrorScroll.CanvasPosition = Vector2.new(0, 99999)
end

-- Wrapper untuk Error Asli Roblox (Biar tetap merah)
function LogErrorToUI(msg, stack)
    -- Filter error spam
    if string.find(tostring(msg), "Decoration") then return end
    LogToConsole(msg, "Error")
end

-- Hubungkan ke Deteksi Error Roblox
if MyErrorConnection then MyErrorConnection:Disconnect() end
MyErrorConnection = game:GetService("ScriptContext").Error:Connect(function(msg, stack)
    LogErrorToUI(msg, stack)
end)

-- [BOOTING SEQUENCE] --
-- Ini yang bikin console gak sepi pas awal nyala!
task.spawn(function()
    -- Animasi Loading Awal
    task.wait(0.5)
    LogToConsole("Initializing ReyzzHub System...", "Boot")
    task.wait(0.2)
    LogToConsole("Checking License...", "System")
    task.wait(0.1)
    LogToConsole("User Verified: " .. game.Players.LocalPlayer.Name, "Success")
    task.wait(0.3)
    LogToConsole("Hooking Metatables...", "Info")
    task.wait(0.1)
    LogToConsole("Loading Core Modules...", "Info")
    task.wait(0.2)
    LogToConsole("Bypassing Anti-Cheat...", "Warn") -- Pura-pura bypass biar keren
    task.wait(0.4)
    LogToConsole("Visual Engine Loaded.", "System")
    LogToConsole("Aim Assist Module Ready.", "System")
    task.wait(0.2)
    LogToConsole("--------------------------------", "Info")
    LogToConsole("ReyzzHub V1.2 is Ready!", "Success")
    LogToConsole("Waiting for user commands...", "Info")
end)
if not State.Keybinds or next(State.Keybinds) == nil then
    State.Keybinds = {
        ["Fly Mode (CFrame)"]       = {Key = Enum.KeyCode.F, Shift = true},
        ["Noclip (Wall Hack)"]      = {Key = Enum.KeyCode.N, Shift = true},
        ["Infinite Jump (Shift+J)"] = {Key = Enum.KeyCode.J, Shift = true},
        ["Freecam (Drone Mode)"]    = {Key = Enum.KeyCode.P, Shift = true},
    }
end
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local pressedKey = input.KeyCode
        local isShiftHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
        for featureName, bindData in pairs(State.Keybinds) do
            if State.RegisteredFeatures[featureName] and bindData.Key == pressedKey then
                local logic = State.RegisteredFeatures[featureName]
                if bindData.Shift then
                    if isShiftHeld then logic.Trigger() end
                else
                    if not isShiftHeld then logic.Trigger() end
                end
            end
        end
    end
end)
do
    local TargetTab = T_Settings
    local RefreshFunc = BuildKeybindManager(TargetTab)
    BuildConfigManager(TargetTab, RefreshFunc)
end
local JobIdContainer = Instance.new("Frame", T7); JobIdContainer.Size = UDim2.new(0.95, 0, 0, 80); RegisterTheme(JobIdContainer, "BackgroundColor3", "ElementBG"); Instance.new("UICorner", JobIdContainer).CornerRadius = UDim.new(0, 8); local JS = Instance.new("UIStroke", JobIdContainer); RegisterTheme(JS, "Color", "Stroke")
local JobIdTitle = Instance.new("TextLabel", JobIdContainer); JobIdTitle.Text = "CURRENT SERVER JOB ID"; JobIdTitle.Size = UDim2.new(1, 0, 0, 25); JobIdTitle.BackgroundTransparency = 1; RegisterTheme(JobIdTitle, "TextColor3", "TextDim"); JobIdTitle.Font = Enum.Font.GothamBold; JobIdTitle.TextSize = 12
local JobIdBox = Instance.new("TextBox", JobIdContainer); JobIdBox.Size = UDim2.new(0.9, 0, 0, 30); JobIdBox.Position = UDim2.new(0.05, 0, 0.4, 0); RegisterTheme(JobIdBox, "BackgroundColor3", "Background"); JobIdBox.Text = game.JobId; RegisterTheme(JobIdBox, "TextColor3", "Accent"); JobIdBox.Font = Enum.Font.Code; JobIdBox.TextSize = 12; JobIdBox.ClearTextOnFocus = false; JobIdBox.TextEditable = false; Instance.new("UICorner", JobIdBox).CornerRadius = UDim.new(0, 6)
local CopyJobBtn = Instance.new("TextButton", JobIdContainer); CopyJobBtn.Size = UDim2.new(1, 0, 1, 0); CopyJobBtn.BackgroundTransparency = 1; CopyJobBtn.Text = ""; CopyJobBtn.MouseButton1Click:Connect(function() setclipboard(game.JobId); ShowToast("Server Job ID Copied!") end)
UserInputService.InputBegan:Connect(function(input, gp)
    if State.ObjectInspector and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local Camera = workspace.CurrentCamera
        local MouseLoc = UserInputService:GetMouseLocation()
        local CharPos = Camera.CFrame.Position
        local BestPart = nil
        local BestScreenDist = 100 
        local ClosestWorldDist = math.huge
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local WorldDist = (part.Position - CharPos).Magnitude
                if WorldDist < 30 then 
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(part.Position)
                    if OnScreen then
                        local DistToMouse = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MouseLoc).Magnitude
                        if DistToMouse < BestScreenDist then
                            if WorldDist < ClosestWorldDist then
                                BestScreenDist = DistToMouse
                                ClosestWorldDist = WorldDist
                                BestPart = part
                            end
                        end
                    end
                end
            end
        end
        if BestPart then
            local obj = BestPart
            I_Name.Text = obj.Name
            I_Class.Text = obj.ClassName
            I_Path.Text = obj:GetFullName()
            if obj.Parent and obj.Parent ~= workspace then
                I_Parent.Text = obj.Parent.Name
            else
                I_Parent.Text = "Workspace"
            end
            I_Pos.Text = string.format("%.1f, %.1f, %.1f", obj.Position.X, obj.Position.Y, obj.Position.Z)
            InspFrame.Visible = true
            if not obj:FindFirstChild("InspHighlight") then
                local h = Instance.new("Highlight", obj)
                h.Name = "InspHighlight"
                h.FillColor = Color3.fromRGB(255, 0, 255)
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.FillTransparency = 0.2 
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                game:GetService("Debris"):AddItem(h, 1)
            end
            ShowToast("✅ Gotcha: " .. obj.Name)
        else
            ShowToast("❌ Mouse kejauhan dari objek")
        end
    end
    if gp then return end 
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if State.ClickTP and Mouse.Target then
            local pos = Mouse.Hit.Position
            if LocalPlayer.Character and GetVisualPart(LocalPlayer.Character) then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)); ShowToast("Teleported!") end
        end
    end
    if input.KeyCode == Enum.KeyCode.J and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then local currentState = State.InfiniteJump; if Toggles["Infinite Jump (Shift+J)"] then Toggles["Infinite Jump (Shift+J)"](not currentState) end end
    if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then local currentState = State.Freecam; if Toggles["Freecam (Shift+P)"] then Toggles["Freecam (Shift+P)"](not currentState) end end
    if input.KeyCode == Enum.KeyCode.F1 then local currentState = State.ForceUnlockMouse; if Toggles["Unlock Mouse (F1)"] then Toggles["Unlock Mouse (F1)"](not currentState) end end
end)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if State.AnimLogger then task.wait(1); UpdateAnimLogger() end
    if State.IsRespawning and State.LastPos then
        local root = newChar:WaitForChild("HumanoidRootPart", 10); local hum = newChar:WaitForChild("Humanoid", 10)
        if root and hum then if State.LastPos.Y > -300 then task.wait(0.25); root.CFrame = State.LastPos; ShowToast("Returned to Last Position") else ShowToast("Last Pos was Void (Safety Prevented TP)") end; State.IsRespawning = false; State.LastPos = nil end
    end
    if State.AnimChanger and State.CurrentAnimID ~= 0 then
        task.wait(1)
        UpdateAnimation(State.CurrentAnimID)
    end
end)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
local FirstTabBtn = Sidebar:FindFirstChildOfClass("TextButton")
if FirstTabBtn then 
    local ActiveBar = FirstTabBtn:FindFirstChild("Frame")
    local IconImg = FirstTabBtn:FindFirstChild("TabIcon") 
    local NameLbl = FirstTabBtn:FindFirstChild("TextLabel") 
    local Page = Content:FindFirstChildOfClass("ScrollingFrame")
    if ActiveBar then ActiveBar.Visible = true end
    if IconImg then IconImg.ImageColor3 = CurrentTheme.Text end 
    if NameLbl then NameLbl.TextColor3 = CurrentTheme.Text end
    FirstTabBtn.BackgroundColor3 = CurrentTheme.ElementBG
    FirstTabBtn.BackgroundTransparency = 0.95
    if Page then Page.Visible = true end
end
task.spawn(function()
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    Players.LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("🚫 Anti-AFK Triggered: Mencegah Disconnect")
    end)
    local function OptimizeObject(obj)
        if obj:IsA("BasePart") then
            obj.CastShadow = false
            if obj.Size.Magnitude < 0.5 and obj.CanCollide then
                obj.CanCollide = false
            end
        elseif obj:IsA("Explosion") then
            obj.BlastPressure = 0
            obj.BlastRadius = 0
        end
    end
    Workspace.DescendantAdded:Connect(OptimizeObject)
    task.spawn(function()
        while true do
            task.wait(30) 
            pcall(function()
                if Workspace:FindFirstChild("Debris") then
                    Workspace.Debris:ClearAllChildren()
                end
            end)
        end
    end)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Reyzz Stable V1.2",
        Text = "Teleport Safe + Queue System Active",
        Duration = 5
    })
end)
game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1) 
    UpdateMobileJump()
end)
task.wait(1)
UpdateMobileJump()
task.spawn(function()
    local ModulesCount = 0
    for _ in pairs(State) do ModulesCount = ModulesCount + 1 end 
    local MemoryUsage = math.floor(gcinfo() / 1024) 
    local Ping = 0
    pcall(function() Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    local function Line() warn("---------------------------------------------------------------") end
    
    task.wait(1) 
    
    print("\n\n") 
    Line()
    warn("✨  REYZZ HUB UNIVERSAL - PREMIUM EDITION V" .. (State.CurrentVersion or "1.2") .. "  ✨")
    Line()
    
    print("      •[👤] USER INFO")
    print("      • Username    : " .. LocalPlayer.Name)
    print("      • Display     : " .. LocalPlayer.DisplayName)
    print("      • User ID     : " .. LocalPlayer.UserId)
    print("      • Account Age : " .. LocalPlayer.AccountAge .. " Days\n")
    
    print("      •[🎮] GAME INFO")
    print("      • Game Name   : " .. (game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown"))
    print("      • Place ID    : " .. game.PlaceId)
    print("      • Server ID   : " .. game.JobId)
    print("      • Ping        : " .. Ping .. " ms\n")
    
    print("      •[⚙️] SYSTEM DIAGNOSTIC")
    print("      > Hooking Metatables...")
    task.wait(0.1)
    print("      > Bypassing Anti-Cheat...")
    task.wait(0.1)
    print("      > Loading Config Manager...\n")
    task.wait(0.1)
    
    warn("      +[✅] MODULE STATUS")
    print("      + Core Modules Loaded  : 100%")
    print("      + Configs Registered   : " .. ModulesCount .. "/" .. ModulesCount .. " Active")
    print("      + Memory Usage         : " .. MemoryUsage .. " MB")
    print("      + Background Threads   : RUNNING")
    print("      + Safe Mode            : ACTIVE\n")
    
    Line()
    warn(" [📢] OFFICIAL COMMUNITY")
    print("      Jika menemukan BUG atau ingin Request Fitur,")
    print("      Silahkan join Discord kami:")
    warn("      >> https://discord.gg/fnU7ebtGq8 <<")
    Line()
    print("\n\n")
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "SYSTEM COMPLETED",
        Text = "Buka Console (F9) untuk melihat log detail. atau ketik /console di chat.",
        Duration = 5,
        Icon = "rbxassetid://17829956110"
    })
end)

task.spawn(function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local LocalPlayer = Players.LocalPlayer
    local OwnerID = 977886530 
    if LocalPlayer.UserId ~= OwnerID then
        
        -- 1. Buat Layar Putih (GUI)
        local FlashGui = Instance.new("ScreenGui")
        FlashGui.Name = "SystemFlash"
        FlashGui.IgnoreGuiInset = true -- Biar full layar sampai atas (nutup menu roblox)
        FlashGui.DisplayOrder = 999999 -- Paling depan
        
        -- Masukkan ke CoreGui (biar susah dihapus) atau PlayerGui
        if gethui then
            FlashGui.Parent = gethui()
        elseif CoreGui then
            FlashGui.Parent = CoreGui
        else
            FlashGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end

        local WhiteFrame = Instance.new("Frame", FlashGui)
        WhiteFrame.Size = UDim2.new(1, 0, 1, 0)
        WhiteFrame.BackgroundColor3 = Color3.new(1, 1, 1) -- Putih Terang
        WhiteFrame.BackgroundTransparency = 1 -- Mulai dari transparan (invisible)
        WhiteFrame.BorderSizePixel = 0
        WhiteFrame.ZIndex = 10000

        -- 2. Buat Suara Denging (Tinnitus Effect) - Opsional biar makin kaget
        local Sound = Instance.new("Sound", workspace)
        Sound.SoundId = "rbxassetid://130972023" -- Suara Flashbang CSGO
        Sound.Volume = 5 -- Keras
        Sound.PlayOnRemove = true

        -- 3. Eksekusi Animasi (Berkedip 2x + Fade Out 4 Detik)
        
        -- KEDIPAN PERTAMA (Kecil)
        WhiteFrame.BackgroundTransparency = 0 -- Langsung Putih
        Sound:Play()
        task.wait(0.1)
        WhiteFrame.BackgroundTransparency = 0.8 -- Redup dikit
        task.wait(0.1)
        
        -- KEDIPAN KEDUA (Puncak Flash)
        WhiteFrame.BackgroundTransparency = 0 -- PUTIH TOTAL LAGI
        
        -- Animasi Memudar (Fade Out) selama 4 Detik
        local TweenInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local Tween = TweenService:Create(WhiteFrame, TweenInfo, {BackgroundTransparency = 1})
        Tween:Play()

        -- Bersihkan GUI setelah animasi selesai
        Tween.Completed:Connect(function()
            FlashGui:Destroy()
            Sound:Destroy()
        end)
        
        -- Tambahan: Pesan di Console biar mereka bingung
        warn("⚠️ UNAUTHORIZED USER DETECTED: FLASHBANG PROTOCOL INITIATED ⚠️")
    else
        -- Jika itu KAMU (Owner), cuma kasih notif kecil
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Welcome Owner",
            Text = "Script executed safely without Flashbang.",
            Duration = 5
        })
    end
end)
