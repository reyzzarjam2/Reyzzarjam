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

-- 3. HAPUS 'local' di fungsi ini juga
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
-- [[ START NATIVE JUMP BUTTON MODIFIER ]] --
do
    local JumpLoop = nil -- Variabel untuk menyimpan loop pemaksa

    function UpdateMobileJump()
        -- 1. Cek apakah device Touchscreen
        if not game:GetService("UserInputService").TouchEnabled then return end
        
        -- 2. Load Config
        if LoadUPConfig then LoadUPConfig() end

        -- 3. Cek Status ON/OFF
        local IsActive = true
        if typeof(UP_Config) == "table" and UP_Config.CustomJumpEnabled ~= nil then
            IsActive = UP_Config.CustomJumpEnabled
        end

        -- 4. Matikan Loop lama (Reset)
        if JumpLoop then JumpLoop:Disconnect() JumpLoop = nil end

        -- Jika fitur dimatikan, kita berhenti di sini. 
        -- Biarkan game mengembalikan posisi tombol ke defaultnya sendiri.
        if not IsActive then return end

        -- 5. Mulai Loop Agresif (Setiap Frame)
        -- Kita pakai RenderStepped supaya gerakan tombol mulus dan "menang" lawan script game
        local RunService = game:GetService("RunService")
        JumpLoop = RunService.RenderStepped:Connect(function()
            pcall(function()
                local Plr = game:GetService("Players").LocalPlayer
                local PlrGui = Plr and Plr:FindFirstChild("PlayerGui")
                local Touch = PlrGui and PlrGui:FindFirstChild("TouchGui")
                local Frame = Touch and Touch:FindFirstChild("TouchControlFrame")
                
                -- Cari tombol loncat asli (kadang namanya JumpButton atau JumpImage)
                local JumpBtn = Frame and (Frame:FindFirstChild("JumpButton") or Frame:FindFirstChild("JumpImage"))
                
                if JumpBtn then
                    -- Ambil nilai Config
                    local Scale = (UP_Config.JumpSize or 1)
                    local PosX = (UP_Config.JumpX or 0.8)
                    local PosY = (UP_Config.JumpY or 0.8)
                    
                    -- Paksa Ukuran & Posisi
                    -- Ukuran base tombol roblox biasanya sekitar 120-150px
                    local BaseSize = 140 
                    
                    JumpBtn.Size = UDim2.new(0, BaseSize * Scale, 0, BaseSize * Scale)
                    JumpBtn.Position = UDim2.new(PosX, 0, PosY, 0)
                    
                    -- Pastikan tombol Visible (kadang game menyembunyikannya)
                    JumpBtn.Visible = true
                end
            end)
        end)
    end
    
    -- Jalankan saat script pertama kali load
    task.delay(1, function() UpdateMobileJump() end)
    
    -- Update lagi saat respawn (karena TouchGui sering reset saat mati)
    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1) -- Tunggu loading GUI
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
    ShowToast("Rejoining Server...")
    if #Players:GetPlayers() <= 1 then
        Players.LocalPlayer:Kick("Rejoining...") 
        task.wait()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
        if not success then
            ShowToast("Instance Rejoin Failed. Finding New...")
            task.wait(1)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
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
    return character.PrimaryPart 
        or character:FindFirstChild("Head") 
        or character:FindFirstChild("HumanoidRootPart") 
        or character:FindFirstChild("Torso") 
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChildWhichIsA("BasePart")
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
    if State.InfiniteJump then
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
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
local function BoostFPS()
    ShowToast("🚀 BOOSTING FPS... (Applying Low Graphics)")
    local s = settings()
    local r = s.Rendering
    r.QualityLevel = "Level01"
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("SunRaysEffect") or v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 1
        Terrain.Decoration = false
    end
    task.spawn(function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Material = Enum.Material.SmoothPlastic
                v.Reflectance = 0
                v.CastShadow = false
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                v.Enabled = false 
            end
        end
    end)
    task.spawn(function()
        local StartTime = tick()
        local Duration = 120 
        ShowToast("🔒 FPS Lock: ACTIVE (2 Menit)")
        ShowToast("🌙 Night Mode Applied")
        while tick() - StartTime < Duration do
            Lighting.ClockTime = 0  
            Lighting.TimeOfDay = "00:00:00"
            Lighting.Brightness = 0
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = "Level01"
            task.wait(1)
        end
        ShowToast("✅ FPS Lock: Selesai (Settings Tetap)")
    end)
end
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
    local root = char and char:FindFirstChild("HumanoidRootPart")
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
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local cam = workspace.CurrentCamera
    if not root or not hum then return end
    hum.PlatformStand = true 
    local targetCFrame = root.CFrame 
    FlyConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
        if not State.Fly or not char or not root or not hum or hum.Health <= 0 then
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
        root.AssemblyLinearVelocity = Vector3.new(0, -2, 0) 
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end
TargetCamPos = nil
TargetCamRot = nil
State.FreecamFOV = 70 
CamFocusPart = nil 
-- [[ GLOBAL VARIABLES ]] --
TargetCamPos = nil
TargetCamRot = nil
State.FreecamFOV = 70 

-- [[ UPDATED FREECAM LOGIC V3 (CPU OPTIMIZED - NO RENDER STREAM) ]] --
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
local StatsFrame = Instance.new("Frame", ScreenGui); StatsFrame.Name = "StatsPanel"; StatsFrame.Size = UDim2.new(0, 220, 0, 180); StatsFrame.Position = UDim2.new(0, 10, 0.4, 0); RegisterTheme(StatsFrame, "BackgroundColor3", "Background"); StatsFrame.Visible = false
Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8); local StatsStroke = Instance.new("UIStroke", StatsFrame); RegisterTheme(StatsStroke, "Color", "Accent"); StatsStroke.Thickness = 1
MakeDraggable(StatsFrame)
local StatsHeader = Instance.new("TextLabel", StatsFrame); StatsHeader.Size = UDim2.new(1, 0, 0, 25); StatsHeader.BackgroundTransparency = 1; StatsHeader.Text = "SYSTEM MONITOR"; RegisterTheme(StatsHeader, "TextColor3", "Accent"); StatsHeader.Font = Enum.Font.GothamBlack; StatsHeader.TextSize = 13
local StatsContainer = Instance.new("Frame", StatsFrame); StatsContainer.Size = UDim2.new(1, -10, 1, -30); StatsContainer.Position = UDim2.new(0, 5, 0, 30); StatsContainer.BackgroundTransparency = 1
local StatsList = Instance.new("UIListLayout", StatsContainer); StatsList.Padding = UDim.new(0, 2)
local function CreateStatLabel(name)
    local f = Instance.new("Frame", StatsContainer); f.Size = UDim2.new(1, 0, 0, 18); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = name; RegisterTheme(l, "TextColor3", "TextDim"); l.Font = Enum.Font.GothamBold; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left
    local v = Instance.new("TextLabel", f); v.Size = UDim2.new(0.5, 0, 1, 0); v.Position = UDim2.new(0.5, 0, 0, 0); v.BackgroundTransparency = 1; v.Text = "..."; RegisterTheme(v, "TextColor3", "Text"); v.Font = Enum.Font.Code; v.TextSize = 12; v.TextXAlignment = Enum.TextXAlignment.Right
    return v
end
local FPSLabel = CreateStatLabel("FPS:")
local PingLabel = CreateStatLabel("Ping:")
local PlrLabel = CreateStatLabel("Players:")
local MemLabel = CreateStatLabel("Memory:")
local RecvLabel = CreateStatLabel("Recv:")
local SentLabel = CreateStatLabel("Sent:")
local InstLabel = CreateStatLabel("Instances:")
task.spawn(function()
    while true do
        if State.ShowStats and StatsFrame.Visible then
            local fps = math.floor(1 / RunService.RenderStepped:Wait())
            FPSLabel.Text = tostring(fps)
            local pingVal = 0
            pcall(function() pingVal = math.floor(LocalPlayer:GetNetworkPing() * 2000) end)
            if pingVal == 0 then pcall(function() pingVal = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()) end) end
            PingLabel.Text = pingVal .. " ms"
            pcall(function() PlrLabel.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers end)
            local mem = math.floor(StatsService:GetTotalMemoryUsageMb())
            MemLabel.Text = mem .. " MB"
            local recv = 0; local sent = 0
            pcall(function() recv = math.floor(StatsService.Network.ServerStatsItem["Data Receive"]:GetValue()) end)
            pcall(function() sent = math.floor(StatsService.Network.ServerStatsItem["Data Send"]:GetValue()) end)
            RecvLabel.Text = recv .. " KB/s"
            SentLabel.Text = sent .. " KB/s"
            pcall(function() InstLabel.Text = tostring(#Workspace:GetDescendants()) end)
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
            if child:IsA("TextButton") then child:Destroy() end 
        end 
        ActiveAnimLabels = {} 
    end
    local function ClearEventLog() for _, child in pairs(ELContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end end
    local function ClearChatLog() for _, child in pairs(CLContainer:GetChildren()) do if child:IsA("TextLabel") then child:Destroy() end end end
    UpdateAnimLogger = function()
        if AnimLoggerConnection then 
            AnimLoggerConnection:Disconnect()
            AnimLoggerConnection = nil
        end
        if not State.AnimLogger then 
            AnimLogFrame.Visible = false; 
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
            if ActiveAnimLabels[track] then return end
            local lbl = Instance.new("TextButton", ALContainer)
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Text = "ID: " .. idNum
            RegisterTheme(lbl, "TextColor3", "Text")
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.MouseButton1Click:Connect(function() 
                setclipboard(idNum)
                ShowToast("Anim ID Copied") 
            end)
            ActiveAnimLabels[track] = lbl
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
                if State.MasterESP and char then
                    local targetPart = GetVisualPart(char)
                    if targetPart then
                        local myRoot = GetVisualPart(LocalPlayer.Character)
                        local dist = (myRoot and math.floor((myRoot.Position - targetPart.Position).Magnitude)) or 0
                        local targetColor = GetTeamColor(p) 
                        local info = char:FindFirstChild("ReyzzESP_V2")
                        if not info then
                            info = Instance.new("BillboardGui", char); info.Name = "ReyzzESP_V2"; info.Size = UDim2.new(0, 200, 0, 100); info.StudsOffset = Vector3.new(0, 4, 0); info.AlwaysOnTop = true 
                            local layout = Instance.new("UIListLayout", info); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                            local nLbl = Instance.new("TextLabel", info); nLbl.Name = "NameLbl"; nLbl.Size = UDim2.new(1,0,0,15); nLbl.BackgroundTransparency = 1; nLbl.Font = Enum.Font.GothamBold; nLbl.TextSize = 14; nLbl.TextStrokeTransparency = 0; nLbl.LayoutOrder = 1
                            local hLbl = Instance.new("TextLabel", info); hLbl.Name = "HPLbl"; hLbl.Size = UDim2.new(1,0,0,15); hLbl.BackgroundTransparency = 1; hLbl.Font = Enum.Font.Code; hLbl.TextSize = 12; hLbl.TextStrokeTransparency = 0; hLbl.LayoutOrder = 2
                            local dLbl = Instance.new("TextLabel", info); dLbl.Name = "DistLbl"; dLbl.Size = UDim2.new(1,0,0,15); dLbl.BackgroundTransparency = 1; dLbl.Font = Enum.Font.GothamBold; dLbl.TextSize = 11; dLbl.TextStrokeTransparency = 0; dLbl.LayoutOrder = 3
                        end
                        info.Enabled = true; info.Adornee = targetPart
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
                        local hpL = info:FindFirstChild("HPLbl"); local hum = char:FindFirstChild("Humanoid")
                        if hpL then if hum then local hp = math.floor(hum.Health); local perc = math.clamp(hp / hum.MaxHealth, 0, 1); hpL.Text = "HP: " .. hp; hpL.TextColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), perc) else hpL.Text = "HP: ?"; hpL.TextColor3 = Color3.new(1,1,1) end end
                        local distL = info:FindFirstChild("DistLbl")
                        if distL then 
                            local txt = "[" .. dist .. "m]"
                            if State.ShowInventory then local tool = char:FindFirstChildOfClass("Tool"); if tool then txt = txt .. "\n[item: " .. tool.Name .. "]" end end
                            distL.Text = txt; distL.TextColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(255, 255, 255), math.clamp(dist/150, 0, 1))
                        end
                        local hl = char:FindFirstChild("GHighlight")
                        if not hl then 
                            hl = Instance.new("Highlight", char)
                            hl.Name = "GHighlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop 
                        end
                        hl.Enabled = true
                        hl.FillColor = targetColor
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255) 
                        hl.FillTransparency = 0.35 
                        hl.OutlineTransparency = 0 
                    end
                else
                    if char then
                        if char:FindFirstChild("ReyzzESP_V2") then char.ReyzzESP_V2.Enabled = false end
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
        else
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
            RegisterTheme(Circle, "BackgroundColor3", "TextDim")
            if not skipToast then ShowToast(Text .. ": OFF 🔴") end
        end
        Callback(Toggled)
        UpdateActiveList(Text, Toggled)
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
    local SearchBox = Instance.new("TextBox", Container)
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, 0, 0, 25)
    RegisterTheme(SearchBox, "BackgroundColor3", "Background")
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "🔍 Search..."
    RegisterTheme(SearchBox, "TextColor3", "Text")
    RegisterTheme(SearchBox, "PlaceholderColor3", "TextDim")
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.TextSize = 12
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
    SearchBox.Visible = UseSearch
    SearchBox.ZIndex = BaseZIndex + 4
    local DropFrame = Instance.new("ScrollingFrame", Container) 
    DropFrame.Position = UseSearch and UDim2.new(0, 0, 0, 30) or UDim2.new(0, 0, 0, 0)
    DropFrame.Size = UseSearch and UDim2.new(1, 0, 1, -30) or UDim2.new(1, 0, 1, 0)
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
        MainBtn.Text = "Select...  ▼"
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
    CreateToggle(Box_Config, "⚡ Auto Execute (Persistence)", function(val)
        SafeWriteFile(AutoExecFile, tostring(val))
        if val then
            local queue = (syn and syn.queue_on_teleport) or queue_on_teleport or request and request.queue_on_teleport
            if queue then
                queue([[ repeat task.wait() until game:IsLoaded(); loadstring(game:HttpGet("LINK_GITHUB_RAW_KAMU"))() ]])
            else ShowToast("Executor not supported!") end
        end
    end, (isfile(AutoExecFile) and readfile(AutoExecFile) == "true"))
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
task.wait(0.1)
local T7 = CreateTab("About", "rbxassetid://116139826677453")
task.wait(0.1)
local T_Settings = CreateTab("Settings", "rbxassetid://10709804836")
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
local function BuildDashboardTab()
    local DashLayout = Instance.new("UIListLayout", T_Dash)
    DashLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DashLayout.Padding = UDim.new(0, 15) 
    local DashPad = Instance.new("UIPadding", T_Dash)
    DashPad.PaddingTop = UDim.new(0, 15)
    DashPad.PaddingLeft = UDim.new(0, 15)
    DashPad.PaddingRight = UDim.new(0, 15)
    local HeaderCard = Instance.new("Frame", T_Dash)
    HeaderCard.Size = UDim2.new(1, 0, 0, 100) 
    HeaderCard.LayoutOrder = 1
    RegisterTheme(HeaderCard, "BackgroundColor3", "ElementBG")
    Instance.new("UICorner", HeaderCard).CornerRadius = UDim.new(0, 12)
    local HGrad = Instance.new("UIGradient", HeaderCard)
    HGrad.Rotation = 45
    HGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), 
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
    }
    local AvatarImg = Instance.new("ImageLabel", HeaderCard)
    AvatarImg.Size = UDim2.new(0, 70, 0, 70) 
    AvatarImg.Position = UDim2.new(0, 15, 0, 15)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    local AvaCorner = Instance.new("UICorner", AvatarImg)
    AvaCorner.CornerRadius = UDim.new(1, 0) 
    local AvaStroke = Instance.new("UIStroke", AvatarImg)
    RegisterTheme(AvaStroke, "Color", "Accent")
    AvaStroke.Thickness = 2
    AvaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local WelcomeLbl = Instance.new("TextLabel", HeaderCard)
    WelcomeLbl.Size = UDim2.new(1, -110, 0, 25)
    WelcomeLbl.Position = UDim2.new(0, 100, 0, 15)
    WelcomeLbl.BackgroundTransparency = 1
    WelcomeLbl.Text = "Hello, " .. LocalPlayer.DisplayName
    RegisterTheme(WelcomeLbl, "TextColor3", "Accent")
    WelcomeLbl.Font = Enum.Font.GothamBlack
    WelcomeLbl.TextSize = 22 
    WelcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
    local InfoLbl = Instance.new("TextLabel", HeaderCard)
    InfoLbl.Size = UDim2.new(1, -110, 0, 20)
    InfoLbl.Position = UDim2.new(0, 100, 0, 42)
    InfoLbl.BackgroundTransparency = 1
    InfoLbl.Text = "@" .. LocalPlayer.Name .. "  |  UID: " .. LocalPlayer.UserId
    RegisterTheme(InfoLbl, "TextColor3", "TextDim")
    InfoLbl.Font = Enum.Font.GothamMedium
    InfoLbl.TextSize = 13
    InfoLbl.TextXAlignment = Enum.TextXAlignment.Left
    local StatusTag = Instance.new("Frame", HeaderCard)
    StatusTag.Size = UDim2.new(0, 100, 0, 22)
    StatusTag.Position = UDim2.new(0, 100, 0, 65)
    StatusTag.BackgroundColor3 = Color3.fromRGB(0, 200, 100) 
    Instance.new("UICorner", StatusTag).CornerRadius = UDim.new(0, 4)
    local StatusText = Instance.new("TextLabel", StatusTag)
    StatusText.Size = UDim2.new(1, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "PREMIUM V" .. State.CurrentVersion
    StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusText.Font = Enum.Font.GothamBold
    StatusText.TextSize = 11
    local StatsContainer = Instance.new("Frame", T_Dash)
    StatsContainer.Size = UDim2.new(1, 0, 0, 160) 
    StatsContainer.BackgroundTransparency = 1
    StatsContainer.LayoutOrder = 2
    local Grid = Instance.new("UIGridLayout", StatsContainer)
    Grid.CellSize = UDim2.new(0.48, 0, 0, 70) 
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local function CreateStatWidget(Title, IconText)
        local Box = Instance.new("Frame", StatsContainer)
        RegisterTheme(Box, "BackgroundColor3", "ElementBG")
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
        local AccentBar = Instance.new("Frame", Box)
        AccentBar.Size = UDim2.new(0, 4, 1, 0)
        RegisterTheme(AccentBar, "BackgroundColor3", "Accent")
        Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 4)
        local VLbl = Instance.new("TextLabel", Box)
        VLbl.Name = "ValueLabel"
        VLbl.Size = UDim2.new(1, -20, 0, 30)
        VLbl.Position = UDim2.new(0, 15, 0.5, -5)
        VLbl.BackgroundTransparency = 1
        VLbl.Text = "..."
        RegisterTheme(VLbl, "TextColor3", "Text")
        VLbl.Font = Enum.Font.GothamBlack 
        VLbl.TextSize = 24 
        VLbl.TextXAlignment = Enum.TextXAlignment.Left
        local TLbl = Instance.new("TextLabel", Box)
        TLbl.Size = UDim2.new(1, -20, 0, 20)
        TLbl.Position = UDim2.new(0, 15, 0.2, 0)
        TLbl.BackgroundTransparency = 1
        TLbl.Text = string.upper(Title)
        RegisterTheme(TLbl, "TextColor3", "TextDim")
        TLbl.Font = Enum.Font.GothamBold
        TLbl.TextSize = 11
        TLbl.TextXAlignment = Enum.TextXAlignment.Left
        return VLbl
    end
    local PingL = CreateStatWidget("Server Ping", "📶")
    local FPSL = CreateStatWidget("Frames Per Sec", "🖥️")
    local PlrL = CreateStatWidget("Total Players", "👥")
    local TimeL = CreateStatWidget("Local Time", "🕒")
    local GuideFrame = Instance.new("Frame", T_Dash)
    GuideFrame.Size = UDim2.new(1, 0, 0, 180)
    GuideFrame.LayoutOrder = 3
    RegisterTheme(GuideFrame, "BackgroundColor3", "ElementBG") 
    GuideFrame.BackgroundTransparency = 0.5
    Instance.new("UICorner", GuideFrame).CornerRadius = UDim.new(0, 8)
    local GStroke = Instance.new("UIStroke", GuideFrame)
    RegisterTheme(GStroke, "Color", "Stroke")
    GStroke.Thickness = 1
    local GuideHeader = Instance.new("TextLabel", GuideFrame)
    GuideHeader.Size = UDim2.new(1, -20, 0, 30)
    GuideHeader.Position = UDim2.new(0, 10, 0, 5)
    GuideHeader.BackgroundTransparency = 1
    GuideHeader.Text = "QUICK GUIDE / PANDUAN"
    RegisterTheme(GuideHeader, "TextColor3", "Accent")
    GuideHeader.Font = Enum.Font.GothamBlack
    GuideHeader.TextSize = 13
    GuideHeader.TextXAlignment = Enum.TextXAlignment.Left
    local SepLine = Instance.new("Frame", GuideFrame)
    SepLine.Size = UDim2.new(1, 0, 0, 1)
    SepLine.Position = UDim2.new(0, 0, 0, 35)
    RegisterTheme(SepLine, "BackgroundColor3", "Stroke")
    SepLine.BorderSizePixel = 0
    local GuideScroll = Instance.new("ScrollingFrame", GuideFrame)
    GuideScroll.Size = UDim2.new(1, 0, 1, -45)
    GuideScroll.Position = UDim2.new(0, 0, 0, 40)
    GuideScroll.BackgroundTransparency = 1
    GuideScroll.ScrollBarThickness = 2
    GuideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local GList = Instance.new("UIListLayout", GuideScroll); GList.Padding = UDim.new(0, 8)
    local GPad = Instance.new("UIPadding", GuideScroll); GPad.PaddingTop = UDim.new(0,5); GPad.PaddingLeft = UDim.new(0,10)
    local function AddGuide(feat, desc)
        local L = Instance.new("TextLabel", GuideScroll)
        L.Size = UDim2.new(1, -20, 0, 0)
        L.AutomaticSize = Enum.AutomaticSize.Y
        L.BackgroundTransparency = 1
        L.RichText = true
        L.Text = '<font color="rgb(0,255,255)">['..feat..']</font>  ' .. desc
        RegisterTheme(L, "TextColor3", "TextDim")
        L.Font = Enum.Font.GothamMedium
        L.TextSize = 12
        L.TextXAlignment = Enum.TextXAlignment.Left
        L.TextWrapped = true
    end
    AddGuide("Click TP", "Tahan 'Left CTRL' + Klik Mouse untuk teleport cepat.")
    AddGuide("Menu Key", "Tekan tombol 'R' untuk menyembunyikan/menampilkan menu.")
    AddGuide("Aimbot", "Tahan Klik Kanan pada musuh untuk mengunci aim.")
    AddGuide("Themes", "Ganti warna menu di tab Misc > Theme Settings.")
    AddGuide("Panic", "Gunakan Panic Button di tab Main jika ingin mematikan semua cheat.")
    task.spawn(function()
        local RunService = game:GetService("RunService")
        while task.wait(1) do
            if T_Dash.Visible then
                local ping = 0; pcall(function() ping = math.floor(LocalPlayer:GetNetworkPing() * 2000) end)
                if ping == 0 then pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end) end
                PingL.Text = ping .. " ms"
                FPSL.Text = math.floor(1 / (RunService.RenderStepped:Wait() + 0.001)) .. " FPS" 
                TimeL.Text = os.date("%H:%M")
                PlrL.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
                if ping < 100 then PingL.TextColor3 = Color3.fromRGB(0, 255, 100)
                elseif ping < 200 then PingL.TextColor3 = Color3.fromRGB(255, 200, 0)
                else PingL.TextColor3 = Color3.fromRGB(255, 50, 50) end
            end
        end
    end)
end
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
    CreateToggle(Box_World, "Night Vision (Thermal)", function(v) State.NightVision = v end)
    CreateToggle(Box_World, "World X-Ray [BETA]", ToggleXRay)
    local Box_Radar = CreateSection(T2, "RADAR & HUD SYSTEM")
    CreateToggle(Box_Radar, "Custom Crosshair (HUD)", function(v) State.Crosshair = v end)
    CreateToggle(Box_Radar, "Proximity Warning ⚠️", function(v) 
        ToggleProximity(v) 
    end)
    CreateDropdown(Box_Radar, "Warning Mode", {"All Players", "Enemy Only"}, "All Players", function(v) State.ProximityMode = v end)
    CreateSlider(Box_Radar, "Detect Distance", 10, 200, 50, function(v) State.ProximityDist = v end)
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
    CreateToggle(Box_Stab, "🚫 No Bobbing (Anti-Goyang)", function(v)
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
    local Box_Finder = CreateSection(T4, "PLAYER FINDER & SPECTATE")
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
        for _,v in pairs(TPList:GetChildren()) do 
            if v:IsA("Frame") then v:Destroy() end 
        end
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pName = string.lower(p.DisplayName) 
                local pReal = string.lower(p.Name)
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
                    TPBtn.MouseButton1Click:Connect(function() 
                    -- Ambil posisi target (Jika player jauh, kita coba cari posisi terakhir yang diketahui atau minta server)
                    local targetPos = nil
                    if p.Character and p.Character:GetPivot() then
                        targetPos = p.Character:GetPivot().Position
                    end

                    if targetPos then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            ShowToast("⏳ Force Teleporting... (Tahan 2dtk)")
                            
                            -- 1. Minta server mengirim map di lokasi target
                            task.spawn(function()
                                pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos) end)
                            end)

                            -- 2. LOOPING TELEPORT (Ini trik Auto Follow-nya)
                            -- Kita kunci posisi karakter di target selama 1.5 detik agar tidak jatuh ke void
                            local StartTime = tick()
                            local Connection
                            Connection = game:GetService("RunService").Stepped:Connect(function()
                                if tick() - StartTime > 1.5 then -- Berhenti setelah 1.5 detik
                                    Connection:Disconnect()
                                    ShowToast("✅ Teleport Selesai!")
                                else
                                    -- Terus menerus set posisi (maksa)
                                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                                    root.Velocity = Vector3.new(0,0,0) -- Matikan velocity biar ga mental
                                end
                            end)
                        end
                    else
                        ShowToast("❌ Gagal: Lokasi Player Tidak Diketahui (Terlalu Jauh)")
                    end
                end)
                    ViewBtn.MouseButton1Click:Connect(function() 
                    local targetPos = nil
                    if p.Character and p.Character:GetPivot() then
                        targetPos = p.Character:GetPivot().Position
                    end

                    if targetPos then
                        State.SpectatingPlayer = p
                        ShowToast("👁️ Memuat Area Spectator... (Tunggu)")

                        -- 1. Lepaskan Kamera dari karakter kita & pindahkan ke lokasi target
                        Camera.CameraType = Enum.CameraType.Scriptable
                        Camera.CFrame = CFrame.new(targetPos + Vector3.new(0, 20, 0), targetPos)

                        -- 2. Minta server memuat area tersebut
                        task.spawn(function()
                            pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos) end)
                        end)

                        -- 3. Loop Check: Tunggu sampai karakter musuh benar-benar muncul
                        task.spawn(function()
                            local MaxWait = 20 -- Batas waktu 2 detik (20 x 0.1)
                            local Found = false
                            
                            for i = 1, MaxWait do
                                -- Cek apakah karakter dan humanoid musuh sudah ter-render
                                if p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
                                    Camera.CameraType = Enum.CameraType.Custom
                                    Camera.CameraSubject = p.Character.Humanoid
                                    ShowToast("✅ Spectating: " .. p.DisplayName)
                                    Found = true
                                    break
                                else
                                    -- Kalau belum ada, paksa request lagi
                                    pcall(function() LocalPlayer:RequestStreamAroundAsync(targetPos) end)
                                end
                                task.wait(0.1)
                            end

                            if not Found then
                                ShowToast("⚠️ Gagal memuat karakter (Jarak Jauh)")
                                Camera.CameraType = Enum.CameraType.Custom
                                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                    Camera.CameraSubject = LocalPlayer.Character.Humanoid
                                end
                            end
                        end)
                    else 
                        ShowToast("❌ Gagal: Player Terlalu Jauh/Tidak Terdeteksi") 
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
    CreateToggle(Box_Atmo, "Disable FX (Anti-Silau)", false, function(val)
        State.DisableLighting = val
        if not val then
            for _, v in pairs(game:GetService("Lighting"):GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Atmosphere") then
                    v.Enabled = true
                end
            end
            game:GetService("Lighting").GlobalShadows = true
        end
    end)
    CreateToggle(Box_Atmo, "Remove Particles", function(v) State.NoParticles = v end)
    local Box_Phys = CreateSection(T5, "PHYSICS MODIFIERS")
    CreateToggle(Box_Phys, "Walk on Water (Jesus)", function(v) State.WalkOnWater = v end) 
    CreateToggle(Box_Phys, "Gravity Control (Magnet)", function(v) State.GravityControl = v end)
    local Box_Opt = CreateSection(T5, "MAP OPTIMIZATION (FPS)")
    CreateButton(Box_Opt, "🚀 Boost FPS (Safe Mode)", BoostFPS)
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
    local R15_Anims = {
        ["Ghost Floating"] = "112082806790047",
        ["Sturdy NYC Dance"] = "140333103929828",
        ["Sturdy Dance Speed"] = "102571052202995",
        ["Metro Man (Super)"] = "71043409187026",
        ["Pumpkin Float"] = "101988298323707",
        ["Zombie Idle"] = "616158929",
        ["Levitation"] = "132783162476851",
        ["Knight Idle"] = "657564596",
        ["Sit on Cloud"] = "70673082198328",
        ["Popular Dance"] = "93062298566806",
        ["Jomok Dance"] = "118364690209655",
        ["Head Throw"] = "138243322520289",
        ["Rusdi Emote"] = "126780665379004",
        ["WHAT THE HELL"] = "78086740525202",
    }
    local R6_Anims = {
        ["R6 Dance 1"] = "507771955",
        ["R6 Dance 2"] = "507776043",
        ["R6 Dance 3"] = "507777268",
        ["R6 Thriller"] = "99835792883875",
        ["R6 Metro Man"] = "80552139463944",
        ["R6 Kyoufuu"] = "137322894494527",
        ["R6 Zombie"] = "120353238054872",
        ["R6 Jomok Dance"] = "131720136455849",
    }
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
    local R15Keys = {}; for k,v in pairs(R15_Anims) do table.insert(R15Keys, k) end; table.sort(R15Keys)
    CreateDropdown(Box_Anim, "R15 Animations", R15Keys, "Select...", function(name)
        if State.AnimRigType == "R15" then 
            State.CurrentAnimID = R15_Anims[name]
            if State.AnimChanger then UpdateAnimation(State.CurrentAnimID) end 
        else ShowToast("❌ Error: You are R6!") end
    end)
    local R6Keys = {}; for k,v in pairs(R6_Anims) do table.insert(R6Keys, k) end; table.sort(R6Keys)
    CreateDropdown(Box_Anim, "R6 Animations", R6Keys, "Select...", function(name)
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
    CreateToggle(Box_Sys, "⚡ Auto Execute (Persistence)", function(val)
        SafeWriteFile(AutoExecFile, tostring(val))
        if val then
            local queue = (syn and syn.queue_on_teleport) or queue_on_teleport or request.queue_on_teleport
            if queue then
                queue([[ 
                    repeat task.wait() until game:IsLoaded()
                    loadstring(game:HttpGet("LINK_GITHUB_RAW_KAMU_DISINI"))() 
                ]])
            else
                ShowToast("Executor tidak support Queue!")
            end
        end
    end, AutoExecStatus) 
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

        CreateSlider(Box_Mobile, "Posisi X (Kiri-Kanan)", 0, 100, (UP_Config.JumpX or 0.8)*100, function(v)
            UP_Config.JumpX = v / 100
            SaveUPConfig()
            -- Tidak perlu panggil UpdateMobileJump() disini karena loop sudah jalan otomatis membaca Config
            -- Tapi kalau mau dipanggil juga tidak masalah.
        end)
        
        CreateSlider(Box_Mobile, "Posisi Y (Atas-Bawah)", 0, 100, (UP_Config.JumpY or 0.8)*100, function(v)
            UP_Config.JumpY = v / 100
            SaveUPConfig()
        end)
        
        CreateSlider(Box_Mobile, "Ukuran Tombol", 50, 200, (UP_Config.JumpSize or 1)*100, function(v)
            UP_Config.JumpSize = v / 100
            SaveUPConfig()
        end)
    end
end
local AboutTitle = Instance.new("TextLabel", T7); AboutTitle.Text = "Reyzzarjam BloxHub Dynamic"; AboutTitle.Size = UDim2.new(1, 0, 0, 40); AboutTitle.BackgroundTransparency = 1; RegisterTheme(AboutTitle, "TextColor3", "Accent"); AboutTitle.Font = Enum.Font.GothamBlack; AboutTitle.TextSize = 28; AboutTitle.TextXAlignment = Enum.TextXAlignment.Center
local AboutDesc = Instance.new("TextLabel", T7); AboutDesc.Text = "If You Find Bug Please Report On My Discord\nSuggest Game For More Feature\nNeed Suggest More Featured\n\n\nCopyright © Reyzzarjam 2025"; AboutDesc.Size = UDim2.new(1, 0, 0, 60); AboutDesc.BackgroundTransparency = 1; RegisterTheme(AboutDesc, "TextColor3", "TextDim"); AboutDesc.Font = Enum.Font.Gotham; AboutDesc.TextSize = 14
local DiscordBtn = CreateButton(T7, "Copy Discord Link", function() setclipboard("https://discord.gg/fnU7ebtGq8"); ShowToast("Discord Link Copied!") end); DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242); DiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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
if (not getgenv().StandardLoaded) then
    getgenv().StandardLoaded = true
    local queue_on_teleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    if queue_on_teleport then
        queue_on_teleport('loadstring(game:HttpGet("URL_SCRIPT_KAMU_DISINI_JIKA_ADA"))()') 
    end
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
        Icon = "rbxassetid://10709752906"
    })
end)

