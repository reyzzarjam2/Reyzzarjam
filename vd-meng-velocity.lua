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
SafeExecute("https://raw.githubusercontent.com/4LynxX/Lynx/refs/heads/main/LynxxMain.lua")
