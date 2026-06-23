-- // KiloUI Script Hub v1.0
-- // Универсальный хаб с автоопределением плейса

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Определяем текущий плейс
local PlaceId = game.PlaceId
local GameName = ""

print("[KiloUI Hub] Запуск...")
print("[KiloUI Hub] Place ID: " .. PlaceId)

-- // Маппинг плейсов
local GameScripts = {
    [189707] = {
        Name = "Build a Boat for Treasure",
        Script = "https://raw.githubusercontent.com/Meller2/roblox-scripts/master/scripts/babft.lua"
    },
    [3351674303] = {
        Name = "Driving Empire",
        Script = "https://raw.githubusercontent.com/Meller2/roblox-scripts/master/scripts/driving_empire.lua"
    }
}

-- // Проверяем есть ли скрипт для этого плейса
local GameInfo = GameScripts[PlaceId]

if GameInfo then
    GameName = GameInfo.Name
    print("[KiloUI Hub] Обнаружена игра: " .. GameName)
    print("[KiloUI Hub] Загрузка скрипта...")
    
    local success, err = pcall(function()
        local scriptUrl = GameInfo.Script .. "?v=" .. tostring(os.time())
        print("[KiloUI Hub] URL: " .. scriptUrl)
        local scriptContent = game:HttpGet(scriptUrl, true)
        if type(scriptContent) ~= "string" or scriptContent == "" then
            warn("[KiloUI Hub] game:HttpGet вернул пустой/неверный ответ: " .. tostring(scriptContent))
            return
        end
        print("[KiloUI Hub] Получено байт: " .. tostring(#scriptContent))
        local func, loadErr = loadstring(scriptContent)
        if not func then
            warn("[KiloUI Hub] Синтаксическая ошибка в скрипте: " .. tostring(loadErr))
            warn("[KiloUI Hub] Первые 300 символов:\n" .. scriptContent:sub(1, 300))
            return
        end
        func()
    end)
    
    if not success then
        warn("[KiloUI Hub] Ошибка загрузки скрипта: " .. tostring(err))
    end
else
    -- // Игра не поддерживается - показываем уведомление
    print("[KiloUI Hub] Игра не поддерживается: Place ID " .. PlaceId)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KiloUI_Hub_Error"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 150)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "KiloUI Script Hub"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -40, 0, 60)
    Text.Position = UDim2.new(0, 20, 0, 45)
    Text.BackgroundTransparency = 1
    Text.Text = "Игра не поддерживается\nPlace ID: " .. PlaceId .. "\n\nПоддерживаемые игры:\n- Build a Boat for Treasure (189707)\n- Driving Empire (3351674303)"
    Text.TextColor3 = Color3.fromRGB(200, 200, 200)
    Text.TextSize = 13
    Text.Font = Enum.Font.Gotham
    Text.TextWrapped = true
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Frame
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 80, 0, 30)
    CloseBtn.Position = UDim2.new(0.5, -40, 1, -40)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(240, 165, 0)
    CloseBtn.Text = "OK"
    CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end
