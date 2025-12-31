local Library = {}
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local ConfigFolder = "ReyzzHub_UniversalConfigs"
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local HttpService = game:GetService("HttpService")
local function GetRandomName()
    return HttpService:GenerateGUID(false)
end

local MySafeName = GetRandomName()
local EspName = GetRandomName()

if not isfolder(ConfigFolder) then
    makefolder(ConfigFolder)
end
local AutoExecFile = "Reyzz_AutoExec_Status.txt"
local AutoExecStatus = isfile(AutoExecFile) and readfile(AutoExecFile) == "true"
-- [[ THEME SYSTEM ]]
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 15), 
        Sidebar = Color3.fromRGB(10, 10, 10),
        ElementBG = Color3.fromRGB(30, 30, 30), 
        Accent = Color3.fromRGB(255, 255, 255), 
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150),
        Stroke = Color3.fromRGB(60, 60, 60)
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

-- [[ STATE VARIABLES ]]
local State = {
    CurrentVersion = "1.1", 
    RegisteredFeatures = {},
    UIListeners = {} 
}

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
    local func = gethui or get_hidden_gui
    if func then
        return func()
    end

    local success, core = pcall(function() return game:GetService("CoreGui") end)
    if success and core then
        if syn and syn.protect_gui then
            syn.protect_gui(core) 
        end
        return core
    end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

function Library:CreateWindow(ConfigName)
    ConfigFolder = ConfigName or "ReyzzHub_UniversalConfigs" -- Pakai nama dari parameter atau default
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = MySafeName 
    ScreenGui.Parent = GetSafeGui()
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647

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

    local ToggleButton, MainFrame, Sidebar, Content, SettingsBtn, SetIcon -- Tambahkan ini

    do
        -- Tombol Bola Mata (Toggle)
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

        -- Jendela Utama (Main Frame)
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
        MainStroke.Thickness = 2 
        MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        RegisterTheme(MainStroke, "Color", "Accent")
        MakeDraggable(MainFrame)
        
        local HeaderFrame = Instance.new("Frame", MainFrame)
        HeaderFrame.Size = UDim2.new(1, 0, 0, 40)
        RegisterTheme(HeaderFrame, "BackgroundColor3", "Background") 
        HeaderFrame.BackgroundTransparency = 1
        HeaderFrame.BorderSizePixel = 0
        
        local HeaderTitle = Instance.new("TextLabel", HeaderFrame)
        HeaderTitle.Text = "ReyzzHubV1.1 | Universal [BETA TEST]" 
        HeaderTitle.Size = UDim2.new(0.7, 0, 1, 0)
        HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
        HeaderTitle.BackgroundTransparency = 1
        RegisterTheme(HeaderTitle, "TextColor3", "Accent")
        HeaderTitle.Font = Enum.Font.GothamBold
        HeaderTitle.TextSize = 14
        HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left

        -- Tombol Kontrol Window
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
        CreateWinBtn("X", 2, function() ScreenGui:Destroy() end)

        -- Garis Pembatas
        local HeaderLine = Instance.new("Frame", MainFrame)
        HeaderLine.Size = UDim2.new(1, 0, 0, 1)
        HeaderLine.Position = UDim2.new(0, 0, 0, 40)
        RegisterTheme(HeaderLine, "BackgroundColor3", "Stroke")
        HeaderLine.BorderSizePixel = 0

        -- Sidebar (Kiri) - INI VARIABEL PENTING
        local SidebarWidth = 160
        Sidebar = Instance.new("ScrollingFrame", MainFrame)
        Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -91)
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
        
            -- [[ BARU: AREA SETTINGS STATIS ]] --
        local SettingsArea = Instance.new("Frame", MainFrame)
        SettingsArea.Name = "SettingsArea"
        SettingsArea.Size = UDim2.new(0, SidebarWidth, 0, 50)
        SettingsArea.Position = UDim2.new(0, 0, 1, -50) -- Mojok bawah
        RegisterTheme(SettingsArea, "BackgroundColor3", "Sidebar")
        SettingsArea.BorderSizePixel = 0

        -- Garis pemisah tipis
        local SetLine = Instance.new("Frame", SettingsArea)
        SetLine.Size = UDim2.new(1, 0, 0, 1)
        RegisterTheme(SetLine, "BackgroundColor3", "Stroke")
        SetLine.BorderSizePixel = 0

        -- Tombol Settings
        SettingsBtn = Instance.new("TextButton", SettingsArea)
        SettingsBtn.Size = UDim2.new(1, -20, 1, -14)
        SettingsBtn.Position = UDim2.new(0, 10, 0, 7)
        RegisterTheme(SettingsBtn, "BackgroundColor3", "ElementBG")
        SettingsBtn.Text = "      Settings"
        RegisterTheme(SettingsBtn, "TextColor3", "TextDim")
        SettingsBtn.Font = Enum.Font.GothamBold
        SettingsBtn.TextSize = 14
        SettingsBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 6)

        SetIcon = Instance.new("ImageLabel", SettingsBtn)
        SetIcon.Size = UDim2.new(0, 20, 0, 20)
        SetIcon.Position = UDim2.new(0, 10, 0.5, -10)
        SetIcon.BackgroundTransparency = 1
        SetIcon.Image = "rbxassetid://9405931578" -- Icon Gear
        RegisterTheme(SetIcon, "ImageColor3", "TextDim")

        -- Content Area (Kanan) - INI VARIABEL PENTING
        Content = Instance.new("Frame", MainFrame)
        Content.Size = UDim2.new(1, -SidebarWidth, 1, -41)
        Content.Position = UDim2.new(0, SidebarWidth, 0, 41)
        Content.BackgroundTransparency = 1
        Content.ClipsDescendants = true
    end
    Content.ClipsDescendants = true
    
    local Window = {}
        function Window:CreateTab(Name, IconId)
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
            RegisterTheme(SettingsBtn, "TextColor3", "TextDim")
            RegisterTheme(SettingsBtn, "BackgroundColor3", "ElementBG")
            RegisterTheme(SetIcon, "ImageColor3", "TextDim")
            -- Cari halaman settings dan sembunyikan
            local SetPage = Content:FindFirstChild("SettingsPage_Fixed")
        if SetPage then SetPage.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    local ab = v:FindFirstChild("Frame")
                    local il = v:FindFirstChild("TabIcon")
                    local nl = v:GetChildren()[3]
                    
                    if ab then ab.Visible = false end
                    if il then il.ImageColor3 = CurrentTheme.TextDim end
                    if nl then nl.TextColor3 = CurrentTheme.TextDim end
                    v.BackgroundTransparency = 1
                end
            end
            
            for _, v in pairs(Content:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            
            ActiveBar.Visible = true
            IconImg.ImageColor3 = CurrentTheme.Text
            NameLbl.TextColor3 = CurrentTheme.Text
            Btn.BackgroundColor3 = CurrentTheme.ElementBG
            Btn.BackgroundTransparency = 0.95
            Page.Visible = true
        end)
        local Tab = {}
            function Tab:CreateToggle(Text, Callback, Default)
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

        function Tab:CreateLabel(Text)
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

        function Tab:CreateInput(Text, Placeholder, Callback, IsString)
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
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = CurrentTheme.Accent}):Play()
            end)

            InputBox.FocusLost:Connect(function(enter)
                TweenService:Create(Stroke, TweenInfo.new(0.2), {Color = CurrentTheme.Stroke}):Play()
                if IsString then 
                    Callback(InputBox.Text) 
                else 
                    local num = tonumber(InputBox.Text)
                    if num then Callback(num) else InputBox.Text = "" end 
                end 
            end)
            return InputBox
        end

        function Tab:CreateButton(Text, Callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(0.95, 0, 0, 35)
            RegisterTheme(Btn, "BackgroundColor3", "ElementBG")
            Btn.Text = Text
            RegisterTheme(Btn, "TextColor3", "Text")
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            
            Btn.MouseEnter:Connect(function() 
                game:GetService("TweenService"):Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play() 
            end)
            Btn.MouseLeave:Connect(function() 
                game:GetService("TweenService"):Create(Btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play() 
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

        function Tab:CreateSlider(Text, Min, Max, Default, Callback)
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

            -- [[ BAGIAN BARU: LISTENER ]]
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

        function Tab:CreateDropdown(Text, Options, Default, Callback)
            local Wrapper = Instance.new("Frame", Page)
            Wrapper.Size = UDim2.new(0.95, 0, 0, 50) 
            RegisterTheme(Wrapper, "BackgroundColor3", "ElementBG")
            Wrapper.ZIndex = 5 
            Wrapper.ClipsDescendants = true 
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
            Lbl.ZIndex = 10 
            
            local MainBtn = Instance.new("TextButton", Wrapper)
            MainBtn.Size = UDim2.new(0, 140, 0, 30)
            MainBtn.Position = UDim2.new(1, -150, 0, 10) 
            RegisterTheme(MainBtn, "BackgroundColor3", "Background")
            MainBtn.Text = Default .. "  ▼"
            RegisterTheme(MainBtn, "TextColor3", "Accent")
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            MainBtn.ZIndex = 20 
            Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 6)

            local DropFrame = Instance.new("ScrollingFrame", Wrapper) 
            DropFrame.Name = "DropdownList"
            DropFrame.Size = UDim2.new(1, -20, 0, 0)
            DropFrame.Position = UDim2.new(0, 10, 0, 55)
            RegisterTheme(DropFrame, "BackgroundColor3", "Background")
            DropFrame.BackgroundTransparency = 0.5
            DropFrame.Visible = true
            DropFrame.ZIndex = 30 
            DropFrame.BorderSizePixel = 0
            DropFrame.ScrollBarThickness = 2
            RegisterTheme(DropFrame, "ScrollBarImageColor3", "Accent")
            DropFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y 
            DropFrame.CanvasSize = UDim2.new(0,0,0,0)
            
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
            
            local ListLayout = Instance.new("UIListLayout", DropFrame); 
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder; 
            ListLayout.Padding = UDim.new(0, 4)
            local ListPadding = Instance.new("UIPadding", DropFrame)
            ListPadding.PaddingTop = UDim.new(0, 5)
            ListPadding.PaddingLeft = UDim.new(0, 5)
            ListPadding.PaddingBottom = UDim.new(0, 5)
            
            local isOpened = false
            local TweenService = game:GetService("TweenService")

            MainBtn.MouseButton1Click:Connect(function()
                isOpened = not isOpened
                if isOpened then
                    MainBtn.Text = MainBtn.Text:gsub("▼", "▲")
                    local itemCount = #DropFrame:GetChildren() - 2 -- Dikurang Layout & Padding
                    local itemHeight = 32 
                    local contentHeight = itemCount * itemHeight + 10 
                    local viewHeight = math.min(contentHeight, 200) 
                    local totalHeight = 50 + viewHeight + 10
                    TweenService:Create(Wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.95, 0, 0, totalHeight)}):Play()
                    TweenService:Create(DropFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, viewHeight)}):Play()
                else
                    MainBtn.Text = MainBtn.Text:gsub("▲", "▼")
                    TweenService:Create(Wrapper, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.95, 0, 0, 50)}):Play()
                    TweenService:Create(DropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                end
            end)

            -- [[ BAGIAN PENTING: FUNGSI REFRESH ]] --
            local function LoadOptions(NewOptions)
                -- Hapus tombol lama
                for _, child in pairs(DropFrame:GetChildren()) do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                -- Buat tombol baru
                for _, opt in ipairs(NewOptions) do
                    local OptBtn = Instance.new("TextButton", DropFrame)
                    OptBtn.Size = UDim2.new(1, -10, 0, 28)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. opt
                    RegisterTheme(OptBtn, "TextColor3", "TextDim")
                    OptBtn.Font = Enum.Font.GothamMedium
                    OptBtn.TextSize = 13
                    OptBtn.ZIndex = 31
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = CurrentTheme.Accent end)
                    OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = CurrentTheme.TextDim end)

                    OptBtn.MouseButton1Click:Connect(function()
                        MainBtn.Text = opt .. "  ▼"
                        Callback(opt)
                        isOpened = false
                        MainBtn.Text = MainBtn.Text:gsub("▲", "▼")
                        TweenService:Create(Wrapper, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 50)}):Play()
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -20, 0, 0)}):Play()
                    end)
                end
            end

            LoadOptions(Options)
            local DropdownAPI = {}
            function DropdownAPI:Refresh(NewList)
                LoadOptions(NewList)
                MainBtn.Text = "Select...  ▼"
            end

            return DropdownAPI 
        end

        function Tab:CreateSection(Title)
            local Wrapper = Instance.new("Frame", Page)
            Wrapper.Name = "Section_" .. Title
            Wrapper.Size = UDim2.new(0.98, 0, 0, 42) 
            Wrapper.BackgroundColor3 = CurrentTheme.ElementBG -- Gunakan warna ElementBG yg sudah kita set gelap
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
        return Tab
    end 
    -- [[ 10. CONFIG & KEYBIND MANAGER (VERSI BARU - FIXED) ]] --
    function Window:AddSettingsTab()
        -- Kita buat Halaman Manual (Bukan lewat CreateTab)
        local Page = Instance.new("ScrollingFrame", Content)
        Page.Name = "SettingsPage_Fixed"
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 4
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)

        local PL = Instance.new("UIListLayout", Page); PL.Padding = UDim.new(0, 10); PL.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local PP = Instance.new("UIPadding", Page); PP.PaddingTop = UDim.new(0, 20); PP.PaddingBottom = UDim.new(0, 20)

        -- Logika Klik Tombol Settings (Aktifkan Halaman Ini)
        SettingsBtn.MouseButton1Click:Connect(function()
            -- Matikan Tab Biasa
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("TextButton") then
                    local ab = v:FindFirstChild("Frame"); if ab then ab.Visible = false end
                    local il = v:FindFirstChild("TabIcon"); if il then RegisterTheme(il, "ImageColor3", "TextDim") end
                    local nl = v:GetChildren()[3]; if nl then RegisterTheme(nl, "TextColor3", "TextDim") end
                    v.BackgroundTransparency = 1
                end
            end
            -- Sembunyikan Halaman Biasa
            for _, v in pairs(Content:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end

            -- Nyalakan Halaman Settings
            Page.Visible = true
            RegisterTheme(SettingsBtn, "TextColor3", "Accent")
            SettingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Sedikit lebih terang
            RegisterTheme(SetIcon, "ImageColor3", "Accent")
        end)

        -- KITA GUNAKAN TRIK:
        -- Kita buat objek "Fake Tab" agar bisa pakai fungsi CreateSection, CreateButton, dll yang sudah ada.
        local SettingsTab = {}

        -- Copy semua fungsi UI Helper ke dalam sini agar nempel ke 'Page' settings
        -- (Untungnya di Lua kita bisa redirect fungsi)

        -- Ambil fungsi dari sembarang tab (kita buat dummy dulu kalau perlu, atau copy manual logicnya)
        -- Tapi cara paling bersih: Kita copy logic CreateSection dll ke sini, tapi arahkan ke 'Page' ini.

        -- BIKIN ULANG FUNGSI UI KHUSUS SETTINGS (Simple Version)
        function SettingsTab:CreateSection(Title)
            -- Gunakan fungsi Section yang sudah ada di Window logic (karena itu lokal di dalam CreateWindow)
            -- Karena fungsi CreateSection ada di dalam CreateTab, kita tidak bisa akses langsung.
            -- JADI KITA COPY PASTE LOGIC SECTION DI SINI (tapi arahkan ke Page ini)

            local Wrapper = Instance.new("Frame", Page) -- PARENT KE PAGE SETTINGS
            Wrapper.Size = UDim2.new(0.98, 0, 0, 42); Wrapper.BackgroundTransparency = 0.5; Wrapper.BackgroundColor3 = CurrentTheme.ElementBG
            Instance.new("UICorner", Wrapper).CornerRadius = UDim.new(0, 8)
            local TitleLbl = Instance.new("TextLabel", Wrapper); TitleLbl.Text = Title; TitleLbl.Size = UDim2.new(1,0,1,0); TitleLbl.BackgroundTransparency=1; RegisterTheme(TitleLbl, "TextColor3", "Accent"); TitleLbl.Font=Enum.Font.GothamBlack; TitleLbl.TextSize=14
            -- (Versi simple untuk settings)
            local Container = Instance.new("Frame", Wrapper); Container.Name="Content"; Container.Size=UDim2.new(1,0,0,0); Container.Position=UDim2.new(0,0,0,42); Container.Visible=false 
            -- Note: Karena logic section kamu kompleks (dropdown), untuk settings kita pakai container langsung di Page aja biar ga ribet.

            -- Biar gampang, return Page aja untuk settings
            return Page 
        end

        -- FUNGSI UI HELPER MANUAL UNTUK SETTINGS PAGE
        local function AddButton(Text, Callback)
            local Btn = Instance.new("TextButton", Page); Btn.Size = UDim2.new(0.95, 0, 0, 35); RegisterTheme(Btn, "BackgroundColor3", "ElementBG"); Btn.Text = Text; RegisterTheme(Btn, "TextColor3", "Text"); Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 13; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(Callback)
        end

        local function AddInput(Text, Callback)
            local Frame = Instance.new("Frame", Page); Frame.Size=UDim2.new(0.95,0,0,50); Frame.BackgroundTransparency=1
            local Lbl = Instance.new("TextLabel", Frame); Lbl.Text=Text; Lbl.Size=UDim2.new(1,0,0,20); Lbl.BackgroundTransparency=1; RegisterTheme(Lbl,"TextColor3","Text"); Lbl.Font=Enum.Font.GothamBold; Lbl.TextSize=12; Lbl.TextXAlignment=Enum.TextXAlignment.Left
            local Box = Instance.new("TextBox", Frame); Box.Size=UDim2.new(1,0,0,30); Box.Position=UDim2.new(0,0,0,20); RegisterTheme(Box,"BackgroundColor3","ElementBG"); Box.Text=""; Box.PlaceholderText="Type here..."; RegisterTheme(Box,"TextColor3","Accent"); Box.Font=Enum.Font.GothamMedium; Box.TextSize=13; Instance.new("UICorner", Box).CornerRadius=UDim.new(0,6)
            Box.FocusLost:Connect(function() Callback(Box.Text) end)
        end

        local function AddLabel(Text)
            local Lbl = Instance.new("TextLabel", Page); Lbl.Size=UDim2.new(0.95,0,0,25); Lbl.Text=Text; Lbl.BackgroundTransparency=1; RegisterTheme(Lbl,"TextColor3","Accent"); Lbl.Font=Enum.Font.GothamBlack; Lbl.TextSize=14
        end

        -- ISI KONTEN SETTINGS (Config & Keybinds)
        AddLabel("CONFIG MANAGER")

        local SelectedConfig = ""
        local function GetConfigs()
            local list = {}; if isfolder(ConfigFolder) then for _, f in pairs(listfiles(ConfigFolder)) do table.insert(list, f:gsub(ConfigFolder.."\\", ""):gsub(ConfigFolder.."/", ""):gsub(".json", "")) end end; return list
        end

        -- Dropdown Config (Manual Simple)
        local DropFrame = Instance.new("Frame", Page); DropFrame.Size=UDim2.new(0.95,0,0,35); RegisterTheme(DropFrame,"BackgroundColor3","ElementBG"); Instance.new("UICorner", DropFrame).CornerRadius=UDim.new(0,6)
        local DropBtn = Instance.new("TextButton", DropFrame); DropBtn.Size=UDim2.new(1,0,1,0); DropBtn.BackgroundTransparency=1; DropBtn.Text="Select Config (Click to Load List)"; RegisterTheme(DropBtn,"TextColor3","Text"); DropBtn.Font=Enum.Font.GothamBold; DropBtn.TextSize=13

        DropBtn.MouseButton1Click:Connect(function()
            -- Logic simple dropdown: print list ke console atau ganti text cycling (agar tidak ribet coding UI dropdown lagi)
            -- Atau kita pakai InputBox untuk nama config biar lebih mudah
            DropBtn.Text = "Check Console (F9) for Config List"
            print("AVAILABLE CONFIGS:")
            for _,v in pairs(GetConfigs()) do print("- "..v) end
        end)

        AddInput("Config Name", function(val) SelectedConfig = val end)

        AddButton("💾 Save Config", function()
            if SelectedConfig == "" then ShowToast("⚠️ No Config Name!") return end
            local Data = { Settings = {}, Keybinds = {} }
            -- Save Logic (Sama seperti sebelumnya)
            if State.Keybinds then for name, bind in pairs(State.Keybinds) do Data.Keybinds[name] = { Key = bind.Key.Name, Shift = bind.Shift } end end
            writefile(ConfigFolder.."/"..SelectedConfig..".json", HttpService:JSONEncode(Data))
            ShowToast("✅ Saved: "..SelectedConfig)
        end)

        AddButton("📂 Load Config", function()
            if SelectedConfig == "" or not isfile(ConfigFolder.."/"..SelectedConfig..".json") then ShowToast("❌ File Not Found") return end
            local Data = HttpService:JSONDecode(readfile(ConfigFolder.."/"..SelectedConfig..".json"))
            if Data.Keybinds then
                for name, kData in pairs(Data.Keybinds) do
                    if State.Keybinds[name] then
                        State.Keybinds[name].Key = Enum.KeyCode[kData.Key] or Enum.KeyCode.Unknown
                        State.Keybinds[name].Shift = kData.Shift
                    end
                end
                ShowToast("✅ Keybinds Loaded")
            end
        end)

        AddLabel("KEYBIND LIST (Read Only)")
        -- Keybind Display Simple
        local KeyList = Instance.new("TextLabel", Page); KeyList.Size=UDim2.new(0.95,0,0,200); KeyList.BackgroundTransparency=1; KeyList.TextYAlignment=Enum.TextYAlignment.Top; KeyList.Text="Feature : Key\n------------"; RegisterTheme(KeyList,"TextColor3","TextDim"); KeyList.Font=Enum.Font.Code; KeyList.TextSize=12

        AddButton("🔄 Refresh Keybind Display", function()
            local str = "Feature : Key\n------------\n"
            for name, data in pairs(State.Keybinds) do
                str = str .. name .. " : " .. data.Key.Name .. "\n"
            end
            KeyList.Text = str
        end)
    end
    -- [[ 11. INITIALIZATION ]] --
    -- Panggil Settings Tab agar ter-load
    Window:AddSettingsTab()

    -- Pilih tab pertama secara otomatis
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
    
    -- Listener Toggle Button (Mata)
    ToggleButton.MouseButton1Click:Connect(function() 
        MainFrame.Visible = not MainFrame.Visible 
    end)
    
    -- Keybind Listener Global (Agar keybind jalan)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            for name, bindData in pairs(State.Keybinds) do
                if State.RegisteredFeatures[name] and bindData.Key == input.KeyCode then
                    local logic = State.RegisteredFeatures[name]
                    local isShift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
                    if bindData.Shift then
                        if isShift then logic.Trigger() end
                    else
                        if not isShift then logic.Trigger() end
                    end
                end
            end
        end
    end)
    return Window -- Penutup fungsi CreateWindow
end

return Library

