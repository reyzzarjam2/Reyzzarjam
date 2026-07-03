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

local customGui = Instance.new("ScreenGui")
customGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local frameBox = Instance.new("Frame", customGui)
frameBox.Size = UDim2.new(0, 250, 0, 70)
frameBox.Position = UDim2.new(1, -270, 1, -90)
frameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local titleText = Instance.new("TextLabel", frameBox)
titleText.Size = UDim2.new(1, 0, 0, 25)
titleText.Text = "Load script kedua?"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.BackgroundTransparency = 1

local btnLanjut = Instance.new("TextButton", frameBox)
btnLanjut.Size = UDim2.new(0.5, -5, 0, 30)
btnLanjut.Position = UDim2.new(0, 5, 1, -35)
btnLanjut.Text = "OKE"
btnLanjut.BackgroundColor3 = Color3.fromRGB(50, 150, 50)

local btnBatal = Instance.new("TextButton", frameBox)
btnBatal.Size = UDim2.new(0.5, -10, 0, 30)
btnBatal.Position = UDim2.new(0.5, 5, 1, -35)
btnBatal.Text = "DISABLE"
btnBatal.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

local function ProsesPilihan(jalankanScript)
    customGui:Destroy()
    
    if jalankanScript then
        SafeExecute("https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua")
    end
    
    task.wait(3)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end

btnLanjut.MouseButton1Click:Connect(function()
    ProsesPilihan(true)
end)

btnBatal.MouseButton1Click:Connect(function()
    ProsesPilihan(false)
end)
