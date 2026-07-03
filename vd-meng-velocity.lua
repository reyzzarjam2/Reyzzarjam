local function SafeExecute(url)
    local success, result = pcall(function()
        local scriptData = game:HttpGet(url)
        loadstring(scriptData)()
    end)
    
    if not success then
        warn("Gagal mengeksekusi script: " .. tostring(result))
    end
end

SafeExecute("https://raw.githubusercontent.com/reyzzarjam2/Reyzzarjam/refs/heads/main/vd-meng.lua")
task.wait(1)

local VercelGui = Instance.new("ScreenGui")
VercelGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local ToastFrame = Instance.new("Frame", VercelGui)
ToastFrame.Size = UDim2.new(0, 320, 0, 110)
ToastFrame.Position = UDim2.new(1, -340, 1, -130)
ToastFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local ToastCorner = Instance.new("UICorner", ToastFrame)
ToastCorner.CornerRadius = UDim.new(0, 8)

local ToastStroke = Instance.new("UIStroke", ToastFrame)
ToastStroke.Color = Color3.fromRGB(51, 51, 51)
ToastStroke.Thickness = 1

local Title = Instance.new("TextLabel", ToastFrame)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 15)
Title.Text = "Execute second script?"
Title.TextColor3 = Color3.fromRGB(237, 237, 237)
Title.Font = Enum.Font.GothamMedium
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

local BtnContainer = Instance.new("Frame", ToastFrame)
BtnContainer.Size = UDim2.new(1, -40, 0, 36)
BtnContainer.Position = UDim2.new(0, 20, 1, -50)
BtnContainer.BackgroundTransparency = 1

local BtnGrid = Instance.new("UIGridLayout", BtnContainer)
BtnGrid.CellSize = UDim2.new(0.48, 0, 1, 0)
BtnGrid.CellPadding = UDim2.new(0.04, 0, 0, 0)
BtnGrid.SortOrder = Enum.SortOrder.LayoutOrder

local BtnExecute = Instance.new("TextButton", BtnContainer)
BtnExecute.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BtnExecute.Text = "Execute"
BtnExecute.TextColor3 = Color3.fromRGB(0, 0, 0)
BtnExecute.Font = Enum.Font.GothamMedium
BtnExecute.TextSize = 13
BtnExecute.LayoutOrder = 2

local ExecCorner = Instance.new("UICorner", BtnExecute)
ExecCorner.CornerRadius = UDim.new(0, 6)

local BtnCancel = Instance.new("TextButton", BtnContainer)
BtnCancel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BtnCancel.Text = "Cancel"
BtnCancel.TextColor3 = Color3.fromRGB(237, 237, 237)
BtnCancel.Font = Enum.Font.GothamMedium
BtnCancel.TextSize = 13
BtnCancel.LayoutOrder = 1

local CancelCorner = Instance.new("UICorner", BtnCancel)
CancelCorner.CornerRadius = UDim.new(0, 6)

local CancelStroke = Instance.new("UIStroke", BtnCancel)
CancelStroke.Color = Color3.fromRGB(51, 51, 51)
CancelStroke.Thickness = 1

local function HandleAction(isExecute)
    VercelGui:Destroy()
    
    if isExecute then
        SafeExecute("https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua")
    end
    
    task.wait(3)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

BtnExecute.MouseButton1Click:Connect(function()
    HandleAction(true)
end)

BtnCancel.MouseButton1Click:Connect(function()
    HandleAction(false)
end)
